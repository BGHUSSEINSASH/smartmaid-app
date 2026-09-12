import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String icon; // emoji
  final DateTime time;
  bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.icon,
    required this.time,
    this.read = false,
  });
}

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier()
    : super([
        AppNotification(
          id: 'n1',
          title: 'تم تأكيد حجزك',
          icon: '✅',
          body: 'حجزك مع روزا فيرنانديز غداً الساعة 10:00 صباحاً',
          time: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        AppNotification(
          id: 'n2',
          title: 'عرض خاص لك',
          icon: '🎁',
          body: 'احصل على خصم 15% على حجزك القادم باستخدام SAVE15',
          time: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        AppNotification(
          id: 'n3',
          title: 'تقييم خدمتك',
          icon: '⭐',
          body: 'كيف كانت تجربتك مع العاملة؟ شاركينا رأيك',
          time: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        AppNotification(
          id: 'n4',
          title: 'نقاط مكافأة',
          icon: '🏆',
          body: 'حصلتِ على 50 نقطة من آخر حجز. رصيدك الآن 120 نقطة',
          time: DateTime.now().subtract(const Duration(days: 1)),
        ),
        AppNotification(
          id: 'n5',
          title: 'عاملة جديدة متاحة',
          icon: '👩',
          body: 'سونيا ميندوزا أصبحت متاحة في منطقتك',
          time: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ]);

  void markAllRead() {
    state = state.map((n) => n..read = true).toList();
  }

  void markRead(String id) {
    state = state.map((n) => n..read = n.id == id ? true : n.read).toList();
  }

  void addNotification(AppNotification n) {
    state = [n, ...state];
  }

  int get unreadCount => state.where((n) => !n.read).length;
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>(
      (ref) => NotificationsNotifier(),
    );

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.read).length;
});
