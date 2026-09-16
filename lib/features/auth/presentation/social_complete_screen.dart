import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models.dart';
import '../../../providers/auth_provider.dart';
import 'auth_widgets.dart';

/// إكمال بيانات الحساب بعد تسجيل Google / Apple
class SocialCompleteScreen extends ConsumerStatefulWidget {
  final AppRole role;
  const SocialCompleteScreen({super.key, required this.role});

  @override
  ConsumerState<SocialCompleteScreen> createState() => _SocialCompleteState();
}

class _SocialCompleteState extends ConsumerState<SocialCompleteScreen> {
  final _phoneCtrl = TextEditingController();
  String _nationality = 'السعودية';
  // worker extras
  final _skillsAll = ['تنظيف عام', 'طبخ', 'رعاية أطفال', 'كبار السن', 'غسيل وكواء'];
  final List<String> _selectedSkills = [];
  // company extras
  final _companyCtrl = TextEditingController();
  final _regCtrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _companyCtrl.dispose();
    _regCtrl.dispose();
    super.dispose();
  }

  void _err(String m) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating));

  Future<void> _save() async {
    if (_phoneCtrl.text.trim().isEmpty) { _err('أدخل رقم الهاتف'); return; }
    setState(() => _loading = true);
    final user = ref.read(authProvider).user;
    if (user == null) { setState(() => _loading = false); return; }

    AppUser updated = user.copyWith(phone: _phoneCtrl.text.trim());
    switch (widget.role) {
      case AppRole.customer:
        updated = updated.copyWith(
          customerInfo: CustomerInfo(nationality: _nationality));
        break;
      case AppRole.worker:
        updated = updated.copyWith(
          workerInfo: WorkerInfo(skills: _selectedSkills));
        break;
      case AppRole.company:
        updated = updated.copyWith(
          companyInfo: CompanyInfo(
            companyName: _companyCtrl.text.trim(),
            commercialRegNo: _regCtrl.text.trim()));
        break;
      default:
        break;
    }
    await ref.read(authProvider.notifier).updateProfile(updated);
    if (!mounted) return;
    setState(() => _loading = false);
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final social = ref.watch(authProvider).user;
    return Scaffold(
      appBar: AppBar(title: const Text('أكمل بياناتك')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // معلومات من الحساب الاجتماعي (للعرض فقط)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage(social?.imageUrl ?? ''),
                backgroundColor: AppColors.stroke),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(social?.name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(social?.email ?? '',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          AuthField(controller: _phoneCtrl, label: 'رقم الهاتف *',
              icon: Icons.phone_rounded, keyboardType: TextInputType.phone),
          const SizedBox(height: 14),
          if (widget.role == AppRole.customer) ..._customerFields(),
          if (widget.role == AppRole.worker) ..._workerFields(),
          if (widget.role == AppRole.company) ..._companyFields(),
          const SizedBox(height: 24),
          SizedBox(height: 52, child: ElevatedButton.icon(
            onPressed: _loading ? null : _save,
            icon: _loading
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_rounded),
            label: Text(_loading ? 'جارٍ الحفظ...' : 'بدء الاستخدام'),
          )),
        ]),
      ),
    );
  }

  List<Widget> _customerFields() => [
    DropdownButtonFormField<String>(
      initialValue: _nationality,
      decoration: const InputDecoration(labelText: 'الجنسية'),
      items: const ['السعودية', 'الإمارات', 'الكويت', 'مصر', 'أخرى']
          .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (v) => setState(() => _nationality = v!),
    ),
  ];

  List<Widget> _workerFields() => [
    const Text('مهاراتك (اختر ما ينطبق)',
        style: TextStyle(fontWeight: FontWeight.w700)),
    const SizedBox(height: 10),
    Wrap(
      spacing: 8, runSpacing: 8,
      children: _skillsAll.map((s) {
        final sel = _selectedSkills.contains(s);
        return FilterChip(
          label: Text(s),
          selected: sel,
          selectedColor: AppColors.primary.withValues(alpha: 0.15),
          checkmarkColor: AppColors.primary,
          onSelected: (v) => setState(() => v
              ? _selectedSkills.add(s) : _selectedSkills.remove(s)),
        );
      }).toList(),
    ),
  ];

  List<Widget> _companyFields() => [
    AuthField(controller: _companyCtrl, label: 'اسم الشركة',
        icon: Icons.business_rounded),
    const SizedBox(height: 12),
    AuthField(controller: _regCtrl, label: 'رقم السجل التجاري',
        icon: Icons.article_rounded),
  ];
}

