import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../data/models.dart';
import '../providers/booking_provider.dart';
import '../providers/currency_provider.dart';

class WorkerRequestsScreen extends ConsumerWidget {
  const WorkerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(myBookingsProvider);
    final currency = ref.watch(currencyProvider);
    final pending = bookings
        .where((b) =>
            b.status == BookingStatus.pending &&
            (b.workerId == 'w1' || b.workerId == 'w2' || b.workerId == 'w4'))
        .toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: Text('طلباتي الواردة (${pending.length})')),
      body: pending.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mark_email_read_rounded,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  const Text('لا طلبات معلقة حالياً'),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: pending.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final b = pending[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: Column(children: [
                    Row(children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(b.workerImage),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${b.service} — العميل ${b.userId == 'u1' ? 'أحمد محمد' : b.userId}',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            Text(
                              '${DateFormat('EEE d MMM', 'ar').format(b.date)} • ${b.timeSlot}',
                              style: const TextStyle(
                                  fontSize: 11.5, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      Text(currency.format(b.total * 0.8),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                              fontSize: 13)),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => ref
                              .read(myBookingsProvider.notifier)
                              .cancelBooking(b.id),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error),
                          icon: const Icon(Icons.close_rounded, size: 16),
                          label: const Text('رفض الطلب'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ref
                                .read(myBookingsProvider.notifier)
                                .confirmBooking(b.id);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text('تم قبول طلب ${DateFormat('d MMM', 'ar').format(b.date)} ✅'),
                                behavior: SnackBarBehavior.floating));
                          },
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: const Text('قبول'),
                        ),
                      ),
                    ]),
                  ]),
                );
              },
            ),
    );
  }
}
