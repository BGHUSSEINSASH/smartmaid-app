import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../providers/subscription_provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/platform_control_provider.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = ref.watch(subscriptionProvider);
    final wallet = ref.watch(walletProvider);
    ref.watch(platformFlagsProvider); // watch for flag changes
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('SmartGold Membership')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── الحالة الحالية
          _CurrentStatusCard(sub: sub, wallet: wallet),
          const SizedBox(height: 20),

          // ── رصيد المحفظة
          _WalletBalanceBar(wallet: wallet),
          const SizedBox(height: 24),

          Text('اختر باقتك',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(
            'الاشتراك يُخصم مباشرة من محفظتك',
            style: TextStyle(
                color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 16),

          _PlanCard(
            tier: SubscriptionTier.gold,
            isActive: sub.tier == SubscriptionTier.gold,
            isDark: isDark,
            walletBalance: wallet.balanceUsd,
            onSelect: () => _handleSubscribe(context, ref, SubscriptionTier.gold, wallet.balanceUsd),
          ),
          const SizedBox(height: 12),
          _PlanCard(
            tier: SubscriptionTier.platinum,
            isActive: sub.tier == SubscriptionTier.platinum,
            isDark: isDark,
            walletBalance: wallet.balanceUsd,
            onSelect: () => _handleSubscribe(context, ref, SubscriptionTier.platinum, wallet.balanceUsd),
          ),

          const SizedBox(height: 20),

          // ── مزايا الاشتراك التفصيلية
          _BenefitsSection(isDark: isDark),

          const SizedBox(height: 20),

          if (sub.isActive) ...[
            // زر الإلغاء
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                onPressed: () => _handleCancel(context, ref),
                icon: const Icon(Icons.cancel_rounded, size: 18),
                label: const Text('إلغاء الاشتراك'),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'لن يتم استرداد الرسوم المدفوعة عند الإلغاء',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _handleSubscribe(
      BuildContext context, WidgetRef ref, SubscriptionTier tier, double balance) {
    final price = tier.monthlyPrice;

    // رصيد غير كافٍ
    if (balance < price) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('رصيد المحفظة غير كافٍ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('رصيدك الحالي: \$${balance.toStringAsFixed(2)}'),
              Text('سعر الاشتراك: \$${price.toStringAsFixed(2)}'),
              Text('الفرق: \$${(price - balance).toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.account_balance_wallet_rounded, size: 16),
              label: const Text('شحن المحفظة'),
              onPressed: () {
                Navigator.pop(context);
                context.push('/wallet');
              },
            ),
          ],
        ),
      );
      return;
    }

    // تأكيد الاشتراك مع تفاصيل الخصم
    showDialog(
      context: context,
      builder: (_) {
        final expiry = DateTime.now().add(const Duration(days: 30));
        final discount = tier == SubscriptionTier.platinum ? 15 : 10;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            Icon(
              tier == SubscriptionTier.platinum
                  ? Icons.diamond_rounded
                  : Icons.workspace_premium_rounded,
              color: tier == SubscriptionTier.platinum
                  ? const Color(0xFF8B5CF6)
                  : const Color(0xFFD4A574),
            ),
            const SizedBox(width: 8),
            Text('تأكيد الاشتراك'),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ConfirmRow(label: 'الباقة', value: tier.arabicLabel),
              _ConfirmRow(label: 'السعر', value: '\$${price.toStringAsFixed(2)}/شهر'),
              _ConfirmRow(
                  label: 'رصيدك بعد الاشتراك',
                  value: '\$${(balance - price).toStringAsFixed(2)}',
                  valueColor: AppColors.success),
              _ConfirmRow(label: 'تاريخ التجديد', value: '${expiry.day}/${expiry.month}/${expiry.year}'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.percent_rounded, color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'ستحصل على خصم $discount% على كل حجوزاتك تلقائياً',
                    style: const TextStyle(
                        color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ]),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // خصم من المحفظة
                ref.read(walletProvider.notifier).pay(price, 'اشتراك ${tier.arabicLabel}');
                // تفعيل الاشتراك
                ref.read(subscriptionProvider.notifier).subscribe(tier);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('✅ تم تفعيل ${tier.arabicLabel} بنجاح!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ));
              },
              child: const Text('تأكيد الاشتراك'),
            ),
          ],
        );
      },
    );
  }

  void _handleCancel(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إلغاء الاشتراك'),
        content: const Text(
            'هل أنت متأكد؟ ستفقد جميع مزايا الاشتراك فور الإلغاء ولن يتم استرداد أي مبلغ.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('تراجع')),
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              ref.read(subscriptionProvider.notifier).cancel();
            },
            child: const Text('إلغاء الاشتراك'),
          ),
        ],
      ),
    );
  }
}

class _CurrentStatusCard extends StatelessWidget {
  final SubscriptionState sub;
  final WalletState wallet;
  const _CurrentStatusCard({required this.sub, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: sub.isActive
            ? LinearGradient(
                colors: sub.tier == SubscriptionTier.platinum
                    ? [const Color(0xFF6D28D9), const Color(0xFF8B5CF6)]
                    : [const Color(0xFFD4A574), const Color(0xFFC49A6C)],
              )
            : AppColors.heroGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(
            sub.tier == SubscriptionTier.platinum
                ? Icons.diamond_rounded
                : sub.tier == SubscriptionTier.gold
                    ? Icons.workspace_premium_rounded
                    : Icons.person_rounded,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            sub.tier.arabicLabel,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
          ),
          if (sub.isActive && sub.expiresAt != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ينتهي في ${sub.expiresAt!.day}/${sub.expiresAt!.month}/${sub.expiresAt!.year}',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'خصم ${sub.tier == SubscriptionTier.platinum ? 15 : 10}% على كل الحجوزات مفعّل',
              style: TextStyle(color: Colors.white.withValues(alpha: .85), fontSize: 12),
            ),
          ],
          if (!sub.isActive) ...[
            const SizedBox(height: 8),
            const Text('اشترك لتوفير أكثر', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}

class _WalletBalanceBar extends StatelessWidget {
  final WalletState wallet;
  const _WalletBalanceBar({required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: .2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          const Text('رصيد المحفظة',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(
            '\$${wallet.balanceUsd.toStringAsFixed(2)}',
            style: const TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _ConfirmRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: valueColor ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _BenefitsSection extends StatelessWidget {
  final bool isDark;
  const _BenefitsSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('مقارنة الباقات',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          _BenefitRow('خصم على الحجوزات', '—', '10%', '15%'),
          _BenefitRow('أولوية في النتائج', '—', '✓', '✓✓'),
          _BenefitRow('إلغاء مجاني', '—', 'قبل 24 ساعة', 'في أي وقت'),
          _BenefitRow('دعم العملاء', 'عادي', 'أولوية', '24/7 مباشر'),
          _BenefitRow('عاملة بديلة مجانية', '—', '—', '✓'),
          _BenefitRow('هدايا حجوزات', '—', '—', '✓'),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String feature;
  final String free;
  final String gold;
  final String platinum;
  const _BenefitRow(this.feature, this.free, this.gold, this.platinum);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(feature,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(child: Text(free,
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
              textAlign: TextAlign.center)),
          Expanded(child: Text(gold,
              style: const TextStyle(fontSize: 11, color: Color(0xFFD4A574), fontWeight: FontWeight.w700),
              textAlign: TextAlign.center)),
          Expanded(child: Text(platinum,
              style: const TextStyle(fontSize: 11, color: Color(0xFF8B5CF6), fontWeight: FontWeight.w700),
              textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionTier tier;
  final bool isActive;
  final bool isDark;
  final double walletBalance;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.tier,
    required this.isActive,
    required this.isDark,
    required this.walletBalance,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = walletBalance >= tier.monthlyPrice;
    final isPlatinum = tier == SubscriptionTier.platinum;

    return GestureDetector(
      onTap: isActive ? null : onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.08)
              : isDark
                  ? AppColors.surfaceDark
                  : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : isPlatinum
                    ? const Color(0xFF8B5CF6)
                    : AppColors.stroke,
            width: isActive || isPlatinum ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPlatinum ? Icons.diamond_rounded : Icons.workspace_premium_rounded,
                  size: 24,
                  color: isActive
                      ? AppColors.primary
                      : isPlatinum
                          ? const Color(0xFF8B5CF6)
                          : const Color(0xFFD4A574),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(tier.arabicLabel,
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: isActive ? AppColors.primary : null)),
                ),
                if (isPlatinum && !isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('الأفضل',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('نشط',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  )
                else
                  Text('\$${tier.monthlyPrice.toStringAsFixed(2)}/شهر',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 14),
            ...tier.benefits.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(b,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white70
                                      : AppColors.textSecondary))),
                    ],
                  ),
                )),
            if (!isActive) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford ? null : AppColors.muted.withValues(alpha: .3),
                  ),
                  onPressed: onSelect,
                  icon: Icon(canAfford ? Icons.star_rounded : Icons.account_balance_wallet_rounded, size: 18),
                  label: Text(canAfford ? 'اشترك الآن' : 'رصيد المحفظة غير كافٍ'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
