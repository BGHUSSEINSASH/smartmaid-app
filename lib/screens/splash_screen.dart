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

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await LocalStore.hydrate();
    await ref.read(authProvider.notifier).restoreSession();
    await ref.read(securityProvider.notifier).load();
    await Future.delayed(const Duration(milliseconds: 1400));
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
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.elasticOut,
                builder: (context, scale, child) => Transform.scale(
                  scale: scale,
                  child: child,
                ),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child:
                      const Icon(Icons.cleaning_services_rounded,
                          size: 48, color: Colors.white),
                ),
              ),
              const SizedBox(height: 22),
              const Text('Smart Maid',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text('خدماتك المنزلية بلمسة واحدة',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13.5)),
              const SizedBox(height: 36),
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                    strokeWidth: 2.4, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
