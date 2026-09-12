import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../core/api/api_client.dart';
import '../core/nav/app_nav.dart';
import '../core/theme/app_theme.dart';
import '../data/models.dart';
import '../providers/booking_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/loyalty_provider.dart';
import '../providers/offers_provider.dart';
import '../providers/platform_control_provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/wallet_provider.dart';
import 'invoice_screen.dart';

enum PayMethod { card, wallet, cash }

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PayMethod _method = PayMethod.card;
  bool _processing = false;
  bool _paid = false;
  bool _failed = false;
  String _failReason = '';
  late final ConfettiController _confettiCtrl =
      ConfettiController(duration: const Duration(seconds: 3));
  final _cardCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _cardCtrl.dispose();
    _nameCtrl.dispose();
    _expCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final totals = ref.read(bookingTotalsProvider);
    if (_method == PayMethod.wallet) {
      final balance = ref.read(walletProvider).balanceUsd;
      if (balance < totals.total) {
        _toast('رصيد المحفظة غير كافٍ — اشحن المحفظة أولاً');
        return;
      }
      ref
          .read(walletProvider.notifier)
          .pay(totals.total, 'دفع حجز عبر SmartPay');
    }
    if (_method == PayMethod.card &&
        _cardCtrl.text.replaceAll(' ', '').length < 12) {
      _toast('أدخل رقم بطاقة صحيح');
      return;
    }
    setState(() => _processing = true);
    await Future.delayed(const Duration(seconds: 2));

    final digits = _cardCtrl.text.replaceAll(' ', '');
    if (_method == PayMethod.card && digits == '4000000000000002') {
      setState(() {
        _processing = false;
        _failed = true;
        _failReason = 'رفضت البطاقة العملية (بطاقة اختبار مرفوضة). جرّب بطاقة أخرى أو المحفظة.';
      });
      Haptics.medium();
      return;
    }

    final flow = ref.read(bookingFlowProvider);
    final intent = await ApiClient.post('/payments/intent', {
      'bookingId': flow.bookingId ?? '',
      'amount': totals.total,
    });
    if (intent == null && !ApiClient.demoOnly) {
      debugPrint('payments API unreachable — continuing in demo mode');
    }

    if (flow.bookingId != null) {
      ref.read(myBookingsProvider.notifier).markPaid(flow.bookingId!);
      ref.read(myBookingsProvider.notifier).confirmBooking(flow.bookingId!);
    }
    ref
        .read(bookingFlowProvider.notifier)
        .setStatus(bookingStatus: 'confirmed', paymentStatus: 'held');
    ref.read(couponProvider.notifier).clear();
    setState(() {
      _processing = false;
      _paid = true;
    });
    Haptics.success();
    _confettiCtrl.play();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totals = ref.watch(bookingTotalsProvider);
    final currency = ref.watch(currencyProvider);
    final flow = ref.watch(bookingFlowProvider);
    final wallet = ref.watch(walletProvider);
    final flags = ref.watch(platformFlagsProvider);
    final sub = ref.watch(subscriptionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    // خصم الاشتراك
    final subDiscountPct = sub.isActive
        ? (sub.tier == SubscriptionTier.platinum ? 0.15 : 0.10)
        : 0.0;
    final subDiscount = totals.total * subDiscountPct;
    final finalTotal = totals.total - subDiscount;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
          title: Text(_paid ? 'تم الدفع' : (_failed ? 'فشل الدفع' : 'إتمام الدفع')),
          automaticallyImplyLeading: !_paid),
      body: _paid
          ? _buildSuccess(flow, currency)
          : _failed
              ? _buildFailed(currency)
              : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.balanceGradient,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Text('المبلغ المطلوب',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  if (subDiscount > 0) ...[
                    Text(
                      currency.format(totals.total),
                      style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.lineThrough),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(currency.format(finalTotal),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800)),
                  if (subDiscount > 0) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'خصم ${(subDiscountPct * 100).round()}% — ${sub.tier.arabicLabel}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${flow.worker?.name ?? ''} • ${flow.bookingTypeLabel}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('طريقة الدفع',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (flags.cardPaymentEnabled)
              _MethodTile(
                icon: Icons.credit_card_rounded,
                title: 'بطاقة بنكية',
                subtitle: 'Visa / MasterCard',
                selected: _method == PayMethod.card,
                onTap: () => setState(() => _method = PayMethod.card),
              ),
            if (flags.cardPaymentEnabled) const SizedBox(height: 10),
            if (flags.walletPaymentEnabled)
              _MethodTile(
                icon: Icons.account_balance_wallet_rounded,
                title: 'محفظة SmartPay',
                subtitle: 'الرصيد: ${currency.format(wallet.balanceUsd)}',
                selected: _method == PayMethod.wallet,
                onTap: () => setState(() => _method = PayMethod.wallet),
              ),
            if (flags.walletPaymentEnabled) const SizedBox(height: 10),
            if (flags.cashPaymentEnabled)
              _MethodTile(
                icon: Icons.payments_rounded,
                title: 'نقداً عند الوصول',
                subtitle: 'ادفع نقداً للعاملة بعد إتمام الخدمة',
                selected: _method == PayMethod.cash,
                onTap: () => setState(() => _method = PayMethod.cash),
              ),
            // إذا طريقة الدفع المختارة أصبحت معطّلة — اختر المتاحة
            if (!flags.cardPaymentEnabled && _method == PayMethod.card &&
                (flags.walletPaymentEnabled || flags.cashPaymentEnabled))
              Builder(builder: (_) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() => _method = flags.walletPaymentEnabled
                      ? PayMethod.wallet
                      : PayMethod.cash);
                });
                return const SizedBox.shrink();
              }),
            if (_method == PayMethod.card) ...[
              const SizedBox(height: 24),
              TextField(
                controller: _cardCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'رقم البطاقة', hintText: '4242 4242 4242 4242'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameCtrl,
                decoration:
                    const InputDecoration(labelText: 'اسم حامل البطاقة'),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _expCtrl,
                    decoration: const InputDecoration(
                        labelText: 'تاريخ الانتهاء', hintText: 'MM/YY'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _cvvCtrl,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'CVV', hintText: '•••'),
                  ),
                ),
              ]),
            ],
          ],
        ),
      ),
      bottomSheet: !_paid
          ? Container(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 14,
                  bottom: 14 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _processing ? null : _pay,
                  icon: _processing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.lock_rounded, size: 18),
                  label: Text(_processing
                      ? 'جارٍ المعالجة...'
                      : 'ادفع ${currency.format(totals.total)}'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildFailed(AppCurrency currency) {
    final totals = ref.read(bookingTotalsProvider);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 56, color: AppColors.error),
            ),
            const SizedBox(height: 24),
            const Text('لم تتم عملية الدفع',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(
              _failReason,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13.5, color: AppColors.muted, height: 1.6),
            ),
            const SizedBox(height: 8),
            Text('المبلغ المطلوب: ${currency.format(totals.total)}',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => setState(() {
                  _failed = false;
                  _failReason = '';
                }),
                icon: const Icon(Icons.refresh_rounded, size: 19),
                label: const Text('إعادة المحاولة'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                child: const Text('إلغاء والعودة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(BookingFlowState flow, AppCurrency currency) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded,
                      size: 60, color: AppColors.success),
                ),
                const SizedBox(height: 28),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: totalsOf(flow)),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => Text(
                    '${currency.format(v.toDouble())} 🎉',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.success),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('تم الدفع بنجاح!',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text(
                  'حجزك مع ${flow.worker?.name ?? 'العاملة'} مؤكد ✅\nالمبلغ محجوز — يُحرر بعد إنهاء المهمة',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.muted, height: 1.6),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (_) => const InvoiceScreen()));
                    },
                    icon: const Icon(Icons.receipt_long_rounded, size: 19),
                    label: const Text('عرض الفاتورة'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    child: const Text('العودة للرئيسية'),
                  ),
                ),
              ],
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiCtrl,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 60,
          maxBlastForce: 24,
          minBlastForce: 8,
          gravity: 0.28,
          colors: const [
            AppColors.primary,
            AppColors.accent,
            AppColors.success,
            AppColors.warning,
          ],
        ),
      ],
    );
  }

  int totalsOf(BookingFlowState flow) =>
      ref.read(bookingTotalsProvider).total.round();
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.stroke,
              width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: selected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
