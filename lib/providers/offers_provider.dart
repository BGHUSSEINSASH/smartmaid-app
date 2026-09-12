import 'package:flutter_riverpod/flutter_riverpod.dart';

class CouponModel {
  final String code;
  final String title;
  final String description;
  final double discountPercent;
  final double minTotalUsd;
  final String emoji;

  const CouponModel({
    required this.code,
    required this.title,
    required this.description,
    required this.discountPercent,
    this.minTotalUsd = 0,
    this.emoji = '🎁',
  });

  double discountFor(double total) =>
      total >= minTotalUsd ? total * discountPercent / 100 : 0;
}

const kDemoCoupons = <CouponModel>[
  CouponModel(
    code: 'SMART50',
    title: 'خصم النصف',
    description: 'خصم 50% على أول حجز لك مع Smart Maid',
    discountPercent: 50,
    minTotalUsd: 50,
    emoji: '🎉',
  ),
  CouponModel(
    code: 'SAVE15',
    title: 'وفّر 15%',
    description: 'خصم 15% على أي حجز يومي أو أسبوعي',
    discountPercent: 15,
    minTotalUsd: 30,
    emoji: '💰',
  ),
  CouponModel(
    code: 'MONTHLY10',
    title: 'باقة الشهر',
    description: 'خصم إضافي 10% على الحجوزات الشهرية والسنوية',
    discountPercent: 10,
    minTotalUsd: 200,
    emoji: '📅',
  ),
];

class AppliedCoupon {
  final CouponModel coupon;
  final double savedUsd;

  const AppliedCoupon({required this.coupon, required this.savedUsd});
}

class CouponNotifier extends StateNotifier<CouponModel?> {
  CouponNotifier() : super(null);

  void clear() => state = null;

  ({bool ok, String message}) apply(String rawCode, double total) {
    final code = rawCode.trim().toUpperCase();
    final match = kDemoCoupons.where((c) => c.code == code).toList();
    if (match.isEmpty) {
      return (ok: false, message: 'كود الخصم غير صحيح');
    }
    final coupon = match.first;
    if (total < coupon.minTotalUsd) {
      return (
        ok: false,
        message: 'الحد الأدنى لهذا الكود \$${coupon.minTotalUsd.toStringAsFixed(0)}',
      );
    }
    state = coupon;
    return (ok: true, message: 'تم تطبيق خصم ${coupon.discountPercent.toStringAsFixed(0)}%');
  }
}

final couponProvider = StateNotifierProvider<CouponNotifier, CouponModel?>(
  (ref) => CouponNotifier(),
);

double discountedTotal(double subtotal, CouponModel? coupon) =>
    coupon == null ? subtotal : (subtotal - coupon.discountFor(subtotal)).clamp(0, double.infinity);

double couponDiscountFor(double subtotal, {CouponModel? coupon}) =>
    coupon?.discountFor(subtotal) ?? 0;

final usedCouponFlagProvider = StateProvider<bool>((ref) => false);
