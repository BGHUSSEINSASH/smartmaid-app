import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/animations.dart';

class AppNav {
  AppNav._();

  static Future pushSlide(BuildContext context, Widget page) =>
      Navigator.of(context).push(SlideInRoute(page: page));

  static Future<T?> pushFade<T>(BuildContext context, Widget page) =>
      Navigator.of(context).push<T>(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => page,
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 260),
        ),
      );
}

class Haptics {
  Haptics._();

  static void light() => HapticFeedback.lightImpact();
  static void medium() => HapticFeedback.mediumImpact();
  static void success() => HapticFeedback.heavyImpact();
}
