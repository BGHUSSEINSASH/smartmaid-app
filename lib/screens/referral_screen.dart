import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/loyalty_provider.dart';

class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referral = ref.watch(referralProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('ادعُ أصدقاءك')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          const Center(child: Text('🎁', style: TextStyle(fontSize: 56))),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'ادعُ صديقاً، اربحوا معاً!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'يحصل صديقك على خصم \$10 لأول حجز،\nوتحصل أنت على +100 نقطة عند أول عملية مكتملة',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13.5, height: 1.7, color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Text('كود الإحالة الخاص بك',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 26, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: Colors.white38, width: 1.2),
                  ),
                  child: Text(referral.code,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2)),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: referral.code));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('تم نسخ ${referral.code}'),
                            behavior: SnackBarBehavior.floating));
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 17),
                      label: const Text('نسخ الكود'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text:
                            'استخدم كود ${referral.code} في تطبيق Smart Maid واحصل على خصم \$10 على أول حجز!'));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('تم تجهيز رسالة الدعوة للحفظ/المشاركة'),
                            behavior: SnackBarBehavior.floating));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                      ),
                      icon: const Icon(Icons.share_rounded, size: 17),
                      label: const Text('مشاركة'),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(children: [
            _StatCard(value: '${referral.invitedCount}', label: 'صديق انضم'),
            const SizedBox(width: 12),
            _StatCard(value: '\$${referral.earnedUsd.toStringAsFixed(0)}',
                label: 'مكافآتك المكتسبة'),
          ]),
          const SizedBox(height: 22),
          const Text('كيف تعمل الإحالة؟',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...const [
            ('1', 'شارك كودك مع أصدقائك عبر أي وسيلة'),
            ('2', 'يسجل صديقك ويستخدم الكود في أول حجز'),
            ('3', 'يحصل هو على خصم فوري \$10'),
            ('4', 'تحصل أنت على +100 نقطة بعد إتمام حجزه'),
          ].map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.1),
                    child: Text(e.$1,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(e.$2,
                          style: const TextStyle(fontSize: 13, height: 1.5))),
                ]),
              )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Column(children: [
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ]),
      ),
    );
  }
}
