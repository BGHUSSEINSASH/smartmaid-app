import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/adaptive.dart';
import '../../data/repository.dart';

/// Opens the dispute-creation bottom sheet, wired to the backend
/// (graceful demo fallback inside TrustRepository).
Future<void> openDisputeSheet(
  BuildContext context, {
  required String bookingId,
}) async {
  final subjectCtrl = TextEditingController();
  final detailCtrl = TextEditingController();
  const categories = [
    'تأخير',
    'جودة الخدمة',
    'طلب استرداد',
    'سلوك غير لائق',
    'أخرى',
  ];
  var category = categories.first;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('فتح نزاع',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(
                'فريقنا سيراجع الحالة ويصلح النزاع خلال 48 ساعة',
                style: TextStyle(
                    fontSize: 12, color: context.mutedText, height: 1.5),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories
                    .map((c) => ChoiceChip(
                          label: Text(c, style: const TextStyle(fontSize: 12)),
                          selected: category == c,
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.2),
                          onSelected: (_) => setSheet(() => category = c),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectCtrl,
                decoration: InputDecoration(
                  hintText: 'عنوان مختصر للمشكلة',
                  filled: true,
                  fillColor: context.surface,
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: detailCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'اشرح التفاصيل (10 أحرف على الأقل)...',
                  filled: true,
                  fillColor: context.surface,
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                  onPressed: () async {
                    if (subjectCtrl.text.trim().length < 3 ||
                        detailCtrl.text.trim().length < 10) {
                      return;
                    }
                    Navigator.pop(ctx);
                    final res = await TrustRepository.openDispute(
                      bookingId: bookingId,
                      category: category,
                      subject: subjectCtrl.text.trim(),
                      detail: detailCtrl.text.trim(),
                    );
                    if (!ctx.mounted) return;
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(res.message),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.gavel_rounded, size: 20),
                  label: const Text('إرسال النزاع',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
