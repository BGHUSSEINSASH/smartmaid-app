import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import '../providers/auth_provider.dart';
import '../providers/company_provider.dart';
import 'worker_profile_screen.dart';

const _kCountries = [
  'إندونيسيا','الفلبين','سريلانكا','إثيوبيا','بنغلاديش','كينيا',
  'أوغندا','تنزانيا','نيبال','الهند','باكستان','ماليزيا','تايلاند',
  'فيتنام','ميانمار','كمبوديا','زيمبابوي','غانا','نيجيريا','رواندا',
  'مدغشقر','موريتانيا','السودان','الصومال','إريتريا','جيبوتي',
  'مصر','المغرب','تونس','الجزائر','ليبيا','السعودية','العراق',
  'سوريا','لبنان','الأردن','فلسطين','اليمن','عمان','الكويت',
  'البحرين','قطر','الإمارات','تركيا','أوكرانيا','روسيا','أخرى',
];

class CompanyWorkersScreen extends ConsumerStatefulWidget {
  const CompanyWorkersScreen({super.key});
  @override
  ConsumerState<CompanyWorkersScreen> createState() => _CompanyWorkersScreenState();
}

class _CompanyWorkersScreenState extends ConsumerState<CompanyWorkersScreen> {
  String? _filterCountry;

  void _addWorkerSheet() {
    final nameCtrl     = TextEditingController();
    final categoryCtrl = TextEditingController();
    final bioCtrl      = TextEditingController();
    final rateCtrl     = TextEditingController(text: '20');
    String? selectedCountry;
    double experienceYears = 0;
    String countrySearch = '';

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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.person_add_rounded, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text('إضافة عاملة للفريق',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                  ]),
                  const SizedBox(height: 14),
                  // الاسم
                  TextField(controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'اسم العاملة *', prefixIcon: Icon(Icons.person_rounded))),
                  const SizedBox(height: 12),
                  // الدولة
                  const Text('جنسية العاملة / الدولة', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    decoration: const InputDecoration(hintText: 'ابحث عن دولة...', prefixIcon: Icon(Icons.search_rounded, size: 18), isDense: true),
                    onChanged: (v) => setSheet(() => countrySearch = v.trim()),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 110,
                    decoration: BoxDecoration(border: Border.all(color: AppColors.stroke), borderRadius: BorderRadius.circular(12)),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      children: _kCountries
                          .where((c) => countrySearch.isEmpty || c.contains(countrySearch))
                          .map((c) => InkWell(
                                onTap: () => setSheet(() => selectedCountry = c),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  color: selectedCountry == c ? AppColors.primaryLight : null,
                                  child: Row(children: [
                                    const Text('🌍', style: TextStyle(fontSize: 13)),
                                    const SizedBox(width: 8),
                                    Text(c, style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: selectedCountry == c ? FontWeight.w700 : FontWeight.normal,
                                        color: selectedCountry == c ? AppColors.primary : null)),
                                    if (selectedCountry == c) ...[const Spacer(), const Icon(Icons.check_rounded, color: AppColors.primary, size: 16)],
                                  ]),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  if (selectedCountry != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('تم اختيار: $selectedCountry',
                          style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  const SizedBox(height: 12),
                  // التخصص
                  TextField(controller: categoryCtrl,
                      decoration: const InputDecoration(labelText: 'التخصص', prefixIcon: Icon(Icons.work_rounded))),
                  const SizedBox(height: 12),
                  // نبذة
                  TextField(controller: bioCtrl, maxLines: 2,
                      decoration: const InputDecoration(
                          labelText: 'نبذة عن العاملة', prefixIcon: Icon(Icons.notes_rounded),
                          hintText: 'خبرة في التنظيف العميق...')),
                  const SizedBox(height: 12),
                  // سنوات الخبرة
                  Row(children: [
                    const Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
                    const SizedBox(width: 6),
                    Text('سنوات الخبرة: ${experienceYears.round()}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ]),
                  Slider(
                    value: experienceYears, min: 0, max: 30, divisions: 30,
                    label: '${experienceYears.round()} سنة',
                    onChanged: (v) => setSheet(() => experienceYears = v),
                  ),
                  // السعر
                  TextField(controller: rateCtrl, keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'السعر بالساعة (\$)', prefixIcon: Icon(Icons.attach_money_rounded))),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty) return;
                        final rate = double.tryParse(rateCtrl.text) ?? 20;
                        final bio = bioCtrl.text.trim().isNotEmpty ? bioCtrl.text.trim() : 'عاملة جديدة ضمن فريق الشركة.';
                        ref.read(companyWorkersProvider.notifier).addWorker(
                              WorkerModel(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                name: nameCtrl.text.trim(),
                                category: categoryCtrl.text.trim().isEmpty ? 'عام' : categoryCtrl.text.trim(),
                                imageUrl: 'https://i.pravatar.cc/150?img=${DateTime.now().millisecond % 70 + 1}',
                                rating: 5.0,
                                reviewCount: 0,
                                jobsCompleted: experienceYears.round() * 20,
                                hourlyRate: rate,
                                location: ref.read(authProvider).user?.companyInfo?.city ?? DemoData.companies.first.location,
                                isAvailable: true,
                                skills: selectedCountry != null ? [selectedCountry!] : const [],
                                about: bio,
                                companyId: ref.read(authProvider).user?.id ?? DemoData.companies.first.id,
                                nationalityCountry: selectedCountry,
                              ),
                            );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('✅ تمت إضافة ${nameCtrl.text.trim()}'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ));
                      },
                      icon: const Icon(Icons.person_add_rounded, size: 19),
                      label: const Text('إضافة عاملة'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allWorkers = ref.watch(companyWorkersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final workers = _filterCountry == null
        ? allWorkers
        : allWorkers.where((w) => w.nationalityCountry == _filterCountry || w.skills.contains(_filterCountry)).toList();
    final availableCountries = allWorkers.where((w) => w.nationalityCountry != null).map((w) => w.nationalityCountry!).toSet().toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: Text('عاملاتي (${workers.length})')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addWorkerSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded, size: 19),
        label: const Text('عاملة جديدة'),
      ),
      body: Column(
        children: [
          if (availableCountries.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                children: [
                  _FilterChip(label: 'الكل', active: _filterCountry == null, onTap: () => setState(() => _filterCountry = null), isDark: isDark),
                  ...availableCountries.map((c) => _FilterChip(label: '🌍 $c', active: _filterCountry == c, onTap: () => setState(() => _filterCountry = c), isDark: isDark)),
                ],
              ),
            ),
          Expanded(
            child: workers.isEmpty
                ? const Center(child: Text('لا توجد عاملات', style: TextStyle(color: AppColors.muted)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: workers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final w = workers[i];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.stroke),
                        ),
                        child: Row(children: [
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkerProfileScreen(worker: w))),
                            child: CircleAvatar(radius: 26, backgroundImage: NetworkImage(w.imageUrl)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(w.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                              Row(children: [
                                Text(w.category, style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
                                if (w.nationalityCountry != null) ...[
                                  const Text(' • ', style: TextStyle(color: AppColors.muted)),
                                  Text('🌍 ${w.nationalityCountry!}', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                                ],
                              ]),
                              Text('\$${w.hourlyRate.toStringAsFixed(0)}/س  •  ${w.experienceYears} سنة',
                                  style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                            ]),
                          ),
                          Column(children: [
                            Switch(
                              value: w.isAvailable, activeThumbColor: AppColors.success,
                              onChanged: (_) => ref.read(companyWorkersProvider.notifier).toggleAvailability(w.id),
                            ),
                            Text(w.isAvailable ? 'متاحة' : 'موقوفة',
                                style: TextStyle(fontSize: 10, color: w.isAvailable ? AppColors.success : AppColors.muted)),
                          ]),
                          IconButton(
                            onPressed: () => showDialog<void>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('حذف العاملة؟'),
                                content: Text('سيتم إزالة ${w.name} من فريقك.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                                  TextButton(
                                    onPressed: () { ref.read(companyWorkersProvider.notifier).removeWorker(w.id); Navigator.pop(ctx); },
                                    child: const Text('حذف', style: TextStyle(color: AppColors.error)),
                                  ),
                                ],
                              ),
                            ),
                            icon: const Icon(Icons.delete_outline_rounded, size: 19, color: AppColors.error),
                          ),
                        ]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool isDark;
  const _FilterChip({required this.label, required this.active, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.primary : AppColors.stroke),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : null, fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    );
  }
}
