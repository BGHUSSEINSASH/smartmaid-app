import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/models.dart';
import '../providers/admin_providers.dart';

/// إنشاء حساب شركة كامل من قبل الإدارة (نشط فوراً، يتجاوز الموافقة).
class AdminCreateCompanyScreen extends ConsumerStatefulWidget {
  const AdminCreateCompanyScreen({super.key});
  @override
  ConsumerState<AdminCreateCompanyScreen> createState() =>
      _AdminCreateCompanyState();
}

class _AdminCreateCompanyState
    extends ConsumerState<AdminCreateCompanyScreen> {
  final _name = TextEditingController();
  final _reg = TextEditingController();
  final _contact = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _city = TextEditingController();
  final _desc = TextEditingController();
  double _commission = 0.20;
  int _maxWorkers = 5;
  SubscriptionPlan _plan = SubscriptionPlan.basic;
  bool _isPro = false;

  @override
  void dispose() {
    _name.dispose();
    _reg.dispose();
    _contact.dispose();
    _phone.dispose();
    _email.dispose();
    _city.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _err(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating));

  void _create() {
    if (_name.text.trim().isEmpty) { _err('أدخل اسم الشركة'); return; }
    if (_reg.text.trim().isEmpty) { _err('أدخل رقم السجل التجاري'); return; }
    final company = CompanyModel(
      id: 'co_${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim(),
      logoUrl: 'https://i.pravatar.cc/150?img=${DateTime.now().second % 70}',
      description: _desc.text.trim().isEmpty
          ? 'شركة خدمات منزلية'
          : _desc.text.trim(),
      location: _city.text.trim().isEmpty ? 'الرياض' : _city.text.trim(),
      isPro: _isPro,
      rating: 5.0,
      workerCount: 0,
      specialties: const ['تنظيف عام'],
      contactEmail: _email.text.trim(),
      contactPhone: _phone.text.trim(),
      commissionRate: _commission,
    );
    ref.read(adminCompaniesProvider.notifier).addCompany(company);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded,
            color: AppColors.success, size: 48),
        title: const Text('تم إنشاء الشركة'),
        content: Text(
            'تم إنشاء حساب "${_name.text.trim()}" وتفعيله فوراً بعمولة ${(_commission * 100).round()}%.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب شركة')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _field(_name, 'اسم الشركة التجاري *', Icons.business_rounded),
          const SizedBox(height: 12),
          _field(_reg, 'رقم السجل التجاري *', Icons.article_rounded),
          const SizedBox(height: 12),
          _field(_contact, 'اسم المسؤول', Icons.person_rounded),
          const SizedBox(height: 12),
          _field(_phone, 'رقم الهاتف', Icons.phone_rounded,
              type: TextInputType.phone),
          const SizedBox(height: 12),
          _field(_email, 'البريد الإلكتروني', Icons.alternate_email_rounded,
              type: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _field(_city, 'المدينة', Icons.location_city_rounded),
          const SizedBox(height: 12),
          _field(_desc, 'وصف الشركة', Icons.description_rounded, lines: 2),
          const SizedBox(height: 20),
          _sectionLabel('العمولة والاشتراك'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Column(children: [
              Row(children: [
                const Text('نسبة العمولة',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('${(_commission * 100).round()}%',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary)),
              ]),
              Slider(
                value: _commission,
                min: 0.05,
                max: 0.40,
                divisions: 35,
                label: '${(_commission * 100).round()}%',
                onChanged: (v) => setState(() => _commission = v),
              ),
              Row(children: [
                const Text('الحد الأقصى للعاملات',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('$_maxWorkers',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary)),
              ]),
              Slider(
                value: _maxWorkers.toDouble(),
                min: 1,
                max: 100,
                divisions: 99,
                label: '$_maxWorkers',
                onChanged: (v) => setState(() => _maxWorkers = v.round()),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _sectionLabel('خطة الاشتراك'),
          const SizedBox(height: 8),
          SegmentedButton<SubscriptionPlan>(
            segments: const [
              ButtonSegment(
                  value: SubscriptionPlan.basic, label: Text('أساسي')),
              ButtonSegment(value: SubscriptionPlan.pro, label: Text('برو')),
              ButtonSegment(
                  value: SubscriptionPlan.enterprise, label: Text('متميز')),
            ],
            selected: {_plan},
            onSelectionChanged: (s) => setState(() => _plan = s.first),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('حساب Pro مميّز',
                style: TextStyle(fontWeight: FontWeight.w700)),
            value: _isPro,
            onChanged: (v) => setState(() => _isPro = v),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _create,
              icon: const Icon(Icons.add_business_rounded),
              label: const Text('إنشاء وتفعيل الشركة'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionLabel(String t) => Text(t,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800));

  Widget _field(TextEditingController c, String label, IconData icon,
          {TextInputType? type, int lines = 1}) =>
      TextField(
        controller: c,
        keyboardType: type,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
        ),
      );
}
