import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models.dart';

class StaffNotifier extends StateNotifier<List<StaffMember>> {
  StaffNotifier() : super([
    StaffMember(
      id: 'st1', name: 'مدير النظام', email: 'admin@demo.com',
      role: StaffRole.superAdmin,
      permissions: StaffPermission.values,
      isActive: true, lastLogin: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    StaffMember(
      id: 'st2', name: 'سارة العمري', email: 'sara.support@smartmaid.com',
      role: StaffRole.supportAgent,
      permissions: StaffRole.supportAgent.defaultPermissions,
      isActive: true,
    ),
    StaffMember(
      id: 'st3', name: 'محمد الأحمدي', email: 'finance@smartmaid.com',
      role: StaffRole.financeOfficer,
      permissions: StaffRole.financeOfficer.defaultPermissions,
      isActive: true,
    ),
    StaffMember(
      id: 'st4', name: 'نورة المطيري', email: 'workers@smartmaid.com',
      role: StaffRole.workerManager,
      permissions: StaffRole.workerManager.defaultPermissions,
      isActive: true,
    ),
  ]);

  void add(StaffMember member) => state = [member, ...state];
  void remove(String id) => state = state.where((s) => s.id != id).toList();
  void toggleActive(String id) => state = state
      .map((s) => s.id == id ? s.copyWith(isActive: !s.isActive) : s)
      .toList();
  void updatePermissions(String id, List<StaffPermission> perms) => state = state
      .map((s) => s.id == id ? s.copyWith(permissions: perms) : s)
      .toList();
  void update(StaffMember updated) => state =
      state.map((s) => s.id == updated.id ? updated : s).toList();
}

final staffProvider =
    StateNotifierProvider<StaffNotifier, List<StaffMember>>(
  (ref) => StaffNotifier(),
);
