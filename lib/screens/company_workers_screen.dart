import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
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

// أعلام الدول الشائعة
const _kFlags = {
  'إندونيسيا':'🇮🇩','الفلبين':'🇵🇭','سريلانكا':'🇱🇰','إثيوبيا':'🇪🇹',
  'بنغلاديش':'🇧🇩','كينيا':'🇰🇪','أوغندا':'🇺🇬','تنزانيا':'🇹🇿',
  'نيبال':'🇳🇵','الهند':'🇮🇳','باكستان':'🇵🇰','ماليزيا':'🇲🇾',
  'تايلاند':'🇹🇭','فيتنام':'🇻🇳','مصر':'🇪🇬','المغرب':'🇲🇦',
  'السعودية':'🇸🇦','العراق':'🇮🇶','الإمارات':'🇦🇪','الكويت':'🇰🇼',
  'تركيا':'🇹🇷','أوكرانيا':'🇺🇦','روسيا':'🇷🇺','أخرى':'🌍',
};

String _flag(String country) => _kFlags[country] ?? '🌍';

class CompanyWorkersScreen extends ConsumerStatefulWidget {
  const CompanyWorkersScreen({super.key});
  @override
  ConsumerState<CompanyWorkersScreen> createState() => _CompanyWorkersScreenState();
}

class _CompanyWorkersScreenState extends ConsumerState<CompanyWorkersScreen> {
  String? _filterCountry;

  Future<void> _addWorkerSheet() async {
    final nameCtrl     = TextEditingController();
    final categoryCtrl = TextEditingController();
    final bioCtrl      = TextEditingController();
    final rateCtrl     = TextEditingController(text: '20');
    String?  selectedCountry;
    double   experienceYears = 0;
    String   countrySearch   = '';
    XFile?   pickedImage;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.92),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: Theme.of(ctx).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── شريط العنوان ──────────────────────────────────
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: AppColors.stroke, borderRadius: BorderRadius.circular(2)),
                ),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.person_add_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('إضافة عاملة للفريق',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                ]),
                const SizedBox(height: 16),

                // ── المحتوى القابل للتمرير ────────────────────────
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── صورة العاملة ──────────────────────────
                        const Text('صورة العاملة',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(height: 8),
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              final result = await showModalBottomSheet<XFile?>(
                                context: ctx,
                                backgroundColor: Colors.transparent,
                                builder: (_) => Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Theme.of(ctx).scaffoldBackgroundColor,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                                    const Text('اختر مصدر الصورة',
                                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                    const SizedBox(height: 16),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                      _ImgSourceBtn(
                                        icon: Icons.photo_library_rounded,
                                        label: 'المعرض',
                                        onTap: () async {
                                          final img = await ImagePicker().pickImage(
                                              source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 85);
                                          if (ctx.mounted) Navigator.pop(ctx, img);
                                        },
                                      ),
                                      _ImgSourceBtn(
                                        icon: Icons.camera_alt_rounded,
                                        label: 'الكاميرا',
                                        onTap: () async {
                                          final img = await ImagePicker().pickImage(
                                              source: ImageSource.camera, maxWidth: 512, maxHeight: 512, imageQuality: 85);
                                          if (ctx.mounted) Navigator.pop(ctx, img);
                                        },
                                      ),
                                    ]),
                                    const SizedBox(height: 8),
                                  ]),
                                ),
                              );
                              if (result != null) setSheet(() => pickedImage = result);
                            },
                            child: Stack(alignment: Alignment.bottomRight, children: [
                              CircleAvatar(
                                radius: 48,
                                backgroundColor: AppColors.primaryLight,
                                backgroundImage: pickedImage != null
                                    ? FileImage(File(pickedImage!.path)) as ImageProvider
                                    : null,
                                child: pickedImage == null
                                    ? const Icon(Icons.person_rounded, size: 40, color: AppColors.primary)
                                    : null,
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                              ),
                            ]),
                          ),
                        ),
                        if (pickedImage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Center(
                              child: TextButton.icon(
                                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                                label: const Text('حذف الصورة', style: TextStyle(fontSize: 12)),
                                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                onPressed: () => setSheet(() => pickedImage = null),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),

                        // ── الاسم ─────────────────────────────────
                        TextField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'اسم العاملة *',
                            prefixIcon: Icon(Icons.badge_rounded),
                            hintText: 'مثال: ماريا سانتوس',
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── الجنسية / الدولة ─────────────────────
                        const Text('الجنسية / الدولة',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'ابحث عن دولة...',
                            prefixIcon: Icon(Icons.search_rounded, size: 18),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          onChanged: (v) => setSheet(() => countrySearch = v.trim()),
                        ),
                        const SizedBox(height: 6),
                        if (selectedCountry != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.success.withOpacity(.25)),
                            ),
                            child: Row(children: [
                              Text(_flag(selectedCountry!), style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(selectedCountry!,
                                  style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => setSheet(() => selectedCountry = null),
                                child: const Icon(Icons.close_rounded, color: AppColors.success, size: 18),
                              ),
                            ]),
                          ),
                        Container(
                          height: 130,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.stroke),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            children: _kCountries
                                .where((c) => countrySearch.isEmpty || c.contains(countrySearch))
                                .map((c) => InkWell(
                                      onTap: () => setSheet(() => selectedCountry = c),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                        color: selectedCountry == c ? AppColors.primaryLight : null,
                                        child: Row(children: [
                                          Text(_flag(c), style: const TextStyle(fontSize: 16)),
                                          const SizedBox(width: 10),
                                          Text(c,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: selectedCountry == c
                                                    ? FontWeight.w700 : FontWeight.normal,
                                                color: selectedCountry == c ? AppColors.primary : null,
                                              )),
                                          if (selectedCountry == c) ...[
                                            const Spacer(),
                                            const Icon(Icons.check_rounded,
                                                color: AppColors.primary, size: 16),
                                          ],
                                        ]),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── التخصص ────────────────────────────────
                        TextField(
                          controller: categoryCtrl,
                          decoration: const InputDecoration(
                            labelText: 'التخصص',
                            prefixIcon: Icon(Icons.work_rounded),
                            hintText: 'مثال: تنظيف منازل',
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── نبذة ──────────────────────────────────
                        TextField(
                          controller: bioCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'نبذة عن العاملة',
                            prefixIcon: Icon(Icons.info_outline_rounded),
                            hintText: 'خبرة في التنظيف العميق والطبخ...',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── سنوات الخبرة ──────────────────────────
                        Row(children: [
                          const Icon(Icons.workspace_premium_rounded,
                              color: AppColors.warning, size: 18),
                          const SizedBox(width: 6),
                          Text('سنوات الخبرة: ${experienceYears.round()}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const Spacer(),
                          // Chips سريعة
                          ...{0,1,3,5,10}.map((n) => GestureDetector(
                            onTap: () => setSheet(() => experienceYears = n.toDouble()),
                            child: Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: experienceYears.round() == n
                                    ? AppColors.primary : AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('$n',
                                style: TextStyle(
                                  color: experienceYears.round() == n
                                      ? Colors.white : AppColors.primary,
                                  fontSize: 11, fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )),
                        ]),
                        Slider(
                          value: experienceYears, min: 0, max: 30, divisions: 30,
                          label: '${experienceYears.round()} سنة',
                          onChanged: (v) => setSheet(() => experienceYears = v),
                        ),
                        const SizedBox(height: 4),

                        // ── السعر ─────────────────────────────────
                        TextField(
                          controller: rateCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'السعر بالساعة (دولار)',
                            prefixIcon: Icon(Icons.attach_money_rounded),
                            hintText: '20',
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── زر الإضافة ────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              final name = nameCtrl.text.trim();
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                                  content: Text('أدخل اسم العاملة'),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                ));
                                return;
                              }
                              final rate = double.tryParse(rateCtrl.text) ?? 20;
                              final bio  = bioCtrl.text.trim().isNotEmpty
                                  ? bioCtrl.text.trim()
                                  : 'عاملة جديدة ضمن فريق الشركة.';

                              // الصورة: محلية إن رُفعت، وإلا avatar تلقائي
                              final imgUrl = pickedImage != null
                                  ? pickedImage!.path
                                  : 'https://i.pravatar.cc/150?img=${DateTime.now().millisecond % 70 + 1}';

                              ref.read(companyWorkersProvider.notifier).addWorker(
                                    WorkerModel(
                                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                                      name: name,
                                      category: categoryCtrl.text.trim().isEmpty
                                          ? 'عام' : categoryCtrl.text.trim(),
                                      imageUrl: imgUrl,
                                      rating: 5.0,
                                      reviewCount: 0,
                                      jobsCompleted: experienceYears.round() * 28,
                                      hourlyRate: rate,
                                      location: ref.read(authProvider).user?.companyInfo?.city
                                          ?? DemoData.companies.first.location,
                                      isAvailable: true,
                                      skills: selectedCountry != null ? [selectedCountry!] : const [],
                                      about: bio,
                                      companyId: ref.read(authProvider).user?.id
                                          ?? DemoData.companies.first.id,
                                      nationalityCountry: selectedCountry,
                                    ),
                                  );
                              Navigator.pop(ctx);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('✅ تمت إضافة $name'),
                                  backgroundColor: AppColors.success,
                                  behavior: SnackBarBehavior.floating,
                                ));
                              }
                            },
                            icon: const Icon(Icons.person_add_rounded, size: 20),
                            label: const Text('إضافة العاملة',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allWorkers   = ref.watch(companyWorkersProvider);
    final isDark       = Theme.of(context).brightness == Brightness.dark;
    final workers      = _filterCountry == null
        ? allWorkers
        : allWorkers.where((w) =>
            w.nationalityCountry == _filterCountry ||
            w.skills.contains(_filterCountry)).toList();
    final countries = allWorkers
        .where((w) => w.nationalityCountry != null)
        .map((w) => w.nationalityCountry!)
        .toSet()
        .toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: Text('عاملاتي (${workers.length})')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addWorkerSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded, size: 19),
        label: const Text('عاملة جديدة', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // ── فلتر الدولة ─────────────────────────────────────────
          if (countries.isNotEmpty)
            SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                children: [
                  _FilterChip(label: 'الكل', active: _filterCountry == null, isDark: isDark,
                      onTap: () => setState(() => _filterCountry = null)),
                  ...countries.map((c) => _FilterChip(
                        label: '${_flag(c)} $c',
                        active: _filterCountry == c,
                        isDark: isDark,
                        onTap: () => setState(() => _filterCountry = c),
                      )),
                ],
              ),
            ),

          // ── قائمة العاملات ──────────────────────────────────────
          Expanded(
            child: workers.isEmpty
                ? Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.people_outline_rounded, size: 64, color: AppColors.muted),
                      const SizedBox(height: 12),
                      const Text('لا توجد عاملات بعد', style: TextStyle(color: AppColors.muted)),
                      const SizedBox(height: 8),
                      const Text('اضغط + لإضافة عاملة جديدة',
                          style: TextStyle(color: AppColors.muted, fontSize: 12)),
                    ]),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: workers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final w = workers[i];
                      return _WorkerTile(
                        worker: w,
                        isDark: isDark,
                        onToggle: () => ref
                            .read(companyWorkersProvider.notifier)
                            .toggleAvailability(w.id),
                        onDelete: () => showDialog<void>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: const Text('حذف العاملة؟'),
                            content: Text('سيتم إزالة ${w.name} من فريقك نهائياً.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                              TextButton(
                                onPressed: () {
                                  ref.read(companyWorkersProvider.notifier).removeWorker(w.id);
                                  Navigator.pop(ctx);
                                },
                                child: const Text('حذف', style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        ),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => WorkerProfileScreen(worker: w))),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── بطاقة العاملة ──────────────────────────────────────────────────────────
class _WorkerTile extends StatelessWidget {
  final WorkerModel worker;
  final bool isDark;
  final VoidCallback onToggle, onDelete, onTap;
  const _WorkerTile({
    required this.worker, required this.isDark,
    required this.onToggle, required this.onDelete, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocalImage = worker.imageUrl.startsWith('/') || worker.imageUrl.startsWith('file');
    final ImageProvider img = isLocalImage
        ? FileImage(File(worker.imageUrl))
        : NetworkImage(worker.imageUrl) as ImageProvider;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.stroke),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
          blurRadius: 8, offset: const Offset(0,3),
        )],
      ),
      child: Row(children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(radius: 28, backgroundImage: img),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(worker.name,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 2),
              Row(children: [
                Text(worker.category,
                    style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                if (worker.nationalityCountry != null) ...[
                  const Text(' • ', style: TextStyle(color: AppColors.muted)),
                  Text('${_flag(worker.nationalityCountry!)} ${worker.nationalityCountry!}',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
                ],
              ]),
              const SizedBox(height: 2),
              Text(
                '\$${worker.hourlyRate.toStringAsFixed(0)}/س  •  ${worker.experienceYears} سنة خبرة',
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ]),
          ),
        ),
        Column(children: [
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: worker.isAvailable,
              activeColor: AppColors.success,
              onChanged: (_) => onToggle(),
            ),
          ),
          Text(
            worker.isAvailable ? 'متاحة' : 'مشغولة',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: worker.isAvailable ? AppColors.success : AppColors.muted,
            ),
          ),
        ]),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
          tooltip: 'حذف العاملة',
        ),
      ]),
    );
  }
}

// ── Chip فلتر الدولة ────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool active, isDark;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.active, required this.isDark, required this.onTap});

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
          boxShadow: active ? [BoxShadow(
            color: AppColors.primary.withOpacity(.2),
            blurRadius: 6, offset: const Offset(0,2),
          )] : null,
        ),
        child: Text(label,
            style: TextStyle(
              color: active ? Colors.white : null,
              fontWeight: FontWeight.w700, fontSize: 12,
            )),
      ),
    );
  }
}

// ── زر مصدر الصورة ──────────────────────────────────────────────────────────
class _ImgSourceBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ImgSourceBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: AppColors.primary, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      ]),
    );
  }
}
