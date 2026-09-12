import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SubscriptionTier { free, gold, platinum }

extension SubscriptionTierX on SubscriptionTier {
  String get label {
    switch (this) {
      case SubscriptionTier.free:
        return 'مجاني';
      case SubscriptionTier.gold:
        return 'ذهبي';
      case SubscriptionTier.platinum:
        return 'بلاتيني';
    }
  }

  String get arabicLabel {
    switch (this) {
      case SubscriptionTier.free:
        return 'مجاني';
      case SubscriptionTier.gold:
        return 'SmartGold ✨';
      case SubscriptionTier.platinum:
        return 'SmartPlatinum 💎';
    }
  }

  double get monthlyPrice {
    switch (this) {
      case SubscriptionTier.free:
        return 0;
      case SubscriptionTier.gold:
        return 9.99;
      case SubscriptionTier.platinum:
        return 19.99;
    }
  }

  List<String> get benefits {
    switch (this) {
      case SubscriptionTier.free:
        return ['خدمة عادية', 'دعم أساسي'];
      case SubscriptionTier.gold:
        return [
          'خصم 10% دائم على الحجوزات',
          'أولوية في النتائج',
          'إلغاء مجاني قبل 24 ساعة',
          'دعم أولوية',
        ];
      case SubscriptionTier.platinum:
        return [
          'خصم 15% دائم على الحجوزات',
          'أولوية قصوى في النتائج',
          'إلغاء مجاني في أي وقت',
          'دعم مباشر 24/7',
          'عاملة بديلة مجانية',
          'ہدیہ على حجوزاتك',
        ];
    }
  }
}

class SubscriptionState {
  final SubscriptionTier tier;
  final DateTime? expiresAt;

  const SubscriptionState({
    this.tier = SubscriptionTier.free,
    this.expiresAt,
  });

  SubscriptionState copyWith({
    SubscriptionTier? tier,
    DateTime? expiresAt,
  }) =>
      SubscriptionState(
        tier: tier ?? this.tier,
        expiresAt: expiresAt ?? this.expiresAt,
      );

  bool get isActive =>
      tier != SubscriptionTier.free &&
      expiresAt != null &&
      expiresAt!.isAfter(DateTime.now());
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier() : super(const SubscriptionState()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final saved = sp.getString('sm.subscription.tier');
      if (saved != null) {
        final tier = SubscriptionTier.values.firstWhere(
          (t) => t.name == saved,
          orElse: () => SubscriptionTier.free,
        );
        final expStr = sp.getString('sm.subscription.expires');
        final expires = expStr != null ? DateTime.tryParse(expStr) : null;
        state = SubscriptionState(tier: tier, expiresAt: expires);
      }
    } catch (_) {}
  }

  Future<void> subscribe(SubscriptionTier tier) async {
    state = SubscriptionState(
      tier: tier,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('sm.subscription.tier', tier.name);
      await sp.setString(
          'sm.subscription.expires', state.expiresAt!.toIso8601String());
    } catch (_) {}
  }

  Future<void> cancel() async {
    state = const SubscriptionState();
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('sm.subscription.tier', 'free');
      await sp.remove('sm.subscription.expires');
    } catch (_) {}
  }

  /// منح اشتراك من الإدارة بعدد أيام محدد.
  Future<void> adminGrant(SubscriptionTier tier, int days) async {
    final expires = DateTime.now().add(Duration(days: days));
    state = SubscriptionState(tier: tier, expiresAt: expires);
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('sm.subscription.tier', tier.name);
      await sp.setString('sm.subscription.expires', expires.toIso8601String());
    } catch (_) {}
  }

  /// إلغاء من الإدارة.
  Future<void> adminRevoke() => cancel();

  /// تمديد مدة الاشتراك الحالي بأيام إضافية.
  Future<void> adminExtend(int extraDays) async {
    final current = state.expiresAt ?? DateTime.now();
    final newExpiry = current.add(Duration(days: extraDays));
    state = state.copyWith(expiresAt: newExpiry);
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('sm.subscription.expires', newExpiry.toIso8601String());
    } catch (_) {}
  }

  /// تغيير الطبقة مع الحفاظ على تاريخ الانتهاء.
  Future<void> adminChangeTier(SubscriptionTier newTier) async {
    state = state.copyWith(tier: newTier);
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('sm.subscription.tier', newTier.name);
    } catch (_) {}
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>(
  (ref) => SubscriptionNotifier(),
);
