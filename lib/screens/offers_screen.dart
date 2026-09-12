import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/offers_provider.dart';

class OffersScreen extends ConsumerWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applied = ref.watch(couponProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('العروض والكوبونات')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (applied != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success),
              ),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                      'كوبون ${applied.code} مفعّل — سيُطبق على حجزك القادم',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.success)),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () =>
                      ref.read(couponProvider.notifier).clear(),
                ),
              ]),
            ),
          ...kDemoCoupons.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.accent.withValues(alpha: 0.08),
                  ]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color:
                          applied?.code == c.code ? AppColors.primary : AppColors.stroke),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(c.emoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text('${c.discountPercent.toStringAsFixed(0)}% خصم',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 17,
                                      color: AppColors.primary)),
                              if (c.minTotalUsd > 0)
                                Text('  •  حد أدنى \$${c.minTotalUsd.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.muted)),
                            ]),
                            const SizedBox(height: 4),
                            Text(c.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 14)),
                            Text(c.description,
                                style: TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: isDark
                                        ? Colors.white60
                                        : AppColors.muted)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: c.code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('تم نسخ الكود ${c.code}'),
                                      behavior: SnackBarBehavior.floating));
                            },
                            child: DashedCoupon(code: c.code),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () {
                              ref.read(couponProvider.notifier).clear();
                              final r = ref
                                  .read(couponProvider.notifier)
                                  .apply(c.code, double.infinity);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(r.message),
                                  behavior: SnackBarBehavior.floating));
                            },
                            child: const Text('استخدام الآن',
                                style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class DashedCoupon extends StatelessWidget {
  final String code;
  const DashedCoupon({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.primary, width: 1.2, style: BorderStyle.solid),
      ),
      child: Text(code,
          style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              fontSize: 13,
              color: AppColors.primary)),
    );
  }
}
