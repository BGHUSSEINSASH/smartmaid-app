import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../widgets/ai_app_bar_button.dart';
import '../data/models.dart';
import '../providers/booking_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/review_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/low_rating_dialog.dart';
import 'invoice_screen.dart';
import 'payment_screen.dart';
import 'booking_detail_screen.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(myBookingsProvider);
    final upcoming = bookings
        .where((b) =>
            b.status == BookingStatus.pending ||
            b.status == BookingStatus.confirmed ||
            b.status == BookingStatus.inProgress)
        .toList();
    final completed =
        bookings.where((b) => b.status == BookingStatus.completed).toList();
    final cancelled =
        bookings.where((b) => b.status == BookingStatus.cancelled).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حجوزاتي'),
          actions: [aiAppBarButton(context, initialMessage: 'ماذا يمكنني فعله بحجوزاتي؟')],
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.muted,
            indicatorColor: AppColors.primary,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800),
            tabs: [
              Tab(text: 'القادمة (${upcoming.length})'),
              Tab(text: 'المكتملة (${completed.length})'),
              Tab(text: 'الملغاة (${cancelled.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _List(bookings: upcoming, tab: _TabMode.upcoming),
            _List(bookings: completed, tab: _TabMode.completed),
            _List(bookings: cancelled, tab: _TabMode.cancelled),
          ],
        ),
      ),
    );
  }
}

enum _TabMode { upcoming, completed, cancelled }

class _List extends ConsumerWidget {
  final List<BookingModel> bookings;
  final _TabMode tab;
  const _List({required this.bookings, required this.tab});

  void _cancel(BuildContext context, WidgetRef ref, BookingModel b) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إلغاء الحجز؟'),
        content:
            Text('هل تريد إلغاء حجزك مع ${b.workerName}؟ لا يمكن التراجع.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('رجوع')),
          TextButton(
            onPressed: () {
              ref.read(myBookingsProvider.notifier).cancelBooking(b.id);
              Navigator.pop(ctx);
            },
            child: const Text('نعم، إلغاء',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _review(BuildContext context, WidgetRef ref, BookingModel b) {
    final user = ref.read(authProvider).user;
    double _selectedRating = 5;
    final ctrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Theme.of(ctx).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('قيّم الخدمة',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                Text(b.workerName, style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 16),
                // ── StarRatingWidget — يفتح LowRatingDialog عند 1-2 نجوم ──
                Center(
                  child: StarRatingWidget(
                    initialRating: _selectedRating,
                    workerName: b.workerName,
                    size: 40,
                    onRatingChanged: (r, reason, comment) {
                      setSheet(() => _selectedRating = r);
                      if (reason != null) ctrl.text = reason;
                    },
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: ctrl,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'شاركنا تجربتك...'),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(reviewsProvider.notifier).addReview(
                        workerId: b.workerId,
                        reviewerName: user?.name ?? 'أنت',
                        reviewerImage: user?.imageUrl ?? 'https://i.pravatar.cc/150?img=68',
                        rating: _selectedRating,
                        comment: ctrl.text.trim().isNotEmpty
                            ? ctrl.text.trim()
                            : 'تقييم جيد',
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('شكراً على تقييمك! ⭐'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ));
                    },
                    child: const Text('إرسال التقييم'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded, size: 64, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(switch (tab) {
              _TabMode.upcoming => 'لا توجد حجوزات قادمة',
              _TabMode.completed => 'لا توجد حجوزات مكتملة',
              _TabMode.cancelled => 'لا توجد حجوزات ملغاة',
            }),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 100),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final b = bookings[i];
        final statusMeta = switch (b.status) {
          BookingStatus.pending => ('بانتظار التأكيد', AppColors.warning),
          BookingStatus.confirmed => ('مؤكد', AppColors.primary),
          BookingStatus.inProgress => ('جارٍ الآن', AppColors.accent),
          BookingStatus.completed => ('مكتمل', AppColors.success),
          BookingStatus.cancelled => ('ملغى', AppColors.error),
        };
        return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => BookingDetailScreen(booking: b))),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(b.workerImage),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.workerName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 15)),
                        Text(b.service,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusMeta.$2.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(statusMeta.$1,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusMeta.$2)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(children: [
                Icon(Icons.calendar_month_rounded,
                    size: 15, color: AppColors.muted),
                const SizedBox(width: 4),
                Text(DateFormat('EEE، d MMMM', 'ar').format(b.date),
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 14),
                Icon(Icons.schedule_rounded, size: 15, color: AppColors.muted),
                const SizedBox(width: 4),
                Text(b.timeSlot, style: const TextStyle(fontSize: 12)),
                const Spacer(),
                Text(currency.format(b.total),
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ]),
              if (tab != _TabMode.cancelled) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (tab == _TabMode.upcoming &&
                        b.paymentStatus == PaymentStatus.unpaid)
                      _ActionBtn(
                        label: 'ادفع الآن',
                        filled: true,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PaymentScreen())),
                      ),
                    if (tab == _TabMode.upcoming &&
                        b.paymentStatus == PaymentStatus.paid)
                      _ActionBtn(
                        label: 'الفاتورة',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => InvoiceScreen())),
                      ),
                    if (tab == _TabMode.upcoming &&
                        b.paymentStatus != PaymentStatus.paid)
                      _ActionBtn(
                        label: 'الفاتورة',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => InvoiceScreen())),
                      ),
                    if (tab == _TabMode.completed)
                      _ActionBtn(
                        label: 'قيّم الخدمة ⭐',
                        filled: true,
                        onTap: () => _review(context, ref, b),
                      ),
                    const Spacer(),
                    if (tab == _TabMode.upcoming)
                      GestureDetector(
                        onTap: () => _cancel(context, ref, b),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Text('إلغاء الحجز',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error)),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        );
      },
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;
  const _ActionBtn({
    required this.label,
    required this.onTap,
    this.filled = false,
  });
  @override
  Widget build(BuildContext context) {
    return filled
        ? SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text(label, style: const TextStyle(fontSize: 12)),
            ),
          )
        : SizedBox(
            height: 36,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text(label, style: const TextStyle(fontSize: 12)),
            ),
          );
  }
}



