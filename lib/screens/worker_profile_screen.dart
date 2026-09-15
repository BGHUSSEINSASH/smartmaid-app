import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_image.dart';
import '../core/nav/app_nav.dart';
import '../core/theme/app_theme.dart';
import '../widgets/ai_app_bar_button.dart';
import '../core/theme/adaptive.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import '../providers/booking_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/review_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/low_rating_dialog.dart';
import '../providers/recommendations_provider.dart';
import 'booking_screen.dart';

class WorkerProfileScreen extends ConsumerStatefulWidget {
  final WorkerModel worker;
  const WorkerProfileScreen({super.key, required this.worker});

  @override
  ConsumerState<WorkerProfileScreen> createState() =>
      _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends ConsumerState<WorkerProfileScreen> {
  void _openBooking() {
    ref.read(bookingFlowProvider.notifier).reset();
    ref.read(bookingFlowProvider.notifier).selectWorker(widget.worker);
    Haptics.light();
    AppNav.pushSlide(context, const BookingScreen());
  }

  void _openChat() {
    ref.read(chatProvider.notifier).startConversation(widget.worker, 'u1');
    Haptics.light();
    context.push('/chat');
  }

  void _showRatingSheet(BuildContext context, WidgetRef ref) {
    final user = ref.read(authProvider).user;
    double selectedRating = 5;
    final ctrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('قيّم العاملة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            Text(widget.worker.name, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 16),
            Center(child: StarRatingWidget(
              initialRating: selectedRating,
              workerName: widget.worker.name,
              size: 42,
              onRatingChanged: (r, reason, comment) {
                setSt(() => selectedRating = r);
                if (reason != null) ctrl.text = reason;
              },
            )),
            const SizedBox(height: 14),
            TextField(controller: ctrl, maxLines: 3,
                decoration: const InputDecoration(hintText: 'شاركنا تجربتك مع هذه العاملة...')),
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(reviewsProvider.notifier).addReview(
                    workerId: widget.worker.id,
                    reviewerName: user?.name ?? 'عميل',
                    reviewerImage: user?.imageUrl ?? 'https://i.pravatar.cc/150?img=68',
                    rating: selectedRating,
                    comment: ctrl.text.trim().isNotEmpty ? ctrl.text.trim() : 'تقييم جيد',
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('شكراً على تقييمك! ⭐'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                child: const Text('إرسال التقييم'),
              ),
            ),
          ]),
        ),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final favorites = ref.watch(favoritesProvider);
    ref.watch(reviewsProvider);
    final reviews = ref.read(reviewsProvider.notifier);
    final availability = ref.watch(workerAvailabilityProvider);
    final workerReviews = reviews.forWorker(widget.worker.id);
    final isFav = favorites.contains(widget.worker.id);
    final isAvailable = availability[widget.worker.id] ?? widget.worker.isAvailable;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRatingSheet(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.star_rounded),
        label: const Text('قيّم العاملة', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            // العنوان يظهر عند الانكماش
            title: Text(
              widget.worker.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              aiAppBarButton(context, initialMessage: 'أخبرني عن تقييمات ${widget.worker.name}'),
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.black38,
                  child: IconButton(
                    icon: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? AppColors.error : Colors.white, size: 20),
                    onPressed: () {
                      ref
                          .read(favoritesProvider.notifier)
                          .toggle(widget.worker.id);
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(url: widget.worker.imageUrl, height: 280),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(widget.worker.name,
                                  style: const TextStyle(
                                      fontSize: 22, fontWeight: FontWeight.w800)),
                            ),
                            StatusPill(
                              label: isAvailable ? 'متاحة الآن' : 'مشغولة',
                              color:
                                  isAvailable ? AppColors.success : AppColors.warning,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${widget.worker.category} • ${widget.worker.location}',
                            style: const TextStyle(color: AppColors.muted)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _Stat(icon: Icons.star_rounded, value: '${widget.worker.rating}', label: 'التقييم', color: AppColors.warning),
                            _Stat(icon: Icons.work_history_rounded, value: '${widget.worker.jobsCompleted}', label: 'مهمة مكتملة', color: AppColors.primary),
                            _Stat(icon: Icons.schedule_rounded, value: '\$${widget.worker.hourlyRate}', label: 'للساعة', color: AppColors.success),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text('نبذة',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text(widget.worker.about,
                            style: TextStyle(
                                fontSize: 13.5,
                                height: 1.7,
                                color: isDark ? Colors.white70 : AppColors.muted)),
                        const SizedBox(height: 18),
                        const Text('المهارات',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.worker.skills
                              .map((s) => Chip(
                                    avatar: const Icon(Icons.check_circle_rounded,
                                        size: 15, color: AppColors.primary),
                                    label: Text(s,
                                        style: const TextStyle(fontSize: 12)),
                                    visualDensity: VisualDensity.compact,
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('التقييمات (${workerReviews.length})',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w800)),
                            if (reviews.averageFor(widget.worker.id) > 0)
                              Row(children: [
                                const Icon(Icons.star_rounded,
                                    size: 17, color: AppColors.warning),
                                Text(
                                  reviews.averageFor(widget.worker.id).toStringAsFixed(1),
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ]),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (workerReviews.isEmpty)
                          Text('لا توجد تقييمات بعد',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white54 : AppColors.textHint)),
                        ...workerReviews.map((r) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                      radius: 19,
                                      backgroundImage: NetworkImage(r.reviewerImage)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(r.reviewerName,
                                                  style: const TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 13)),
                                            ),
                                            Icon(Icons.star_rounded,
                                                size: 14, color: AppColors.warning),
                                            Text('${r.rating}',
                                                style: const TextStyle(fontSize: 12)),
                                          ],
                                        ),
                                        Text(r.comment,
                                            style: TextStyle(
                                                fontSize: 12.5,
                                                color: isDark
                                                    ? Colors.white60
                                                    : AppColors.muted,
                                                height: 1.5)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Similar workers section
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                final similar = getSimilarWorkers(widget.worker);
                if (similar.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('عاملات مشابهات',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: similar.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, i) {
                            final w = similar[i];
                            return GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          WorkerProfileScreen(worker: w))),
                              child: Container(
                                width: 80,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: context.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: context.stroke),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(w.imageUrl),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(w.name.split(' ').first,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700)),
                                    Text('\$${w.hourlyRate}/س',
                                        style: const TextStyle(
                                            fontSize: 9,
                                            color: AppColors.primary)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Row(
            children: [
              IconButton.outlined(
                onPressed: _openChat,
                icon: const Icon(Icons.chat_bubble_outline_rounded,
                    color: AppColors.primary),
              ),
              const SizedBox(width: 6),
              Text(
                '${currency.format(widget.worker.hourlyRate)}/ساعة',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const Spacer(),
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(110, 46),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  onPressed: _openBooking,
                  icon: const Icon(Icons.event_available_rounded, size: 18),
                  label: const Text('احجز الآن'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const StatusPill({super.key, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800, color: color)),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}




