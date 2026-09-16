import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/painter/logo_painter.dart';

/// شعار شغّالتي — widget مشترك
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
          LogoWidget(size: size, darkBackground: isDark, withShadow: !isDark),
          SizedBox(width: size * 0.18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'شغّالتي',
                style: TextStyle(
                  fontSize: size * 0.40,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              if (showSubtitle)
                Text(
                  'SmartMaid',
                  style: TextStyle(
                    fontSize: size * 0.21,
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

    return LogoWidget(size: size, darkBackground: isDark, withShadow: !isDark);
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

