import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../data/demo_data.dart';
import '../providers/currency_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/pro_components.dart';
import 'worker_profile_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIds = ref.watch(favoritesProvider);
    final currency = ref.watch(currencyProvider);
    final all = [...DemoData.workers, ...DemoData.companyWorkers];
    final favorites = all.where((w) => favIds.contains(w.id)).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('المفضلة')),
      body: favorites.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'لا توجد مفضلات بعد',
              subtitle: 'اضغط على القلب ♥ لحفظ عاملاتك المفضلين والوصول إليهم بسرعة',
              actionLabel: 'تصفّح العاملات',
              onAction: () => context.push('/search'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final w = favorites[i];
                return Container(
                  padding: const EdgeInsets.all(12),
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
                          radius: 27,
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
                            Text('${w.category} • ${w.location}',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.muted)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_rounded,
                            color: AppColors.error),
                        onPressed: () =>
                            ref.read(favoritesProvider.notifier).toggle(w.id),
                      ),
                      Text(currency.format(w.hourlyRate),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
