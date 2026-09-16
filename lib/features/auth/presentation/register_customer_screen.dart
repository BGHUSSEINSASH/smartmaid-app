import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models.dart';
import '../../../providers/auth_provider.dart';
import '../domain/password_strength.dart';
import 'auth_widgets.dart';
import 'register_shared_widgets.dart';

/// تسجيل العميل — خطوتان: بيانات الحساب + التحقق
class RegisterCustomerScreen extends ConsumerStatefulWidget {
  const RegisterCustomerScreen({super.key});
  @override
  ConsumerState<RegisterCustomerScreen> createState() =>
      _RegisterCustomerScreenState();
}

class _RegisterCustomerScreenState
    extends ConsumerState<RegisterCustomerScreen> {
  final _pageCtrl = PageController();
  // خطوة 1
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  bool _obscure = true;
  bool _accepted = false;
  String _nationality = 'السعودية';
  String _gender = 'ذكر';
  // خطوة 2 — OTP
  final _otpCtrl = TextEditingController();
  String? _devOtp;

  static const _nationalities = [
    'السعودية', 'الإمارات', 'الكويت', 'البحرين', 'قطر',
    'عُمان', 'الأردن', 'مصر', 'العراق', 'سوريا', 'أخرى',
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _refCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _err(String m) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating));

  Future<void> _goStep2() async {
    if (_nameCtrl.text.trim().length < 2) { _err('أدخل اسمك الكامل'); return; }
    if (_phoneCtrl.text.trim().isEmpty) { _err('أدخل رقم الهاتف'); return; }
    if (_passCtrl.text != _confirmCtrl.text) { _err('كلمتا المرور غير متطابقتين'); return; }
    if (!_accepted) { _err('يجب الموافقة على الشروط'); return; }
    // محاكاة إرسال OTP
    setState(() => _devOtp = '123456');
    _pageCtrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
  }

  Future<void> _finalize() async {
    if (_otpCtrl.text.trim() != _devOtp) { _err('رمز التحقق غير صحيح'); return; }
final ok = await ref.read(authProvider.notifier).register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      role: AppRole.customer,
      phone: _phoneCtrl.text.trim(),
      extraData: {
        'nationality': _nationality,
        'gender': _gender,
        'referralCode': _refCtrl.text.trim(),
      },
    );
    if (!mounted) return;
    ok ? context.go('/') : _err(ref.read(authProvider).error ?? 'تعذر إنشاء الحساب');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final s = PasswordStrength.evaluate(_passCtrl.text);
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل — عميل'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _StepBar(steps: 2, current: _pageCtrl.hasClients
              ? (_pageCtrl.page?.round() ?? 0) : 0),
        ),
      ),
      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // ── خطوة 1: بيانات الحساب ──────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const _SectionTitle('بيانات الحساب الشخصي'),
              const SizedBox(height: 16),
              AuthField(controller: _nameCtrl, label: 'الاسم الكامل',
                  icon: Icons.person_rounded, action: TextInputAction.next),
              const SizedBox(height: 12),
              AuthField(controller: _phoneCtrl, label: 'رقم الهاتف',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  action: TextInputAction.next),
              const SizedBox(height: 12),
              AuthField(controller: _emailCtrl, label: 'البريد الإلكتروني',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  action: TextInputAction.next),
              const SizedBox(height: 12),
              _DropField(label: 'الجنسية', value: _nationality,
                  items: _nationalities,
                  onChanged: (v) => setState(() => _nationality = v!)),
              const SizedBox(height: 12),
              _DropField(label: 'الجنس', value: _gender,
                  items: const ['ذكر', 'أنثى'],
                  onChanged: (v) => setState(() => _gender = v!)),
              const SizedBox(height: 12),
              AuthField(controller: _passCtrl, label: 'كلمة المرور',
                  icon: Icons.lock_rounded, obscure: _obscure,
                  onChanged: (_) => setState(() {}),
                  suffix: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )),
              if (_passCtrl.text.isNotEmpty) _StrengthBar(s),
              const SizedBox(height: 12),
              AuthField(controller: _confirmCtrl, label: 'تأكيد كلمة المرور',
                  icon: Icons.lock_outline_rounded, obscure: _obscure),
              const SizedBox(height: 12),
              AuthField(controller: _refCtrl, label: 'رمز الإحالة (اختياري)',
                  icon: Icons.card_giftcard_rounded),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _accepted,
                onChanged: (v) => setState(() => _accepted = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('أوافق على الشروط وسياسة الخصوصية',
                    style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(height: 12),
              SizedBox(height: 52, child: ElevatedButton.icon(
                onPressed: _goStep2,
                icon: const Icon(Icons.arrow_forward_rounded, size: 19),
                label: const Text('التالي'),
              )),
            ]),
          ),
          // ── خطوة 2: التحقق بـ OTP ──────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Icon(Icons.sms_rounded, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text('أرسلنا رمزاً إلى ${_phoneCtrl.text}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted)),
              if (_devOtp != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12)),
                  child: Text('رمز التطوير: $_devOtp',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
              const SizedBox(height: 24),
              AuthField(controller: _otpCtrl, label: 'رمز التحقق (6 أرقام)',
                  icon: Icons.dialpad_rounded,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              SizedBox(height: 52, child: ElevatedButton.icon(
                onPressed: auth.isLoading ? null : _finalize,
                icon: auth.isLoading
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_rounded, size: 19),
                label: Text(auth.isLoading ? 'جارٍ الإنشاء...' : 'إنشاء الحساب'),
              )),
              TextButton(onPressed: () {
                setState(() => _devOtp = '123456');
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إعادة الإرسال'),
                        behavior: SnackBarBehavior.floating));
              }, child: const Text('إعادة إرسال الرمز')),
            ]),
          ),
        ],
      ),
    );
  }
}

// Re-export shared widgets with local aliases
typedef _StepBar = RegStepBar;
typedef _SectionTitle = RegSectionTitle;
typedef _StrengthBar = RegStrengthBar;

class _DropField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropField({required this.label, required this.value,
      required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}


