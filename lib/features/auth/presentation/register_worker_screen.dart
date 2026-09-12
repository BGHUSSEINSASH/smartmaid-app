import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models.dart';
import '../../../providers/auth_provider.dart';
import 'register_shared_widgets.dart';
import 'auth_widgets.dart';

/// تسجيل العاملة — 3 خطوات
class RegisterWorkerScreen extends ConsumerStatefulWidget {
  const RegisterWorkerScreen({super.key});
  @override
  ConsumerState<RegisterWorkerScreen> createState() => _RegisterWorkerState();
}

class _RegisterWorkerState extends ConsumerState<RegisterWorkerScreen> {
  final _page = PageController();
  int _step = 0;

  // خطوة 1 — بيانات شخصية
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _passportCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  bool _obscure = true;
  bool _accepted = false;
  String _nationality = 'الفلبين';

  // خطوة 2 — بيانات العمل
  final _skillsAll = ['تنظيف عام', 'طبخ', 'رعاية أطفال', 'رعاية كبار السن', 'غسيل وكواء', 'تنظيف عميق'];
  List<String> _selectedSkills = [];
  int _exp = 1;
  final _bioCtrl = TextEditingController();
  double _hourly = 30;
  double _daily = 120;
  double _monthly = 1500;

  // خطوة 3 — مستندات
  final _ibanCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();

  static const _nationalities = [
    'الفلبين', 'إندونيسيا', 'إثيوبيا', 'سريلانكا',
    'الهند', 'نيبال', 'بنغلاديش', 'أخرى',
  ];

  void _err(String m) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating));

  void _next() {
    if (_step == 0) {
      if (_nameCtrl.text.trim().length < 2) { _err('أدخل الاسم'); return; }
      if (_passportCtrl.text.trim().isEmpty) { _err('أدخل رقم جواز السفر'); return; }
      if (!_accepted) { _err('يجب الموافقة على الشروط'); return; }
    } else if (_step == 1) {
      if (_selectedSkills.isEmpty) { _err('اختر مهارة واحدة على الأقل'); return; }
    }
    setState(() => _step++);
    _page.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
  }

  Future<void> _submit() async {
    final ok = await ref.read(authProvider.notifier).register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      role: AppRole.worker,
      phone: _phoneCtrl.text.trim(),
      extraData: {
        'nationality': _nationality,
        'passportNumber': _passportCtrl.text.trim(),
        'passportExpiry': _expiryCtrl.text.trim(),
        'skills': _selectedSkills,
        'experienceYears': _exp,
        'bio': _bioCtrl.text.trim(),
        'hourlyRate': _hourly,
        'dailyRate': _daily,
        'monthlyRate': _monthly,
        'bankName': _bankCtrl.text.trim(),
        'iban': _ibanCtrl.text.trim(),
        'kycStatus': 'pending',
      },
    );
    if (!mounted) return;
    if (ok) {
      // عاملة جديدة → KYC pending
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('طلبك قيد المراجعة'),
          content: const Text(
              'شكراً لتسجيلك! سيتم مراجعة بياناتك ومستنداتك خلال 24 ساعة وسيصلك إشعار عند القبول.'),
          actions: [
            ElevatedButton(
              onPressed: () { Navigator.pop(context); context.go('/login'); },
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    } else {
      _err(ref.read(authProvider).error ?? 'تعذر إنشاء الحساب');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل — عاملة'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _StepBar(steps: 3, current: _step),
        ),
      ),
      body: PageView(
        controller: _page,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // ── خطوة 1: بيانات شخصية ─────────────────────────────
          _buildStep1(),
          // ── خطوة 2: بيانات العمل ─────────────────────────────
          _buildStep2(),
          // ── خطوة 3: المستندات ────────────────────────────────
          _buildStep3(auth.isLoading),
        ],
      ),
    );
  }

  Widget _buildStep1() => SingleChildScrollView(
    padding: const EdgeInsets.all(22),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const _SectionTitle('البيانات الشخصية'),
      const SizedBox(height: 16),
      AuthField(controller: _nameCtrl, label: 'الاسم الكامل', icon: Icons.person_rounded),
      const SizedBox(height: 12),
      AuthField(controller: _phoneCtrl, label: 'رقم الهاتف', icon: Icons.phone_rounded,
          keyboardType: TextInputType.phone),
      const SizedBox(height: 12),
      AuthField(controller: _emailCtrl, label: 'البريد الإلكتروني',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _nationality,
        decoration: const InputDecoration(labelText: 'الجنسية'),
        items: _nationalities.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => setState(() => _nationality = v!),
      ),
      const SizedBox(height: 12),
      AuthField(controller: _passportCtrl, label: 'رقم جواز السفر',
          icon: Icons.badge_rounded),
      const SizedBox(height: 12),
      AuthField(controller: _expiryCtrl, label: 'تاريخ انتهاء الجواز (YYYY-MM-DD)',
          icon: Icons.calendar_today_rounded,
          keyboardType: TextInputType.datetime),
      const SizedBox(height: 12),
      AuthField(controller: _passCtrl, label: 'كلمة المرور',
          icon: Icons.lock_rounded, obscure: _obscure,
          suffix: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded),
            onPressed: () => setState(() => _obscure = !_obscure),
          )),
      const SizedBox(height: 8),
      CheckboxListTile(
        value: _accepted,
        onChanged: (v) => setState(() => _accepted = v ?? false),
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: const Text('أوافق على الشروط وسياسة الخصوصية',
            style: TextStyle(fontSize: 13)),
      ),
      const SizedBox(height: 12),
      SizedBox(height: 52, child: ElevatedButton.icon(
        onPressed: _next,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: const Text('التالي'),
      )),
    ]),
  );

  Widget _buildStep2() => SingleChildScrollView(
    padding: const EdgeInsets.all(22),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const _SectionTitle('بيانات العمل'),
      const SizedBox(height: 16),
      const Text('المهارات (اختر ما ينطبق)', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _skillsAll.map((skill) {
          final sel = _selectedSkills.contains(skill);
          return FilterChip(
            label: Text(skill),
            selected: sel,
            onSelected: (v) => setState(() {
              v ? _selectedSkills.add(skill) : _selectedSkills.remove(skill);
            }),
            selectedColor: AppColors.primary.withValues(alpha: 0.15),
            checkmarkColor: AppColors.primary,
          );
        }).toList(),
      ),
      const SizedBox(height: 16),
      Text('سنوات الخبرة: $_exp سنة',
          style: const TextStyle(fontWeight: FontWeight.w700)),
      Slider(
        value: _exp.toDouble(),
        min: 0, max: 20,
        divisions: 20,
        label: '$_exp',
        onChanged: (v) => setState(() => _exp = v.round()),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _bioCtrl,
        maxLines: 3,
        decoration: const InputDecoration(
            labelText: 'نبذة شخصية', prefixIcon: Icon(Icons.info_outline_rounded)),
      ),
      const SizedBox(height: 16),
      const Text('المعدل المطلوب', style: TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      _RateField(label: 'بالساعة (د.ك)', value: _hourly, icon: Icons.access_time_rounded,
          onChanged: (v) => setState(() => _hourly = v)),
      const SizedBox(height: 10),
      _RateField(label: 'باليوم (د.ك)', value: _daily, icon: Icons.calendar_today_rounded,
          onChanged: (v) => setState(() => _daily = v)),
      const SizedBox(height: 10),
      _RateField(label: 'بالشهر (د.ك)', value: _monthly, icon: Icons.date_range_rounded,
          onChanged: (v) => setState(() => _monthly = v)),
      const SizedBox(height: 20),
      SizedBox(height: 52, child: ElevatedButton.icon(
        onPressed: _next,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: const Text('التالي'),
      )),
    ]),
  );

  Widget _buildStep3(bool loading) => SingleChildScrollView(
    padding: const EdgeInsets.all(22),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const _SectionTitle('المستندات والبيانات البنكية'),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4))),
        child: const Row(children: [
          Icon(Icons.info_rounded, color: AppColors.warning, size: 20),
          SizedBox(width: 10),
          Expanded(child: Text('ستتم مراجعة المستندات خلال 24 ساعة',
              style: TextStyle(fontSize: 13))),
        ]),
      ),
      const SizedBox(height: 16),
      _DocUploadTile(icon: Icons.badge_rounded, label: 'صورة جواز السفر'),
      const SizedBox(height: 10),
      _DocUploadTile(icon: Icons.face_rounded, label: 'صورة شخصية (Selfie)'),
      const SizedBox(height: 16),
      AuthField(controller: _bankCtrl, label: 'اسم البنك', icon: Icons.account_balance_rounded),
      const SizedBox(height: 12),
      AuthField(controller: _ibanCtrl, label: 'رقم IBAN', icon: Icons.numbers_rounded),
      const SizedBox(height: 24),
      SizedBox(height: 52, child: ElevatedButton.icon(
        onPressed: loading ? null : _submit,
        icon: loading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.send_rounded),
        label: Text(loading ? 'جارٍ الإرسال...' : 'إرسال الطلب'),
      )),
    ]),
  );
}

class _RateField extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final ValueChanged<double> onChanged;
  const _RateField({required this.label, required this.value,
      required this.icon, required this.onChanged});

  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: value.toStringAsFixed(0),
    keyboardType: TextInputType.number,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20)),
    onChanged: (v) { final d = double.tryParse(v); if (d != null) onChanged(d); },
  );
}

class _DocUploadTile extends RegDocUploadTile {
  const _DocUploadTile({required super.icon, required super.label});
}

typedef _StepBar = RegStepBar;
typedef _SectionTitle = RegSectionTitle;

