import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../widgets/ai_app_bar_button.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/pro_components.dart';

/// شاشة الحجز السنوي الشامل
class AnnualBookingScreen extends ConsumerStatefulWidget {
  const AnnualBookingScreen({super.key});
  @override
  ConsumerState<AnnualBookingScreen> createState() => _AnnualBookingState();
}

class _AnnualBookingState extends ConsumerState<AnnualBookingScreen> {
  String? _selectedWorkerId;
  final Set<int> _weekdays = {1, 4}; // الاثنين والخميس افتراضياً
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  int _hoursPerSession = 3;
  final _notesCtrl = TextEditingController();
  bool _confirmed = false;

  static const _dayNames = ['', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
  static const double _hourlyRate = 30;
  static const double _discountRate = 0.30;

  double get _sessionsPerYear => _weekdays.length * 52;
  double get _totalBeforeDiscount => _sessionsPerYear * _hoursPerSession * _hourlyRate;
  double get _savings => _totalBeforeDiscount * _discountRate;
  double get _totalAfterDiscount => _totalBeforeDiscount - _savings;

  @override
  void dispose() { _notesCtrl.dispose(); super.dispose(); }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  void _confirm() {
    if (_weekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('اختر يوماً واحداً على الأقل'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final user = ref.read(authProvider).user;
    final currency = ref.read(currencyProvider);
    // إنشاء حجز سنوي (booking نموذجي يمثّل العقد)
    final worker = _selectedWorkerId != null
        ? DemoData.workers.where((w) => w.id == _selectedWorkerId).firstOrNull
        : DemoData.workers.first;
    if (worker == null) return;
    final booking = BookingModel(
      id: 'annual_${DateTime.now().millisecondsSinceEpoch}',
      workerId: worker.id,
      workerName: worker.name,
      workerImage: worker.imageUrl,
      userId: user?.id ?? 'u1',
      date: DateTime.now().add(const Duration(days: 1)),
      timeSlot: '${_time.hour.toString().padLeft(2,'0')}:${_time.minute.toString().padLeft(2,'0')}',
      service: 'حجز سنوي — ${_weekdays.map((d) => _dayNames[d]).join(' / ')}',
      total: _totalAfterDiscount,
      status: BookingStatus.confirmed,
      paymentStatus: PaymentStatus.held,
      notes: _notesCtrl.text,
    );
    ref.read(myBookingsProvider.notifier).add(booking);
    setState(() => _confirmed = true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('✅ تم تأكيد حجزك السنوي! وفّرت ${currency.format(_savings)}'),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDeep : AppColors.bg,
      appBar: AppBar(title: const Text('الحجز السنوي الشامل'), actions: [aiAppBarButton(context, initialMessage: 'ما أفضل خطة للحجز السنوي؟')]),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Hero banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              const Text('📅', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('حجز سنوي متكامل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 4),
                Text('وفّر ${(_discountRate * 100).round()}% على الحجوزات الأسبوعية الثابتة',
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ])),
            ]),
          ),
          const SizedBox(height: 18),

          // اختيار العاملة
          _sectionTitle('اختر العاملة'),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: DemoData.workers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final w = DemoData.workers[i];
                final sel = _selectedWorkerId == w.id || (_selectedWorkerId == null && i == 0);
                return GestureDetector(
                  onTap: () => setState(() => _selectedWorkerId = w.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary.withValues(alpha: .1) : (isDark ? AppColors.surfaceDark : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: sel ? AppColors.primary : AppColors.stroke, width: sel ? 2 : 1),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      CircleAvatar(radius: 22, backgroundImage: NetworkImage(w.imageUrl)),
                      const SizedBox(height: 4),
                      Text(w.name.split(' ').first, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sel ? AppColors.primary : null)),
                    ]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),

          // أيام الأسبوع
          _sectionTitle('أيام الأسبوع'),
          Wrap(spacing: 8, runSpacing: 8, children: List.generate(7, (i) {
            final day = i + 1;
            final sel = _weekdays.contains(day);
            return GestureDetector(
              onTap: () => setState(() => sel ? _weekdays.remove(day) : _weekdays.add(day)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : (isDark ? AppColors.surfaceDark : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? AppColors.primary : AppColors.stroke),
                ),
                child: Text(_dayNames[day],
                    style: TextStyle(color: sel ? Colors.white : null, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            );
          })),
          const SizedBox(height: 18),

          // الوقت
          _sectionTitle('الوقت الثابت'),
          GestureDetector(
            onTap: _pickTime,
            child: ProCard(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                const Icon(Icons.access_time_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Text('${_time.format(context)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                const Spacer(),
                const Text('تغيير', style: TextStyle(color: AppColors.muted, fontSize: 13)),
              ]),
            ),
          ),
          const SizedBox(height: 18),

          // ساعات في الجلسة
          _sectionTitle('ساعات كل جلسة'),
          ProCard(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(children: [
                Text('$_hoursPerSession ساعات',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
                const Spacer(),
                Text(currency.format(_hoursPerSession * _hourlyRate) + '/جلسة',
                    style: TextStyle(color: AppColors.muted, fontSize: 13)),
              ]),
              Slider(value: _hoursPerSession.toDouble(), min: 1, max: 8, divisions: 7,
                  label: '$_hoursPerSession ساعات', onChanged: (v) => setState(() => _hoursPerSession = v.round())),
            ]),
          ),
          const SizedBox(height: 18),

          // ملاحظات
          _sectionTitle('ملاحظات دائمة'),
          TextField(controller: _notesCtrl, maxLines: 3,
              decoration: const InputDecoration(hintText: 'مثال: الرجاء إحضار المعدات / الدخول من الباب الخلفي...')),
          const SizedBox(height: 24),

          // ملخص التسعير
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.success.withValues(alpha: .3)),
            ),
            child: Column(children: [
              const Row(children: [
                Icon(Icons.calculate_rounded, color: AppColors.success, size: 20),
                SizedBox(width: 8),
                Text('ملخص الحجز السنوي', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.success)),
              ]),
              const Divider(height: 18),
              _priceRow('عدد الجلسات السنوية', '${_sessionsPerYear.round()} جلسة'),
              _priceRow('السعر الأصلي', currency.format(_totalBeforeDiscount)),
              _priceRow('خصم ${(_discountRate * 100).round()}%', '- ${currency.format(_savings)}', color: AppColors.success),
              const Divider(height: 12),
              _priceRow('الإجمالي السنوي', currency.format(_totalAfterDiscount), bold: true, large: true),
            ]),
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _confirm,
              icon: const Icon(Icons.check_circle_rounded),
              label: Text('تأكيد الحجز السنوي — ${currency.format(_totalAfterDiscount)}',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
  );

  Widget _priceRow(String k, String v, {Color? color, bool bold = false, bool large = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Text(k, style: TextStyle(color: AppColors.muted, fontSize: large ? 14 : 13)),
      const Spacer(),
      Text(v, style: TextStyle(
        color: color ?? (bold ? AppColors.textPrimary : AppColors.muted),
        fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
        fontSize: large ? 16 : 13,
      )),
    ]),
  );
}


