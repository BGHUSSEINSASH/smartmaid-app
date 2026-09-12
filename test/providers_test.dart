import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_maid_app/data/models.dart';
import 'package:smart_maid_app/data/demo_data.dart';
import 'package:smart_maid_app/providers/booking_provider.dart';
import 'package:smart_maid_app/providers/favorites_provider.dart';
import 'package:smart_maid_app/providers/loyalty_provider.dart';
import 'package:smart_maid_app/providers/offers_provider.dart';
import 'package:smart_maid_app/providers/wallet_provider.dart';

ProviderContainer makeContainer() => ProviderContainer();

void main() {
  group('Booking pricing', () {
    test('daily = hourly × 8', () {
      final flow = BookingFlowState(
        worker: DemoData.workers.first,
        bookingType: BookingType.daily,
      );
      expect(flow.baseTotal, DemoData.workers.first.hourlyRate * 8);
    });

    test('weekly gets 10% discount', () {
      final w = DemoData.workers.first;
      final flow = BookingFlowState(worker: w, bookingType: BookingType.weekly);
      expect(flow.baseTotal, closeTo(w.hourlyRate * 40 * 0.9, 0.01));
    });

    test('monthly gets 20% discount', () {
      final w = DemoData.workers.first;
      final flow = BookingFlowState(worker: w, bookingType: BookingType.monthly);
      expect(flow.baseTotal, closeTo(w.hourlyRate * 176 * 0.8, 0.01));
    });

    test('annual gets 30% discount', () {
      final w = DemoData.workers.first;
      final flow = BookingFlowState(worker: w, bookingType: BookingType.annual);
      expect(
          flow.baseTotal, closeTo(w.hourlyRate * 176 * 11 * 0.7, 0.01));
    });

    test('extras add to total', () {
      var flow = const BookingFlowState();
      expect(flow.total, 0);
      flow = BookingFlowState(selectedExtras: ['deep', 'iron']);
      expect(flow.extrasTotal, 30);
    });
  });

  group('Coupons', () {
    test('applies valid coupon above minimum', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      final r =
          container.read(couponProvider.notifier).apply('SMART50', 200);
      expect(r.ok, isTrue);
      expect(container.read(couponProvider)!.code, 'SMART50');
      expect(discountedTotal(200, container.read(couponProvider)), 100);
    });

    test('rejects unknown code', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      final r = container.read(couponProvider.notifier).apply('NOPE', 500);
      expect(r.ok, isFalse);
    });

    test('rejects below minimum total', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      final r = container.read(couponProvider.notifier).apply('SMART50', 20);
      expect(r.ok, isFalse);
    });

    test('clear resets applied coupon', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      container.read(couponProvider.notifier).apply('SAVE15', 100);
      container.read(couponProvider.notifier).clear();
      expect(container.read(couponProvider), isNull);
    });
  });

  group('Loyalty tiers & redeem', () {
    test('tier thresholds', () {
      expect(const LoyaltyState(points: 100).tier, LoyaltyTier.bronze);
      expect(const LoyaltyState(points: 700).tier, LoyaltyTier.silver);
      expect(const LoyaltyState(points: 2000).tier, LoyaltyTier.gold);
    });

    test('earn applies tier multiplier', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      container.read(loyaltyProvider.notifier).earn(100, 'test');
      expect(container.read(loyaltyProvider).points, greaterThan(1250));
    });

    test('redeem fails when points insufficient', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(
        container.read(loyaltyProvider.notifier).redeem(9999),
        isFalse,
      );
    });

    test('redeem deducts cost', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      final before = container.read(loyaltyProvider).points;
      expect(container.read(loyaltyProvider.notifier).redeem(5), isTrue);
      expect(container.read(loyaltyProvider).points, before - 100);
    });
  });

  group('Wallet guards', () {
    test('topUp increases balance', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      final before = container.read(walletProvider).balanceUsd;
      container.read(walletProvider.notifier).topUp(50);
      expect(container.read(walletProvider).balanceUsd, before + 50);
    });

    test('pay rejects exceeding balance', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(
        container.read(walletProvider.notifier).pay(99999, 'x'),
        isFalse,
      );
    });

    test('withdraw reduces balance', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      final before = container.read(walletProvider).balanceUsd;
      expect(container.read(walletProvider.notifier).withdraw(30), isTrue);
      expect(container.read(walletProvider).balanceUsd, before - 30);
    });
  });

  group('Favorites', () {
    test('toggle adds and removes', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      container.read(favoritesProvider.notifier).toggle('w2');
      expect(container.read(favoritesProvider).contains('w2'), isTrue);
      container.read(favoritesProvider.notifier).toggle('w2');
      expect(container.read(favoritesProvider).contains('w2'), isFalse);
    });
  });

  group('My bookings mutations', () {
    test('cancel marks cancelled', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      final id = container.read(myBookingsProvider).first.id;
      container.read(myBookingsProvider.notifier).cancelBooking(id);
      expect(
        container
            .read(myBookingsProvider)
            .firstWhere((b) => b.id == id)
            .status,
        BookingStatus.cancelled,
      );
    });
  });
}
