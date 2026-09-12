import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../domain/password_strength.dart';
import 'auth_widgets.dart';

/// تدفق استرجاع كلمة المرور في 3 خطوات: البريد → رمز التحقق → كلمة مرور جديدة.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  int _step = 0; // 0=email, 1=code, 2=newPassword
  String? _devCode;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.error,
    ));
  }

  void _info(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.success,
    ));
  }

  Future<void> _sendCode() async {
    final code = await ref
        .read(authProvider.notifier)
        .sendPasswordReset(_emailCtrl.text);
    if (!mounted) return;
    if (code != null) {
      setState(() {
        _devCode = code;
        _step = 1;
      });
      _info('تم إرسال رمز التحقق إلى بريدك');
    } else {
      _err(ref.read(authProvider).error ?? 'تعذر الإرسال');
    }
  }

  void _verifyCode() {
    if (_codeCtrl.text.trim().isEmpty) {
      _err('أدخل رمز التحقق');
      return;
    }
    setState(() => _step = 2);
  }

  Future<void> _reset() async {
    final ok = await ref.read(authProvider.notifier).resetPassword(
          email: _emailCtrl.text,
          code: _codeCtrl.text,
          newPassword: _passCtrl.text,
        );
    if (!mounted) return;
    if (ok) {
      _info('تم تغيير كلمة المرور بنجاح');
      context.go('/login');
    } else {
      _err(ref.read(authProvider).error ?? 'تعذر تغيير كلمة المرور');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('استرجاع كلمة المرور')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _stepIndicator(),
                const SizedBox(height: 24),
                if (_step == 0) ..._emailStep(auth.isLoading),
                if (_step == 1) ..._codeStep(),
                if (_step == 2) ..._passwordStep(auth.isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepIndicator() {
    return Row(
      children: List.generate(3, (i) {
        final active = i <= _step;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: i == 2 ? 0 : 6),
            height: 6,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.stroke,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  List<Widget> _emailStep(bool loading) => [
        const Icon(Icons.mark_email_read_rounded,
            size: 56, color: AppColors.primary),
        const SizedBox(height: 16),
        const Text('أدخل بريدك الإلكتروني',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        const Text('سنرسل لك رمز تحقق لإعادة تعيين كلمة المرور',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 13)),
        const SizedBox(height: 22),
        AuthField(
          controller: _emailCtrl,
          label: 'البريد الإلكتروني',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: loading ? null : _sendCode,
            child: Text(loading ? 'جارٍ الإرسال...' : 'إرسال الرمز'),
          ),
        ),
      ];

  List<Widget> _codeStep() => [
        const Icon(Icons.pin_rounded, size: 56, color: AppColors.primary),
        const SizedBox(height: 16),
        const Text('أدخل رمز التحقق',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text('أرسلنا رمزاً إلى ${_emailCtrl.text}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, fontSize: 13)),
        if (_devCode != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('رمز التطوير: $_devCode',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
        const SizedBox(height: 22),
        AuthField(
          controller: _codeCtrl,
          label: 'رمز التحقق',
          icon: Icons.dialpad_rounded,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _verifyCode,
            child: const Text('متابعة'),
          ),
        ),
        TextButton(
          onPressed: _sendCode,
          child: const Text('إعادة إرسال الرمز'),
        ),
      ];

  List<Widget> _passwordStep(bool loading) {
    final s = PasswordStrength.evaluate(_passCtrl.text);
    return [
      const Icon(Icons.lock_reset_rounded,
          size: 56, color: AppColors.primary),
      const SizedBox(height: 16),
      const Text('كلمة مرور جديدة',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      const SizedBox(height: 22),
      AuthField(
        controller: _passCtrl,
        label: 'كلمة المرور الجديدة',
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
      if (_passCtrl.text.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('قوة كلمة المرور: ${s.label}',
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ),
      const SizedBox(height: 20),
      SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: loading ? null : _reset,
          child: Text(loading ? 'جارٍ الحفظ...' : 'تعيين كلمة المرور'),
        ),
      ),
    ];
  }
}
