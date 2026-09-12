import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/platform_control_provider.dart';
import '../providers/auth_provider.dart';
import '../data/models.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});
  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _pulse;
  Timer? _timer;
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulse = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // 5 نقرات سرية → وصول المدير
  void _onLogoTap() {
    _tapCount++;
    if (_tapCount >= 5) {
      _tapCount = 0;
      final user = ref.read(authProvider).user;
      if (user?.role == AppRole.admin) {
        ref.read(platformFlagsProvider.notifier).disableMaintenance();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم إيقاف وضع الصيانة'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () => _tapCount = 0);
  }

  @override
  Widget build(BuildContext context) {
    final flags = ref.watch(platformFlagsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة متحركة
              ScaleTransition(
                scale: _pulse,
                child: GestureDetector(
                  onTap: _onLogoTap,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: .3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.construction_rounded,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // العنوان
              Text(
                'نحن نُحسّن تجربتك',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // الرسالة
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.primary.withValues(alpha: .15)),
                ),
                child: Text(
                  flags.maintenanceMessage,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // وقت انتهاء الصيانة
              if (flags.maintenanceEndTime.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.warning.withValues(alpha: .3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule_rounded, color: AppColors.warning, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'متوقع الانتهاء: ${flags.maintenanceEndTime}',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // خطوات الصيانة
              _StepRow(icon: Icons.speed_rounded, text: 'تحسين سرعة التطبيق'),
              const SizedBox(height: 10),
              _StepRow(icon: Icons.security_rounded, text: 'تعزيز الأمان'),
              const SizedBox(height: 10),
              _StepRow(icon: Icons.star_rounded, text: 'إضافة ميزات جديدة'),

              const SizedBox(height: 40),

              // زر إعادة المحاولة
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // إعادة تحميل الـ flags من الـ SharedPreferences
                    ref.invalidate(platformFlagsProvider);
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'SmartMaid — شغالتي',
                style: TextStyle(
                  color: isDark ? Colors.white38 : AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _StepRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: AppColors.muted),
        ),
      ],
    );
  }
}
