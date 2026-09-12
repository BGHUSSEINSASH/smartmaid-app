import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../widgets/ai_app_bar_button.dart';
import '../core/theme/adaptive.dart';
import '../data/models.dart';
import '../data/repository.dart';
import '../providers/booking_provider.dart';
import '../providers/admin_providers.dart';
import '../providers/wallet_provider.dart';
import 'booking_detail_screen.dart' show BookingOtp;

class CompletionScreen extends ConsumerStatefulWidget {
  final BookingModel booking;
  const CompletionScreen({super.key, required this.booking});

  @override
  ConsumerState<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends ConsumerState<CompletionScreen> {
  final _otpCtrl = TextEditingController();
  final List<bool> _checklist = List.filled(5, false);
  final List<_DrawingPoint> _points = [];
  bool _isDrawing = false;

  static const _checklistItems = [
    'تم تنظيف جميع الغرف',
    'تم تنظيف المطبخ والحمامات',
    'تم ترتيب الأثاث',
    'تم التأكد من نظافة الأرضيات',
    'العميل راضٍ عن العمل',
  ];

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  bool get _allChecked => _checklist.every((c) => c);

  void _submit() {
    final expected = BookingOtp.codeFor(widget.booking.id);
    if (_otpCtrl.text.trim() != expected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الكود غير صحيح — اطلب الكود من العميل'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!_allChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أكمل جميع فحوصات الإنهاء'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.read(myBookingsProvider.notifier).completeBooking(widget.booking.id);
    ref.read(myBookingsProvider.notifier).markPaid(widget.booking.id);
    ref.read(walletProvider.notifier).addEarning(
        widget.booking.total * (1 - (ref.read(systemSettingsProvider).defaultCommissionRate)), 'أرباح مهمة ${widget.booking.service}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إنهاء المهمة بنجاح! 🎉'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('إنهاء المهمة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // OTP verification
            SurfaceCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pin_rounded,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('تحقق بكود العميل',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, color: context.ink)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('اطلب من العميل الكود الظاهر في تفاصيل حجزه:',
                      style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _otpCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24,
                        letterSpacing: 10,
                        fontWeight: FontWeight.w900),
                    decoration: const InputDecoration(
                      counterText: '',
                      hintText: '••••',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Checklist
            SurfaceCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.checklist_rounded,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('قائمة الفحص',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, color: context.ink)),
                      const Spacer(),
                      Text(
                          '${_checklist.where((c) => c).length}/${_checklist.length}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_checklistItems.length, (i) {
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColors.success,
                      value: _checklist[i],
                      onChanged: (v) =>
                          setState(() => _checklist[i] = v ?? false),
                      title: Text(_checklistItems[i],
                          style: const TextStyle(fontSize: 13.5)),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height:16),

            // Signature pad
            SurfaceCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.draw_rounded,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('توقيع إنهاء (اختياري)',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, color: context.ink)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.stroke),
                    ),
                    child: GestureDetector(
                      onPanStart: (d) => setState(() {
                        _isDrawing = true;
                        _points.add(_DrawingPoint(
                          offset: d.localPosition,
                          paint: Paint()
                            ..strokeWidth = 3
                            ..strokeCap = StrokeCap.round
                            ..color = AppColors.primary,
                        ));
                      }),
                      onPanUpdate: (d) => setState(() {
                        if (!_isDrawing) return;
                        _points.add(_DrawingPoint(
                          offset: d.localPosition,
                          paint: Paint()
                            ..strokeWidth = 3
                            ..strokeCap = StrokeCap.round
                            ..color = AppColors.primary,
                        ));
                      }),
                      onPanEnd: (_) => setState(() => _isDrawing = false),
                      child: CustomPaint(
                        painter: _SignaturePainter(_points),
                        size: const Size(double.infinity, 150),
                        child: _points.isEmpty
                            ? Center(
                                child: Text(
                                  'ارسم توقيعك هنا ✍️',
                                  style: TextStyle(
                                      color: AppColors.muted.withValues(alpha: 0.5),
                                      fontSize: 14),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  if (_points.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => setState(() => _points.clear()),
                        icon: const Icon(Icons.delete_outline_rounded, size: 16),
                        label: const Text('مسح التوقيع',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
                onPressed: _submit,
                icon: const Icon(Icons.check_circle_rounded, size: 22),
                label: const Text('تأكيد إنهاء المهمة',
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawingPoint {
  final Offset offset;
  final Paint paint;
  const _DrawingPoint({required this.offset, required this.paint});
}

class _SignaturePainter extends CustomPainter {
  final List<_DrawingPoint> points;
  _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i].offset, points[i + 1].offset, points[i].paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter old) =>
      old.points.length != points.length;
}



