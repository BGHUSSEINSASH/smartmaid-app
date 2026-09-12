import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/demo_data.dart';

class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  late final _nameCtrl =
      TextEditingController(text: DemoData.companies.first.name);
  late final _phoneCtrl =
      TextEditingController(text: DemoData.companies.first.contactPhone);
  late final _emailCtrl =
      TextEditingController(text: DemoData.companies.first.contactEmail);
  late final _descCtrl =
      TextEditingController(text: DemoData.companies.first.description);
  bool _acceptAuto = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الشركة')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Stack(children: [
              CircleAvatar(
                radius: 42,
                backgroundImage:
                    NetworkImage(DemoData.companies.first.logoUrl),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.edit_rounded,
                      size: 14, color: Colors.white),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 22),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'اسم الشركة')),
          const SizedBox(height: 12),
          TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'هاتف التواصل')),
          const SizedBox(height: 12),
          TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'البريد الرسمي')),
          const SizedBox(height: 12),
          TextField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'نبذة عن الشركة')),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.stroke),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('قبول الطلبات تلقائياً',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              subtitle: const Text('تأكيد الحجز فور استلامه دون مراجعة',
                  style: TextStyle(fontSize: 11.5)),
              value: _acceptAuto,
              activeThumbColor: AppColors.primary,
              onChanged: (v) => setState(() => _acceptAuto = v),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('تم حفظ إعدادات الشركة ✅'),
                    behavior: SnackBarBehavior.floating));
              },
              icon: const Icon(Icons.save_rounded, size: 19),
              label: const Text('حفظ التغييرات'),
            ),
          ),
        ],
      ),
    );
  }
}
