import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../providers/support_provider.dart';

class SupportTicketScreen extends ConsumerStatefulWidget {
  const SupportTicketScreen({super.key});

  @override
  ConsumerState<SupportTicketScreen> createState() =>
      _SupportTicketScreenState();
}

class _SupportTicketScreenState extends ConsumerState<SupportTicketScreen> {
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'حجز';
  TicketPriority _priority = TicketPriority.medium;

  static const _categories = [
    'حجز',
    'دفع',
    'عملية',
    'شكوى',
    'اقتراح',
    'أخرى',
  ];

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_subjectCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أكمل جميع الحقول المطلوبة'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.read(ticketsProvider.notifier).add(SupportTicket(
          id: 't_${DateTime.now().millisecondsSinceEpoch}',
          subject: _subjectCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          category: _category,
          priority: _priority,
          createdAt: DateTime.now(),
        ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إرسال تذكرتك بنجاح ✅'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('تذكرة دعم')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category
            const Text('الفئة',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((c) {
                final sel = _category == c;
                return ChoiceChip(
                  label: Text(c),
                  selected: sel,
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: sel ? AppColors.primary : context.mutedText,
                  ),
                  onSelected: (_) => setState(() => _category = c),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Priority
            const Text('الأولوية',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              children: TicketPriority.values.map((p) {
                final sel = _priority == p;
                final label = switch (p) {
                  TicketPriority.low => 'منخفضة',
                  TicketPriority.medium => 'متوسطة',
                  TicketPriority.high => 'عالية',
                };
                final color = switch (p) {
                  TicketPriority.low => AppColors.success,
                  TicketPriority.medium => AppColors.warning,
                  TicketPriority.high => AppColors.error,
                };
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: sel,
                      selectedColor: color.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: sel ? color : context.mutedText,
                      ),
                      onSelected: (_) => setState(() => _priority = p),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Subject
            const Text('الموضوع',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 10),
            TextField(
              controller: _subjectCtrl,
              decoration: const InputDecoration(
                hintText: 'مثال: مشكلة في الحجز رقم 123',
              ),
            ),
            const SizedBox(height: 16),

            // Description
            const Text('التفاصيل',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 10),
            TextField(
              controller: _descCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'اشرح المشكلة بالتفصيل...',
              ),
            ),
            const SizedBox(height: 24),

            // Submit
            SizedBox(
              height: 54,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('إرسال التذكرة',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
