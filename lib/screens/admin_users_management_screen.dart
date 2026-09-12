import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/models.dart';
import '../providers/admin_providers.dart';
import '../widgets/pro_components.dart';

class AdminUsersManagementScreen extends ConsumerStatefulWidget {
  const AdminUsersManagementScreen({super.key});
  @override
  ConsumerState<AdminUsersManagementScreen> createState() =>
      _AdminUsersManagementState();
}

class _AdminUsersManagementState
    extends ConsumerState<AdminUsersManagementScreen> {
  String _search = '';
  AppRole? _filterRole;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(usersManagementProvider);
    final filtered = all.where((u) {
      final matchSearch = _search.isEmpty ||
          u.name.contains(_search) ||
          u.email.contains(_search);
      final matchRole = _filterRole == null || u.role == _filterRole;
      return matchSearch && matchRole;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المستخدمين')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: [
            Expanded(child: TextField(
              decoration: const InputDecoration(
                  hintText: 'بحث بالاسم أو البريد...',
                  prefixIcon: Icon(Icons.search_rounded, size: 20),
                  contentPadding: EdgeInsets.symmetric(vertical: 10)),
              onChanged: (v) => setState(() => _search = v),
            )),
            const SizedBox(width: 10),
            DropdownButton<AppRole?>(
              value: _filterRole,
              hint: const Text('الكل'),
              items: [
                const DropdownMenuItem(value: null, child: Text('الكل')),
                ...AppRole.values.map((r) =>
                    DropdownMenuItem(value: r, child: Text(r.arabicLabel))),
              ],
              onChanged: (v) => setState(() => _filterRole = v),
            ),
          ]),
        ),
        Expanded(child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) => _UserTile(user: filtered[i]),
        )),
      ]),
    );
  }
}

class _UserTile extends ConsumerWidget {
  final AppUser user;
  const _UserTile({required this.user});

  Color get _statusColor => switch (user.accountStatus) {
    AccountStatus.active => AppColors.success,
    AccountStatus.suspended => AppColors.warning,
    AccountStatus.deleted => AppColors.error,
  };

  String get _statusLabel => switch (user.accountStatus) {
    AccountStatus.active => 'نشط',
    AccountStatus.suspended => 'معلّق',
    AccountStatus.deleted => 'محذوف',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProCard(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Stack(children: [
          CircleAvatar(radius: 22,
              backgroundImage: NetworkImage(user.imageUrl),
              backgroundColor: AppColors.stroke),
          if (user.isVerified)
            Positioned(bottom: 0, right: 0, child: Container(
              width: 14, height: 14,
              decoration: const BoxDecoration(
                  color: AppColors.success, shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                      BorderSide(color: Colors.white, width: 1.5))),
              child: const Icon(Icons.check, size: 9, color: Colors.white),
            )),
        ]),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.name,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            Text(user.email,
                style: const TextStyle(color: AppColors.muted, fontSize: 11)),
            Row(children: [
              _RoleBadge(user.role.arabicLabel),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(_statusLabel,
                    style: TextStyle(fontSize: 10, color: _statusColor,
                        fontWeight: FontWeight.w700)),
              ),
            ]),
          ])),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (action) {
            final nm = ref.read(usersManagementProvider.notifier);
            switch (action) {
              case 'suspend':
                nm.suspend(user.id);
                break;
              case 'activate':
                nm.activate(user.id);
                break;
              case 'delete':
                showDialog(context: context, builder: (_) => AlertDialog(
                  title: const Text('حذف الحساب؟'),
                  content: Text('هل تريد حذف حساب "${user.name}"؟'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error),
                      onPressed: () { nm.delete(user.id); Navigator.pop(context); },
                      child: const Text('حذف'),
                    ),
                  ],
                ));
                break;
            }
          },
          itemBuilder: (_) => [
            if (user.accountStatus == AccountStatus.active)
              const PopupMenuItem(value: 'suspend',
                  child: ListTile(leading: Icon(Icons.pause_circle_rounded,
                      color: AppColors.warning),
                      title: Text('تعليق الحساب'), dense: true)),
            if (user.accountStatus == AccountStatus.suspended)
              const PopupMenuItem(value: 'activate',
                  child: ListTile(leading: Icon(Icons.play_circle_rounded,
                      color: AppColors.success),
                      title: Text('تفعيل الحساب'), dense: true)),
            const PopupMenuItem(value: 'delete',
                child: ListTile(leading: Icon(Icons.delete_forever_rounded,
                    color: AppColors.error),
                    title: Text('حذف الحساب'), dense: true)),
          ],
        ),
      ]),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String label;
  const _RoleBadge(this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6)),
    child: Text(label,
        style: const TextStyle(fontSize: 10, color: AppColors.primary,
            fontWeight: FontWeight.w700)),
  );
}
