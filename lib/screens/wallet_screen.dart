import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../widgets/ai_app_bar_button.dart';
import '../providers/currency_provider.dart';
import '../providers/wallet_provider.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  void _topUpSheet() {
    double amount = 50;
    final currency = ref.read(currencyProvider);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(ctx).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('شحن المحفظة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('اختر المبلغ أو أدخل مبلغاً مخصصاً',
                    style: TextStyle(fontSize: 13, color: AppColors.muted)),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [25, 50, 100, 250].map((v) {
                    final sel = amount == v.toDouble();
                    return GestureDetector(
                      onTap: () => setSheet(() => amount = v.toDouble()),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 70,
                        height: 54,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: sel
                                  ? AppColors.primary
                                  : AppColors.stroke),
                        ),
                        child: Text(currency.format(v.toDouble()),
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: sel ? Colors.white : AppColors.primary)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'مبلغ مخصص',
                    prefixIcon: Icon(Icons.attach_money_rounded),
                  ),
                  onChanged: (v) {
                    final d = double.tryParse(v);
                    if (d != null) setSheet(() => amount = d);
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (amount <= 0) return;
                      ref.read(walletProvider.notifier).topUp(amount);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('تم شحن ${currency.format(amount)} إلى محفظتك ✅'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.success,
                      ));
                    },
                    icon: const Icon(Icons.add_card_rounded, size: 19),
                    label: Text('اشحن ${currency.format(amount)}'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _withdrawSheet() {
    final ctrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('طلب سحب',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'المبلغ (\$)'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final v = double.tryParse(ctrl.text.trim()) ?? 0;
                    final ok = ref.read(walletProvider.notifier).withdraw(v);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok
                          ? 'تم إرسال طلب السحب، قيد المراجعة ⏳'
                          : 'مبلغ غير صالح أو يتجاوز الرصيد'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor:
                          ok ? AppColors.success : AppColors.error,
                    ));
                  },
                  icon: const Icon(Icons.upload_rounded, size: 19),
                  label: const Text('إرسال الطلب'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('محفظة SmartPay'), actions: [aiAppBarButton(context, initialMessage: 'كيف أشحن محفظتي؟')]),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppColors.balanceGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white70, size: 18),
                  const SizedBox(width: 6),
                  Text('الرصيد الحالي',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9))),
                ]),
                const SizedBox(height: 10),
                Text(currency.format(wallet.balanceUsd),
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _WalletAction(
                        icon: Icons.add_rounded,
                        label: 'شحن رصيد',
                        onTap: _topUpSheet,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _WalletAction(
                        icon: Icons.upload_rounded,
                        label: 'طلب سحب',
                        onTap: _withdrawSheet,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('سجل المعاملات (${wallet.transactions.length})',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          ...wallet.transactions.map((t) {
            final credit = t.isCredit;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.stroke),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: (credit ? AppColors.success : AppColors.error)
                          .withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      switch (t.type) {
                        WalletTxType.topup => Icons.add_card_rounded,
                        WalletTxType.payment => Icons.shopping_bag_rounded,
                        WalletTxType.withdrawal => Icons.upload_rounded,
                        WalletTxType.earning => Icons.trending_up_rounded,
                        WalletTxType.refund => Icons.replay_rounded,
                      },
                      size: 20,
                      color: credit ? AppColors.success : AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13.5)),
                        Text(DateFormat('yyyy/MM/dd – HH:mm').format(t.date),
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  Text(
                    '${t.amountUsd > 0 ? '+' : ''}${currency.format(t.amountUsd)}',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color:
                            credit ? AppColors.success : AppColors.error),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _WalletAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 19),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}


