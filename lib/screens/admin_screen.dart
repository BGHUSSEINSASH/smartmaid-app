import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../providers/currency_provider.dart';
import '../providers/platform_control_provider.dart';
import '../widgets/pro_components.dart';
import 'admin_companies_screen.dart';
import 'admin_disputes_screen.dart';
import 'admin_finance_screen.dart';
import 'admin_discounts_screen.dart';
import 'admin_commissions_screen.dart';
import 'admin_system_settings_screen.dart';
import 'admin_kyc_review_screen.dart';
import 'admin_push_notifications_screen.dart';
import 'admin_users_management_screen.dart';
import 'admin_platform_control_screen.dart';
import 'admin_create_company_screen.dart';
import 'admin_subscriptions_screen.dart';
import 'admin_auto_replies_screen.dart';
import 'admin_conversations_screen.dart';
import 'admin_staff_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/staff_provider.dart';
import '../data/models.dart';
import 'admin_compensations_screen.dart';
import 'maintenance_screen.dart';
import 'privacy_policy_screen.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});
  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  /// يتحقق إن كان المستخدم الحالي يملك صلاحية معينة.
  bool _hasPerm(StaffPermission perm) {
    final user = ref.read(authProvider).user;
    if (user == null) return false;
    if (user.role == AppRole.admin) {
      final staff = ref.read(staffProvider);
      final me = staff.where((s) => s.email == user.email).firstOrNull;
      if (me == null) return true; // superAdmin بلا قيود
      return me.permissions.contains(perm);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      backgroundColor: context.pageBg,
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: AdaptiveHeader(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\u0645\u0631\u062d\u0628\u0627\u064b \u0628\u0643\u060c \u0645\u062f\u064a\u0631 \u0627\u0644\u0646\u0638\u0627\u0645 \ud83d\udc4b',
                          style: TextStyle(
                            color: context.mutedText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\u0644\u0648\u062d\u0629 \u062a\u062d\u0643\u0645 \u0645\u0624\u0633\u0633 \u0627\u0644\u0646\u0638\u0627\u0645',
                          style: TextStyle(
                            color: context.ink,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: AppColors.heroGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '\u26a1 \u0635\u0644\u0627\u062d\u064a\u0627\u062a \u0643\u0627\u0645\u0644\u0629',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                  // ── Quick Stats ─────────────────────────────────────────────
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      _StatCard(
                        title: 'إيرادات اليوم',
                        value: currency.format(12450),
                        icon: Icons.attach_money_rounded,
                        color: AppColors.primary,
                        isCurrency: true,
                      ),
                      _StatCard(
                        title: 'الشركات النشطة',
                        value: '14',
                        icon: Icons.business_rounded,
                        color: const Color(0xFF8B5CF6),
                      ),
                      _StatCard(
                        title: 'العاملات المتاحات',
                        value: '45',
                        icon: Icons.people_alt_rounded,
                        color: const Color(0xFF3B82F6),
                      ),
                      _StatCard(
                        title: 'الطلبات المعلقة',
                        value: '8',
                        icon: Icons.pending_actions_rounded,
                        color: AppColors.warning,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const SectionHeader(title: 'إيرادات آخر 7 أيام'),
                  const SizedBox(height: 16),
                  ProCard(
                    child: SizedBox(
                      height: 180,
                      child: _RevenueChart(),
                    ),
                  ),

                  const SizedBox(height: 32),
                  const SectionHeader(title: 'إدارة النظام السريعة'),
                  const SizedBox(height: 16),

                  // ── Quick Actions — Full Grid ─────────────────────
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.92,
                    children: [
                      if (_hasPerm(StaffPermission.manageUsers))
                        _ActionCard(title: 'المستخدمون', icon: Icons.group_rounded, color: const Color(0xFFE0F2FE), iconColor: const Color(0xFF0284C7), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersManagementScreen()))),
                      if (_hasPerm(StaffPermission.manageCompanies))
                        _ActionCard(title: 'الشركات', icon: Icons.domain_rounded, color: const Color(0xFFF3E8FF), iconColor: const Color(0xFF7E22CE), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCompaniesScreen()))),
                      if (_hasPerm(StaffPermission.manageFinance))
                        _ActionCard(title: 'المالية', icon: Icons.account_balance_wallet_rounded, color: const Color(0xFFDCFCE7), iconColor: const Color(0xFF166534), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminFinanceScreen()))),
                      _ActionCard(title: 'النزاعات', icon: Icons.gavel_rounded, color: const Color(0xFFFFF7ED), iconColor: const Color(0xFFEA580C), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDisputesScreen()))),
                      if (_hasPerm(StaffPermission.manageDiscounts))
                        _ActionCard(title: 'الخصومات', icon: Icons.percent_rounded, color: const Color(0xFFECFDF5), iconColor: const Color(0xFF059669), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDiscountsScreen()))),
                      if (_hasPerm(StaffPermission.manageCommissions))
                        _ActionCard(title: 'العمولات', icon: Icons.price_change_rounded, color: const Color(0xFFFEF3C7), iconColor: const Color(0xFFB45309), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCommissionsScreen()))),
                      if (_hasPerm(StaffPermission.approveKyc))
                        _ActionCard(title: 'مراجعة KYC', icon: Icons.verified_user_rounded, color: const Color(0xFFEDE9FE), iconColor: AppColors.primary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminKycReviewScreen()))),
                      if (_hasPerm(StaffPermission.sendBroadcast))
                        _ActionCard(title: 'الإشعارات', icon: Icons.notifications_rounded, color: const Color(0xFFFDF2F8), iconColor: const Color(0xFFDB2777), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPushNotificationsScreen()))),
                      if (_hasPerm(StaffPermission.changeSystemSettings))
                        _ActionCard(title: 'إعدادات النظام', icon: Icons.settings_rounded, color: const Color(0xFFF1F5F9), iconColor: const Color(0xFF475569), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSystemSettingsScreen()))),
                      if (_hasPerm(StaffPermission.managePlatformFlags))
                        _ActionCard(title: 'التحكم بالمنصة', icon: Icons.tune_rounded, color: const Color(0xFFEEF2FF), iconColor: AppColors.primary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPlatformControlScreen()))),
                      if (_hasPerm(StaffPermission.createCompany))
                        _ActionCard(title: 'إنشاء شركة', icon: Icons.add_business_rounded, color: const Color(0xFFFCE7F3), iconColor: const Color(0xFFBE185D), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCreateCompanyScreen()))),
                      if (_hasPerm(StaffPermission.manageSubscriptions))
                        _ActionCard(title: 'الاشتراكات', icon: Icons.card_membership_rounded, color: const Color(0xFFF0FDF4), iconColor: const Color(0xFF16A34A), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSubscriptionsScreen()))),
                      if (_hasPerm(StaffPermission.respondToChats))
                        _ActionCard(title: 'ردود تلقائية', icon: Icons.auto_awesome_rounded, color: const Color(0xFFFFF7ED), iconColor: const Color(0xFFD97706), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAutoRepliesScreen()))),
                      if (_hasPerm(StaffPermission.respondToChats))
                        _ActionCard(title: 'المحادثات', icon: Icons.chat_rounded, color: const Color(0xFFE0F2FE), iconColor: const Color(0xFF0369A1), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminConversationsScreen()))),
                      _ActionCard(title: 'فريق الإدارة', icon: Icons.manage_accounts_rounded, color: const Color(0xFFF3E8FF), iconColor: const Color(0xFF9333EA), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminStaffScreen()))),
                      if (_hasPerm(StaffPermission.issueCompensations))
                        _ActionCard(title: 'التعويضات', icon: Icons.volunteer_activism_rounded, color: const Color(0xFFFFF1F2), iconColor: const Color(0xFFE11D48), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCompensationsScreen()))),
                      _ActionCard(title: 'سياسة الخصوصية', icon: Icons.privacy_tip_rounded, color: const Color(0xFFE0F2FE), iconColor: const Color(0xFF0369A1), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()))),
                    ],
                  ),

                  const SizedBox(height: 32),
                  // ── وضع الصيانة السريع ──────────────────────────────
                  _MaintenanceQuickCard(hasPerm: _hasPerm(StaffPermission.changeSystemSettings)),

                  const SizedBox(height: 32),
                  const SectionHeader(title: 'أحدث التنبيهات'),
                  const SizedBox(height: 16),

                  // ── Alerts List ─────────────────────────────────────────────
                  ProCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _AlertItem(
                          title: 'طلب انضمام شركة جديدة',
                          subtitle: 'شركة النظافة المتقدمة تنتظر الموافقة',
                          time: 'منذ 10 دقائق',
                          isUrgent: true,
                        ),
                        const Divider(height: 1, indent: 60),
                        _AlertItem(
                          title: 'سحب أرباح معلق',
                          subtitle: 'تم طلب سحب بقيمة ',
                          time: 'منذ ساعة',
                          isUrgent: false,
                        ),
                        const Divider(height: 1, indent: 60),
                        _AlertItem(
                          title: 'شكوى جديدة مسجلة',
                          subtitle: 'العميل أحمد رفع تذكرة دعم للطلب #4092',
                          time: 'منذ ساعتين',
                          isUrgent: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isCurrency;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isCurrency = false,
  });

  @override
  Widget build(BuildContext context) {
    return ProCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.mutedText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    color: context.ink,
                    fontSize: isCurrency ? 19 : 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withAlpha(40)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(height: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final bool isUrgent;

  const _AlertItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isUrgent,
  });

  @override
  Widget build(BuildContext context) {
    return ProListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isUrgent
              ? AppColors.error.withAlpha(20)
              : AppColors.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isUrgent ? Icons.warning_rounded : Icons.info_rounded,
          color: isUrgent ? AppColors.error : AppColors.primary,
          size: 22,
        ),
      ),
      title: title,
      subtitle: subtitle,
      trailing: Text(
        time,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {},
    );
  }
}

class _RevenueChart extends StatelessWidget {
  static const _values = [8.2, 9.6, 7.4, 11.2, 10.1, 12.8, 12.45];
  static const _days = ['سبت', 'أحد', 'اثن', 'ثلا', 'أرب', 'خمي', 'جمع'];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 14,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= _days.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_days[i],
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.muted)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < _values.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: _values[i],
                width: 16,
                borderRadius: BorderRadius.circular(6),
                gradient: AppColors.heroGradient,
              ),
            ]),
        ],
      ),
    );
  }
}

// ── بطاقة وضع الصيانة السريع ────────────────────────────────────────
class _MaintenanceQuickCard extends ConsumerWidget {
  final bool hasPerm;
  const _MaintenanceQuickCard({required this.hasPerm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(platformFlagsProvider);
    final n = ref.read(platformFlagsProvider.notifier);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: flags.maintenanceMode
            ? const LinearGradient(colors: [Color(0xFFDC2626), Color(0xFF991B1B)])
            : LinearGradient(
                colors: [AppColors.primary.withValues(alpha: .08), AppColors.primary.withValues(alpha: .04)]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: flags.maintenanceMode
              ? const Color(0xFFDC2626)
              : AppColors.primary.withValues(alpha: .2),
        ),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: flags.maintenanceMode
                ? Colors.white.withValues(alpha: .2)
                : AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            flags.maintenanceMode ? Icons.construction_rounded : Icons.check_circle_rounded,
            color: flags.maintenanceMode ? Colors.white : AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              flags.maintenanceMode ? 'التطبيق في وضع الصيانة' : 'التطبيق يعمل بشكل طبيعي',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: flags.maintenanceMode ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            Text(
              flags.maintenanceMode
                  ? flags.maintenanceEndTime.isNotEmpty
                      ? 'ينتهي: ${flags.maintenanceEndTime}'
                      : 'جميع المستخدمين يرون شاشة الصيانة'
                  : 'لا توجد قيود على المستخدمين',
              style: TextStyle(
                color: flags.maintenanceMode
                    ? Colors.white70
                    : AppColors.muted,
                fontSize: 12,
              ),
            ),
          ]),
        ),
        const SizedBox(width: 8),
        if (hasPerm)
          GestureDetector(
            onTap: () => flags.maintenanceMode
                ? n.disableMaintenance()
                : Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminPlatformControlScreen()),
                  ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: flags.maintenanceMode ? Colors.white : AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                flags.maintenanceMode ? 'إيقاف' : 'إدارة',
                style: TextStyle(
                  color: flags.maintenanceMode ? const Color(0xFFDC2626) : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ]),
    );
  }
}



