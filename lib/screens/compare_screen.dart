import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import '../providers/favorites_provider.dart';
import '../providers/booking_provider.dart';
import '../widgets/app_image.dart';
import 'booking_screen.dart';
import 'worker_profile_screen.dart';

class CompareScreen extends ConsumerStatefulWidget {
  final String? worker1Id;
  final String? worker2Id;
  const CompareScreen({super.key, this.worker1Id, this.worker2Id});

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  WorkerModel? _w1;
  WorkerModel? _w2;

  @override
  void initState() {
    super.initState();
    if (widget.worker1Id != null) {
      _w1 = DemoData.byId(widget.worker1Id!);
    }
    if (widget.worker2Id != null) {
      _w2 = DemoData.byId(widget.worker2Id!);
    }
    // Auto-select first two if not specified
    _w1 ??= DemoData.workers.first;
    _w2 ??= DemoData.workers.length > 1 ? DemoData.workers[1] : DemoData.workers.first;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favorites = ref.watch(favoritesProvider);

    if (_w1 == null || _w2 == null) {
      return const Scaffold(body: Center(child: Text('لا توجد عاملات للمقارنة')));
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('مقارنة العاملات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'تبديل',
            onPressed: () => setState(() {
              final tmp = _w1;
              _w1 = _w2;
              _w2 = tmp;
            }),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header row with avatars
          Row(
            children: [
              Expanded(child: _workerHeader(_w1!, favorites)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.compare_arrows_rounded,
                    size: 28, color: AppColors.primary),
              ),
              Expanded(child: _workerHeader(_w2!, favorites)),
            ],
          ),
          const SizedBox(height: 24),

          // Comparison rows
          _CompareRow(
            label: 'التقييم',
            w1: '${_w1!.rating} ⭐',
            w2: '${_w2!.rating} ⭐',
            w1Better: _w1!.rating > _w2!.rating,
          ),
          _CompareRow(
            label: 'عدد المهام',
            w1: '${_w1!.jobsCompleted}',
            w2: '${_w2!.jobsCompleted}',
            w1Better: _w1!.jobsCompleted > _w2!.jobsCompleted,
          ),
          _CompareRow(
            label: 'التقييمات',
            w1: '${_w1!.reviewCount}',
            w2: '${_w2!.reviewCount}',
            w1Better: _w1!.reviewCount > _w2!.reviewCount,
          ),
          _CompareRow(
            label: 'السعر/ساعة',
            w1: '\$${_w1!.hourlyRate}',
            w2: '\$${_w2!.hourlyRate}',
            w1Better: _w1!.hourlyRate < _w2!.hourlyRate,
            invertHigher: true,
          ),
          _CompareRow(
            label: 'الخبرة',
            w1: '${_w1!.experienceYears} سنوات',
            w2: '${_w2!.experienceYears} سنوات',
            w1Better: _w1!.experienceYears > _w2!.experienceYears,
          ),
          _CompareRow(
            label: 'الموقع',
            w1: _w1!.location,
            w2: _w2!.location,
          ),
          _CompareRow(
            label: 'الفئة',
            w1: _w1!.category,
            w2: _w2!.category,
          ),
          _CompareRow(
            label: 'التوافر',
            w1: _w1!.isAvailable ? 'متاحة ✅' : 'غير متاحة',
            w2: _w2!.isAvailable ? 'متاحة ✅' : 'غير متاحة',
          ),

          // Skills comparison
          const SizedBox(height: 20),
          SurfaceCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المهارات',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: context.ink)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _skillsList(_w1!.skills)),
                    const SizedBox(width: 12),
                    Expanded(child: _skillsList(_w2!.skills)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(bookingFlowProvider.notifier).selectWorker(_w1!);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const BookingScreen()));
                  },
                  icon: const Icon(Icons.book_online_rounded, size: 18),
                  label: Text('احجز ${_w1!.name.split(' ').first}'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(bookingFlowProvider.notifier).selectWorker(_w2!);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const BookingScreen()));
                  },
                  icon: const Icon(Icons.book_online_rounded, size: 18),
                  label: Text('احجز ${_w2!.name.split(' ').first}'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _workerHeader(WorkerModel w, Set<String> favorites) {
    return Column(
      children: [
        AppAvatar(url: w.imageUrl, radius: 32),
        const SizedBox(height: 8),
        Text(w.name,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(w.category,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
            textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (w.verified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('موثّقة ✓',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _skillsList(List<String> skills) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: skills
          .map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(s,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600)),
              ))
          .toList(),
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final String w1;
  final String w2;
  final bool? w1Better;
  final bool invertHigher;

  const _CompareRow({
    required this.label,
    required this.w1,
    required this.w2,
    this.w1Better,
    this.invertHigher = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w1Color = w1Better == true
        ? AppColors.success
        : w1Better == false
            ? AppColors.error
            : null;
    final w2Color = w1Better == true
        ? AppColors.error
        : w1Better == false
            ? AppColors.success
            : null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(w1,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: w1Color)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.stroke.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted)),
          ),
          Expanded(
            child: Text(w2,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: w2Color)),
          ),
        ],
      ),
    );
  }
}
