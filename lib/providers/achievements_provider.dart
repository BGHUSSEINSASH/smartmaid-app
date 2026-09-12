import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'address_provider.dart';
import 'booking_provider.dart';
import 'favorites_provider.dart';
import 'loyalty_provider.dart';
import 'offers_provider.dart';
import 'review_provider.dart';

class Achievement {
  final String id;
  final String emoji;
  final String title;
  final String description;

  const Achievement({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
  });
}

class AchievementsState {
  final List<Achievement> unlocked;
  final List<Achievement> locked;

  const AchievementsState({
    required this.unlocked,
    required this.locked,
  });

  int get total => unlocked.length + locked.length;
}

final achievementsProvider = Provider<AchievementsState>((ref) {
  final bookings = ref.watch(myBookingsProvider);
  final completed =
      bookings.where((b) => b.status.name == 'completed').length;
  final hasReview = ref.watch(reviewsCountProvider) > 0;
  final usedCoupon = ref.watch(couponProvider) != null ||
      ref.watch(usedCouponFlagProvider);
  final points = ref.watch(loyaltyProvider).points;
  final favCount = ref.watch(favoritesProvider).length;
  final addresses = ref.watch(addressProvider).length;

  final all = <(String, String, String, String, bool)>[
    (
      'first_booking',
      '🥇',
      'البداية',
      'أكملت أول حجز لك',
      bookings.isNotEmpty
    ),
    ('three_bookings', '🔥', 'منظم', '3 حجوزات مكتملة', completed >= 3),
    ('reviewer', '⭐', 'صوت مؤثر', 'قيّمت خدمة واحدة على الأقل', hasReview),
    ('saver', '💰', 'موفر', 'استخدمت كوبون خصم', usedCoupon),
    ('collector', '❤️', 'ذوذوق', 'أضفت عاملة للمفضلة', favCount > 0),
    (
      'loyal',
      '🏆',
      'وفّي',
      'وصلت لمستوى فضي أو أعلى',
      points >= 500
    ),
    ('planner', '📍', 'مخطط', 'حفظت عنواناً واحداً', addresses > 0),
  ];

  return AchievementsState(
    unlocked: [
      for (final a in all)
        if (a.$5)
          Achievement(
              id: a.$1,
              emoji: a.$2,
              title: a.$3,
              description: a.$4),
    ],
    locked: [
      for (final a in all)
        if (!a.$5)
          Achievement(
              id: a.$1,
              emoji: a.$2,
              title: a.$3,
              description: a.$4),
    ],
  );
});
