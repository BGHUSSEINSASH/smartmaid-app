import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';

/// Slider لاختيار عدد الأيام (1-365) مع chips سريعة وحقل نصي.
class DaySlider extends StatefulWidget {
  final int days;
  final ValueChanged<int> onChanged;
  final List<int> quickOptions;
  const DaySlider({
    super.key,
    required this.days,
    required this.onChanged,
    this.quickOptions = const [1, 7, 30, 90, 180, 365],
  });

  @override
  State<DaySlider> createState() => _DaySliderState();
}

class _DaySliderState extends State<DaySlider> {
  late int _days;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _days = widget.days;
    _ctrl = TextEditingController(text: '$_days');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _update(int d) {
    final clamped = d.clamp(1, 365);
    setState(() {
      _days = clamped;
      _ctrl.text = '$clamped';
    });
    widget.onChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('المدة:', style: TextStyle(fontWeight: FontWeight.w800)),
        const Spacer(),
        Container(
          width: 80,
          height: 38,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary.withValues(alpha: .4)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 4),
              suffixText: ' يوم',
              suffixStyle: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) {
              final d = int.tryParse(v);
              if (d != null) _update(d);
            },
          ),
        ),
      ]),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: AppColors.primary,
          thumbColor: AppColors.primary,
          overlayColor: AppColors.primary.withValues(alpha: .1),
          inactiveTrackColor: AppColors.stroke,
          trackHeight: 4,
        ),
        child: Slider(
          value: _days.toDouble(),
          min: 1,
          max: 365,
          divisions: 364,
          label: '$_days يوم',
          onChanged: (v) => _update(v.round()),
        ),
      ),
      Wrap(
        spacing: 6,
        runSpacing: 4,
        children: widget.quickOptions.map((d) {
          final lbl = switch (d) {
            1 => 'يوم',
            7 => 'أسبوع',
            30 => 'شهر',
            90 => '3 أشهر',
            180 => '6 أشهر',
            365 => 'سنة',
            _ => '$d يوم',
          };
          return ChoiceChip(
            label: Text(lbl, style: const TextStyle(fontSize: 12)),
            selected: _days == d,
            selectedColor: AppColors.primary.withValues(alpha: .15),
            checkmarkColor: AppColors.primary,
            onSelected: (_) => _update(d),
          );
        }).toList(),
      ),
    ]);
  }
}

/// ملخص بصري لعملية المنح/التعويض.
class GrantSummary extends StatelessWidget {
  final String name;
  final String? tierLabel;
  final int days;
  final DateTime? baseDate;

  const GrantSummary({
    super.key,
    required this.name,
    required this.tierLabel,
    required this.days,
    this.baseDate,
  });

  @override
  Widget build(BuildContext context) {
    final from = baseDate ?? DateTime.now();
    final until = from.add(Duration(days: days));
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: .08),
            AppColors.accent.withValues(alpha: .06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: .2)),
      ),
      child: Column(children: [
        const Row(children: [
          Icon(Icons.summarize_rounded, color: AppColors.primary, size: 18),
          SizedBox(width: 8),
          Text('ملخص العملية',
              style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
        ]),
        const Divider(height: 14),
        _row('المستفيد', name),
        if (tierLabel != null) _row('نوع الاشتراك', tierLabel!),
        _row('المدة', '$days يوم'),
        _row('ينتهي في',
            '${until.day.toString().padLeft(2, '0')}/${until.month.toString().padLeft(2, '0')}/${until.year}'),
      ]),
    );
  }

  Widget _row(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Text(k, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      const Spacer(),
      Text(v, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
    ]),
  );
}
