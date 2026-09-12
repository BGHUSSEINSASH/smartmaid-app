import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  static const _pages = [
    (
      emoji: '🧹',
      title: 'كل خدمات المنزل في مكان واحد',
      subtitle: 'تنظيف، طبخ، رعاية أطفال ومسنين — أكثر من 110 خدمات معتمدة بأسعار واضحة.',
      gradient: AppColors.heroGradient,
    ),
    (
      emoji: '📅',
      title: 'احجز في أقل من دقيقة',
      subtitle: 'اختر العاملة والوقت ونوع التعاقد، مع خصومات تصل إلى 30% على التعاقدات الطويلة.',
      gradient: AppColors.savingsGradient,
    ),
    (
      emoji: '🎁',
      title: 'اكسب نقاطاً وعروضاً حصرية',
      subtitle: 'محفظة SmartPay، نقاط مكافآت، كوبونات خصم، ومكافآت عند دعوة أصدقائك.',
      gradient: AppColors.balanceGradient,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await markOnboardingDone();
    if (!mounted) return;
    final loggedIn = ref.read(authProvider).isLoggedIn;
    context.go(loggedIn ? '/' : '/login');
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('تخطي',
                      style: TextStyle(color: AppColors.muted)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            gradient: p.gradient,
                            borderRadius: BorderRadius.circular(44),
                          ),
                          child:
                              Center(child: Text(p.emoji, style: const TextStyle(fontSize: 62))),
                        ),
                        const SizedBox(height: 40),
                        Text(p.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 14),
                        Text(p.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                height: 1.8,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white70
                                    : AppColors.muted)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 26 : 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: _page == i
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _next,
                  icon: Icon(_page == _pages.length - 1
                      ? Icons.rocket_launch_rounded
                      : Icons.arrow_back_rounded),
                  label: Text(_page == _pages.length - 1
                      ? 'ابدأ الآن'
                      : 'التالي'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class onboarding_screen extends OnboardingScreen {
  const onboarding_screen({super.key});
}
