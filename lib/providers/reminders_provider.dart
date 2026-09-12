import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models.dart';

class Reminder {
  final String bookingId;
  final DateTime fireAt;

  const Reminder({required this.bookingId, required this.fireAt});
}

class RemindersNotifier extends StateNotifier<List<Reminder>> {
  RemindersNotifier() : super(const []);

  static const _kReminded = 'sm.reminders.done';

  Future<void> scanUpcoming(List<BookingModel> bookings) async {
    final done = await _loadDone();
    final now = DateTime.now();
    var changed = false;

    for (final b in bookings) {
      if (done.contains(b.id)) continue;
      if (b.status != BookingStatus.confirmed &&
          b.status != BookingStatus.pending) {
        continue;
      }
      final diff = b.date.difference(now);

      if (diff.inMinutes <= 60 && diff.inMinutes > -30) {
        _fireNotification(b.id, b.workerName, b.timeSlot);
        done.add(b.id);
        changed = true;
        state = state
            .where((r) => r.bookingId != b.id)
            .toList();
      } else if (diff.inMinutes > 60 && diff.inHours <= 24) {
        final queued = state.any((r) => r.bookingId == b.id);
        if (!queued) {
          state = [
            ...state,
            Reminder(
              bookingId: b.id,
              fireAt: b.date.subtract(const Duration(hours: 1)),
            ),
          ];
        }
      }
    }

    for (final r in List<Reminder>.from(state)) {
      if (DateTime.now().isAfter(r.fireAt)) {
        final target = bookings
            .where((b) => b.id == r.bookingId)
            .firstOrNull;
        _fireNotification(
          r.bookingId,
          target?.workerName ?? 'العاملة',
          target?.timeSlot ?? '',
        );
        done.add(r.bookingId);
        state = state.where((x) => x.bookingId != r.bookingId).toList();
        changed = true;
      }
    }

    if (changed) await _saveDone(done);
  }

  void _fireNotification(String bookingId, String workerName, String slot) {
    NotificationsBus.add(
      title: 'تذكير بموعدك ⏰',
      icon: '⏰',
      body: 'حجزك مع $workerName بعد أقل من ساعة ($slot). جهّز المنزل!',
    );
  }

  Future<Set<String>> _loadDone() async {
    try {
      final sp = await SharedPreferences.getInstance();
      return (sp.getStringList(_kReminded) ?? []).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveDone(Set<String> set) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setStringList(_kReminded, set.toList());
    } catch (_) {}
  }
}

/// Decouples reminders from the notifications notifier instance.
class NotificationsBus {
  NotificationsBus._();

  static final List<({String title, String body, String icon})> _pending = [];
  static ValueSink? sink;

  static void add({
    required String title,
    required String body,
    required String icon,
  }) {
    _pending.add((title: title, body: body, icon: icon));
    sink?.call(title, body, icon);
  }

  static List<({String title, String body, String icon})> drain() {
    final list = List.of(_pending);
    _pending.clear();
    return list;
  }
}

typedef ValueSink = void Function(String title, String body, String icon);

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, List<Reminder>>(
      (ref) => RemindersNotifier(),
    );
