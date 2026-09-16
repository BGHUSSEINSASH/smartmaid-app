import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';

/// شاشة التحقق بـ OTP — 6 خانات منفصلة مع مؤقت
class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  final String devCode;
  const OtpScreen({super.key, required this.phone, required this.devCode});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _len = 6;
  final _controllers = List.generate(_len, (_) => TextEditingController());
  final _focusNodes = List.generate(_len, (_) => FocusNode());
  int _seconds = 60;
  Timer? _timer;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNodes[0].requestFocus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds == 0) { _timer?.cancel(); return; }
      setState(() => _seconds--);
    });
  }

  void _onDigit(int idx, String val) {
    if (val.isEmpty) {
      if (idx > 0) _focusNodes[idx - 1].requestFocus();
      return;
    }
    // دعم اللصق الكامل
    if (val.length == _len) {
      for (int i = 0; i < _len; i++) {
        _controllers[i].text = val[i];
      }
      _focusNodes[_len - 1].requestFocus();
      _submit();
      return;
    }
    _controllers[idx].text = val[0];
    if (idx < _len - 1) {
      _focusNodes[idx + 1].requestFocus();
    } else {
      _submit();
    }
  }

  String get _enteredOtp => _controllers.map((c) => c.text).join();

  Future<void> _submit() async {
    final code = _enteredOtp;
    if (code.length < _len) return;
    setState(() => _loading = true);
    final ok = await ref.read(authProvider.notifier).verifyPhoneOtp(widget.phone, code);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      HapticFeedback.lightImpact();
      context.go('/');
    } else {
      HapticFeedback.heavyImpact();
      // رج الخانات
      for (final c in _controllers) { c.clear(); }
      _focusNodes[0].requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('رمز التحقق غير صحيح، حاول مجدداً'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _resend() async {
    setState(() => _loading = true);
    await ref.read(authProvider.notifier).sendPhoneOtp(widget.phone);
    if (!mounted) return;
    setState(() => _loading = false);
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDeep : AppColors.bg,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(22)),
              child: const Icon(Icons.verified_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 24),
            Text('رمز التحقق', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.primary)),
            const SizedBox(height: 8),
            Text('أرسلنا رمزاً مكوّناً من 6 أرقام إلى\n${widget.phone}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.muted, height: 1.6)),
            // Dev code hint
            if (widget.devCode.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withValues(alpha: .4)),
                ),
                child: Text('رمز التطوير: ${widget.devCode}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.warning)),
              ),
            ],
            const SizedBox(height: 36),
            // OTP خانات — 6 خانات فعلية + فراغ فاصل في المنتصف
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _OtpBox(controller: _controllers[0], focusNode: _focusNodes[0], onChanged: (v) => _onDigit(0, v)),
                const SizedBox(width: 8),
                _OtpBox(controller: _controllers[1], focusNode: _focusNodes[1], onChanged: (v) => _onDigit(1, v)),
                const SizedBox(width: 8),
                _OtpBox(controller: _controllers[2], focusNode: _focusNodes[2], onChanged: (v) => _onDigit(2, v)),
                const SizedBox(width: 18), // فاصل بصري
                _OtpBox(controller: _controllers[3], focusNode: _focusNodes[3], onChanged: (v) => _onDigit(3, v)),
                const SizedBox(width: 8),
                _OtpBox(controller: _controllers[4], focusNode: _focusNodes[4], onChanged: (v) => _onDigit(4, v)),
                const SizedBox(width: 8),
                _OtpBox(controller: _controllers[5], focusNode: _focusNodes[5], onChanged: (v) => _onDigit(5, v)),
              ],
            ),
            const SizedBox(height: 36),
            // زر التأكيد
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('تأكيد', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 20),
            // إعادة الإرسال
            TextButton(
              onPressed: _seconds == 0 ? _resend : null,
              child: _seconds > 0
                  ? Text('إعادة الإرسال خلال $_seconds ثانية',
                      style: TextStyle(color: AppColors.muted))
                  : const Text('إعادة إرسال الرمز',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  const _OtpBox({required this.controller, required this.focusNode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 48, height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.stroke, width: 1.5),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .08), blurRadius: 10, offset: const Offset(0,4))],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 6, // دعم اللصق
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : AppColors.primary,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: onChanged,
      ),
    );
  }
}


