import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// نافذة تعليق إلزامية عند تقييم 1 أو 2 نجوم
class LowRatingDialog extends StatefulWidget {
  final double rating;
  final String workerName;
  final void Function(String reason, String comment) onSubmit;

  const LowRatingDialog({
    super.key,
    required this.rating,
    required this.workerName,
    required this.onSubmit,
  });

  @override
  State<LowRatingDialog> createState() => _LowRatingDialogState();
}

class _LowRatingDialogState extends State<LowRatingDialog> {
  int? _selectedReason;
  final _commentCtrl = TextEditingController();

  static const _reasons = [
    'الخدمة لم تكن نظيفة بما يكفي',
    'العاملة تأخرت عن الموعد المحدد',
    'تصرف غير لائق من العاملة',
    'لم تُتم المهام المطلوبة',
    'جودة الخدمة أقل من المتوقع',
    'أخرى',
  ];

  @override
  void dispose() { _commentCtrl.dispose(); super.dispose(); }

  void _submit() {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('الرجاء اختيار سبب التقييم المنخفض'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    widget.onSubmit(_reasons[_selectedReason!], _commentCtrl.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final stars = widget.rating.round();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.error.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.warning_rounded, color: AppColors.error, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('تقييم منخفض', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
              Text('لـ ${widget.workerName}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ])),
            Row(children: List.generate(5, (i) => Icon(
              i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
              color: AppColors.warning, size: 18,
            ))),
          ]),
          const SizedBox(height: 16),
          Text(
            'أخبرنا ما الذي لم يعجبك؟ سيساعدنا في تحسين جودة الخدمة.',
            style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 14),
          // Reasons
          ...List.generate(_reasons.length, (i) => GestureDetector(
            onTap: () => setState(() => _selectedReason = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _selectedReason == i
                    ? AppColors.primary.withValues(alpha: .08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedReason == i ? AppColors.primary : AppColors.stroke,
                  width: _selectedReason == i ? 1.5 : 1,
                ),
              ),
              child: Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _selectedReason == i ? AppColors.primary : Colors.transparent,
                    border: Border.all(color: _selectedReason == i ? AppColors.primary : AppColors.stroke, width: 1.5),
                  ),
                  child: _selectedReason == i
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 12)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(_reasons[i], style: TextStyle(
                  fontSize: 13,
                  fontWeight: _selectedReason == i ? FontWeight.w700 : FontWeight.w500,
                  color: _selectedReason == i ? AppColors.primary : null,
                ))),
              ]),
            ),
          )),
          const SizedBox(height: 8),
          // Comment
          TextField(
            controller: _commentCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'تعليق إضافي (اختياري)...',
              hintStyle: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('تخطّي'),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _submit,
              child: const Text('إرسال التقييم', style: TextStyle(fontWeight: FontWeight.w800)),
            )),
          ]),
        ]),
      ),
    );
  }
}

/// StarRatingWidget — يطلق نافذة التعليق عند 1 أو 2 نجوم
class StarRatingWidget extends StatefulWidget {
  final double initialRating;
  final String workerName;
  final void Function(double rating, String? reason, String? comment) onRatingChanged;
  final double size;

  const StarRatingWidget({
    super.key,
    this.initialRating = 0,
    required this.workerName,
    required this.onRatingChanged,
    this.size = 36,
  });

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  double _rating = 0;

  @override
  void initState() { super.initState(); _rating = widget.initialRating; }

  Future<void> _onStarTap(double r) async {
    setState(() => _rating = r);
    if (r <= 2) {
      // افتح نافذة التعليق الإلزامية
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => LowRatingDialog(
          rating: r,
          workerName: widget.workerName,
          onSubmit: (reason, comment) {
            widget.onRatingChanged(r, reason, comment);
          },
        ),
      );
    } else {
      widget.onRatingChanged(r, null, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starVal = (i + 1).toDouble();
        return GestureDetector(
          onTap: () => _onStarTap(starVal),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Icon(
              _rating >= starVal ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _rating >= starVal ? AppColors.warning : AppColors.stroke,
              size: widget.size,
            ),
          ),
        );
      }),
    );
  }
}
