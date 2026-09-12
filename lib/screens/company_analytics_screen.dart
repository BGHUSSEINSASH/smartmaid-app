import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/app_theme.dart';
import '../widgets/ai_app_bar_button.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import '../providers/booking_provider.dart';
import '../providers/company_provider.dart';
import '../providers/currency_provider.dart';

class CompanyAnalyticsScreen extends ConsumerWidget {
  const CompanyAnalyticsScreen({super.key});

  List<double> _weeklyRevenue(List<BookingModel> bookings) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return bookings
          .where((b) =>
              b.status == BookingStatus.completed &&
              b.date.year == day.year &&
              b.date.month == day.month &&
              b.date.day == day.day)
          .fold<double>(0, (s, b) => s + b.total);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;
    final bookings = ref.watch(myBookingsProvider);
    final workers = ref.watch(companyWorkersProvider);
    final currency = ref.watch(currencyProvider);

    final totalBookings = bookings.length;
    final completed = bookings.where((b) => b.status == BookingStatus.completed).toList();
    final completionRate = totalBookings > 0 ? (completed.length / totalBookings * 100).round() : 0;
    final avgRating = workers.isEmpty
        ? 0.0
        : workers.fold<double>(0, (s, w) => s + w.rating) / workers.length;
    final totalRevenue = completed.fold<double>(0, (s, b) => s + b.total);

    final weeklyData = _weeklyRevenue(bookings);
    final maxWeekly = weeklyData.isEmpty ? 100.0 : (weeklyData.reduce((a, b) => a > b ? a : b) + 50);

    final topWorkers = [...workers]..sort((a, b) => b.rating.compareTo(a.rating));

    final dayLabels = ['أحد', 'اثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت'];
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
          title: const Text('تقارير الأداء'),
          actions: [aiAppBarButton(context, initialMessage: 'حلل أداء شركتي')]),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // KPIs
          Row(children: [
            _Kpi(value: '$totalBookings', label: 'إجمالي الطلبات', color: AppColors.primary),
            const SizedBox(width: 12),
            _Kpi(value: '$completionRate%', label: 'نسبة الإنجاز', color: AppColors.success),
            const SizedBox(width: 12),
            _Kpi(value: avgRating.toStringAsFixed(1), label: 'متوسط التقييم', color: AppColors.warning),
          ]),
          const SizedBox(height: 16),

          // Total revenue card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(children: [
              const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('إجمالي الإيرادات', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(currency.format(totalRevenue),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              ]),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${workers.length} عاملة', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text('${workers.where((w) => w.isAvailable).length} متاحة',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),

          // Weekly revenue chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.stroke)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('إيرادات آخر 7 أيام', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxWeekly,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                          currency.format(rod.toY), const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, _) {
                            final dayIndex = now.subtract(Duration(days: 6 - val.toInt())).weekday % 7;
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(dayLabels[dayIndex], style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: weeklyData.asMap().entries.map((e) =>
                      BarChartGroupData(x: e.key, barRods: [
                        BarChartRodData(
                          toY: e.value > 0 ? e.value : 5,
                          width: 22,
                          borderRadius: BorderRadius.circular(6),
                          color: e.key == 6 ? AppColors.primary : AppColors.primary.withValues(alpha: .4),
                        ),
                      ])
                    ).toList(),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Top workers
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.stroke)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('أفضل العاملات أداءً', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 12),
              if (topWorkers.isEmpty)
                const Center(child: Text('لا توجد بيانات', style: TextStyle(color: AppColors.muted)))
              else
                ...topWorkers.take(5).map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(children: [
                    CircleAvatar(radius: 20, backgroundImage: NetworkImage(w.imageUrl), backgroundColor: AppColors.stroke),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(w.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text('${w.jobsCompleted} مهمة مكتملة', style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
                    ])),
                    Row(children: [
                      const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                      const SizedBox(width: 3),
                      Text(w.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w800)),
                    ]),
                  ]),
                )),
            ]),
          ),
          const SizedBox(height: 16),

          // Booking status breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.stroke)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('توزيع الطلبات', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 12),
              _StatusRow('مكتملة', completed.length, totalBookings, AppColors.success),
              const SizedBox(height: 8),
              _StatusRow('معلّقة', bookings.where((b) => b.status == BookingStatus.pending).length, totalBookings, AppColors.warning),
              const SizedBox(height: 8),
              _StatusRow('ملغاة', bookings.where((b) => b.status == BookingStatus.cancelled).length, totalBookings, AppColors.error),
            ]),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final String value, label;
  final Color color;
  const _Kpi({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.muted), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final int count, total;
  final Color color;
  const _StatusRow(this.label, this.count, this.total, this.color);

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const Spacer(),
        Text('$count (${(pct * 100).round()}%)', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: pct,
          minHeight: 6,
          backgroundColor: AppColors.stroke,
          color: color,
        ),
      ),
    ]);
  }
}

