import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import '../providers/auth_provider.dart';
import '../providers/company_provider.dart';
import 'worker_profile_screen.dart';

class CompanyWorkersScreen extends ConsumerStatefulWidget {
  const CompanyWorkersScreen({super.key});

  @override
  ConsumerState<CompanyWorkersScreen> createState() =>
      _CompanyWorkersScreenState();
}

class _CompanyWorkersScreenState extends ConsumerState<CompanyWorkersScreen> {
  void _addWorkerSheet() {
    final nameCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('إضافة عاملة للفريق',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'اسم العاملة'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryCtrl,
                decoration:
                    const InputDecoration(labelText: 'التخصص (مثال: تنظيف عميق)'),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    ref.read(companyWorkersProvider.notifier).addWorker(
                          WorkerModel(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            name: nameCtrl.text.trim(),
                            category:
                                categoryCtrl.text.trim().isEmpty ? 'عام' : categoryCtrl.text.trim(),
                            imageUrl:
                                'https://i.pravatar.cc/150?img=${DateTime.now().millisecond % 70 + 1}',
                            rating: 5.0,
                            reviewCount: 0,
                            jobsCompleted: 0,
                            hourlyRate: 20,
                            location: ref.read(authProvider).user?.companyInfo?.city ?? DemoData.companies.first.location,
                            isAvailable: true,
                            skills: const [],
                            about: 'عاملة جديدة ضمن فريق الشركة.',
                            companyId: ref.read(authProvider).user?.id ?? DemoData.companies.first.id,
                          ),
                        );
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.person_add_rounded, size: 19),
                  label: const Text('إضافة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workers = ref.watch(companyWorkersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: Text('عاملاتي (${workers.length})')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addWorkerSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded, size: 19),
        label: const Text('عاملة جديدة'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
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
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => WorkerProfileScreen(worker: w))),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(w.imageUrl),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(w.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15)),
                      Text('${w.category} • \$${w.hourlyRate}/س',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.muted)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Switch(
                      value: w.isAvailable,
                      activeThumbColor: AppColors.success,
                      onChanged: (_) => ref
                          .read(companyWorkersProvider.notifier)
                          .toggleAvailability(w.id),
                    ),
                    Text(w.isAvailable ? 'متاحة' : 'موقوفة',
                        style: TextStyle(
                            fontSize: 10,
                            color: w.isAvailable
                                ? AppColors.success
                                : AppColors.muted)),
                  ],
                ),
                IconButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('حذف العاملة؟'),
                      content: Text('سيتم إزالة ${w.name} من فريقك.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('إلغاء')),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(companyWorkersProvider.notifier)
                                .removeWorker(w.id);
                            Navigator.pop(ctx);
                          },
                          child: const Text('حذف',
                              style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 19, color: AppColors.error),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
