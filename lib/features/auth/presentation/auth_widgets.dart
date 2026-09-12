import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// حقل إدخال موحّد لشاشات المصادقة.
class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? action;

  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: action,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffix,
        errorText: errorText,
      ),
    );
  }
}

/// زر تسجيل دخول اجتماعي (Google / Apple).
class SocialButton extends StatelessWidget {
  final String label;
  final Widget leading;
  final VoidCallback? onTap;
  final Color background;
  final Color foreground;

  const SocialButton({
    super.key,
    required this.label,
    required this.leading,
    required this.onTap,
    this.background = Colors.white,
    this.foreground = AppColors.textPrimary,
  });

  factory SocialButton.google({VoidCallback? onTap}) => SocialButton(
        label: 'المتابعة عبر Google',
        onTap: onTap,
        leading: const _GoogleGlyph(),
      );

  factory SocialButton.apple({VoidCallback? onTap}) => SocialButton(
        label: 'المتابعة عبر Apple',
        onTap: onTap,
        background: Colors.black,
        foreground: Colors.white,
        leading: const Icon(Icons.apple, size: 22, color: Colors.white),
      );

  /// هل تُعرض Apple على هذه المنصة؟ (iOS/macOS فقط)
  static bool get showApple {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isMacOS;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                leading,
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4285F4), Color(0xFF34A853)],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'G',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 14,
        ),
      ),
    );
  }
}

/// فاصل "أو" مع خطين.
class AuthDivider extends StatelessWidget {
  final String label;
  const AuthDivider({super.key, this.label = 'أو'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.stroke)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ),
        const Expanded(child: Divider(color: AppColors.stroke)),
      ],
    );
  }
}
