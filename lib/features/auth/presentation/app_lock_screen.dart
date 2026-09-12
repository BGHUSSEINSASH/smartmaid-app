import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/security_provider.dart';

/// شاشة قفل التطبيق — تدعم وضعين: التحقق (verify) والتعيين (setup).
class AppLockScreen extends ConsumerStatefulWidget {
  /// عند التعيين: بعد نجاح التعيين يُستدعى [onDone].
  final bool setupMode;
  final VoidCallback? onDone;

  const AppLockScreen({super.key, this.setupMode = false, this.onDone});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  String _pin = '';
  String _firstPin = '';
  bool _confirming = false;
  String? _error;
  bool _busy = false;

  static const _len = 4;

  Future<void> _onDigit(String d) async {
    if (_busy || _pin.length >= _len) return;
    setState(() {
      _error = null;
      _pin += d;
    });
    if (_pin.length == _len) {
      await Future.delayed(const Duration(milliseconds: 120));
      _submit();
    }
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    if (widget.setupMode) {
      if (!_confirming) {
        setState(() {
          _firstPin = _pin;
          _pin = '';
          _confirming = true;
          _busy = false;
        });
        return;
      }
      if (_pin != _firstPin) {
        HapticFeedback.heavyImpact();
        setState(() {
          _error = 'الرمزان غير متطابقين، حاول مجدداً';
          _pin = '';
          _firstPin = '';
          _confirming = false;
          _busy = false;
        });
        return;
      }
      await ref.read(securityProvider.notifier).setPin(_pin);
      if (mounted) widget.onDone?.call();
      return;
    }
    // وضع التحقق
    final ok = await ref.read(securityProvider.notifier).verifyPin(_pin);
    if (!mounted) return;
    if (ok) {
      widget.onDone?.call();
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _error = 'الرمز غير صحيح';
        _pin = '';
        _busy = false;
      });
    }
  }

  String get _title {
    if (widget.setupMode) {
      return _confirming ? 'أعد إدخال الرمز للتأكيد' : 'أنشئ رمز الحماية';
    }
    return 'أدخل رمز الحماية';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.bgDeep, AppColors.cardDark]
                : const [Color(0xFFF8FAFF), Color(0xFFEDEBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.lock_rounded,
                    size: 36, color: Colors.white),
              ),
              const SizedBox(height: 18),
              Text(_title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 22),
              _dots(),
              const SizedBox(height: 12),
              SizedBox(
                height: 20,
                child: _error != null
                    ? Text(_error!,
                        style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700))
                    : null,
              ),
              const Spacer(),
              _keypad(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_len, (i) {
        final filled = i < _pin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 9),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? AppColors.primary : Colors.transparent,
            border: Border.all(
                color: filled ? AppColors.primary : AppColors.muted,
                width: 2),
          ),
        );
      }),
    );
  }

  Widget _keypad() {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '<'];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: keys.map((k) {
          if (k.isEmpty) return const SizedBox.shrink();
          final isBack = k == '<';
          return Material(
            color: AppColors.primary.withValues(alpha: 0.06),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                HapticFeedback.selectionClick();
                isBack ? _backspace() : _onDigit(k);
              },
              child: Center(
                child: isBack
                    ? const Icon(Icons.backspace_rounded,
                        color: AppColors.primary)
                    : Text(k,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
