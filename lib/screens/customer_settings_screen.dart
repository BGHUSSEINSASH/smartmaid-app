import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/address_provider.dart';
import '../providers/payment_cards_provider.dart';
import 'payment_cards_screen.dart';

class CustomerSettingsScreen extends ConsumerStatefulWidget {
  const CustomerSettingsScreen({super.key});
  @override
  ConsumerState<CustomerSettingsScreen> createState() => _CustomerSettingsState();
}

class _CustomerSettingsState extends ConsumerState<CustomerSettingsScreen> {
  String _defaultLang = 'عربية';
  bool _hidePhone = false;
  bool _allowRating = true;
  bool _notifyConfirm = true;
  bool _notifyArrival = true;
  bool _notifyComplete = true;
  bool _notifyOffers = true;

  final _instructionsCtrl = TextEditingController();

  @override
  void dispose() { _instructionsCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final addresses = ref.watch(addressProvider);
    final cards = ref.watch(paymentCardsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الحساب')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _group('الملف الشخصي', [
          _navTile(Icons.person_rounded, 'الاسم الكامل', user?.name ?? '', () {}),
          _navTile(Icons.phone_rounded, 'رقم الهاتف', user?.phone.isEmpty == true ? 'غير محدد' : user?.phone ?? '', () {}),
          _navTile(Icons.alternate_email_rounded, 'البريد الإلكتروني', user?.email ?? '', () {}),
          _navTile(Icons.flag_rounded, 'الجنسية', user?.customerInfo?.nationality.isEmpty == true ? 'غير محددة' : user?.customerInfo?.nationality ?? 'غير محددة', () {}),
        ]),
        const SizedBox(height: 14),
        _group('الحجز والخدمة', [
          ListTile(
            leading: const Icon(Icons.location_on_rounded, color: AppColors.primary),
            title: const Text('العنوان الافتراضي', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(addresses.isEmpty ? 'لا يوجد عنوان محفوظ' : '${addresses.length} عنوان محفوظ'),
            trailing: const Icon(Icons.chevron_left_rounded),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _AddressQuickPicker())),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.credit_card_rounded, color: AppColors.primary),
            title: const Text('البطاقة الافتراضية', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(cards.isEmpty ? 'لا توجد بطاقة' : '•••• ${cards.firstWhere((c) => c.isDefault, orElse: () => cards.first).lastFour}'),
            trailing: const Icon(Icons.chevron_left_rounded),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentCardsScreen())),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.language_rounded, color: AppColors.primary),
            title: const Text('لغة العاملة المفضّلة', style: TextStyle(fontWeight: FontWeight.w700)),
            trailing: DropdownButton<String>(
              value: _defaultLang, underline: const SizedBox(),
              items: ['عربية','إنجليزية','فلبينية'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) => setState(() => _defaultLang = v!),
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _instructionsCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'تعليمات افتراضية للحجز',
                hintText: 'مثال: الرجاء إحضار معدات التنظيف...',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        _group('الإشعارات', [
          _switchTile(Icons.check_circle_rounded, 'تأكيد الحجز', _notifyConfirm, (v) => setState(() => _notifyConfirm = v)),
          _switchTile(Icons.directions_walk_rounded, 'وصول العاملة', _notifyArrival, (v) => setState(() => _notifyArrival = v)),
          _switchTile(Icons.done_all_rounded, 'انتهاء الخدمة', _notifyComplete, (v) => setState(() => _notifyComplete = v)),
          _switchTile(Icons.local_offer_rounded, 'العروض والخصومات', _notifyOffers, (v) => setState(() => _notifyOffers = v)),
        ]),
        const SizedBox(height: 14),
        _group('الخصوصية', [
          _switchTile(Icons.phone_locked_rounded, 'إخفاء رقم الهاتف عن العاملة', _hidePhone, (v) => setState(() => _hidePhone = v)),
          _switchTile(Icons.star_rounded, 'السماح بتقييمي', _allowRating, (v) => setState(() => _allowRating = v)),
        ]),
        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _group(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(padding: const EdgeInsets.only(bottom: 8, right: 4), child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.muted))),
      Container(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.stroke)), clipBehavior: Clip.antiAlias, child: Column(children: children)),
    ],
  );

  Widget _navTile(IconData icon, String title, String sub, VoidCallback onTap) => ListTile(
    leading: Icon(icon, color: AppColors.primary),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
    trailing: const Icon(Icons.chevron_left_rounded),
    onTap: onTap,
  );

  Widget _switchTile(IconData icon, String label, bool value, ValueChanged<bool> onChanged) => SwitchListTile(
    secondary: Icon(icon, color: AppColors.primary),
    title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    value: value, onChanged: onChanged,
  );
}

// بطاقة سريعة لاختيار العنوان
class _AddressQuickPicker extends ConsumerWidget {
  const _AddressQuickPicker();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('اختيار العنوان الافتراضي')),
      body: addresses.isEmpty
          ? const Center(child: Text('لا توجد عناوين محفوظة'))
          : ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (_, i) {
                final a = addresses[i];
                return ListTile(
                  leading: const Icon(Icons.location_on_rounded, color: AppColors.primary),
                  title: Text(a.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(a.details),
                  trailing: a.isDefault ? const Icon(Icons.check_circle_rounded, color: AppColors.success) : null,
                  onTap: () {
                    ref.read(addressProvider.notifier).setDefault(a.id);
                    Navigator.pop(context);
                  },
                );
              },
            ),
    );
  }
}
