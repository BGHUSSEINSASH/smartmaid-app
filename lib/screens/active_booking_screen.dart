import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import '../providers/booking_provider.dart';
import '../providers/currency_provider.dart';
import '../widgets/app_image.dart';
import 'completion_screen.dart';

class ActiveBookingScreen extends ConsumerStatefulWidget {
  final BookingModel booking;
  const ActiveBookingScreen({super.key, required this.booking});

  @override
  ConsumerState<ActiveBookingScreen> createState() =>
      _ActiveBookingScreenState();
}

class _ActiveBookingScreenState extends ConsumerState<ActiveBookingScreen>
    with SingleTickerProviderStateMixin {
  BookingModel? _live;
  late Timer _timer;
  late AnimationController _pulseCtrl;
  int _elapsed = 0;
  int _etaSeconds = 12 * 60; // 12 minutes ETA

  BookingModel get b => _live ?? widget.booking;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsed++;
        if (_etaSeconds > 0) _etaSeconds--;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _sync() {
    final list = ref.read(myBookingsProvider);
    final found = list.where((x) => x.id == widget.booking.id).firstOrNull;
    if (found != null && mounted) setState(() => _live = found);
  }

  void _markArrival() {
    final updated = b.copyWith(arrivalTime: DateTime.now());
    ref.read(myBookingsProvider.notifier).updateBooking(updated);
    setState(() => _live = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تسجيل الوصول ✅'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _etaLabel() {
    if (b.arrivalTime != null) return 'تم الوصول';
    if (_etaSeconds <= 0) return 'قريب الوصول';
    return 'الوصول خلال ${_formatTime(_etaSeconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (_elapsed / 720).clamp(0.0, 0.85); // 12 min max

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(b.arrivalTime != null ? 'الخدمة جارية' : 'تتبع العاملة'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Worker info card
          SurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AppAvatar(url: b.workerImage, radius: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.workerName,
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: context.ink)),
                      Text(b.service,
                          style: TextStyle(
                              fontSize: 13, color: context.mutedText)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: b.arrivalTime != null
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    b.arrivalTime != null ? 'في الموقع 📍' : 'في الطريق 🚗',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: b.arrivalTime != null
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Map placeholder with animated pin
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark
                  : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Grid pattern
                ...List.generate(6, (i) {
                  return Positioned(
                    top: 20 + i * 30.0,
                    left: 20,
                    right: 20,
                    child: Container(
                      height: 1,
                      color: AppColors.stroke.withValues(alpha: 0.5),
                    ),
                  );
                }),
                ...List.generate(8, (i) {
                  return Positioned(
                    left: 20 + i * 40.0,
                    top: 20,
                    bottom: 20,
                    child: Container(
                      width: 1,
                      color: AppColors.stroke.withValues(alpha: 0.5),
                    ),
                  );
                }),
                // Animated pin
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, -_pulseCtrl.value * 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary
                                    .withValues(alpha: 0.3 + _pulseCtrl.value * 0.2),
                                blurRadius: 12 + _pulseCtrl.value * 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: AppAvatar(url: b.workerImage, radius: 16),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Progress bar at bottom
                Positioned(
                  bottom: 16,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: AppColors.stroke,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _etaLabel(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: b.arrivalTime != null
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ETA countdown
          if (b.arrivalTime == null && _etaSeconds > 0)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text('وقت الوصول المتوقع',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(_etaSeconds),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('العاملة في طريقها إليك',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          if (b.arrivalTime != null)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: AppColors.success, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('تم الوصول في ${b.arrivalTime!.hour}:${b.arrivalTime!.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.success)),
                        const Text('الخدمة جارية الآن',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),

          // Booking details
          SurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _detailRow(Icons.calendar_month_rounded, 'التاريخ',
                    '${b.date.day}/${b.date.month}/${b.date.year}'),
                _detailRow(Icons.schedule_rounded, 'الوقت', b.timeSlot),
                _detailRow(Icons.badge_rounded, 'الخدمة', b.service),
                _detailRow(Icons.payments_rounded, 'الإجمالي',
                    currency.format(b.total)),
                if (b.expressFee)
                  _detailRow(Icons.speed_rounded, 'خدمة سريعة', '+\$5'),
                if (b.needTools)
                  _detailRow(Icons.build_rounded, 'أدوات التنظيف', '+\$10'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          if (b.arrivalTime == null)
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
                onPressed: _markArrival,
                icon: const Icon(Icons.location_on_rounded, size: 20),
                label: const Text('وصلت الموقع',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            )
          else
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CompletionScreen(booking: b),
                    ),
                  );
                },
                icon: const Icon(Icons.task_alt_rounded, size: 20),
                label: const Text('إنهاء المهمة',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('العودة للتفاصيل'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(fontSize: 13, color: context.mutedText)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: context.ink)),
        ],
      ),
    );
  }
}
