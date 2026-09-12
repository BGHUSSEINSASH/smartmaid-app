import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/models.dart';
import '../providers/admin_providers.dart';
import '../widgets/pro_components.dart';

class AdminKycReviewScreen extends ConsumerWidget {
  const AdminKycReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersManagementProvider);
    final pending = users
        .where((u) => u.workerInfo?.kycStatus == KycStatus.pending)
        .toList();
    final approved = users
        .where((u) => u.workerInfo?.kycStatus == KycStatus.approved)
        .toList();
    final rejected = users
        .where((u) => u.workerInfo?.kycStatus == KycStatus.rejected)
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مراجعة KYC — العاملات'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'معلّق (${pending.length})'),
              Tab(text: 'مقبول (${approved.length})'),
              Tab(text: 'مرفوض (${rejected.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _KycList(users: pending, status: KycStatus.pending),
            _KycList(users: approved, status: KycStatus.approved),
            _KycList(users: rejected, status: KycStatus.rejected),
          ],
        ),
      ),
    );
  }
}

class _KycList extends ConsumerWidget {
  final List<AppUser> users;
  final KycStatus status;
  const _KycList({required this.users, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (users.isEmpty) {
      return Center(child: EmptyState(
        icon: Icons.verified_user_rounded,
        title: 'لا توجد طلبات ${status == KycStatus.pending ? 'معلّقة' : status == KycStatus.approved ? 'مقبولة' : 'مرفوضة'}',
        subtitle: '',
      ));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) => _KycCard(user: users[i]),
    );
  }
}

class _KycCard extends ConsumerWidget {
  final AppUser user;
  const _KycCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wi = user.workerInfo;
    final status = wi?.kycStatus ?? KycStatus.none;
    Color statusColor = switch (status) {
      KycStatus.pending => AppColors.warning,
      KycStatus.approved => AppColors.success,
      KycStatus.rejected => AppColors.error,
      _ => AppColors.muted,
    };
    String statusLabel = switch (status) {
      KycStatus.pending => 'معلّق',
      KycStatus.approved => 'مقبول',
      KycStatus.rejected => 'مرفوض',
      _ => 'غير محدد',
    };

    return ProCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 24,
              backgroundImage: NetworkImage(user.imageUrl),
              backgroundColor: AppColors.stroke),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(user.email,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              if (wi?.skills.isNotEmpty == true)
                Text('المهارات: ${wi!.skills.join(', ')}',
                    style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Text(statusLabel,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                    color: statusColor)),
          ),
        ]),
        if (status == KycStatus.pending) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () {
                ref.read(usersManagementProvider.notifier).rejectKyc(user.id);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('تم رفض الطلب'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating));
              },
              icon: const Icon(Icons.close_rounded, size: 16,
                  color: AppColors.error),
              label: const Text('رفض',
                  style: TextStyle(color: AppColors.error)),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(
              onPressed: () {
                ref.read(usersManagementProvider.notifier).approveKyc(user.id);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('تم قبول الطلب'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating));
              },
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text('قبول'),
            )),
          ]),
        ],
      ]),
    );
  }
}
