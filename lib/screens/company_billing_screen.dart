import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../data/models.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/currency_provider.dart';

class CompanyBillingScreen extends ConsumerWidget {
  const CompanyBillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final bookings = ref.watch(myBookingsProvider);
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final commissionRate = user?.companyInfo?.commissionRate ?? 0.20;
    final companyName = user?.companyInfo?.companyName.isNotEmpty == true
        ? user!.companyInfo!.companyName
        : user?.name ?? 'شركتي';

    final completed = bookings.where((b) => b.status == BookingStatus.completed).toList();
    final totalRevenue = completed.fold<double>(0, (s, b) => s + b.total);
    final commission = totalRevenue * commissionRate;
    final net = totalRevenue - commission;

    // تسويات شهرية محسوبة من الحجوزات الفعلية
    final settlements = _buildMonthlySettlements(bookings, commissionRate);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('الفواتير والتسوية'),
        actions: [
          TextButton.icon(
            onPressed: () => _exportPDF(context, companyName, totalRevenue, commission, net, commissionRate, settlements),
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
            label: const Text('تصدير PDF'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ملخص مالي
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('إجمالي الإيرادات', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(currency.format(totalRevenue),
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                ]),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('عمولة المنصة ${(commissionRate * 100).round()}%',
                      style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  Text('-${currency.format(commission)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ]),
              ]),
              const Divider(color: Colors.white24, height: 20),
              Row(children: [
                const Text('صافي أرباحك:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                const Spacer(),
                Text(currency.format(net),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),

          // الحجوزات المكتملة
          const Text('الحجوزات المكتملة', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          if (completed.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('لا توجد حجوزات مكتملة بعد', style: TextStyle(color: AppColors.muted)),
            ))
          else
            ...completed.take(10).map((b) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.stroke),
              ),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(b.workerName, style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(DateFormat('dd/MM/yyyy', 'ar').format(b.date),
                      style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
                ]),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(currency.format(b.total),
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
                  Text('صافي: ${currency.format(b.total * (1 - commissionRate))}',
                      style: const TextStyle(fontSize: 11, color: AppColors.success)),
                ]),
              ]),
            )),

          const SizedBox(height: 20),
          // التسويات الشهرية
          const Text('التسويات الشهرية', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          if (settlements.isEmpty)
            const Center(child: Text('لا توجد تسويات', style: TextStyle(color: AppColors.muted)))
          else
            ...settlements.map((s) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.stroke),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(DateFormat('MMMM yyyy', 'ar').format(s.month),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text('مكتمل', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  _BillingRow('الإجمالي', currency.format(s.totalRevenue)),
                  _BillingRow('العمولة', '-${currency.format(s.commission)}'),
                  _BillingRow('الصافي', currency.format(s.net)),
                ]),
                const SizedBox(height: 6),
                Text('${s.bookingsCount} حجز مكتمل',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
              ]),
            )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  List<_Settlement> _buildMonthlySettlements(List<BookingModel> bookings, double commissionRate) {
    final Map<String, List<BookingModel>> byMonth = {};
    for (final b in bookings.where((b) => b.status == BookingStatus.completed)) {
      final key = '${b.date.year}-${b.date.month.toString().padLeft(2,'0')}';
      byMonth.putIfAbsent(key, () => []).add(b);
    }
    return byMonth.entries.map((e) {
      final revenue = e.value.fold<double>(0, (s, b) => s + b.total);
      return _Settlement(
        month: DateTime.parse('${e.key}-01'),
        totalRevenue: revenue,
        commission: revenue * commissionRate,
        net: revenue * (1 - commissionRate),
        bookingsCount: e.value.length,
      );
    }).toList()..sort((a, b) => b.month.compareTo(a.month));
  }

  Future<void> _exportPDF(
    BuildContext context,
    String companyName,
    double total,
    double commission,
    double net,
    double commissionRate,
    List<_Settlement> settlements,
  ) async {
    try {
      final doc = pw.Document();
      doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('كشف حساب — $companyName',
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('تاريخ التصدير: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 12)),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('إجمالي الإيرادات:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('\$${total.toStringAsFixed(2)}'),
            ]),
            pw.SizedBox(height: 6),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('عمولة المنصة (${(commissionRate * 100).round()}%):'),
              pw.Text('-\$${commission.toStringAsFixed(2)}'),
            ]),
            pw.SizedBox(height: 6),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('صافي الأرباح:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Text('\$${net.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            ]),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text('التسويات الشهرية:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            pw.SizedBox(height: 8),
            pw.Table.fromTextArray(
              headers: ['الشهر', 'الحجوزات', 'الإجمالي', 'العمولة', 'الصافي'],
              data: settlements.map((s) => [
                DateFormat('MM/yyyy').format(s.month),
                '${s.bookingsCount}',
                '\$${s.totalRevenue.toStringAsFixed(2)}',
                '-\$${s.commission.toStringAsFixed(2)}',
                '\$${s.net.toStringAsFixed(2)}',
              ]).toList(),
            ),
          ],
        ),
      ));

      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/billing_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(path);
      await file.writeAsBytes(await doc.save());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('✅ تم تصدير PDF: $path'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('خطأ في تصدير PDF: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ));
      }
    }
  }
}

class _Settlement {
  final DateTime month;
  final double totalRevenue, commission, net;
  final int bookingsCount;
  const _Settlement({required this.month, required this.totalRevenue,
      required this.commission, required this.net, required this.bookingsCount});
}

class _BillingRow extends StatelessWidget {
  final String label, value;
  const _BillingRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
    ]),
  );
}
