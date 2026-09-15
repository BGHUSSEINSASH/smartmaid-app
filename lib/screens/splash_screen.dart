import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/painter/logo_painter.dart';
import '../core/session/session_store.dart';
import '../core/storage/local_store.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/security_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>    _scale;
  late final Animation<double>    _fade;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _scale = Tween(begin: 0.65, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade  = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));
    _ctrl.forward();
    _bootstrap();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _bootstrap() async {
    await LocalStore.hydrate();
    await ref.read(authProvider.notifier).restoreSession();
    await ref.read(securityProvider.notifier).load();
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final onboarded =
        await SettingsPersistence.loadBool(SettingsPersistence.kOnboarded);
    final loggedIn = ref.read(authProvider).isLoggedIn;
    if (!onboarded) {
      context.go('/onboarding');
    } else {
      context.go(loggedIn ? '/' : '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── شعار شغّالتي ──────────────────────────────────────────
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, child) => Transform.scale(
                scale: _scale.value,
                child: Opacity(opacity: _fade.value.clamp(0.0, 1.0), child: child),
              ),
              child: LogoWidget(
                size: 160,
                darkBackground: isDark,
                withShadow: !isDark,
              ),
            ),

            const SizedBox(height: 32),

            // ── اسم التطبيق ──────────────────────────────────────────
            AnimatedBuilder(
              animation: _fade,
              builder: (_, child) => Opacity(opacity: _fade.value.clamp(0.0, 1.0), child: child),
              child: Column(
                children: [
                  Text(
                    'شغّالتي',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF03045A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'خدماتك المنزلية بلمسة واحدة',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.65)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 52),

            // ── مؤشر تحميل ───────────────────────────────────────────
            AnimatedBuilder(
              animation: _fade,
              builder: (_, child) => Opacity(opacity: _fade.value.clamp(0.0, 1.0), child: child),
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: isDark ? Colors.white54 : const Color(0xFF03045A).withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
