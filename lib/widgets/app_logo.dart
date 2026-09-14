import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// شعار شغّالتي — widget مشترك للاستخدام في كل الشاشات
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showSubtitle;
  final bool darkBackground;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showText = false,
    this.showSubtitle = false,
    this.darkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = darkBackground || Theme.of(context).brightness == Brightness.dark;

    if (showText) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LogoImage(size: size),
          SizedBox(width: size * 0.2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'شغّالتي',
                style: TextStyle(
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              if (showSubtitle)
                Text(
                  'SmartMaid',
                  style: TextStyle(
                    fontSize: size * 0.22,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : AppColors.muted,
                  ),
                ),
            ],
          ),
        ],
      );
    }

    return _LogoImage(size: size);
  }
}

/// الصورة وحدها
class _LogoImage extends StatelessWidget {
  final double size;
  const _LogoImage({required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icon/icon_original.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

/// نسخة مصغّرة للـ AppBar
class AppLogoSmall extends StatelessWidget {
  const AppLogoSmall({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLogo(size: 36, showText: true);
  }
}
