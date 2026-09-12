import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/local_store.dart';
import '../data/models.dart';
import '../data/demo_data.dart';
import 'offers_provider.dart';
import 'loyalty_provider.dart';
import 'notifications_provider.dart';

class BookingFlowState {
  final WorkerModel? worker;
  final DateTime? date;
  final String? timeSlot;
  final bool isPaid;
  final BookingType bookingType;
  final List<String> selectedExtras;
  final String? paymentIntentId;
  final String? bookingId;
  final String bookingStatus;
  final String paymentStatus;
  final String notes;
  final bool expressFee;
  final bool needTools;

  const BookingFlowState({
    this.worker,
    this.date,
    this.timeSlot,
    this.isPaid = false,
    this.bookingType = BookingType.daily,
    this.selectedExtras = const [],
    this.paymentIntentId,
    this.bookingId,
    this.bookingStatus = 'draft',
    this.paymentStatus = 'pending',
    this.notes = '',
    this.expressFee = false,
    this.needTools = false,
  });

  BookingFlowState copyWith({
    WorkerModel? worker,
    DateTime? date,
    String? timeSlot,
    bool? isPaid,
    BookingType? bookingType,
    List<String>? selectedExtras,
    String? paymentIntentId,
    String? bookingId,
    String? bookingStatus,
    String? paymentStatus,
    String? notes,
    bool? expressFee,
    bool? needTools,
  }) {
    return BookingFlowState(
      worker: worker ?? this.worker,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      isPaid: isPaid ?? this.isPaid,
      bookingType: bookingType ?? this.bookingType,
      selectedExtras: selectedExtras ?? this.selectedExtras,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      bookingId: bookingId ?? this.bookingId,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      expressFee: expressFee ?? this.expressFee,
      needTools: needTools ?? this.needTools,
    );
  }

  bool get hasBooking => bookingId != null || worker != null;

  double get baseTotal {
    final h = worker?.hourlyRate ?? 0;
    switch (bookingType) {
      case BookingType.daily:
        return h * 8;
      case BookingType.weekly:
        return h * 8 * 5 * 0.9;
      case BookingType.monthly:
        return h * 8 * 22 * 0.8;
      case BookingType.annual:
        return h * 8 * 22 * 11 * 0.7;
    }
  }

  double get extrasTotal => DemoData.extraServices
      .where((e) => selectedExtras.contains(e.id))
      .fold(0.0, (sum, e) => sum + e.priceUsd);

  static const double _expressFee = 5.0;
  static const double _toolsFee = 10.0;

  double get expressFeeTotal => expressFee ? _expressFee : 0.0;
  double get toolsFeeTotal => needTools ? _toolsFee : 0.0;

  double get total => baseTotal + extrasTotal + expressFeeTotal + toolsFeeTotal;

  String get bookingTypeLabel {
    switch (bookingType) {
      case BookingType.daily:
        return 'يومي';
      case BookingType.weekly:
        return 'أسبوعي';
      case BookingType.monthly:
        return 'شهري';
      case BookingType.annual:
        return 'سنوي';
    }
  }
}

class BookingFlowNotifier extends StateNotifier<BookingFlowState> {
  BookingFlowNotifier() : super(const BookingFlowState());

  void selectWorker(WorkerModel w) => state = state.copyWith(worker: w);
  void selectDate(DateTime d) => state = state.copyWith(date: d);
  void selectTimeSlot(String t) => state = state.copyWith(timeSlot: t);
  void setBookingType(BookingType t) => state = state.copyWith(bookingType: t);
  void setNotes(String n) => state = state.copyWith(notes: n);
  void toggleExpressFee() => state = state.copyWith(expressFee: !state.expressFee);
  void toggleNeedTools() => state = state.copyWith(needTools: !state.needTools);
  void toggleExtra(String id) {
    final list = List<String>.from(state.selectedExtras);
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    state = state.copyWith(selectedExtras: list);
  }

  void pay() => state = state.copyWith(isPaid: true);
  void setPaymentIntent(String id) =>
      state = state.copyWith(paymentIntentId: id, paymentStatus: 'pending');

  void setFromBooking(Map<String, dynamic> booking) {
    final id = booking['id']?.toString();
    final status = booking['status']?.toString() ?? state.bookingStatus;
    final payment = booking['paymentStatus']?.toString() ?? state.paymentStatus;
    state = state.copyWith(
      bookingId: id ?? state.bookingId,
      bookingStatus: status,
      paymentStatus: payment,
    );
  }

  void setStatus({
    required String bookingStatus,
    required String paymentStatus,
  }) {
    state = state.copyWith(
      bookingStatus: bookingStatus,
      paymentStatus: paymentStatus,
    );
  }

  void reset() => state = const BookingFlowState();
}

final bookingFlowProvider =
    StateNotifierProvider<BookingFlowNotifier, BookingFlowState>(
      (ref) => BookingFlowNotifier(),
    );

class MyBookingsNotifier extends StateNotifier<List<BookingModel>> {
  MyBookingsNotifier() : super(LocalStore.bookingsCache ?? DemoData.bookings);

  void add(BookingModel b) {
    state = [b, ...state];
    LocalStore.persistBookings(state);
  }

  void cancelBooking(String id) => _setStatus(id, BookingStatus.cancelled);

  void completeBooking(String id) => _setStatus(id, BookingStatus.completed);

  void confirmBooking(String id) => _setStatus(id, BookingStatus.confirmed);

  void startBooking(String id) => _setStatus(id, BookingStatus.inProgress);

  void markPaid(String id) {
    state = state
        .map((b) =>
            b.id == id ? b.copyWith(paymentStatus: PaymentStatus.paid) : b)
        .toList();
    LocalStore.persistBookings(state);
  }

  void updateBooking(BookingModel updated) {
    state = state.map((b) => b.id == updated.id ? updated : b).toList();
    LocalStore.persistBookings(state);
  }

  void _setStatus(String id, BookingStatus s) {
    state = state
        .map((b) => b.id == id ? b.copyWith(status: s) : b)
        .toList();
    LocalStore.persistBookings(state);
  }
}

final myBookingsProvider =
    StateNotifierProvider<MyBookingsNotifier, List<BookingModel>>(
      (ref) => MyBookingsNotifier(),
    );

class BookingTotals {
  final double subtotal;
  final double discount;
  final double total;
  const BookingTotals({
    required this.subtotal,
    required this.discount,
    required this.total,
  });
}

final bookingTotalsProvider = Provider<BookingTotals>((ref) {
  final flow = ref.watch(bookingFlowProvider);
  final coupon = ref.watch(couponProvider);
  final subtotal = flow.total;
  final discount = coupon?.discountFor(subtotal) ?? 0;
  return BookingTotals(
    subtotal: subtotal,
    discount: discount,
    total: (subtotal - discount).clamp(0, double.infinity),
  );
});

typedef BookingResult = ({bool ok, String bookingId});

Future<BookingResult> confirmCurrentBooking(WidgetRef ref) async {
  final flow = ref.read(bookingFlowProvider);
  final totals = ref.read(bookingTotalsProvider);
  if (!flow.hasBooking || flow.date == null || flow.timeSlot == null) {
    return (ok: false, bookingId: '');
  }
  final id = 'b_${DateTime.now().millisecondsSinceEpoch}';
  final booking = BookingModel(
    id: id,
    workerId: flow.worker!.id,
    workerName: flow.worker!.name,
    workerImage: flow.worker!.imageUrl,
    userId: 'u1',
    date: flow.date!,
    timeSlot: flow.timeSlot!,
    service: flow.worker!.category,
    total: totals.total,
    status: BookingStatus.pending,
    paymentStatus: PaymentStatus.held,
    notes: flow.notes,
    expressFee: flow.expressFee,
    needTools: flow.needTools,
  );
  ref.read(myBookingsProvider.notifier).add(booking);
  ref.read(bookingFlowProvider.notifier).setFromBooking({
    'id': id,
    'status': 'pending',
    'paymentStatus': 'unpaid',
  });
  ref.read(notificationsProvider.notifier).addNotification(
        AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'تم إنشاء حجزك',
          icon: '📌',
          body:
              'حجزك مع ${flow.worker!.name} يوم ${booking.date.day}/${booking.date.month} الساعة ${flow.timeSlot}',
          time: DateTime.now(),
        ),
      );
  ref
      .read(loyaltyProvider.notifier)
      .earn(totals.total.round(), 'حجز ${flow.bookingTypeLabel}');
  return (ok: true, bookingId: id);
}
