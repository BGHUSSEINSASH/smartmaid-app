import 'package:intl/intl.dart';

String timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'الآن';
  if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
  if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
  if (diff.inDays == 1) return 'أمس';
  if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
  return DateFormat('d MMM', 'ar').format(dt);
}

String daySeparatorLabel(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final that = DateTime(dt.year, dt.month, dt.day);
  if (that == today) return 'اليوم';
  if (that == today.subtract(const Duration(days: 1))) return 'أمس';
  return DateFormat('EEEE، d MMMM', 'ar').format(dt);
}
