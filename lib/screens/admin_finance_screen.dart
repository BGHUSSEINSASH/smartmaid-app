import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../providers/company_provider.dart';
import '../data/demo_data.dart';
import '../providers/currency_provider.dart';
import '../providers/wallet_provider.dart';

class AdminFinanceScreen extends ConsumerWidget {
  const AdminFinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final withdrawals = ref.watch(withdrawalsProvider);
    final stats = companyStatsForId('co1') +
        _sum(companyStatsForId('co2'), companyStatsForId('co3'));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('المالية والعمولات')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.deductionGradient,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(children: [
              Text('عمولة المنصة المتراكمة (20%)',
                  style:
                      TextStyle(color: Colors.white.withValues(alpha: 0.8))),
              const SizedBox(height: 6),
              FittedBox(
                child: Text(currency.format(stats.platformCommission),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                    child: _FinStat(
                        label: 'إجمالي المعاملات',
                        value: currency.format(stats.totalRevenue))),
                const SizedBox(width: 10),
                Expanded(
                    child: _FinStat(
                        label: 'صافي الشركات',
                        value: currency.format(stats.netRevenue))),
              ]),
            ]),
          ),
          const SizedBox(height: 22),
          Text('طلبات السحب المعلقة (${withdrawals.where((w) => !w.approved).length})',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          ...withdrawals.map((w) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.stroke),
                ),
                child: Row(children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.08),
                    child: Icon(
                        w.requesterName.contains('شركة')
                            ? Icons.domain_rounded
                            : Icons.person_rounded,
                        size: 19,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(w.requesterName,
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(DateFormat('yyyy/MM/dd').format(w.date),
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  Text(currency.format(w.amountUsd),
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  w.approved
                      ? const Icon(Icons.verified_rounded,
                          color: AppColors.success)
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 34),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          onPressed: () {
                            ref.read(withdrawalsProvider.notifier).approve(w.id);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'تمت الموافقة على سحب ${currency.format(w.amountUsd)}'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.success));
                          },
                          child: const Text('موافقة',
                              style: TextStyle(fontSize: 11.5)),
                        ),
                ]),
              )),
        ],
      ),
    );
  }

  static CompanyBookingStats operatorSum(CompanyBookingStats a, CompanyBookingStats b) =>
      CompanyBookingStats(
        totalBookings: a.totalBookings + b.totalBookings,
        totalRevenue: a.totalRevenue + b.totalRevenue,
        netRevenue: a.netRevenue + b.netRevenue,
        platformCommission: a.platformCommission + b.platformCommission,
      );

  static CompanyBookingStats _sum(CompanyBookingStats a, CompanyBookingStats b) =>
      operatorSum(a, b);
}

extension on CompanyBookingStats {
  CompanyBookingStats operator +(CompanyBookingStats other) =>
      AdminFinanceScreen.operatorSum(this, other);
}

class _FinStat extends StatelessWidget {
  final String label;
  final String value;
  const _FinStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: [
        FittedBox(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15))),
        const SizedBox(height: 3),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75), fontSize: 10.5)),
      ]),
    );
  }
}


