import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/models.dart';
import '../providers/admin_providers.dart';
import '../widgets/pro_components.dart';

class AdminDiscountsScreen extends ConsumerStatefulWidget {
  const AdminDiscountsScreen({super.key});
  @override
  ConsumerState<AdminDiscountsScreen> createState() => _AdminDiscountsState();
}

class _AdminDiscountsState extends ConsumerState<AdminDiscountsScreen> {
  void _showAddSheet() {
    final codeCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    double pct = 10;
    double min = 0;
    int max = 1000;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('كوبون جديد',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            TextField(controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'كود الخصم')),
            const SizedBox(height: 10),
            TextField(controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'العنوان')),
            const SizedBox(height: 10),
            Row(children: [
              const Text('نسبة الخصم: '),
              Expanded(child: Slider(
                  value: pct, min: 1, max: 100, divisions: 99,
                  label: '${pct.round()}%',
                  onChanged: (v) => setSt(() => pct = v))),
              Text('${pct.round()}%'),
            ]),
            Row(children: [
              const Text('الحد الأقصى للاستخدام: '),
              Expanded(child: Slider(
                  value: max.toDouble(), min: 10, max: 10000,
                  divisions: 999,
                  label: '$max',
                  onChanged: (v) => setSt(() => max = v.round()))),
              Text('$max'),
            ]),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (codeCtrl.text.isEmpty || titleCtrl.text.isEmpty) return;
                  ref.read(discountsProvider.notifier).add(DiscountModel(
                    id: 'd${DateTime.now().millisecondsSinceEpoch}',
                    code: codeCtrl.text.toUpperCase(),
                    title: titleCtrl.text,
                    discountPercent: pct,
                    minTotal: min, maxUses: max,
                  ));
                  Navigator.pop(ctx);
                },
                child: const Text('إضافة الكوبون'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discounts = ref.watch(discountsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الخصومات والكوبونات')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('كوبون جديد'),
      ),
      body: discounts.isEmpty
          ? const Center(child: Text('لا توجد كوبونات'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: discounts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _DiscountCard(
                discount: discounts[i],
                onToggle: () => ref.read(discountsProvider.notifier)
                    .toggle(discounts[i].id),
                onDelete: () => showDialog(
                  context: ctx,
                  builder: (_) => AlertDialog(
                    title: const Text('حذف الكوبون؟'),
                    content: Text('هل تريد حذف كوبون "${discounts[i].code}"؟'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx),
                          child: const Text('إلغاء')),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(discountsProvider.notifier).remove(discounts[i].id);
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        child: const Text('حذف'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _DiscountCard extends StatelessWidget {
  final DiscountModel discount;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  const _DiscountCard({required this.discount, required this.onToggle,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ProCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: discount.isActive
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.stroke,
              borderRadius: BorderRadius.circular(10)),
            child: Text(discount.code,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: discount.isActive ? AppColors.primary : AppColors.muted)),
          ),
          const SizedBox(width: 10),
          Text(discount.title,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const Spacer(),
          Switch.adaptive(
              value: discount.isActive, onChanged: (_) => onToggle()),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _InfoChip('${discount.discountPercent.round()}% خصم',
              Icons.percent_rounded, AppColors.success),
          const SizedBox(width: 8),
          _InfoChip('${discount.usedCount}/${discount.maxUses} استخدام',
              Icons.people_rounded, AppColors.primary),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: onDelete,
          ),
        ]),
      ]),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _InfoChip(this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
    ]),
  );
}
