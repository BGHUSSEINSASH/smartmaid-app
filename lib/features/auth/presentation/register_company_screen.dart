import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models.dart';
import '../../../providers/auth_provider.dart';
import 'register_shared_widgets.dart';
import 'auth_widgets.dart';

typedef _StepBar = RegStepBar;
typedef _SectionTitle = RegSectionTitle;

class _DocUploadTile extends RegDocUploadTile {
  const _DocUploadTile({required super.icon, required super.label});
}

/// تسجيل الشركة — 3 خطوات
class RegisterCompanyScreen extends ConsumerStatefulWidget {
  const RegisterCompanyScreen({super.key});
  @override
  ConsumerState<RegisterCompanyScreen> createState() => _RegisterCompanyState();
}

class _RegisterCompanyState extends ConsumerState<RegisterCompanyScreen> {
  final _page = PageController();
  int _step = 0;

  // خطوة 1 — بيانات الشركة
  final _companyNameCtrl = TextEditingController();
  final _regNoCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  // خطوة 2 — بيانات المسؤول
  final _contactCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _accepted = false;

  // خطوة 3 — الوثائق والخطة
  SubscriptionPlan _plan = SubscriptionPlan.basic;

  void _err(String m) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating));

  void _next() {
    if (_step == 0) {
      if (_companyNameCtrl.text.trim().isEmpty) { _err('أدخل اسم الشركة'); return; }
      if (_regNoCtrl.text.trim().isEmpty) { _err('أدخل رقم السجل التجاري'); return; }
    } else if (_step == 1) {
      if (_passCtrl.text != _confirmCtrl.text) { _err('كلمتا المرور غير متطابقتين'); return; }
      if (!_accepted) { _err('يجب الموافقة على الشروط'); return; }
    }
    setState(() => _step++);
    _page.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
  }

  Future<void> _submit() async {
    final ok = await ref.read(authProvider.notifier).register(
      name: _contactCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      role: AppRole.company,
      phone: _phoneCtrl.text.trim(),
      extraData: {
        'companyName': _companyNameCtrl.text.trim(),
        'commercialRegNo': _regNoCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'contactPerson': _contactCtrl.text.trim(),
        'subscriptionPlan': _plan.name,
        'accountStatus': 'pending',
      },
    );
    if (!mounted) return;
    if (ok) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('طلبك قيد المراجعة الإدارية'),
          content: const Text(
              'تم استلام طلب تسجيل شركتك. سيتم التواصل معك خلال 48 ساعة بعد مراجعة الوثائق والموافقة.'),
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
        title: const Text('تسجيل — شركة'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _StepBar(steps: 3, current: _step),
        ),
      ),
      body: PageView(
        controller: _page,
        physics: const NeverScrollableScrollPhysics(),
        children: [_buildStep1(), _buildStep2(), _buildStep3(auth.isLoading)],
      ),
    );
  }

  Widget _buildStep1() => SingleChildScrollView(
    padding: const EdgeInsets.all(22),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const _SectionTitle('بيانات الشركة'),
      const SizedBox(height: 16),
      AuthField(controller: _companyNameCtrl, label: 'اسم الشركة التجاري',
          icon: Icons.business_rounded),
      const SizedBox(height: 12),
      AuthField(controller: _regNoCtrl, label: 'رقم السجل التجاري',
          icon: Icons.article_rounded),
      const SizedBox(height: 12),
      AuthField(controller: _cityCtrl, label: 'المدينة / المنطقة',
          icon: Icons.location_city_rounded),
      const SizedBox(height: 12),
      AuthField(controller: _addressCtrl, label: 'العنوان التفصيلي',
          icon: Icons.pin_drop_rounded),
      const SizedBox(height: 20),
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
      const _SectionTitle('بيانات المسؤول'),
      const SizedBox(height: 16),
      AuthField(controller: _contactCtrl, label: 'اسم المسؤول الكامل',
          icon: Icons.person_rounded),
      const SizedBox(height: 12),
      AuthField(controller: _phoneCtrl, label: 'رقم الهاتف',
          icon: Icons.phone_rounded, keyboardType: TextInputType.phone),
      const SizedBox(height: 12),
      AuthField(controller: _emailCtrl, label: 'البريد الإلكتروني',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 12),
      AuthField(controller: _passCtrl, label: 'كلمة المرور',
          icon: Icons.lock_rounded, obscure: _obscure,
          suffix: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded),
            onPressed: () => setState(() => _obscure = !_obscure),
          )),
      const SizedBox(height: 12),
      AuthField(controller: _confirmCtrl, label: 'تأكيد كلمة المرور',
          icon: Icons.lock_outline_rounded, obscure: _obscure),
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

  Widget _buildStep3(bool loading) => SingleChildScrollView(
    padding: const EdgeInsets.all(22),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const _SectionTitle('الوثائق والخطة'),
      const SizedBox(height: 16),
      _DocUploadTile(icon: Icons.article_rounded, label: 'صورة السجل التجاري'),
      const SizedBox(height: 10),
      _DocUploadTile(icon: Icons.image_rounded, label: 'شعار الشركة'),
      const SizedBox(height: 20),
      const Text('خطة الاشتراك', style: TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      ..._planCards(),
      const SizedBox(height: 24),
      SizedBox(height: 52, child: ElevatedButton.icon(
        onPressed: loading ? null : _submit,
        icon: loading
            ? const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.send_rounded),
        label: Text(loading ? 'جارٍ الإرسال...' : 'إرسال الطلب'),
      )),
    ]),
  );

  List<Widget> _planCards() {
    const plans = [
      (SubscriptionPlan.basic, 'أساسي', 'حتى 5 عاملات', '49 د.ك/شهر', Color(0xFF0EA5E9)),
      (SubscriptionPlan.pro, 'برو', 'حتى 20 عاملة', '129 د.ك/شهر', Color(0xFF7C3AED)),
      (SubscriptionPlan.enterprise, 'متميز', 'غير محدود', 'تواصل معنا', Color(0xFF4F46E5)),
    ];
    return plans.map((p) {
      final (plan, name, desc, price, color) = p;
      final sel = _plan == plan;
      return GestureDetector(
        onTap: () => setState(() => _plan = plan),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: sel ? color.withValues(alpha: 0.1) : AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: sel ? color : AppColors.stroke,
                width: sel ? 2 : 1)),
          child: Row(children: [
            Icon(sel ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                color: color),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.w800, color: color)),
              Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            ])),
            Text(price, style: TextStyle(fontWeight: FontWeight.w900, color: color)),
          ]),
        ),
      );
    }).toList();
  }
}
