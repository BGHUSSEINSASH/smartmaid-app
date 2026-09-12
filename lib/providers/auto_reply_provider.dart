import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models.dart';

class AutoReplyNotifier extends StateNotifier<List<AutoReplyRule>> {
  AutoReplyNotifier() : super(const [
    AutoReplyRule(id: 'ar1', keyword: 'كيف أحجز', priority: 10,
        response: 'للحجز: اذهب لتبويب "الخدمات"، اختر عاملة، ثم اضغط "احجز الآن". يمكنك الاختيار بين الساعة واليوم والشهر. 😊'),
    AutoReplyRule(id: 'ar2', keyword: 'الأسعار', priority: 9,
        response: 'تبدأ أسعارنا من \$25/ساعة للعاملات المستقلات. يمكنك مقارنة الأسعار مباشرة في قائمة العاملات. 💳'),
    AutoReplyRule(id: 'ar3', keyword: 'إلغاء', priority: 8,
        response: 'يمكنك إلغاء الحجز من "حجوزاتي" → اختر الحجز → "إلغاء". لاحظ أن الإلغاء المجاني متاح قبل 24 ساعة من الموعد.'),
    AutoReplyRule(id: 'ar4', keyword: 'استرداد', priority: 8,
        response: 'طلبات الاسترداد تُعالَج خلال 3-5 أيام عمل. يمكنك تقديم طلب استرداد من صفحة تفاصيل الحجز. 🔄'),
    AutoReplyRule(id: 'ar5', keyword: 'شكراً', priority: 5,
        response: 'شكراً لك! هل يمكنني مساعدتك بشيء آخر؟ 🌟'),
  ]);

  /// يبحث عن رد تلقائي مناسب للرسالة والدور.
  String? getAutoReply(String message, AppRole? userRole) {
    final msgLower = message.trim().toLowerCase();
    final sorted = state
        .where((r) => r.isActive)
        .where((r) => r.targetRoles.isEmpty || (userRole != null && r.targetRoles.contains(userRole)))
        .toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
    for (final rule in sorted) {
      if (msgLower.contains(rule.keyword.toLowerCase())) return rule.response;
    }
    return null;
  }

  void add(AutoReplyRule rule) => state = [rule, ...state];
  void remove(String id) => state = state.where((r) => r.id != id).toList();
  void toggle(String id) => state = state
      .map((r) => r.id == id ? r.copyWith(isActive: !r.isActive) : r)
      .toList();
  void update(AutoReplyRule updated) => state =
      state.map((r) => r.id == updated.id ? updated : r).toList();
}

final autoReplyProvider =
    StateNotifierProvider<AutoReplyNotifier, List<AutoReplyRule>>(
  (ref) => AutoReplyNotifier(),
);
