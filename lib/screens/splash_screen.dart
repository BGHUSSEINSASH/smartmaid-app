import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── شعار شغّالتي ────────────────────────────────────
              AnimatedBuilder(
                animation: _ctrl,
                builder: (_, child) => Transform.scale(
                  scale: _scale.value,
                  child: Opacity(opacity: _fade.value.clamp(0.0, 1.0), child: child),
                ),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(34),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(34),
                    child: Image.asset(
                      'assets/icon/icon.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── اسم التطبيق ──────────────────────────────────────
              AnimatedBuilder(
                animation: _fade,
                builder: (_, child) => Opacity(opacity: _fade.value.clamp(0.0, 1.0), child: child),
                child: Column(
                  children: [
                    const Text(
                      'شغّالتي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'خدماتك المنزلية بلمسة واحدة',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.80),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // ── مؤشر تحميل ───────────────────────────────────────
              AnimatedBuilder(
                animation: _fade,
                builder: (_, child) => Opacity(opacity: _fade.value.clamp(0.0, 1.0), child: child),
                child: const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
