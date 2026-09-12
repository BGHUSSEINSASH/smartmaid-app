import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/company_provider.dart';

class AdminCompaniesScreen extends ConsumerWidget {
  const AdminCompaniesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companies = ref.watch(companiesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: Text('الشركات (${companies.length})')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
            ),
            child: Row(children: [
              Icon(Icons.pending_actions_rounded, color: AppColors.warning, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('طلب انضمام: شركة النظافة المتقدمة — الرياض',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 21),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('تم قبول الشركة ✅'),
                        behavior: SnackBarBehavior.floating)),
              ),
              IconButton(
                icon: const Icon(Icons.cancel_rounded,
                    color: AppColors.error, size: 21),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('تم رفض الطلب'),
                        behavior: SnackBarBehavior.floating)),
              ),
            ]),
          ),
          ...companies.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.stroke),
                ),
                child: Column(children: [
                  Row(children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(c.logoUrl),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name,
                              style: const TextStyle(fontWeight: FontWeight.w800)),
                          Text('${c.location} • ${c.workerCount} عاملة • ⭐ ${c.rating}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Icon(Icons.workspace_premium_rounded,
                        size: 17,
                        color: c.isPro ? AppColors.warning : AppColors.muted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('عضوية Pro',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: c.isPro
                                  ? AppColors.warning
                                  : AppColors.muted)),
                    ),
                    Switch(
                      value: c.isPro,
                      activeThumbColor: AppColors.warning,
                      onChanged: (_) => ref
                          .read(companiesProvider.notifier)
                          .togglePro(c.id),
                    ),
                  ]),
                ]),
              )),
        ],
      ),
    );
  }
}
