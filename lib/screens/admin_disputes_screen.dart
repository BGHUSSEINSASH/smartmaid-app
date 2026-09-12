import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';

class DisputeModel {
  final String id;
  final String customer;
  final String subject;
  final String detail;
  bool resolved;

  DisputeModel({
    required this.id,
    required this.customer,
    required this.subject,
    required this.detail,
    this.resolved = false,
  });
}

class DisputesNotifier extends StateNotifier<List<DisputeModel>> {
  DisputesNotifier()
      : super([
          DisputeModel(
            id: '#4092',
            customer: 'أحمد محمد',
            subject: 'العاملة تأخرت ساعتين',
            detail:
                'وصلت العاملة متأخرة عن الموعد المحدد دون إشعار مسبق، وأطلب تعويضاً مناسباً.',
          ),
          DisputeModel(
            id: '#4095',
            customer: 'نورة الشمري',
            subject: 'خدمة غير مطابقة للوصف',
            detail: 'طلبت تنظيف عميق لكن الخدمة كانت عادية ولم تشمل النوافذ.',
          ),
          DisputeModel(
            id: '#4097',
            customer: 'خالد العتيبي',
            subject: 'مشكلة في استرداد المبلغ',
            detail: 'ألغيت الحجز قبل 24 ساعة ولم يُرد المبلغ بعد 5 أيام.',
          ),
        ]);

  void resolve(String id) {
    state = state
        .map((d) => d.id == id ? (d..resolved = true) : d)
        .toList();
  }
}

final disputesProvider =
    StateNotifierProvider<DisputesNotifier, List<DisputeModel>>(
      (ref) => DisputesNotifier(),
    );

class AdminDisputesScreen extends ConsumerWidget {
  const AdminDisputesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disputes = ref.watch(disputesProvider);
    final open = disputes.where((d) => !d.resolved).toList();
    final resolved = disputes.where((d) => d.resolved).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('البلاغات والنزاعات'),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.muted,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'مفتوحة (${open.length})'),
              Tab(text: 'تم حلها (${resolved.length})'),
            ],
          ),
        ),
        body: TabBarView(children: [
          _List(disputes: open),
          _List(disputes: resolved),
        ]),
      ),
    );
  }
}

class _List extends ConsumerWidget {
  final List<DisputeModel> disputes;
  const _List({required this.disputes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (disputes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user_rounded,
                size: 64, color: AppColors.success),
            const SizedBox(height: 12),
            const Text('لا بلاغات هنا — كل شيء تحت السيطرة ✅'),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: disputes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final d = disputes[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(d.id,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.error)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(d.subject,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14.5)),
                ),
              ]),
              const SizedBox(height: 8),
              Text(d.detail,
                  style: const TextStyle(fontSize: 12.5, height: 1.6, color: AppColors.muted)),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.person_outline_rounded, size: 14),
                const SizedBox(width: 4),
                Text(d.customer,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const Spacer(),
                if (!d.resolved)
                  SizedBox(
                    height: 34,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(disputesProvider.notifier).resolve(d.id);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('تم إغلاق البلاغ ${d.id} ✅'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.success));
                      },
                      icon: const Icon(Icons.check_rounded, size: 15),
                      label: const Text('حل البلاغ',
                          style: TextStyle(fontSize: 12)),
                    ),
                  )
                else
                  const Text('تم الحل ✓',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success)),
              ]),
            ],
          ),
        );
      },
    );
  }
}
