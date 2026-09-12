import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/models.dart';
import '../providers/payment_cards_provider.dart';
import '../widgets/pro_components.dart';

class PaymentCardsScreen extends ConsumerStatefulWidget {
  const PaymentCardsScreen({super.key});
  @override
  ConsumerState<PaymentCardsScreen> createState() => _PaymentCardsScreenState();
}

class _PaymentCardsScreenState extends ConsumerState<PaymentCardsScreen> {
  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(paymentCardsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('بطاقاتي البنكية')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCardSheet,
        icon: const Icon(Icons.add_card_rounded),
        label: const Text('إضافة بطاقة'),
      ),
      body: cards.isEmpty
          ? EmptyState(
              icon: Icons.credit_card_off_rounded,
              title: 'لا توجد بطاقات محفوظة',
              subtitle: 'أضف بطاقتك البنكية للدفع السريع',
              actionLabel: 'إضافة بطاقة',
              onAction: _showAddCardSheet,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cards.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _CardTile(card: cards[i]),
            ),
    );
  }

  void _showAddCardSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddCardSheet(
        onAdd: (card) {
          ref.read(paymentCardsProvider.notifier).add(card);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تمت إضافة البطاقة بنجاح'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ));
        },
      ),
    );
  }
}

class _CardTile extends ConsumerWidget {
  final PaymentCard card;
  const _CardTile({required this.card});

  Color get _bgColor => switch (card.brand) {
    CardBrand.visa => const Color(0xFF1A1F71),
    CardBrand.mastercard => const Color(0xFF252525),
    CardBrand.amex => const Color(0xFF007AC1),
    CardBrand.other => AppColors.primary,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_bgColor, _bgColor.withValues(alpha: .7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _bgColor.withValues(alpha: .35), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Stack(
        children: [
          // decorative circles
          Positioned(top: -20, right: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .06)))),
          Positioned(bottom: -30, left: -10, child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .04)))),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Text(card.brandName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  const Spacer(),
                  if (card.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .15), borderRadius: BorderRadius.circular(99)),
                      child: const Text('افتراضية', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
                    onSelected: (v) {
                      if (v == 'default') ref.read(paymentCardsProvider.notifier).setDefault(card.id);
                      if (v == 'delete') ref.read(paymentCardsProvider.notifier).remove(card.id);
                    },
                    itemBuilder: (_) => [
                      if (!card.isDefault)
                        const PopupMenuItem(value: 'default', child: ListTile(leading: Icon(Icons.star_rounded, color: AppColors.warning), title: Text('تعيين كافتراضية'), dense: true)),
                      const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_rounded, color: AppColors.error), title: Text('حذف البطاقة'), dense: true)),
                    ],
                  ),
                ]),
                Text('•••• •••• •••• ${card.lastFour}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 2)),
                Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('حامل البطاقة', style: TextStyle(color: Colors.white54, fontSize: 10)),
                    Text(card.holderName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(width: 24),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('صالحة حتى', style: TextStyle(color: Colors.white54, fontSize: 10)),
                    Text('${card.expiryMonth}/${card.expiryYear}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                  ]),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddCardSheet extends StatefulWidget {
  final void Function(PaymentCard) onAdd;
  const _AddCardSheet({required this.onAdd});

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _numCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  bool _isDefault = false;
  bool _obscureCvv = true;
  CardBrand _brand = CardBrand.other;

  @override
  void dispose() {
    _numCtrl.dispose(); _nameCtrl.dispose();
    _expiryCtrl.dispose(); _cvvCtrl.dispose();
    super.dispose();
  }

  CardBrand _detectBrand(String number) {
    if (number.startsWith('4')) return CardBrand.visa;
    if (number.startsWith('5') || number.startsWith('2')) return CardBrand.mastercard;
    if (number.startsWith('3')) return CardBrand.amex;
    return CardBrand.other;
  }

  void _submit() {
    final raw = _numCtrl.text.replaceAll(' ', '');
    if (raw.length < 16 || _nameCtrl.text.isEmpty || _expiryCtrl.text.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أكمل جميع الحقول'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating));
      return;
    }
    final parts = _expiryCtrl.text.split('/');
    final card = PaymentCard(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      lastFour: raw.substring(raw.length - 4),
      brand: _brand,
      holderName: _nameCtrl.text.trim(),
      expiryMonth: parts.first.trim(),
      expiryYear: parts.length > 1 ? parts.last.trim() : '00',
      isDefault: _isDefault,
    );
    widget.onAdd(card);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('إضافة بطاقة جديدة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        TextField(
          controller: _numCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _CardNumberFormatter(),
          ],
          decoration: InputDecoration(
            labelText: 'رقم البطاقة',
            prefixIcon: const Icon(Icons.credit_card_rounded),
            suffixIcon: _brand != CardBrand.other
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(switch (_brand) { CardBrand.visa => 'VISA', CardBrand.mastercard => 'MC', CardBrand.amex => 'AMEX', CardBrand.other => '' }, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                  )
                : null,
          ),
          onChanged: (v) => setState(() => _brand = _detectBrand(v.replaceAll(' ', ''))),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'اسم حامل البطاقة', prefixIcon: Icon(Icons.person_rounded)),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: TextField(
            controller: _expiryCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')), LengthLimitingTextInputFormatter(5)],
            decoration: const InputDecoration(labelText: 'MM/YY', prefixIcon: Icon(Icons.calendar_today_rounded)),
            onChanged: (v) {
              if (v.length == 2 && !v.contains('/')) {
                _expiryCtrl.text = '$v/';
                _expiryCtrl.selection = TextSelection.collapsed(offset: 3);
              }
            },
          )),
          const SizedBox(width: 12),
          Expanded(child: TextField(
            controller: _cvvCtrl,
            keyboardType: TextInputType.number,
            obscureText: _obscureCvv,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
            decoration: InputDecoration(
              labelText: 'CVV',
              prefixIcon: const Icon(Icons.lock_rounded),
              suffixIcon: IconButton(icon: Icon(_obscureCvv ? Icons.visibility_off_rounded : Icons.visibility_rounded), onPressed: () => setState(() => _obscureCvv = !_obscureCvv)),
            ),
          )),
        ]),
        const SizedBox(height: 4),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('تعيين كبطاقة افتراضية', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          value: _isDefault,
          onChanged: (v) => setState(() => _isDefault = v),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 52, width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.add_card_rounded),
            label: const Text('إضافة البطاقة'),
          ),
        ),
      ]),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue nw) {
    final digits = nw.text.replaceAll(' ', '');
    if (digits.length > 16) return old;
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final result = buffer.toString();
    return TextEditingValue(text: result, selection: TextSelection.collapsed(offset: result.length));
  }
}
