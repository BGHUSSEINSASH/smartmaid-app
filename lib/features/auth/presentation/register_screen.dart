import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../domain/app_role.dart';
import '../domain/password_strength.dart';
import 'auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  AppRole _role = AppRole.customer;
  bool _obscure = true;
  bool _accepted = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.error,
    ));
  }

  Future<void> _submit() async {
    if (_passCtrl.text != _confirmCtrl.text) {
      _err('كلمتا المرور غير متطابقتين');
      return;
    }
    if (!_accepted) {
      _err('يجب الموافقة على الشروط والأحكام');
      return;
    }
    final ok = await ref.read(authProvider.notifier).register(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          password: _passCtrl.text,
          role: _role,
        );
    if (!mounted) return;
    if (ok) {
      context.go('/');
    } else {
      _err(ref.read(authProvider).error ?? 'تعذر إنشاء الحساب');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final strength = PasswordStrength.evaluate(_passCtrl.text);

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب جديد')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('اختر نوع الحساب',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                _roleSelector(),
                const SizedBox(height: 18),
                AuthField(
                  controller: _nameCtrl,
                  label: 'الاسم الكامل',
                  icon: Icons.person_rounded,
                  action: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                AuthField(
                  controller: _emailCtrl,
                  label: 'البريد الإلكتروني',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  action: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                AuthField(
                  controller: _passCtrl,
                  label: 'كلمة المرور',
                  icon: Icons.lock_rounded,
                  obscure: _obscure,
                  onChanged: (_) => setState(() {}),
                  suffix: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                if (_passCtrl.text.isNotEmpty) _strengthBar(strength),
                const SizedBox(height: 14),
                AuthField(
                  controller: _confirmCtrl,
                  label: 'تأكيد كلمة المرور',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  action: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: _accepted,
                  onChanged: (v) => setState(() => _accepted = v ?? false),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('أوافق على الشروط وسياسة الخصوصية',
                      style: TextStyle(fontSize: 13)),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: auth.isLoading ? null : _submit,
                    icon: auth.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.person_add_rounded, size: 19),
                    label: Text(
                        auth.isLoading ? 'جارٍ الإنشاء...' : 'إنشاء الحساب'),
                  ),
                ),
                const SizedBox(height: 16),
                const AuthDivider(),
                const SizedBox(height: 16),
                SocialButton.google(
                  onTap: auth.isLoading
                      ? null
                      : () async {
                          final ok = await ref
                              .read(authProvider.notifier)
                              .signInWithGoogle();
                          if (!context.mounted) return;
                          if (ok) context.go('/');
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleSelector() {
    final items = [
      (AppRole.customer, '👤', 'عميل'),
      (AppRole.worker, '👩‍💼', 'عاملة'),
      (AppRole.company, '🏢', 'شركة'),
    ];
    return Row(
      children: [
        for (final (role, emoji, label) in items) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _role = role),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _role == role
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _role == role
                        ? AppColors.primary
                        : AppColors.stroke,
                    width: _role == role ? 1.6 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(label,
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: _role == role
                                ? AppColors.primary
                                : AppColors.muted)),
                  ],
                ),
              ),
            ),
          ),
          if (role != AppRole.company) const SizedBox(width: 10),
        ],
      ],
    );
  }

  Widget _strengthBar(PasswordStrength s) {
    final colors = [
      AppColors.error,
      AppColors.warning,
      AppColors.warning,
      AppColors.success,
      AppColors.success,
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (s.score + 1) / 5,
                minHeight: 6,
                backgroundColor: AppColors.stroke,
                color: colors[s.score],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(s.label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors[s.score])),
        ],
      ),
    );
  }
}
