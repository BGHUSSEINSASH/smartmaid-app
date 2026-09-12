import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/demo_data.dart';

class WorkerScheduleScreen extends StatefulWidget {
  const WorkerScheduleScreen({super.key});

  @override
  State<WorkerScheduleScreen> createState() => _WorkerScheduleScreenState();
}

class _WorkerScheduleScreenState extends State<WorkerScheduleScreen> {
  final Set<int> _leaveDays = {};
  List<bool> get _weekShifts {
    final seed = DateTime.now().day;
    return List.generate(7, (i) => ((seed + i * 3) % 4) != 0);
  }

  @override
  Widget build(BuildContext context) {
    final shifts = _weekShifts;
    const dayNames = [
      'السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'
    ];
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('جدولي الأسبوعي')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.savingsGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(children: [
              const Icon(Icons.calendar_month_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'أسبوع ${now.day}/${now.month} — ${shifts.where((s) => s).length} ورديات مجدولة',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          ...List.generate(7, (i) {
            final hasShift = shifts[i] && !_leaveDays.contains(i);
            final date = now.add(Duration(days: i));
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.surfaceDark
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: hasShift ? AppColors.primary : AppColors.stroke,
                    width: hasShift ? 1.4 : 1),
              ),
              child: Row(children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: hasShift
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${date.day}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 15)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dayNames[i],
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text(
                        hasShift ? '08:00 صباحاً — 04:00 مساءً' : 'إجازة',
                        style: TextStyle(
                            fontSize: 12,
                            color: hasShift
                                ? AppColors.muted
                                : AppColors.textHint),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: hasShift
                        ? AppColors.success.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(hasShift ? 'وردية' : 'راحة',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: hasShift
                              ? AppColors.success
                              : AppColors.muted)),
                ),
              ]),
            );
          }),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (ctx) => StatefulBuilder(
                  builder: (ctx, setDialog) => AlertDialog(
                    title: const Text('طلب إجازة'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(7, (i) {
                        return CheckboxListTile(
                          dense: true,
                          title: Text(dayNames[i],
                              style: const TextStyle(fontSize: 13)),
                          value: _leaveDays.contains(i),
                          activeColor: AppColors.primary,
                          onChanged: (v) => setDialog(() {
                            v == true
                                ? _leaveDays.add(i)
                                : _leaveDays.remove(i);
                          }),
                        );
                      }),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('إلغاء')),
                      FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(0, 42),
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap),
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                            content: Text(_leaveDays.isEmpty
                                ? 'تم إلغاء طلبات الإجازة'
                                : 'تم إرسال طلب إجازة لـ${_leaveDays.length} أيام ⏳'),
                            behavior: SnackBarBehavior.floating,
                          ));
                        },
                        child: const Text('إرسال الطلب'),
                      ),
                    ],
                  ),
                ),
              ),
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.5))),
              icon: const Icon(Icons.beach_access_rounded, size: 18),
              label: const Text('طلب إجازة'),
            ),
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text('لتعديل وردياتك تواصلي مع إدارة الشركة',
                style: TextStyle(fontSize: 11.5, color: AppColors.textHint)),
          ),
        ],
      ),
    );
  }
}

