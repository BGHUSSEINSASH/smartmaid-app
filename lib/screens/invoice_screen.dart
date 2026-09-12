import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import '../core/theme/app_theme.dart';
import '../data/models.dart';
import '../providers/booking_provider.dart';
import '../providers/currency_provider.dart';

class InvoiceScreen extends ConsumerWidget {
  const InvoiceScreen({super.key});

  BookingModel? _resolveBooking(WidgetRef ref) {
    final flow = ref.watch(bookingFlowProvider);
    final bookings = ref.watch(myBookingsProvider);
    if (flow.bookingId != null) {
      for (final b in bookings) {
        if (b.id == flow.bookingId) return b;
      }
    }
    return bookings.isNotEmpty ? bookings.first : null;
  }

  Future<String> _generatePdf(BookingModel b, String currencyLabel) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Smart Maid',
                      style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#4F46E5'))),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('فاتورة خدمة',
                          style: pw.TextStyle(
                              fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text('INV-${b.id}',
                          style:
                              const pw.TextStyle(fontSize: 11, color: PdfColors.grey)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F3F0FF'),
                  borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(10)),
                ),
                child: pw.Table(
                  children: [
                    _row('العاملة', b.workerName),
                    _row('الخدمة', b.service),
                    _row('التاريخ', DateFormat('yyyy/MM/dd').format(b.date)),
                    _row('الوقت', b.timeSlot),
                    _row('حالة الدفع', switch (b.paymentStatus) {
                      PaymentStatus.paid => 'مدفوع',
                      PaymentStatus.held => 'محجوز',
                      _ => 'غير مدفوع',
                    }),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  'الإجمالي: ${b.total.toStringAsFixed(0)} $currencyLabel',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  'شكراً لثقتكم بخدمات Smart Maid',
                  style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/invoice_${b.id}.pdf');
    await file.writeAsBytes(await doc.save());
    return file.path;
  }

  static pw.TableRow _row(String k, String v) => pw.TableRow(
        decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
        children: [
          pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 6),
              child: pw.Text(k,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 6),
              child: pw.Text(v)),
        ],
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final booking = _resolveBooking(ref);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الفاتورة')),
        body: const Center(child: Text('لا توجد فاتورة لعرضها')),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('الفاتورة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.cleaning_services_rounded,
                        color: Colors.white, size: 24),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('فاتورة خدمة',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                      Text('#${booking.id}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.muted)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _invRow('العاملة', booking.workerName),
              _invRow('الخدمة', booking.service),
              _invRow('التاريخ', DateFormat('yyyy/MM/dd').format(booking.date)),
              _invRow('الوقت', booking.timeSlot),
              _invRow(
                  'حالة الدفع',
                  switch (booking.paymentStatus) {
                    PaymentStatus.paid => 'مدفوع ✅',
                    PaymentStatus.held => 'محجوز 🔒',
                    PaymentStatus.unpaid => 'غير مدفوع',
                    PaymentStatus.refunded => 'مسترد',
                  }),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الإجمالي',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  Text(currency.format(booking.total),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('شكراً لثقتك بخدمات Smart Maid 💜',
                    style: TextStyle(fontSize: 12, color: AppColors.muted)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  final path = await _generatePdf(
                      booking, currency.code == 'USD' ? 'USD' : 'IQD');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('تم حفظ الفاتورة في:\n$path'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.success,
                    ));
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('تعذر حفظ الملف'),
                        behavior: SnackBarBehavior.floating));
                  }
                }
              },
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 19),
              label: const Text('حفظ كملف PDF'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _invRow(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Text(k,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600)),
            const Spacer(),
            Flexible(
              child: Text(v,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
}
