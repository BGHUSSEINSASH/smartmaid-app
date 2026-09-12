import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class WorkerSettingsScreen extends ConsumerStatefulWidget {
  const WorkerSettingsScreen({super.key});
  @override
  ConsumerState<WorkerSettingsScreen> createState() => _WorkerSettingsState();
}

class _WorkerSettingsState extends ConsumerState<WorkerSettingsScreen> {
  final _bioCtrl = TextEditingController();
  final _ibanCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  bool _autoAccept = false;
  bool _available = true;
  int _maxDailyJobs = 3;
  double _maxDistance = 20;
  bool _notifyNewJob = true;
  bool _notifyPayment = true;
  bool _notifyCancel = true;

  final _allSkills = ['تنظيف عام','طبخ','رعاية أطفال','كبار السن','غسيل وكواء','تنظيف عميق'];
  final _selectedSkills = <String>{'تنظيف عام','غسيل وكواء'};

  @override
  void initState() {
    super.initState();
    final wi = ref.read(authProvider).user?.workerInfo;
    if (wi != null) {
      _bioCtrl.text = wi.bio;
      _ibanCtrl.text = wi.iban;
      _bankCtrl.text = wi.bankName;
      _available = wi.kycStatus.name == 'approved';
      _selectedSkills.clear();
      _selectedSkills.addAll(wi.skills);
    }
  }

  @override
  void dispose() { _bioCtrl.dispose(); _ibanCtrl.dispose(); _bankCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الحساب')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // الحالة
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: _available ? AppColors.heroGradient : const LinearGradient(colors: [Color(0xFF475569),Color(0xFF1E293B)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(children: [
            Icon(_available ? Icons.check_circle_rounded : Icons.cancel_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_available ? 'متاحة للعمل' : 'غير متاحة', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              Text(_available ? 'تستقبلين الطلبات الآن' : 'لن تصلك طلبات جديدة', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ])),
            Switch.adaptive(value: _available, onChanged: (v) => setState(() => _available = v), activeColor: Colors.white, activeTrackColor: Colors.white24),
          ]),
        ),
        const SizedBox(height: 14),
        _group('المعلومات المهنية', [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(controller: _bioCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'النبذة التعريفية', prefixIcon: Icon(Icons.info_outline_rounded))),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Text('المهارات', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(spacing: 8, runSpacing: 8, children: _allSkills.map((s) {
              final sel = _selectedSkills.contains(s);
              return FilterChip(label: Text(s), selected: sel, selectedColor: AppColors.primary.withValues(alpha: .15), checkmarkColor: AppColors.primary, onSelected: (v) => setState(() => v ? _selectedSkills.add(s) : _selectedSkills.remove(s)));
            }).toList()),
          ),
        ]),
        const SizedBox(height: 14),
        _group('إعدادات الطلبات', [
          _switchTile(Icons.auto_awesome_rounded, 'قبول الطلبات تلقائياً', _autoAccept, (v) => setState(() => _autoAccept = v)),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _sliderTile('الحد الأقصى للطلبات اليومية', '$_maxDailyJobs طلبات', _maxDailyJobs.toDouble(), 1, 10, (v) => setState(() => _maxDailyJobs = v.round())),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _sliderTile('نطاق الخدمة', '$_maxDistance كم', _maxDistance, 5, 100, (v) => setState(() => _maxDistance = v.roundToDouble())),
        ]),
        const SizedBox(height: 14),
        _group('البيانات البنكية', [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(controller: _bankCtrl, decoration: const InputDecoration(labelText: 'اسم البنك', prefixIcon: Icon(Icons.account_balance_rounded))),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(controller: _ibanCtrl, decoration: const InputDecoration(labelText: 'رقم IBAN', prefixIcon: Icon(Icons.numbers_rounded))),
          ),
        ]),
        const SizedBox(height: 14),
        _group('الإشعارات', [
          _switchTile(Icons.notifications_rounded, 'طلب عمل جديد', _notifyNewJob, (v) => setState(() => _notifyNewJob = v)),
          _switchTile(Icons.account_balance_wallet_rounded, 'تحويل مالي', _notifyPayment, (v) => setState(() => _notifyPayment = v)),
          _switchTile(Icons.cancel_rounded, 'إلغاء حجز', _notifyCancel, (v) => setState(() => _notifyCancel = v)),
        ]),
        const SizedBox(height: 16),
        SizedBox(height: 52, child: ElevatedButton.icon(
          onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الإعدادات'), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.success)); },
          icon: const Icon(Icons.save_rounded), label: const Text('حفظ الإعدادات'),
        )),
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

  Widget _switchTile(IconData icon, String label, bool value, ValueChanged<bool> cb) => SwitchListTile(
    secondary: Icon(icon, color: AppColors.primary),
    title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)), value: value, onChanged: cb,
  );

  Widget _sliderTile(String label, String display, double value, double min, double max, ValueChanged<double> cb) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))), Text(display, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900))])),
      Slider(value: value, min: min, max: max, onChanged: cb),
    ],
  );
}
