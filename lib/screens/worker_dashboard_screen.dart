import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/review_provider.dart';
import '../providers/wallet_provider.dart';
import '../core/theme/adaptive.dart';
import 'booking_detail_screen.dart' show BookingOtp;

class WorkerDashboardScreen extends ConsumerWidget {
  const WorkerDashboardScreen({super.key});

  void _startJob(BookingModel b, WidgetRef ref, BuildContext context) {
    ref.read(myBookingsProvider.notifier).startBooking(b.id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('بدأت المهمة — بالتوفيق! 💪'),
        behavior: SnackBarBehavior.floating));
  }

  

  void _finishJob(BookingModel b, WidgetRef ref, BuildContext context) {
    final ctrl = TextEditingController();
    final expected = BookingOtp.codeFor(b.id);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد إنهاء المهمة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('اطلب من العميل كود التأكيد الظاهر في تفاصيل حجزه:'),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.w900),
              decoration: const InputDecoration(
                  counterText: '', hintText: '••••'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                minimumSize: const Size(0, 42),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            onPressed: () {
              if (ctrl.text.trim() != expected) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('الكود غير صحيح'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating));
                return;
              }
              ref.read(myBookingsProvider.notifier).completeBooking(b.id);
              ref.read(myBookingsProvider.notifier).markPaid(b.id);
              ref
                  .read(walletProvider.notifier)
                  .addEarning(b.total * 0.8, 'أرباح مهمة ${b.service}');
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      'اكتملت المهمة! أُضيف ${b.total * 0.8} لمحفظتك 🎉'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating));
            },
            child: const Text('تأكيد الإنهاء'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final myId = user?.id ?? 'w1';
    final myName = user?.name ?? DemoData.workers.first.name;
    final myImage = user?.imageUrl ?? DemoData.workers.first.imageUrl;

    final bookings = ref.watch(myBookingsProvider);
    final currency = ref.watch(currencyProvider);
    final availability = ref.watch(workerAvailabilityProvider);
    final isAvailable = availability[myId] ?? true;
    final todayJobs = bookings
        .where((b) =>
            b.workerId == myId &&
            (b.status == BookingStatus.pending ||
                b.status == BookingStatus.confirmed))
        .toList();
    final completed = bookings
        .where((b) => b.workerId == myId && b.status == BookingStatus.completed)
        .toList();
    final monthEarnings = completed.fold(0.0, (s, b) => s + b.total * 0.8);
    final walletBalance = ref.watch(walletProvider).balanceUsd;

    return Scaffold(
      appBar: AppBar(title: const Text('لوحتي')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(myImage),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('مرحباً، ${myName.split(' ').first} 👋',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 17)),
                    const SizedBox(height: 2),
                    Text('${todayJobs.length} مهام اليوم',
                        style:
                            const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isAvailable
                  ? AppColors.success.withValues(alpha: 0.09)
                  : AppColors.warning.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isAvailable ? AppColors.success : AppColors.warning,
                  width: 1.3),
            ),
            child: Row(children: [
              Icon(isAvailable ? Icons.wifi_tethering_rounded : Icons.do_not_disturb_on_rounded,
                  color: isAvailable ? AppColors.success : AppColors.warning,
                  size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isAvailable ? 'أنتِ متاحة لاستقبال الطلبات الآن' : 'وضع الإيقاف المؤقت',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: isAvailable ? AppColors.success : AppColors.warning),
                ),
              ),
              Switch(
                value: isAvailable,
                activeThumbColor:
                    isAvailable ? AppColors.success : AppColors.warning,
                onChanged: (_) => ref
                    .read(workerAvailabilityProvider.notifier)
                    .toggle(myId),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          Row(children: [
            _Stat(value: currency.format(monthEarnings), label: 'أرباح الشهر', color: AppColors.primary, icon: Icons.trending_up_rounded),
            const SizedBox(width: 12),
            _Stat(value: currency.format(walletBalance), label: 'رصيد المحفظة', color: AppColors.success, icon: Icons.wallet_rounded),
          ]),
          const SizedBox(height: 18),
          SurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('أرباحك الأسبوعية (80% صافي)',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        color: context.ink)),
                const SizedBox(height: 14),
                SizedBox(
                  height: 110,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: completed.isEmpty ? 300 : completed.fold(0.0, (s,b) => s+b.total*0.8) / 7 * 3 + 50,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: const FlTitlesData(show: false),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(7, (i) {
                        final dayEarnings = completed
                            .where((b) => b.date.weekday - 1 == i)
                            .fold(0.0, (s,b) => s + b.total * 0.8);
                        final v = dayEarnings > 0 ? dayEarnings : (i % 4 + 1) * 20.0 + 10;
                        return BarChartGroupData(x: i, barRods: [
                          BarChartRodData(
                            toY: v,
                            width: 14,
                            borderRadius: BorderRadius.circular(5),
                            color: i == DateTime.now().weekday - 1
                                ? AppColors.primary
                                : AppColors.success.withValues(alpha: 0.45),
                          ),
                        ]);
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('مهام اليوم',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: context.ink)),
              if (completed.isNotEmpty)
                Text('${completed.length} مكتملة',
                    style: const TextStyle(fontSize: 12, color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 10),
          ...todayJobs.map((b) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.stroke),
                ),
                child: Column(children: [
                  Row(children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                          b.status == BookingStatus.confirmed
                              ? Icons.check_circle_outline_rounded
                              : Icons.directions_run_rounded,
                          size: 21,
                          color: b.status == BookingStatus.confirmed
                              ? AppColors.primary
                              : AppColors.accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${b.service} — ${b.timeSlot}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  color: context.ink)),
                          if (b.notes.isNotEmpty)
                            Text('📝 ${b.notes}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 11, color: context.mutedText)),
                        ],
                      ),
                    ),
                    Text(currency.format(b.total * 0.8),
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.success,
                            fontSize: 13)),
                  ]),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 38),
                          backgroundColor: b.status == BookingStatus.confirmed
                              ? AppColors.primary
                              : AppColors.success,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      onPressed: () => b.status == BookingStatus.confirmed
                          ? _startJob(b, ref, context)
                          : _finishJob(b, ref, context),
                      icon: Icon(
                          b.status == BookingStatus.confirmed
                              ? Icons.play_arrow_rounded
                              : Icons.task_alt_rounded,
                          size: 17),
                      label: Text(
                          b.status == BookingStatus.confirmed
                              ? 'بدء المهمة الآن'
                              : 'إنهاء المهمة (كود العميل)',
                          style: const TextStyle(fontSize: 12.5)),
                    ),
                  ),
                ]),
              )),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  const _Stat({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(height: 8),
            FittedBox(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17))),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}



