import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models.dart';

class CompensationNotifier extends StateNotifier<List<CompensationModel>> {
  CompensationNotifier() : super([
    CompensationModel(
      id: 'cp1', userId: 'u1', userName: 'أحمد محمد',
      type: CompensationType.walletCredit, amount: 25,
      reason: 'تأخير العاملة عن الموعد المحدد',
      issuedBy: 'st1', issuedByName: 'مدير النظام',
      issuedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    CompensationModel(
      id: 'cp2', userId: 'u6', userName: 'سارة القحطاني',
      type: CompensationType.subscriptionDays, subscriptionDays: 7,
      reason: 'مشكلة تقنية في التطبيق',
      issuedBy: 'st1', issuedByName: 'مدير النظام',
      issuedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ]);

  void issue(CompensationModel c) => state = [c, ...state];

  List<CompensationModel> forUser(String userId) =>
      state.where((c) => c.userId == userId).toList();
}

final compensationProvider =
    StateNotifierProvider<CompensationNotifier, List<CompensationModel>>(
  (ref) => CompensationNotifier(),
);
