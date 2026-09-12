import 'package:flutter/material.dart';
import 'app_theme.dart';

extension AdaptiveThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get surface => isDark ? AppColors.surfaceDark : Colors.white;

  Color get pageBg =>
      isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

  Color get stroke => isDark ? const Color(0xFF334155) : AppColors.stroke;

  Color get ink => isDark ? Colors.white : AppColors.textPrimary;

  Color get mutedText => isDark ? Colors.white60 : AppColors.muted;

  LinearGradient get headerGradient => isDark
      ? const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )
      : const LinearGradient(
          colors: [Color(0xFFF8FAFF), Color(0xFFEDEBFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );

  LinearGradient get heroSoftGradient => isDark
      ? LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.28),
            AppColors.accent.withValues(alpha: 0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : AppColors.heroGradient;
}

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Color? colorOverride;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.onTap,
    this.colorOverride,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorOverride ?? context.surface,
          borderRadius: borderRadius ?? BorderRadius.circular(18),
          border: Border.all(color: context.stroke),
        ),
        child: child,
      ),
    );
  }
}

class AdaptiveHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const AdaptiveHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding.copyWith(
          top: padding.top + MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(gradient: context.headerGradient),
      child: child,
    );
  }
}
