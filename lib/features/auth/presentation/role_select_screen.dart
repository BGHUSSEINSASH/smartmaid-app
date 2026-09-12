import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models.dart';

/// شاشة اختيار نوع الحساب — نقطة الانطلاق لكل تسجيل
class RoleSelectScreen extends StatelessWidget {
  final bool isSocialFlow;
  const RoleSelectScreen({super.key, this.isSocialFlow = false});

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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(Icons.cleaning_services_rounded,
                        size: 36, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('أنشئ حسابك',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('اختر نوع حسابك للبدء',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14, color: AppColors.muted)),
                const SizedBox(height: 36),
                _RoleCard(
                  role: AppRole.customer,
                  emoji: '👤',
                  title: 'عميل',
                  desc: 'احجز خدمات التنظيف والعناية المنزلية',
                  color: const Color(0xFF4F46E5),
                  onTap: () => context.push(
                      isSocialFlow
                          ? '/register/social/customer'
                          : '/register/customer'),
                ),
                const SizedBox(height: 14),
                _RoleCard(
                  role: AppRole.worker,
                  emoji: '👩‍🔧',
                  title: 'عاملة',
                  desc: 'قدّمي خدماتك واكسبي دخلاً يومياً',
                  color: const Color(0xFF7C3AED),
                  onTap: () => context.push(
                      isSocialFlow
                          ? '/register/social/worker'
                          : '/register/worker'),
                ),
                const SizedBox(height: 14),
                _RoleCard(
                  role: AppRole.company,
                  emoji: '🏢',
                  title: 'شركة',
                  desc: 'سجّل شركتك وأدر فريقك وعملياتك',
                  color: const Color(0xFF0EA5E9),
                  onTap: () => context.push(
                      isSocialFlow
                          ? '/register/social/company'
                          : '/register/company'),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('لديك حساب بالفعل؟',
                        style: TextStyle(color: AppColors.muted)),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('تسجيل الدخول'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final AppRole role;
  final String emoji;
  final String title;
  final String desc;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.emoji,
    required this.title,
    required this.desc,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                    child: Text(emoji,
                        style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: color)),
                    const SizedBox(height: 3),
                    Text(desc,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.muted)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: color.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}
