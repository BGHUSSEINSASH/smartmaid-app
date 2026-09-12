import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../data/models.dart';
import '../providers/admin_providers.dart';
import '../providers/compensation_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/pro_components.dart';
import '../widgets/day_slider.dart';

class AdminCompensationsScreen extends ConsumerStatefulWidget {
  const AdminCompensationsScreen({super.key});
  @override
  ConsumerState<AdminCompensationsScreen> createState() => _AdminCompensationsState();
}

class _AdminCompensationsState extends ConsumerState<AdminCompensationsScreen> {
  @override
  Widget build(BuildContext context) {
    final compensations = ref.watch(compensationProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة التعويضات')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showIssueSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('إصدار تعويض'),
      ),
      body: compensations.isEmpty
          ? EmptyState(icon: Icons.volunteer_activism_rounded, title: 'لا توجد تعويضات', subtitle: 'لم يتم إصدار أي تعويض بعد')
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: compensations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) => _CompensationTile(comp: compensations[i]),
            ),
    );
  }

  void _showIssueSheet() {
    final users = ref.read(usersManagementProvider);
    String? selectedUserId = users.first.id;
    String? selectedUserName = users.first.name;
    CompensationType type = CompensationType.walletCredit;
    final amountCtrl = TextEditingController(text: '25');
    final reasonCtrl = TextEditingController();
    int days = 7;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (ctx, setSt) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('إصدار تعويض', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: selectedUserId,
            decoration: const InputDecoration(labelText: 'المستفيد', prefixIcon: Icon(Icons.person_rounded)),
            items: users.map((u) => DropdownMenuItem(value: u.id, child: Text('${u.name} (${u.role.arabicLabel})'))).toList(),
            onChanged: (v) { setSt(() { selectedUserId = v; selectedUserName = users.firstWhere((u) => u.id == v).name; }); },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<CompensationType>(
            value: type,
            decoration: const InputDecoration(labelText: 'نوع التعويض', prefixIcon: Icon(Icons.category_rounded)),
            items: CompensationType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.arabicLabel))).toList(),
            onChanged: (v) => setSt(() => type = v!),
          ),
          const SizedBox(height: 10),
          if (type == CompensationType.walletCredit || type == CompensationType.manualRefund)
            TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'المبلغ (دولار)', prefixIcon: Icon(Icons.attach_money_rounded))),
          if (type == CompensationType.subscriptionDays)
            DaySlider(
              days: days,
              onChanged: (d) => setSt(() => days = d),
            ),
          const SizedBox(height: 10),
          TextField(controller: reasonCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'سبب التعويض *', prefixIcon: Icon(Icons.description_rounded))),
          const SizedBox(height: 14),
          SizedBox(height: 52, width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.send_rounded),
              label: const Text('إصدار التعويض'),
              onPressed: () {
                if (reasonCtrl.text.isEmpty) return;
                final comp = CompensationModel(
                  id: 'cp_${DateTime.now().millisecondsSinceEpoch}',
                  userId: selectedUserId!, userName: selectedUserName!,
                  type: type,
                  amount: type == CompensationType.walletCredit || type == CompensationType.manualRefund ? double.tryParse(amountCtrl.text) : null,
                  subscriptionDays: type == CompensationType.subscriptionDays ? days : null,
                  reason: reasonCtrl.text.trim(),
                  issuedBy: 'st1', issuedByName: 'مدير النظام',
                  issuedAt: DateTime.now(),
                );
                ref.read(compensationProvider.notifier).issue(comp);
                // إضافة للمحفظة إن كان ائتمان
                if (type == CompensationType.walletCredit) {
                  ref.read(walletProvider.notifier).topUp(double.parse(amountCtrl.text));
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('تم إصدار التعويض لـ $selectedUserName'),
                  backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating,
                ));
              },
            ),
          ),
        ])),
      )),
    );
  }
}

class _CompensationTile extends StatelessWidget {
  final CompensationModel comp;
  const _CompensationTile({required this.comp});

  Color get _typeColor => switch (comp.type) {
    CompensationType.walletCredit => AppColors.success,
    CompensationType.subscriptionDays => AppColors.warning,
    CompensationType.coupon => AppColors.primary,
    CompensationType.manualRefund => AppColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    return ProCard(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: _typeColor.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.volunteer_activism_rounded, color: _typeColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(comp.userName, style: const TextStyle(fontWeight: FontWeight.w800)),
            const Spacer(),
            Text(DateFormat('dd/MM/yyyy').format(comp.issuedAt), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ]),
          Text(comp.type.arabicLabel, style: TextStyle(fontSize: 11, color: _typeColor, fontWeight: FontWeight.w700)),
          Text(comp.reason, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (comp.amount != null)
            Text('+\$${comp.amount?.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.success, fontSize: 13)),
          if (comp.subscriptionDays != null)
            Text('+${comp.subscriptionDays} يوم اشتراك', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.warning, fontSize: 13)),
        ])),
      ]),
    );
  }
}

