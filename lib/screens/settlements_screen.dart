import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../data/repository.dart';
import '../providers/trust_provider.dart';

/// Worker monthly settlements (earnings) screen.
class SettlementsScreen extends ConsumerStatefulWidget {
  const SettlementsScreen({super.key});

  @override
  ConsumerState<SettlementsScreen> createState() => _SettlementsScreenState();
}

class _SettlementsScreenState extends ConsumerState<SettlementsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settlementsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fmt = NumberFormat.currency(locale: 'en', symbol: '\$', decimalDigits: 0);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('أرباحي ومستحقاتي')),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async =>
                  ref.read(settlementsProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SummaryCard(records: state.records, fmt: fmt),
                  const SizedBox(height: 16),
                  Text('التسويات الشهرية',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: context.ink)),
                  const SizedBox(height: 10),
                  if (state.records.isEmpty)
                    SurfaceCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(children: [
                        const Icon(Icons.payments_outlined,
                            size: 40, color: AppColors.muted),
                        const SizedBox(height: 10),
                        Text('لا توجد تسويات بعد',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: context.ink)),
                        const SizedBox(height: 4),
                        Text(
                          'ستظهر أرباحك هنا بعد إتمام أول مهامك واكتمال التسوية الشهرية',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12,
                              color: context.mutedText,
                              height: 1.5),
                        ),
                      ]),
                    )
                  else
                    ...state.records.map(
                        (r) => _SettlementTile(record: r, fmt: fmt)),
                ],
              ),
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final List<SettlementRecord> records;
  final NumberFormat fmt;
  const _SummaryCard({required this.records, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final totalNet = records.fold<double>(0, (s, r) => s + r.netPayout);
    final totalJobs = records.fold<int>(0, (s, r) => s + r.bookingsCount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('صافي المستحقات (كل الفترات)',
              style: TextStyle(color: Colors.white70, fontSize: 12.5)),
          const SizedBox(height: 6),
          Text(fmt.format(totalNet),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Row(children: [
            _Chip(label: '${records.length} فترات تسوية'),
            const SizedBox(width: 8),
            _Chip(label: '$totalJobs مهمة مكتملة'),
          ]),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}

class _SettlementTile extends StatelessWidget {
  final SettlementRecord record;
  final NumberFormat fmt;
  const _SettlementTile({required this.record, required this.fmt});

  String get _monthLabel {
    final parts = record.month.split('-');
    if (parts.length != 2) return record.month;
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    final idx = int.tryParse(parts[1]) ?? 1;
    return '${months[(idx - 1).clamp(0, 11)]} ${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SurfaceCard(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.calendar_month_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_monthLabel,
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: context.ink)),
                const SizedBox(height: 3),
                Text(
                  '${record.bookingsCount} مهمة • عمولة المنصة ${fmt.format(record.platformFee)}',
                  style: TextStyle(fontSize: 11, color: context.mutedText),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fmt.format(record.netPayout),
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary)),
              const SizedBox(height: 3),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: record.settled
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  record.settled ? 'مسدّدة' : 'قيد التحضير',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: record.settled
                          ? AppColors.success
                          : AppColors.warning),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
