import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/models.dart';
import '../providers/staff_provider.dart';
import '../widgets/pro_components.dart';

class AdminStaffScreen extends ConsumerStatefulWidget {
  const AdminStaffScreen({super.key});
  @override
  ConsumerState<AdminStaffScreen> createState() => _AdminStaffState();
}

class _AdminStaffState extends ConsumerState<AdminStaffScreen> {
  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(staffProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('فريق الإدارة')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('إضافة موظف'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: staff.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) => _StaffTile(member: staff[i]),
      ),
    );
  }

  void _showAddSheet() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    StaffRole role = StaffRole.supportAgent;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (ctx, setSt) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('إضافة موظف جديد', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person_rounded))),
          const SizedBox(height: 10),
          TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.alternate_email_rounded))),
          const SizedBox(height: 10),
          DropdownButtonFormField<StaffRole>(
            value: role,
            decoration: const InputDecoration(labelText: 'الدور الوظيفي'),
            items: StaffRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.arabicLabel))).toList(),
            onChanged: (v) => setSt(() => role = v!),
          ),
          const SizedBox(height: 14),
          SizedBox(height: 52, width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('إضافة الموظف'),
              onPressed: () {
                if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) return;
                ref.read(staffProvider.notifier).add(StaffMember(
                  id: 'st_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  role: role,
                  permissions: role.defaultPermissions,
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة الموظف'), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.success));
              },
            ),
          ),
        ]),
      )),
    );
  }
}

class _StaffTile extends ConsumerWidget {
  final StaffMember member;
  const _StaffTile({required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 22, backgroundColor: AppColors.primary.withValues(alpha: .12), child: Text(member.name.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(member.name, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(member.email, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .1), borderRadius: BorderRadius.circular(99)),
              child: Text(member.role.arabicLabel, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w800)),
            ),
          ])),
          Switch.adaptive(
            value: member.isActive,
            onChanged: (_) => ref.read(staffProvider.notifier).toggleActive(member.id),
          ),
        ]),
        const SizedBox(height: 10),
        const Text('الصلاحيات:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 4, children: [
          ...member.permissions.map((p) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.stroke, borderRadius: BorderRadius.circular(8)),
            child: Text(_permLabel(p), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
          )),
          InkWell(
            onTap: () => _showPermissionsSheet(context, ref),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
              child: const Text('تعديل ✎', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ]),
    );
  }

  String _permLabel(StaffPermission p) => switch (p) {
    StaffPermission.manageUsers => 'إدارة المستخدمين',
    StaffPermission.suspendUsers => 'تعليق حسابات',
    StaffPermission.deleteUsers => 'حذف حسابات',
    StaffPermission.viewUserDetails => 'عرض التفاصيل',
    StaffPermission.manageCompanies => 'إدارة الشركات',
    StaffPermission.approveCompanies => 'قبول الشركات',
    StaffPermission.createCompany => 'إنشاء شركة',
    StaffPermission.manageWorkers => 'إدارة العاملات',
    StaffPermission.approveKyc => 'قبول KYC',
    StaffPermission.controlWorkerSection => 'تحكم قسم العاملات',
    StaffPermission.manageFinance => 'المالية',
    StaffPermission.processWithdrawals => 'السحوبات',
    StaffPermission.issueCompensations => 'التعويضات',
    StaffPermission.manageCommissions => 'العمولات',
    StaffPermission.manageSubscriptions => 'الاشتراكات',
    StaffPermission.grantProAccess => 'منح Pro',
    StaffPermission.revokeSubscriptions => 'إلغاء اشتراكات',
    StaffPermission.manageDiscounts => 'الخصومات',
    StaffPermission.respondToChats => 'الردود',
    StaffPermission.sendBroadcast => 'إشعارات جماعية',
    StaffPermission.changeSystemSettings => 'إعدادات النظام',
    StaffPermission.viewAuditLog => 'سجل التدقيق',
    StaffPermission.managePlatformFlags => 'تحكم المنصة',
  };

  void _showPermissionsSheet(BuildContext context, WidgetRef ref) {
    final current = List<StaffPermission>.from(member.permissions);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (ctx, setSt) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('صلاحيات ${member.name}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          ...StaffPermission.values.map((p) => CheckboxListTile(
            title: Text(_permLabel(p)),
            value: current.contains(p),
            onChanged: (v) => setSt(() => v! ? current.add(p) : current.remove(p)),
            controlAffinity: ListTileControlAffinity.leading,
          )),
          const SizedBox(height: 10),
          SizedBox(height: 52, width: double.infinity,
            child: ElevatedButton(
              onPressed: () { ref.read(staffProvider.notifier).updatePermissions(member.id, current); Navigator.pop(ctx); },
              child: const Text('حفظ الصلاحيات'),
            ),
          ),
        ]),
      )),
    );
  }
}
