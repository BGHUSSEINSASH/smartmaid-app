import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/ai/assistant_engine.dart';
import '../core/responsive/breakpoints.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import '../providers/currency_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/platform_control_provider.dart';
import '../widgets/app_image.dart';
import '../widgets/smart_search_bar.dart';
import 'worker_profile_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';
  bool _loading = false;
  List<AssistantMatch> _aiMatches = [];
  String? _aiSuggestion;

  // فلاتر سريعة — القيمة الثانية هي كلمة البحث الجزئية لـ contains
  String? _activeFilter;
  static const _filters = [
    ('الكل',         null),
    ('تنظيف',        'تنظيف'),
    ('طبخ',          'طبخ'),
    ('أطفال',        'أطفال'),
    ('كبار السن',    'كبار السن'),
    ('غسيل',         'غسيل'),
    ('تنظيف عميق',   'عميق'),
  ];

  // اقتراحات شائعة
  static const _popular = [
    '🧹 تنظيف منزلي عام',
    '🍳 طباخة خبيرة',
    '👶 جليسة أطفال',
    '✨ تنظيف عميق',
    '👴 رعاية كبار السن',
    '👕 غسيل وكواء',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _ctrl.text = widget.initialQuery!;
      _query = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) => _runSearch(widget.initialQuery!));
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _runSearch(String q) async {
    if (q.trim().isEmpty) {
      setState(() { _query = ''; _aiMatches = []; _aiSuggestion = null; });
      return;
    }
    setState(() { _query = q.trim(); _loading = true; _aiMatches = []; _aiSuggestion = null; });
    await Future.delayed(const Duration(milliseconds: 280));

    // ادمج الفلتر مع الاستعلام لنتائج أدق
    final searchTerm = (_activeFilter != null && _activeFilter!.isNotEmpty)
        ? '${q.trim()} ${_activeFilter!}'
        : q.trim();

    final matches = matchWorkers(searchTerm);
    if (matches.isEmpty) {
      _aiSuggestion = suggestCorrection(q.trim());
    }
    if (mounted) setState(() { _aiMatches = matches; _loading = false; });
  }

  List<WorkerModel> get _filteredWorkers {
    final all = [...DemoData.workers, ...DemoData.companyWorkers];

    // إذا لم يكن هناك بحث — أظهر الكل مع فلترة التصنيف إن وُجد
    if (_aiMatches.isEmpty && _query.isEmpty) {
      if (_activeFilter != null && _activeFilter!.isNotEmpty) {
        return all.where((w) =>
            w.category.contains(_activeFilter!) ||
            w.skills.any((s) => s.contains(_activeFilter!))).toList();
      }
      return all;
    }

    // نتائج AI — ربط بـ ID
    if (_aiMatches.isNotEmpty) {
      final matched = <WorkerModel>[];
      for (final m in _aiMatches) {
        final w = all.where((w) => w.id == m.workerId).firstOrNull;
        if (w != null) matched.add(w);
      }
      // إذا AI أعطى نتائج وفيه فلتر — فلتر فوقها
      if (_activeFilter != null && _activeFilter!.isNotEmpty && matched.isNotEmpty) {
        final filtered = matched.where((w) =>
            w.category.contains(_activeFilter!) ||
            w.skills.any((s) => s.contains(_activeFilter!))).toList();
        return filtered.isEmpty ? matched : filtered;
      }
      return matched;
    }

    // بحث نصي بسيط كـ fallback
    return all.where((w) =>
        w.name.contains(_query) ||
        w.category.contains(_query) ||
        w.skills.any((s) => s.contains(_query))).toList();
  }

  double _matchScore(String workerId) {
    final m = _aiMatches.where((m) => m.workerId == workerId).firstOrNull;
    return m?.matchScore ?? 0.5;
  }

  String _matchLabel(String workerId) {
    final m = _aiMatches.where((m) => m.workerId == workerId).firstOrNull;
    if (m == null) return '';
    final pct = (m.matchScore * 100).round();
    if (pct >= 90) return '🤖 تطابق ممتاز ($pct%)';
    if (pct >= 70) return '🤖 تطابق جيد ($pct%)';
    return '🤖 تطابق ($pct%)';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = ref.watch(currencyProvider);
    final flags = ref.watch(platformFlagsProvider);
    final workers = _filteredWorkers;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 4, right: 12),
          child: SmartSearchBar(
            controller: _ctrl,
            autofocus: widget.initialQuery == null,
            hint: 'ابحث بالنص أو الصوت...',
            aiInitialMessage: _query.isNotEmpty ? _query : 'ساعدني في العثور على عاملة',
            onSearch: _runSearch,
          ),
        ),
      ),
      body: CustomScrollView(slivers: [
        // ── فلاتر سريعة ──────────────────────────────────────────────
        SliverToBoxAdapter(
          child: SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              children: _filters.map((f) {
                final (label, cat) = f;
                final active = _activeFilter == cat;
                return GestureDetector(
                  onTap: () {
                    setState(() => _activeFilter = cat);
                    if (_query.isNotEmpty || cat != null) _runSearch(cat ?? _query);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : (isDark ? AppColors.surfaceDark : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: active ? AppColors.primary : AppColors.stroke),
                    ),
                    child: Text(label, style: TextStyle(
                      color: active ? Colors.white : null,
                      fontWeight: FontWeight.w700, fontSize: 13,
                    )),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // ── حالة: قبل البحث → اقتراحات شائعة ──────────────────────
        if (_query.isEmpty && !_loading)
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('الأكثر بحثاً', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 12),
              Wrap(spacing: 10, runSpacing: 10, children: _popular.map((p) => GestureDetector(
                onTap: () { _ctrl.text = p.substring(2).trim(); _runSearch(p.substring(2).trim()); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: Text(p, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              )).toList()),
              const SizedBox(height: 24),
            ]),
          )),

        // ── حالة: تحميل ──────────────────────────────────────────────
        if (_loading)
          SliverList(delegate: SliverChildBuilderDelegate(
            (_, i) => _ShimmerCard(),
            childCount: 4,
          )),

        // ── نتيجة: لا توجد + اقتراح ──────────────────────────────────
        if (!_loading && _query.isNotEmpty && workers.isEmpty)
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(children: [
              const Icon(Icons.search_off_rounded, size: 64, color: AppColors.muted),
              const SizedBox(height: 14),
              Text('لا توجد نتائج لـ "$_query"', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              if (_aiSuggestion != null) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () { _ctrl.text = _aiSuggestion!; _runSearch(_aiSuggestion!); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: .2)),
                    ),
                    child: Text('🤖 هل تقصد: "$_aiSuggestion"؟',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ]),
          )),

        // ── ترويسة النتائج ──────────────────────────────────────────
        if (!_loading && workers.isNotEmpty)
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(children: [
              Text('${workers.length} عاملة', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              if (_query.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('لـ "$_query"', style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              ],
              const Spacer(),
              if (_aiMatches.isNotEmpty)
                const Row(children: [
                  Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.accent),
                  SizedBox(width: 4),
                  Text('مرتّب بالذكاء الاصطناعي', style: TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w700)),
                ]),
            ]),
          )),

        // ── قائمة العاملات ────────────────────────────────────────────
        if (!_loading && workers.isNotEmpty)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              Bp.hPad(context), 0,
              Bp.hPad(context),
              Bp.listBottomPad(context),
            ),
            sliver: Bp.isPhone(context)
                ? SliverList(delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final w = workers[i];
                      return _WorkerCard(
                        worker: w,
                        currency: currency,
                        aiLabel: _matchLabel(w.id),
                        aiScore: _matchScore(w.id),
                        onTap: () => Navigator.push(ctx,
                            MaterialPageRoute(builder: (_) => WorkerProfileScreen(worker: w))),
                      );
                    },
                    childCount: workers.length,
                  ))
                : SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final w = workers[i];
                        return _WorkerCard(
                          worker: w,
                          currency: currency,
                          aiLabel: _matchLabel(w.id),
                          aiScore: _matchScore(w.id),
                          onTap: () => Navigator.push(ctx,
                              MaterialPageRoute(builder: (_) => WorkerProfileScreen(worker: w))),
                        );
                      },
                      childCount: workers.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Bp.gridCols(context),
                      childAspectRatio: Bp.isTablet(context) ? 1.8 : 1.6,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                  ),
          ),
      ]),
    );
  }
}

// ── Worker Card مع AI label ──────────────────────────────────────────
class _WorkerCard extends ConsumerWidget {
  final WorkerModel worker;
  final AppCurrency currency;
  final String aiLabel;
  final double aiScore;
  final VoidCallback onTap;

  const _WorkerCard({required this.worker, required this.currency,
      required this.aiLabel, required this.aiScore, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFav = ref.watch(favoritesProvider).contains(worker.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: aiScore >= 0.8 ? AppColors.primary.withValues(alpha: .3) : AppColors.stroke),
          boxShadow: [BoxShadow(
            color: aiScore >= 0.8 ? AppColors.primary.withValues(alpha: .06) : Colors.black.withValues(alpha: .03),
            blurRadius: 12, offset: const Offset(0, 4),
          )],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AppImage(url: worker.imageUrl, width: 64, height: 64),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(worker.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
                if (worker.isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.success.withValues(alpha: .1), borderRadius: BorderRadius.circular(8)),
                    child: const Text('متاحة', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w700)),
                  ),
              ]),
              const SizedBox(height: 3),
              Text(worker.category, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              const SizedBox(height: 5),
              Row(children: [
                const Icon(Icons.star_rounded, color: AppColors.warning, size: 14),
                const SizedBox(width: 3),
                Text('${worker.rating}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(width: 8),
                const Icon(Icons.work_rounded, color: AppColors.muted, size: 12),
                const SizedBox(width: 3),
                Text('${worker.jobsCompleted} مهمة', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                const Spacer(),
                Text(currency.format(worker.hourlyRate) + '/س', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 13)),
              ]),
            ])),
            IconButton(
              icon: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFav ? AppColors.error : AppColors.muted, size: 20),
              onPressed: () => ref.read(favoritesProvider.notifier).toggle(worker.id),
            ),
          ]),
          // AI Label
          if (aiLabel.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(aiLabel, style: const TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w700)),
            ),
          ],
          // مهارات
          if (worker.skills.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 4, children: worker.skills.take(3).map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
              child: Text(s, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
            )).toList()),
          ],
        ]),
      ),
    );
  }
}

// ── Shimmer Card ────────────────────────────────────────────────────
class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}
class _ShimmerCardState extends State<_ShimmerCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _anim = Tween(begin: -1.5, end: 1.5).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF1A1D27) : const Color(0xFFE8EDF2);
    final highlight = isDark ? const Color(0xFF252836) : const Color(0xFFF5F8FC);
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0), end: Alignment(_anim.value + 1, 0),
            colors: [base, highlight, highlight, base],
            stops: const [0.0, 0.35, 0.65, 1.0],
          ),
        ),
      ),
    );
  }
}

