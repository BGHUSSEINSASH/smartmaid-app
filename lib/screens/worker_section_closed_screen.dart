import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/models.dart';
import '../providers/auth_provider.dart';
import '../providers/platform_control_provider.dart';

/// شاشة تظهر للعاملة عندما يُغلق المدير قسم العاملات.
/// للمدير: يظهر تحكم مباشر لإعادة الفتح.
class WorkerSectionClosedScreen extends ConsumerWidget {
  const WorkerSectionClosedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags   = ref.watch(platformFlagsProvider);
    final notifier = ref.read(platformFlagsProvider.notifier);
    final user    = ref.watch(authProvider).user;
    final isAdmin = user?.role == AppRole.admin;
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDeep : const Color(0xFFF8FAFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ── أيقونة حالة القسم ─────────────────────────────────
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: .30),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.construction_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 28),

              // ── العنوان ───────────────────────────────────────────
              const Text(
                'قسم العاملات مغلق مؤقتاً',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.4,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                flags.accountSuspensionMessage.isNotEmpty &&
                        flags.accountSuspensionMessage != 'تم تعليق حسابك مؤقتاً. تواصل مع الدعم للمساعدة.'
                    ? flags.accountSuspensionMessage
                    : 'هذا القسم مُغلق حالياً من قِبل إدارة المنصة.\nسيتم إعادة تفعيله قريباً وسيصلك إشعار فور ذلك.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.5,
                  color: AppColors.muted,
                  height: 1.65,
                ),
              ),

              const SizedBox(height: 28),

              // ── بطاقة معلومات ─────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: .15)),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppColors.primary, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'طلبك الوارد لتسجيلك كعاملة قيد المراجعة. سنتواصل معك عبر البريد الإلكتروني.',
                      style: TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 24),

              // ── زر دعم للعاملة ────────────────────────────────────
              if (!isAdmin)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/support'),
                    icon: const Icon(Icons.support_agent_rounded),
                    label: const Text('التواصل مع الإدارة'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),

              // ── تحكم المدير ───────────────────────────────────────
              if (isAdmin) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.warning.withValues(alpha: .25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [
                        Icon(Icons.admin_panel_settings_rounded,
                            color: AppColors.warning, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'لوحة تحكم المدير',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.warning,
                            fontSize: 13,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      const Text(
                        'أنت تشاهد هذه الشاشة لأن قسم العاملات مغلق حالياً. يمكنك إعادة فتحه فوراً:',
                        style: TextStyle(fontSize: 12.5, height: 1.5),
                      ),
                      const SizedBox(height: 14),

                      // زر إعادة الفتح
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            notifier.enableWorkerSection();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ تم فتح قسم العاملات بالكامل'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.lock_open_rounded, size: 18),
                          label: const Text(
                            'فتح قسم العاملات',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // زر تحكم المنصة
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/'),
                          icon: const Icon(Icons.tune_rounded, size: 18),
                          label: const Text('لوحة التحكم الكاملة'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // حالة الـ flags الحالية للمدير
                _AdminFlagsSummary(flags: flags, notifier: notifier),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ── ملخص حالة flags لوحة المدير ─────────────────────────────────────────────
class _AdminFlagsSummary extends StatelessWidget {
  final PlatformFlags flags;
  final PlatformFlagsNotifier notifier;
  const _AdminFlagsSummary({required this.flags, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('قسم العاملات',     flags.workerSectionVisible,    'workerSection'),
      ('بحث العاملات',     flags.workerSearchVisible,     'workerSearch'),
      ('بطاقات في الرئيسية', flags.workerProfilesVisible, 'workerProfiles'),
      ('تسجيل عاملات',    flags.workerRegistrationOpen,  'workerReg'),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: .04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'حالة مفاتيح التحكم',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 10),
          ...items.map((item) {
            final (label, value, key) = item;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: value ? AppColors.success : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(label,
                      style: const TextStyle(fontSize: 12.5)),
                ),
                GestureDetector(
                  onTap: () => notifier.toggle(key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (value ? AppColors.success : AppColors.error)
                          .withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      value ? 'مفعّل' : 'مغلق',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: value ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                ),
              ]),
            );
          }),
        ],
      ),
    );
  }
}
