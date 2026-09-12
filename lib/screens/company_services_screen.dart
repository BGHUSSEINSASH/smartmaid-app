import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/company_services_provider.dart';
import '../widgets/pro_components.dart';

class CompanyServicesScreen extends ConsumerStatefulWidget {
  const CompanyServicesScreen({super.key});
  @override
  ConsumerState<CompanyServicesScreen> createState() => _CompanyServicesState();
}

class _CompanyServicesState extends ConsumerState<CompanyServicesScreen> {
  void _showAddSheet() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '30');
    final iconCtrl = TextEditingController(text: '🧹');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('إضافة خدمة جديدة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          TextField(controller: iconCtrl, decoration: const InputDecoration(labelText: 'الإيموجي', prefixIcon: Icon(Icons.emoji_emotions_rounded))),
          const SizedBox(height: 10),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الخدمة', prefixIcon: Icon(Icons.cleaning_services_rounded))),
          const SizedBox(height: 10),
          TextField(
            controller: priceCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'السعر (\$)', prefixIcon: Icon(Icons.attach_money_rounded)),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 52, width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة الخدمة'),
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final price = double.tryParse(priceCtrl.text) ?? 30;
                ref.read(companyServicesProvider.notifier).add(ServiceItem(
                  id: 'svc_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  icon: iconCtrl.text.trim().isEmpty ? '🧹' : iconCtrl.text.trim(),
                  price: price,
                ));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('تمت إضافة الخدمة'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success,
                ));
              },
            ),
          ),
        ]),
      ),
    );
  }

  void _showEditSheet(ServiceItem service) {
    final priceCtrl = TextEditingController(text: service.price.toStringAsFixed(2));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Text(service.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Text(service.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 16),
          TextField(
            controller: priceCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'السعر الجديد (\$)',
              prefixIcon: Icon(Icons.attach_money_rounded),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 52, width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_rounded),
              label: const Text('حفظ السعر'),
              onPressed: () {
                final price = double.tryParse(priceCtrl.text);
                if (price != null) {
                  ref.read(companyServicesProvider.notifier).updatePrice(service.id, price);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('تم حفظ السعر'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success,
                ));
              },
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(companyServicesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('خدماتنا وأسعارنا')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('خدمة جديدة'),
      ),
      body: services.isEmpty
          ? EmptyState(icon: Icons.cleaning_services_rounded, title: 'لا توجد خدمات', subtitle: 'أضف خدماتك لتظهر للعملاء')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: services.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final s = services[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: s.isActive ? AppColors.stroke : AppColors.stroke.withValues(alpha: .5),
                    ),
                  ),
                  child: Row(children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: s.isActive ? AppColors.primary.withValues(alpha: .1) : AppColors.stroke,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(child: Text(s.icon, style: const TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.name, style: TextStyle(fontWeight: FontWeight.w800, color: s.isActive ? null : AppColors.muted)),
                      Text('\$${s.price.toStringAsFixed(2)} / ساعة',
                          style: TextStyle(fontSize: 13, color: s.isActive ? AppColors.primary : AppColors.muted, fontWeight: FontWeight.w700)),
                    ])),
                    Switch.adaptive(
                      value: s.isActive,
                      onChanged: (_) => ref.read(companyServicesProvider.notifier).toggleActive(s.id),
                      activeColor: AppColors.primary,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
                      onPressed: () => _showEditSheet(s),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('حذف الخدمة؟'),
                          content: Text('هل تريد حذف خدمة "${s.name}"؟'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                              onPressed: () {
                                ref.read(companyServicesProvider.notifier).remove(s.id);
                                Navigator.pop(context);
                              },
                              child: const Text('حذف'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                );
              },
            ),
    );
  }
}
