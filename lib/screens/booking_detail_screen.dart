import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/nav/app_nav.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import '../data/repository.dart';
import '../providers/booking_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/currency_provider.dart';
import '../widgets/app_image.dart';
import '../widgets/dispute_sheet.dart';
import 'booking_screen.dart';
import 'invoice_screen.dart';
import 'payment_screen.dart';
import 'active_booking_screen.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final BookingModel booking;
  const BookingDetailScreen({super.key, required this.booking});

  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  BookingModel? _live;

  BookingModel get b => _live ?? widget.booking;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  void _sync() {
    final list = ref.read(myBookingsProvider);
    final found = list.where((x) => x.id == widget.booking.id).firstOrNull;
    if (found != null && mounted) setState(() => _live = found);
  }

  void _cancelFlow() {
    String? reason;
    const reasons = [
      'تغيرت خططي',
      'حجزت عن طريق الخطأ',
      'السعر غير مناسب',
      'وجدت بديلاً',
      'سبب آخر',
    ];
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text('إلغاء الحجز'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ما سبب الإلغاء؟ يساعدنا في التحسين.'),
              const SizedBox(height: 10),
              ...reasons.map((r) => RadioListTile<String>(
                    value: r,
                    groupValue: reason,
                    dense: true,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setDialog(() => reason = v),
                    title: Text(r, style: const TextStyle(fontSize: 13.5)),
                  )),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('رجوع')),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  minimumSize: const Size(0, 42),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              onPressed: reason == null
                  ? null
                  : () {
                      ref.read(myBookingsProvider.notifier).cancelBooking(b.id);
                      final list = ref.read(myBookingsProvider);
                      final updated = list
                          .where((x) => x.id == b.id)
                          .firstOrNull!
                          .copyWith(cancelReason: reason);
                      ref
                          .read(myBookingsProvider.notifier)
                          .updateBooking(updated);
                      Navigator.pop(ctx);
                      setState(() => _live = updated);
                    },
              child: const Text('تأكيد الإلغاء'),
            ),
          ],
        ),
      ),
    );
  }

  void _reschedule() {
    DateTime picked = b.date;
    String slot = b.timeSlot;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('إعادة جدولة الحجز',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          SizedBox(
            height: 72,
            child: CalendarDatePicker(
              initialDate:
                  b.date.isAfter(DateTime.now()) ? b.date : DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 90)),
              onDateChanged: (d) => picked = d,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 46)),
              onPressed: () {
                final updated = b.copyWith(date: picked, timeSlot: slot);
                ref.read(myBookingsProvider.notifier).updateBooking(updated);
                Navigator.pop(ctx);
                setState(() => _live = updated);
                appSnackTop(context, 'تمت إعادة الجدولة ✅');
              },
              icon: const Icon(Icons.event_repeat_rounded, size: 18),
              label: const Text('تأكيد الموعد الجديد'),
            ),
          ),
        ]),
      ),
    );
  }

  void _openChat() {
    final worker = ref
        .read(myBookingsProvider)
        .where((x) => x.id == b.id)
        .map((x) => x.workerId)
        .firstOrNull;
    final w = DemoData.byId(worker ?? '');
    if (w != null) {
      ref.read(chatProvider.notifier).startConversation(w, 'u1');
    }
    context.push('/chat');
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final steps = const [
      BookingStatus.pending,
      BookingStatus.confirmed,
      BookingStatus.inProgress,
      BookingStatus.completed,
    ];
    final currentIdx = b.status == BookingStatus.cancelled
        ? -1
        : steps.indexOf(b.status) < 0
            ? 0
            : steps.indexOf(b.status);

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(title: const Text('تفاصيل الحجز')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              AppAvatar(url: b.workerImage, radius: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.workerName,
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: context.ink)),
                      Text(b.service,
                          style: TextStyle(
                              fontSize: 12.5, color: context.mutedText)),
                    ]),
              ),
              IconButton.outlined(
                tooltip: 'مراسلة العاملة',
                onPressed: _openChat,
                icon: const Icon(Icons.chat_bubble_outline_rounded,
                    size: 18, color: AppColors.primary),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          if (b.status == BookingStatus.inProgress) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.savingsGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                const Icon(Icons.pin_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                      'كود إنهاء المهمة — شاركيه مع العاملة عند الانتهاء:',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12.5)),
                ),
                Text(
                  BookingOtp.codeFor(b.id),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  minimumSize: const Size(0, 48),
                ),
                onPressed: () async {
                  final res = await TrustRepository.sendSos(
                    location: b.workerName.isNotEmpty
                        ? 'أثناء مهمة مع ${b.workerName}'
                        : 'أثناء مهمة',
                    message: 'طوارئ أثناء حجز ${b.id}',
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🚨 ${res.message}'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.emergency_rounded, size: 20),
                label: const Text('🚨 طوارئ — SOS',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (b.status == BookingStatus.cancelled) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.4)),
              ),
              child: Row(children: [
                const Icon(Icons.cancel_rounded, color: AppColors.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    b.cancelReason.isEmpty
                        ? 'تم إلغاء هذا الحجز'
                        : 'سبب الإلغاء: ${b.cancelReason}',
                    style: TextStyle(color: context.ink, fontSize: 13),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),
          ] else
            SurfaceCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('حالة الحجز',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, color: context.ink)),
                  const SizedBox(height: 16),
                  ...List.generate(steps.length, (i) {
                    final done = i <= currentIdx;
                    final isLast = i == steps.length - 1;
                    return IntrinsicHeight(
                      child: Row(children: [
                        Column(children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done
                                  ? AppColors.primary
                                  : context.stroke,
                            ),
                            child: done
                                ? const Icon(Icons.check_rounded,
                                    size: 16, color: Colors.white)
                                : null,
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                  width: 2.5,
                                  color: i < currentIdx
                                      ? AppColors.primary
                                      : context.stroke),
                            ),
                        ]),
                        const SizedBox(width: 12),
                        Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                          child: Text(
                            switch (steps[i]) {
                              BookingStatus.pending => 'بانتظار التأكيد',
                              BookingStatus.confirmed => 'مؤكد',
                              BookingStatus.inProgress => 'جارٍ التنفيذ',
                              BookingStatus.completed => 'مكتمل',
                              BookingStatus.cancelled => 'ملغى',
                            },
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: done
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              color: done
                                  ? context.ink
                                  : context.mutedText,
                            ),
                          ),
                        ),
                      ]),
                    );
                  }),
                ],
              ),
            ),
          const SizedBox(height: 16),
          SurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Column(children: [
              _row(context, Icons.calendar_month_rounded, 'التاريخ',
                  DateFormat('EEEE، d MMMM yyyy', 'ar').format(b.date)),
              _row(context, Icons.schedule_rounded, 'الوقت', b.timeSlot),
              _row(context, Icons.badge_rounded, 'نوع التعاقد', b.service),
              if (b.notes.isNotEmpty)
                _row(context, Icons.sticky_note_2_rounded, 'ملاحظاتك',
                    b.notes),
              if (b.expressFee)
                _row(context, Icons.speed_rounded, 'خدمة سريعة', '+\$5'),
              if (b.needTools)
                _row(context, Icons.build_rounded, 'أدوات التنظيف', '+\$10'),
              const Divider(height: 22),
              Row(children: [
                Text('الإجمالي',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: context.ink)),
                const Spacer(),
                Text(currency.format(b.total),
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: AppColors.primary)),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Text('حالة الدفع',
                    style: TextStyle(
                        fontSize: 12.5, color: context.mutedText)),
                const Spacer(),
                Text(
                  switch (b.paymentStatus) {
                    PaymentStatus.paid => 'مدفوع ✅',
                    PaymentStatus.held => 'محجوز 🔒',
                    PaymentStatus.unpaid => 'غير مدفوع',
                    PaymentStatus.refunded => 'مسترد',
                  },
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: b.paymentStatus == PaymentStatus.paid
                          ? AppColors.success
                          : b.paymentStatus == PaymentStatus.held
                              ? AppColors.warning
                              : AppColors.muted),
                ),
              ]),
              if (b.paymentStatus == PaymentStatus.held) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_rounded,
                          size: 14, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'المبلغ محجوز — يُحرر بعد تأكيد إنهاء المهمة بالكود',
                          style: TextStyle(
                              fontSize: 11, color: context.mutedText),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 16),
          if (b.beforeAfterPhotos.isNotEmpty) ...[
            SurfaceCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.camera_alt_rounded,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('صور قبل/بعد',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, color: context.ink)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: b.beforeAfterPhotos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            b.beforeAfterPhotos[i],
                            width: 120,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 120,
                              height: 100,
                              color: AppColors.stroke,
                              child: const Icon(Icons.image_outlined,
                                  color: AppColors.muted),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (b.paymentStatus == PaymentStatus.unpaid &&
                  b.status != BookingStatus.cancelled)
                _Action(
                    label: 'ادفع الآن',
                    icon: Icons.payments_rounded,
                    filled: true,
                    onTap: () => AppNav.pushSlide(
                        context, const PaymentScreen())),
              if (b.status == BookingStatus.inProgress) ...[
                _Action(
                    label: 'تتبع العاملة',
                    icon: Icons.location_on_rounded,
                    filled: true,
                    onTap: () => AppNav.pushSlide(
                        context, ActiveBookingScreen(booking: b))),
                _Action(
                    label: 'الفاتورة',
                    icon: Icons.receipt_long_rounded,
                    onTap: () => AppNav.pushSlide(
                        context, InvoiceScreen())),
              ],
              if (b.status == BookingStatus.confirmed) ...[
                _Action(
                    label: 'إعادة جدولة',
                    icon: Icons.event_repeat_rounded,
                    onTap: _reschedule),
                _Action(
                    label: 'الفاتورة',
                    icon: Icons.receipt_long_rounded,
                    onTap: () => AppNav.pushSlide(
                        context, InvoiceScreen())),
                _Action(
                    label: 'إلغاء الحجز',
                    icon: Icons.cancel_outlined,
                    danger: true,
                    onTap: _cancelFlow),
              ],
              if (b.status == BookingStatus.completed) ...[
                _Action(
                    label: 'الفاتورة',
                    icon: Icons.receipt_long_rounded,
                    onTap: () => AppNav.pushSlide(
                        context, InvoiceScreen())),
                _Action(
                    label: 'فتح نزاع',
                    icon: Icons.gavel_rounded,
                    danger: true,
                    onTap: () =>
                        openDisputeSheet(context, bookingId: b.id)),
                _Action(
                    label: 'احجز مجدداً',
                    icon: Icons.replay_rounded,
                    filled: true,
                    onTap: () {
                      final flow = ref.read(bookingFlowProvider.notifier);
                      flow.reset();
                      final w = DemoData.byId(b.workerId);
                      if (w != null) flow.selectWorker(w);
                      AppNav.pushSlide(context, const BookingScreen());
                    }),
              ],
              if (b.status == BookingStatus.cancelled)
                _Action(
                    label: 'احجز مجدداً',
                    icon: Icons.replay_rounded,
                    filled: true,
                    onTap: () {
                      final flow = ref.read(bookingFlowProvider.notifier);
                      flow.reset();
                      final w = DemoData.byId(b.workerId);
                      if (w != null) flow.selectWorker(w);
                      AppNav.pushSlide(context, const BookingScreen());
                    }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(k,
            style: TextStyle(fontSize: 12.5, color: context.mutedText)),
        const Spacer(),
        Flexible(
          child: Text(v,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.ink)),
        ),
      ]),
    );
  }
}

void appSnackTop(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), behavior: SnackBarBehavior.floating));
}

class BookingOtp {
  static String codeFor(String bookingId) {
    final code = bookingId.hashCode.abs().toString();
    return code.length >= 4
        ? code.substring(code.length - 4)
        : code.padLeft(4, '0');
  }
}

class _Action extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  final bool danger;

  const _Action({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.error : AppColors.primary;
    return filled
        ? ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: color,
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            onPressed: onTap,
            icon: Icon(icon, size: 17),
            label: Text(label, style: const TextStyle(fontSize: 13)))
        : OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
                foregroundColor: color,
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                side: BorderSide(color: color.withValues(alpha: 0.5)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            onPressed: onTap,
            icon: Icon(icon, size: 17),
            label: Text(label, style: const TextStyle(fontSize: 13)));
  }
}

