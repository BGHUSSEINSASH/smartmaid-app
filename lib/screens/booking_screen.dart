import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../widgets/ai_app_bar_button.dart';
import '../core/storage/local_store.dart';
import '../core/theme/adaptive.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import '../providers/address_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/offers_provider.dart';
import 'payment_screen.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String? workerId;
  const BookingScreen({super.key, this.workerId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _couponCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  int? _selectedDayOffset;
  bool _agreedTerms = false;
  bool _draftLoaded = false;

  static int _slotHour(String slot) {
    final hourPart = int.tryParse(slot.split(':').first) ?? 0;
    if (slot.contains('مساءً')) return hourPart == 12 ? 12 : hourPart + 12;
    if (slot.contains('ظهراً')) return 12;
    return hourPart == 12 ? 0 : hourPart;
  }

  bool _slotDisabled(String slot) {
    if ((_selectedDayOffset ?? 0) != 0) return false;
    return _slotHour(slot) <= DateTime.now().hour;
  }

  Future<void> _saveDraft() async {
    final flow = ref.read(bookingFlowProvider);
    await LocalStore.saveBookingDraft({
      'workerId': flow.worker?.id,
      'dayOffset': _selectedDayOffset,
      'timeSlot': flow.timeSlot,
      'type': flow.bookingType.index,
      'extras': flow.selectedExtras,
      'notes': _notesCtrl.text,
    });
  }

  Future<void> _restoreDraft() async {
    if (_draftLoaded) return;
    _draftLoaded = true;
    final d = await LocalStore.loadBookingDraft();
    if (d == null || !mounted) return;
    final flow = ref.read(bookingFlowProvider);
    if (flow.worker != null) return;
    final notifier = ref.read(bookingFlowProvider.notifier);
    if (d['workerId'] is String) {
      final w = DemoData.byId(d['workerId'] as String);
      if (w != null) notifier.selectWorker(w);
    }
    if (d['dayOffset'] is int) _selectedDayOffset = d['dayOffset'] as int;
    if (d['timeSlot'] is String) notifier.selectTimeSlot(d['timeSlot'] as String);
    if (d['type'] is int &&
        d['type'] >= 0 &&
        d['type'] < BookingType.values.length) {
      notifier.setBookingType(BookingType.values[d['type'] as int]);
    }
    if (d['extras'] is List) {
      for (final e in (d['extras'] as List)) {
        notifier.toggleExtra(e.toString());
      }
    }
    if (d['notes'] is String) _notesCtrl.text = d['notes'] as String;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (widget.workerId != null) {
      final w = DemoData.byId(widget.workerId!);
      if (w != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(bookingFlowProvider.notifier).selectWorker(w);
          if (mounted) setState(() {});
        });
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreDraft());
  }

  @override
  void dispose() {
    _couponCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAddress() async {
    final list = ref.read(addressProvider);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('اختر عنوان الخدمة',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              ),
              ...list.map((a) => ListTile(
                    leading: Icon(
                      a.isDefault ? Icons.home_rounded : Icons.location_on_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text('${a.label} — ${a.city}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(a.details),
                    trailing: a.isDefault
                        ? const StatusChip(label: 'افتراضي')
                        : null,
                    onTap: () {
                      ref.read(selectedAddressIdProvider.notifier).state = a.id;
                      Navigator.pop(ctx);
                    },
                  )),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  void _applyCoupon(double subtotal) {
    final result = ref
        .read(couponProvider.notifier)
        .apply(_couponCtrl.text, subtotal);
    if (result.ok) {
      ref.read(usedCouponFlagProvider.notifier).state = true;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: result.ok ? AppColors.success : AppColors.error,
      ),
    );
    setState(() {});
  }

  Future<void> _continue() async {
    final flow = ref.read(bookingFlowProvider);
    if (flow.worker == null) {
      _toast('اختر عاملة أولاً');
      return;
    }
    if (_selectedDayOffset == null || flow.timeSlot == null) {
      _toast('حدد التاريخ والوقت المناسبين');
      return;
    }
    if (!_agreedTerms) {
      _toast('الرجاء الموافقة على شروط الحجز أولاً');
      return;
    }
    final date = DateTime.now().add(Duration(days: _selectedDayOffset!));
    ref.read(bookingFlowProvider.notifier).selectDate(date);
    final totals = ref.read(bookingTotalsProvider);
    final currency = ref.read(currencyProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحجز'),
        content: Text(
          'العاملة: ${flow.worker!.name}\n'
          'الموعد: ${date.day}/${date.month} — ${flow.timeSlot}\n'
          'التعاقد: ${flow.bookingTypeLabel}\n'
          'الإجمالي: ${currency.format(totals.total)}',
          style: const TextStyle(height: 1.7),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('تعديل')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('تأكيد ومتابعة الدفع')),
        ],
      ),
    );
    if (confirmed != true) return;
    await confirmCurrentBooking(ref);
    await LocalStore.clearBookingDraft();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PaymentScreen()),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  String _dayLabel(int offset) {
    final d = DateTime.now().add(Duration(days: offset));
    const names = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    if (offset == 0) return 'اليوم';
    if (offset == 1) return 'غداً';
    return names[d.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(bookingFlowProvider);
    final totals = ref.watch(bookingTotalsProvider);
    final currency = ref.watch(currencyProvider);
    final address = ref.watch(selectedAddressProvider);
    final coupon = ref.watch(couponProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('حجز جديد'),
          actions: [aiAppBarButton(context, initialMessage: 'اقترح لي أفضل عاملة')]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('1. اختر العاملة'),
            const SizedBox(height: 12),
            SizedBox(
              height: 132,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: DemoData.workers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final w = DemoData.workers[i];
                  final selected = flow.worker?.id == w.id;
                  return GestureDetector(
                    onTap: () {
                      ref.read(bookingFlowProvider.notifier).selectWorker(w);
                      _saveDraft();
                      setState(() {});
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 104,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.stroke,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundImage: NetworkImage(w.imageUrl),
                          ),
                          const SizedBox(height: 8),
                          Text(w.name.split(' ').first,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: textColor)),
                          Text('\$${w.hourlyRate}/س',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            _SectionTitle('2. حدد التاريخ'),
            const SizedBox(height: 12),
            SizedBox(
              height: 84,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 14,
                itemBuilder: (context, i) {
                  final selected = _selectedDayOffset == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDayOffset = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(left: 10),
                      width: 72,
                      decoration: BoxDecoration(
                        color:
                            selected ? AppColors.primary : cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.stroke),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_dayLabel(i),
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? Colors.white70
                                      : AppColors.muted)),
                          const SizedBox(height: 4),
                          Text(
                            '${DateTime.now().add(Duration(days: i)).day}',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: selected ? Colors.white : textColor),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            _SectionTitle('3. الوقت'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DemoData.timeSlots.map((t) {
                final disabled = _slotDisabled(t);
                return ChoiceChip(
                  label: Text(t),
                  selected: flow.timeSlot == t,
                  selectedColor:
                      AppColors.primary.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: disabled
                        ? context.mutedText.withValues(alpha: 0.5)
                        : flow.timeSlot == t
                            ? AppColors.primary
                            : textColor,
                  ),
                  onSelected: disabled
                      ? null
                      : (_) {
                          ref
                              .read(bookingFlowProvider.notifier)
                              .selectTimeSlot(t);
                          _saveDraft();
                          setState(() {});
                        },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.speed_rounded,
                      size: 22, color: AppColors.warning),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('خدمة سريعة ✈',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                                color: textColor)),
                        const Text('وصول خلال 30 دقيقة — +\$5',
                            style: TextStyle(
                                fontSize: 11.5, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  Switch(
                    value: flow.expressFee,
                    onChanged: (_) {
                      ref.read(bookingFlowProvider.notifier).toggleExpressFee();
                      _saveDraft();
                      setState(() {});
                    },
                    activeColor: AppColors.warning,
                  ),
                ],
              ),
            ),
            _SectionTitle('4. نوع التعاقد'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.9,
              children: [
                for (final t in BookingType.values)
                  _ContractTypeCard(
                    type: t,
                    selected: flow.bookingType == t,
                    onTap: () {
                      ref
                          .read(bookingFlowProvider.notifier)
                          .setBookingType(t);
                      _saveDraft();
                      setState(() {});
                    },
                  ),
              ],
            ),
            _SectionTitle('5. خدمات إضافية'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DemoData.extraServices.map((e) {
                final sel = flow.selectedExtras.contains(e.id);
                return FilterChip(
                  avatar: Text(e.icon),
                  label: Text('${e.name} (+\$${e.priceUsd.toStringAsFixed(0)})',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? AppColors.primary : textColor)),
                  selected: sel,
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  onSelected: (_) {
                    ref.read(bookingFlowProvider.notifier).toggleExtra(e.id);
                    _saveDraft();
                    setState(() {});
                  },
                );
              }).toList(),
            ),
            _SectionTitle('6. ملاحظات للعاملة'),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              onChanged: (_) => _saveDraft(),
              decoration: const InputDecoration(
                hintText: 'مثال: التركيز على المطبخ، يوجد قطط في المنزل...',
              ),
            ),
            _SectionTitle('7. العنوان'),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _pickAddress,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.stroke),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: address == null
                          ? const Text('اختر العنوان',
                              style: TextStyle(fontWeight: FontWeight.w700))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${address.label} — ${address.city}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: textColor)),
                                Text(address.details,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.muted)),
                              ],
                            ),
                    ),
                    const Icon(Icons.chevron_left_rounded,
                        color: AppColors.muted),
                  ],
                ),
              ),
            ),
            _SectionTitle('8. كود خصم'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'مثال: SMART50',
                      prefixIcon: const Icon(Icons.local_offer_rounded),
                      suffixIcon: coupon != null
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  size: 18),
                              onPressed: () {
                                ref.read(couponProvider.notifier).clear();
                                _couponCtrl.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _applyCoupon(flow.total),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(90, 52)),
                  child: const Text('تطبيق'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  _SummaryRow('الأساس (${flow.bookingTypeLabel})',
                      currency.format(flow.baseTotal), Colors.white),
                  if (flow.extrasTotal > 0)
                    _SummaryRow('خدمات إضافية',
                        currency.format(flow.extrasTotal), Colors.white),
                  if (flow.expressFee)
                    _SummaryRow('خدمة سريعة ✈', '+\$5', const Color(0xFFFFF3CD)),
                  if (flow.needTools)
                    _SummaryRow('أدوات التنظيف 🧹', '+\$10', const Color(0xFFFFF3CD)),
                  if (totals.discount > 0)
                    _SummaryRow(
                        'خصم ${coupon!.code}',
                        '- ${currency.format(totals.discount)}',
                        const Color(0xFFB9F5CE)),
                  const Divider(color: Colors.white38, height: 24),
                  _SummaryRow('الإجمالي', currency.format(totals.total),
                      Colors.white, bold: true),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        padding: EdgeInsets.only(
            left: 20, right: 20, top: 10,
            bottom: 10 + MediaQuery.of(context).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primary,
              value: _agreedTerms,
              onChanged: (v) => setState(() => _agreedTerms = v ?? false),
              title: const Text.rich(
                TextSpan(
                  text: 'أوافق على ',
                  children: [
                    TextSpan(
                      text: 'شروط الاستخدام وسياسة الإلغاء',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800),
                    ),
                    TextSpan(text: ' (إلغاء مجاني قبل 24 ساعة)'),
                  ],
                ),
                style: TextStyle(fontSize: 12),
              ),
            ),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _continue,
                icon: const Icon(Icons.payments_rounded, size: 20),
                label: Text('متابعة الدفع • ${currency.format(totals.total)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  const StatusChip({super.key, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Text(text,
          style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.2)),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool bold;
  const _SummaryRow(this.label, this.value, this.color, {this.bold = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: bold ? 15 : 13,
                      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                      color: color))),
          Text(value,
              style: TextStyle(
                  fontSize: bold ? 18 : 14,
                  fontWeight: FontWeight.w800,
                  color: color)),
        ],
      ),
    );
  }
}

class _ContractTypeCard extends StatelessWidget {
  final BookingType type;
  final bool selected;
  final VoidCallback onTap;

  const _ContractTypeCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  (String, String?, IconData) get _meta => switch (type) {
        BookingType.daily => ('يومي', null, Icons.today_rounded),
        BookingType.weekly =>
          ('أسبوعي', 'وفّر 10%', Icons.date_range_rounded),
        BookingType.monthly =>
          ('شهري', 'وفّر 20%', Icons.calendar_month_rounded),
        BookingType.annual => ('سنوي', 'وفّر 30%', Icons.workspace_premium_rounded),
      };

  @override
  Widget build(BuildContext context) {
    final (label, badge, icon) = _meta;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.stroke,
              width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 22,
                color: selected ? AppColors.primary : AppColors.muted),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: selected
                              ? AppColors.primary
                              : (isDark
                                  ? Colors.white
                                  : AppColors.textPrimary))),
                  if (badge != null)
                    Text(badge,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



