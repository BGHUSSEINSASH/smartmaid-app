import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../providers/achievements_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/loyalty_provider.dart';

class LoyaltyScreen extends ConsumerWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loyalty = ref.watch(loyaltyProvider);
    final currency = ref.watch(currencyProvider);
    final tier = loyalty.tier;
    final next = loyalty.nextTier;
    final remaining = (loyalty.nextTierAt - loyalty.points).clamp(0, loyalty.nextTierAt);

    return Scaffold(
      appBar: AppBar(title: const Text('نقاط المكافآت')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppColors.savingsGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text(tier.emoji, style: const TextStyle(fontSize: 44)),
                const SizedBox(height: 8),
                Text('${loyalty.points} نقطة',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900)),
                Text('مستواك الحالي: ${tier.label}',
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: loyalty.progressToNext,
                    minHeight: 10,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.amber),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tier == LoyaltyTier.gold
                      ? 'وصلت للمستوى الأعلى 🎉'
                      : '${next.emoji} ${remaining} نقطة تفصلك عن ${next.label}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('استبدل نقاطك بخصومات',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _RedeemCard(
                  discount: 5,
                  points: loyalty.pointsForDiscount(5),
                  currencyLabel: currency.code,
                  enabled: loyalty.points >= loyalty.pointsForDiscount(5),
                  onRedeem: () =>
                      _redeem(ref, context, 5, loyalty.pointsForDiscount(5)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RedeemCard(
                  discount: 15,
                  points: loyalty.pointsForDiscount(15),
                  currencyLabel: currency.code,
                  enabled: loyalty.points >= loyalty.pointsForDiscount(15),
                  onRedeem: () => _redeem(
                      ref, context, 15, loyalty.pointsForDiscount(15)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Builder(builder: (context) {
            final ach = ref.watch(achievementsProvider);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('الإنجازات',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: context.ink)),
                  const SizedBox(width: 8),
                  Text('${ach.unlocked.length}/${ach.total}',
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                ]),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final a in [...ach.unlocked, ...ach.locked])
                      Container(
                        width: 104,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.stroke),
                        ),
                        child: Column(children: [
                          Opacity(
                            opacity: ach.unlocked.contains(a) ? 1 : 0.35,
                            child: Text(a.emoji,
                                style: const TextStyle(fontSize: 26)),
                          ),
                          const SizedBox(height: 6),
                          Text(a.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: context.ink)),
                          Text(ach.unlocked.contains(a)
                              ? 'محققة ✓'
                              : 'قيد الطريق',
                              style: TextStyle(
                                  fontSize: 9.5,
                                  color: ach.unlocked.contains(a)
                                      ? AppColors.success
                                      : AppColors.muted)),
                        ]),
                      ),
                  ],
                ),
              ],
            );
          }),
          const SizedBox(height: 22),
          Text('كيف تكسب النقاط؟',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.ink)),
          const SizedBox(height: 10),
          ...const [
            ('🧾', 'كل \$1 من قيمة الحجز = نقطة واحدة'),
            ('⭐', 'تقييم 5 نجوم = +50 نقطة مكافأة'),
            ('👥', 'دعوة صديق عبر الإحالة = +100 نقطة لكما'),
            ('🥇', 'المستوى الذهبي يضاعف النقاط ×1.5'),
          ].map((e) => ListTile(
                dense: true,
                leading: Text(e.$1, style: const TextStyle(fontSize: 20)),
                title: Text(e.$2, style: const TextStyle(fontSize: 13)),
              )),
          const SizedBox(height: 14),
          const Text('سجل النقاط',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ...loyalty.history.map((h) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  h.points >= 0
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color:
                      h.points >= 0 ? AppColors.success : AppColors.error,
                  size: 19,
                ),
                title: Text(h.title,
                    style: const TextStyle(fontSize: 13.5)),
                subtitle: Text(DateFormat('yyyy/MM/dd').format(h.date),
                    style: const TextStyle(fontSize: 11)),
                trailing: Text(
                  '${h.points > 0 ? '+' : ''}${h.points}',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color:
                          h.points >= 0 ? AppColors.success : AppColors.error),
                ),
              )),
        ],
      ),
    );
  }

  void _redeem(WidgetRef ref, BuildContext ctx, double usd, int cost) {
    final ok = ref.read(loyaltyProvider.notifier).redeem(usd);
    if (ok) {
      Clipboard.setData(ClipboardData(text: 'LOYAL$cost'));
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(
            'تم الاستبدال! كود الخصم LOYAL$cost بقيمة \$$usd — استخدمه في حجزك القادم'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ));
    } else {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
          content: Text('نقاطك غير كافية للاستبدال'),
          behavior: SnackBarBehavior.floating));
    }
  }
}

class _RedeemCard extends StatelessWidget {
  final double discount;
  final int points;
  final String currencyLabel;
  final bool enabled;
  final VoidCallback onRedeem;

  const _RedeemCard({
    required this.discount,
    required this.points,
    required this.currencyLabel,
    required this.enabled,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: enabled
            ? AppColors.primary.withValues(alpha: 0.06)
            : Theme.of(context).dividerColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: enabled ? AppColors.primary : AppColors.stroke,
            width: enabled ? 1.5 : 1),
      ),
      child: Column(
        children: [
          Text('خصم \$${discount.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 17)),
          const SizedBox(height: 4),
          Text('$points نقطة',
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ElevatedButton(
              onPressed: enabled ? onRedeem : null,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16)),
              child: const Text('استبدال', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
