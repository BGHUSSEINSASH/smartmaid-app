import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/painter/logo_painter.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';

/// شاشة تسجيل الدخول الجديدة — بالرقم فقط
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  String _countryCode = '+966';
  bool _loading = false;

  static const _codes = ['+966', '+965', '+971', '+973', '+968', '+974', '+1', '+44', '+964'];

  @override
  void dispose() { _phoneCtrl.dispose(); super.dispose(); }

  void _err(String m) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(m), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating));

  Future<void> _send() async {
    final raw = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (raw.length < 7) { _err('أدخل رقم هاتف صحيح'); return; }
    setState(() => _loading = true);
    final fullPhone = '$_countryCode$raw';
    final code = await ref.read(authProvider.notifier).sendPhoneOtp(fullPhone);
    if (!mounted) return;
    setState(() => _loading = false);
    if (code != null) {
      context.push('/otp', extra: {'phone': fullPhone, 'devCode': code});
    } else {
      _err(ref.read(authProvider).error ?? 'تعذر إرسال الرمز');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final hPad    = Bp.isPhone(context) ? 28.0 : 32.0;
    final logoSz  = Bp.isPhone(context) ? 80.0 : 96.0;

    final content = SingleChildScrollView(
      padding: EdgeInsets.all(hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: Bp.isPhone(context) ? 32.0 : 16.0),
          // ── شعار شغّالتي ──────────────────────────────────────
          Row(children: [
            LogoWidget(size: logoSz, darkBackground: isDark),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'شغّالتي',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF03045A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'SmartMaid',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 32),
              Text('أهلاً بك',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.primary)),
              const SizedBox(height: 8),
              Text('أدخل رقم هاتفك للمتابعة',
                  style: TextStyle(fontSize: 15, color: AppColors.muted)),
              const SizedBox(height: 36),
              // Phone field
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.stroke),
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .06), blurRadius: 16, offset: const Offset(0,6))],
                ),
                child: Row(children: [
                  // Country code picker
                  PopupMenuButton<String>(
                    initialValue: _countryCode,
                    onSelected: (v) => setState(() => _countryCode = v),
                    itemBuilder: (_) => _codes.map((c) => PopupMenuItem(value: c, child: Text(c))).toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: AppColors.stroke)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(_countryCode, style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 15)),
                        const Icon(Icons.expand_more_rounded, size: 18, color: AppColors.muted),
                      ]),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(12)],
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 2),
                      decoration: const InputDecoration(
                        hintText: '5X XXX XXXX',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _send,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : const Text('إرسال رمز التحقق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 40),
              // Divider
              Row(children: [
                const Expanded(child: Divider()),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('أو', style: TextStyle(color: AppColors.muted))),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 24),
              // Quick dev login
              _DevQuickLogin(),
              const SizedBox(height: 16),
              Center(child: TextButton(
                onPressed: () => context.push('/register/role'),
                child: const Text('ليس لديك حساب؟ سجّل الآن'),
              )),
            ],
          ),
        );

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDeep : AppColors.bg,
      body: SafeArea(
        child: Bp.isPhone(context)
            ? content
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: Bp.formMax),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: AppColors.stroke),
                    ),
                    child: content,
                  ),
                ),
              ),
      ),
    );
  }
}

class _DevQuickLogin extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text('🧪 دخول سريع للاختبار',
          style: TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600)),
      children: [
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final (label, emoji, user) in [
            ('عميل', '👤', 'customer'),
            ('عاملة', '👩‍🔧', 'worker'),
            ('شركة', '🏢', 'company'),
            ('إدارة', '🛡️', 'admin'),
          ])
            GestureDetector(
              onTap: () async {
                await ref.read(authProvider.notifier).loginByRole(user);
                if (context.mounted) context.go('/');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: .2)),
                ),
                child: Text('$emoji $label',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ),
        ]),
      ],
    );
  }
}

