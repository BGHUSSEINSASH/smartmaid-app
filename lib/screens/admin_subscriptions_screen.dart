import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../providers/subscription_provider.dart';
import '../providers/admin_providers.dart';
import '../data/models.dart';
import '../widgets/pro_components.dart';

/// سجل اشتراكات متعدد المستخدمين — مستقل عن الجلسة الحالية
class UserSubRecord {
  final String userId;
  final String userName;
  final String userPhone;
  final AppRole role;
  SubscriptionTier tier;
  DateTime? expiresAt;
  final List<_SubAuditEntry> history;

  UserSubRecord({
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.role,
    this.tier = SubscriptionTier.free,
    this.expiresAt,
    List<_SubAuditEntry>? history,
  }) : history = history ?? [];

  bool get isActive =>
      tier != SubscriptionTier.free &&
      expiresAt != null &&
      expiresAt!.isAfter(DateTime.now());

  int get daysLeft => expiresAt != null
      ? expiresAt!.difference(DateTime.now()).inDays.clamp(0, 9999)
      : 0;
}

class _SubAuditEntry {
  final String action;
  final String adminName;
  final DateTime at;
  _SubAuditEntry({required this.action, required this.adminName, required this.at});
}

class AdminSubscriptionsScreen extends ConsumerStatefulWidget {
  const AdminSubscriptionsScreen({super.key});
  @override
  ConsumerState<AdminSubscriptionsScreen> createState() => _AdminSubsState();
}

class _AdminSubsState extends ConsumerState<AdminSubscriptionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _search = '';
  final _searchCtrl = TextEditingController();

  // سجل الاشتراكات — في التطبيق الحقيقي يأتي من backend
  late final List<UserSubRecord> _records;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _records = _buildDemoRecords();
  }

  List<UserSubRecord> _buildDemoRecords() {
    final users = ref.read(usersManagementProvider);
    return users.map((u) {
      // محاكاة: 30% من المستخدمين لديهم اشتراك
      final idx = users.indexOf(u);
      SubscriptionTier tier = SubscriptionTier.free;
      DateTime? exp;
      if (idx % 3 == 0) {
        tier = SubscriptionTier.gold;
        exp = DateTime.now().add(Duration(days: 15 + idx * 3));
      } else if (idx % 5 == 0) {
        tier = SubscriptionTier.platinum;
        exp = DateTime.now().add(Duration(days: 25 + idx * 2));
      }
      return UserSubRecord(
        userId: u.id,
        userName: u.name,
        userPhone: u.phone.isEmpty ? '05xxxxxxxx' : u.phone,
        role: u.role,
        tier: tier,
        expiresAt: exp,
      );
    }).toList();
  }

  List<UserSubRecord> get _filtered {
    var list = _records;
    final tab = _tab.index;
    if (tab == 1) list = list.where((r) => r.isActive).toList();
    if (tab == 2) list = list.where((r) => !r.isActive).toList();
    if (_search.isNotEmpty) {
      list = list
          .where((r) =>
              r.userName.contains(_search) || r.userPhone.contains(_search))
          .toList();
    }
    return list;
  }

  int get _activeCount => _records.where((r) => r.isActive).length;
  int get _goldCount =>
      _records.where((r) => r.tier == SubscriptionTier.gold && r.isActive).length;
  int get _platCount =>
      _records.where((r) => r.tier == SubscriptionTier.platinum && r.isActive).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        title: const Text('إدارة الاشتراكات'),
        bottom: TabBar(
          controller: _tab,
          onTap: (_) => setState(() {}),
          tabs: [
            Tab(text: 'الكل (${_records.length})'),
            Tab(text: 'نشط ($_activeCount)'),
            Tab(text: 'منتهي'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── إحصائيات سريعة
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(children: [
              _MiniStat(label: 'المشتركون', value: '$_activeCount', color: AppColors.success),
              const SizedBox(width: 10),
              _MiniStat(label: 'ذهبي', value: '$_goldCount', color: const Color(0xFFD4A574)),
              const SizedBox(width: 10),
              _MiniStat(label: 'بلاتيني', value: '$_platCount', color: const Color(0xFF8B5CF6)),
              const SizedBox(width: 10),
              _MiniStat(
                label: 'إيرادات (تقديري)',
                value: '\$${(_goldCount * 9.99 + _platCount * 19.99).toStringAsFixed(0)}',
                color: AppColors.primary,
              ),
            ]),
          ),

          // ── بحث
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'بحث بالاسم أو رقم الهاتف...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: context.pageBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),

          // ── القائمة
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('لا توجد نتائج'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) => _UserSubCard(
                      record: _filtered[i],
                      onGrant: (tier, days) => _grantSub(_filtered[i], tier, days),
                      onRevoke: () => _revokeSub(_filtered[i]),
                      onExtend: (days) => _extendSub(_filtered[i], days),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _grantSub(UserSubRecord rec, SubscriptionTier tier, int days) {
    setState(() {
      rec.tier = tier;
      rec.expiresAt = DateTime.now().add(Duration(days: days));
      rec.history.insert(0, _SubAuditEntry(
        action: 'منح ${tier.arabicLabel} لمدة $days يوم',
        adminName: 'المدير',
        at: DateTime.now(),
      ));
    });
    // إذا كان المستخدم هو الجلسة الحالية — نحدّث الـ provider
    ref.read(subscriptionProvider.notifier).adminGrant(tier, days);
    _snack('✅ تم منح ${tier.arabicLabel} لـ ${rec.userName} لمدة $days يوم', AppColors.success);
  }

  void _revokeSub(UserSubRecord rec) {
    setState(() {
      rec.tier = SubscriptionTier.free;
      rec.expiresAt = null;
      rec.history.insert(0, _SubAuditEntry(
        action: 'إلغاء الاشتراك',
        adminName: 'المدير',
        at: DateTime.now(),
      ));
    });
    ref.read(subscriptionProvider.notifier).adminRevoke();
    _snack('تم إلغاء اشتراك ${rec.userName}', AppColors.error);
  }

  void _extendSub(UserSubRecord rec, int days) {
    setState(() {
      final current = rec.expiresAt ?? DateTime.now();
      rec.expiresAt = current.add(Duration(days: days));
      rec.history.insert(0, _SubAuditEntry(
        action: 'تمديد الاشتراك $days يوم',
        adminName: 'المدير',
        at: DateTime.now(),
      ));
    });
    ref.read(subscriptionProvider.notifier).adminExtend(days);
    _snack('تم تمديد اشتراك ${rec.userName} بـ $days يوم', AppColors.primary);
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }
}

class _UserSubCard extends StatelessWidget {
  final UserSubRecord record;
  final void Function(SubscriptionTier, int) onGrant;
  final VoidCallback onRevoke;
  final void Function(int) onExtend;

  const _UserSubCard({
    required this.record,
    required this.onGrant,
    required this.onRevoke,
    required this.onExtend,
  });

  @override
  Widget build(BuildContext context) {
    final color = record.tier == SubscriptionTier.platinum
        ? const Color(0xFF8B5CF6)
        : record.tier == SubscriptionTier.gold
            ? const Color(0xFFD4A574)
            : AppColors.muted;

    return ProCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── رأس البطاقة
          Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: .15),
              child: Text(
                record.userName.isNotEmpty ? record.userName[0] : '?',
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(record.userName,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                Text(record.userPhone,
                    style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ]),
            ),
            // شارة الدور
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _roleLabel(record.role),
                style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 6),
            // شارة الاشتراك
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                record.tier.arabicLabel,
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ),
          ]),

          // ── معلومات الاشتراك
          if (record.isActive) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: .06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withValues(alpha: .2)),
              ),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                const SizedBox(width: 8),
                Text(
                  'نشط — ينتهي في ${record.expiresAt!.day}/${record.expiresAt!.month}/${record.expiresAt!.year}',
                  style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text('${record.daysLeft} يوم',
                    style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w900)),
              ]),
            ),
          ],

          const SizedBox(height: 12),

          // ── أزرار التحكم
          Row(children: [
            Expanded(child: _ActionBtn(
              label: 'منح',
              icon: Icons.card_membership_rounded,
              color: AppColors.primary,
              onTap: () => _showGrantDialog(context),
            )),
            const SizedBox(width: 8),
            Expanded(child: _ActionBtn(
              label: 'تمديد',
              icon: Icons.add_circle_rounded,
              color: AppColors.warning,
              onTap: () => _showExtendDialog(context),
            )),
            const SizedBox(width: 8),
            Expanded(child: _ActionBtn(
              label: 'إلغاء',
              icon: Icons.cancel_rounded,
              color: AppColors.error,
              onTap: record.isActive ? onRevoke : null,
            )),
            const SizedBox(width: 8),
            // سجل التعديلات
            if (record.history.isNotEmpty)
              GestureDetector(
                onTap: () => _showHistory(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.history_rounded, color: AppColors.primary, size: 18),
                ),
              ),
          ]),
        ],
      ),
    );
  }

  void _showGrantDialog(BuildContext context) {
    SubscriptionTier selectedTier = SubscriptionTier.gold;
    int days = 30;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('منح اشتراك'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('المستخدم: ${record.userName}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              const Text('نوع الاشتراك:', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...SubscriptionTier.values.where((t) => t != SubscriptionTier.free).map((t) =>
                GestureDetector(
                  onTap: () => setSt(() => selectedTier = t),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selectedTier == t ? AppColors.primaryLight : null,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selectedTier == t ? AppColors.primary : AppColors.stroke,
                      ),
                    ),
                    child: Row(children: [
                      Icon(
                        t == SubscriptionTier.platinum ? Icons.diamond_rounded : Icons.workspace_premium_rounded,
                        color: selectedTier == t ? AppColors.primary : AppColors.muted,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(t.arabicLabel, style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: selectedTier == t ? AppColors.primary : null,
                        )),
                        Text('\$${t.monthlyPrice}/شهر', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                      ]),
                      if (selectedTier == t) ...[
                        const Spacer(),
                        const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                      ],
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('المدة: $days يوم', style: const TextStyle(fontWeight: FontWeight.w700)),
              Slider(
                value: days.toDouble(),
                min: 1, max: 365,
                divisions: 36,
                label: '$days يوم',
                onChanged: (v) => setSt(() => days = v.round()),
              ),
              // Chips سريعة
              Wrap(spacing: 6, children: [7, 14, 30, 90, 180, 365].map((d) =>
                GestureDetector(
                  onTap: () => setSt(() => days = d),
                  child: Chip(
                    label: Text('$d ي'),
                    backgroundColor: days == d ? AppColors.primary : null,
                    labelStyle: TextStyle(color: days == d ? Colors.white : null, fontSize: 11),
                  ),
                ),
              ).toList()),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () { Navigator.pop(ctx); onGrant(selectedTier, days); },
              child: const Text('منح الاشتراك'),
            ),
          ],
        ),
      ),
    );
  }

  void _showExtendDialog(BuildContext context) {
    int days = 30;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('تمديد الاشتراك'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('الاشتراك الحالي: ${record.tier.arabicLabel}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              if (record.expiresAt != null)
                Text('ينتهي: ${record.expiresAt!.day}/${record.expiresAt!.month}/${record.expiresAt!.year}'),
              const SizedBox(height: 16),
              Text('تمديد بـ: $days يوم'),
              Slider(
                value: days.toDouble(),
                min: 1, max: 365,
                divisions: 36,
                label: '$days يوم',
                onChanged: (v) => setSt(() => days = v.round()),
              ),
              Wrap(spacing: 6, children: [7, 14, 30, 90].map((d) =>
                GestureDetector(
                  onTap: () => setSt(() => days = d),
                  child: Chip(
                    label: Text('$d ي'),
                    backgroundColor: days == d ? AppColors.primary : null,
                    labelStyle: TextStyle(color: days == d ? Colors.white : null, fontSize: 11),
                  ),
                ),
              ).toList()),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () { Navigator.pop(ctx); onExtend(days); },
              child: const Text('تمديد'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('سجل اشتراكات ${record.userName}'),
        content: SizedBox(
          width: 300,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: record.history.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final h = record.history[i];
              return ListTile(
                dense: true,
                leading: const Icon(Icons.history_rounded, color: AppColors.primary, size: 18),
                title: Text(h.action, style: const TextStyle(fontSize: 13)),
                subtitle: Text('${h.adminName} — ${h.at.day}/${h.at.month}/${h.at.year}',
                    style: const TextStyle(fontSize: 11)),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))],
      ),
    );
  }

  String _roleLabel(AppRole role) => switch (role) {
    AppRole.customer => 'عميل',
    AppRole.worker => 'عاملة',
    AppRole.company => 'شركة',
    AppRole.admin => 'مدير',
  };
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _ActionBtn({required this.label, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: .3)),
          ),
          child: Column(children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: .2)),
        ),
        child: Column(children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 9), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
