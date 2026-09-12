import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../data/models.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/company_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/platform_control_provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/pro_components.dart';
import 'company_analytics_screen.dart';
import 'company_bookings_screen.dart';
import 'company_services_screen.dart';
import 'company_settings_screen.dart';
import 'company_workers_screen.dart';
import 'company_billing_screen.dart';

class CompanyDashboardScreen extends ConsumerStatefulWidget {
  const CompanyDashboardScreen({super.key});

  @override
  ConsumerState<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends ConsumerState<CompanyDashboardScreen> {
  late final PageController _bannerController;
  int _currentBannerIndex = 0;

  static const _banners = [
    _CompanyBannerData(
      title: 'طلبات اليوم تحت السيطرة',
      subtitle: 'تابع فريقك لحظيا ووزع الطلبات بذكاء.',
      chip: 'لوحة الشركة',
      cta: 'عرض الطلبات',
      icon: Icons.dashboard_customize_rounded,
      gradient: LinearGradient(
        colors: [AppColors.primary, Color(0xFF6366F1), AppColors.primary],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
    ),
    _CompanyBannerData(
      title: 'رضا العملاء ارتفع 18%',
      subtitle: 'استمر بنفس جودة الخدمة للحفاظ على التقييمات.',
      chip: 'نمو الأداء',
      cta: 'تفاصيل الأداء',
      icon: Icons.trending_up_rounded,
      gradient: LinearGradient(
        colors: [Color(0xFF0EA5E9), Color(0xFF2563EB), AppColors.primary],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
    ),
    _CompanyBannerData(
      title: 'جدولة ذكية للفِرق',
      subtitle: 'قلل وقت التنقل وارفع عدد المهام اليومية.',
      chip: 'تشغيل ذكي',
      cta: 'افتح الجدول',
      icon: Icons.auto_awesome_rounded,
      gradient: LinearGradient(
        colors: [AppColors.primary, Color(0xFF9333EA), Color(0xFFEC4899)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _onBannerCta(int i) {
    switch (i) {
      case 0:
        _push(const CompanyBookingsScreen());
        break;
      case 1:
        _push(const CompanyAnalyticsScreen());
        break;
      default:
        _push(const CompanyWorkersScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final companyName = user?.companyInfo?.companyName.isNotEmpty == true
        ? user!.companyInfo!.companyName
        : user?.name ?? 'شركتي';
    final isVerified = user?.isVerified ?? false;
    final sub = ref.watch(subscriptionProvider);
    final workers = ref.watch(companyWorkersProvider);
    final bookings = ref.watch(myBookingsProvider);
    final wallet = ref.watch(walletProvider);
    final currency = ref.watch(currencyProvider);
    final flags = ref.watch(platformFlagsProvider);
    final pendingCount = bookings.where((b) => b.status == BookingStatus.pending).length;
    final completedCount = bookings.where((b) => b.status == BookingStatus.completed).length;
    final availableWorkers = workers.where((w) => w.isAvailable).length;
    final todayRevenue = bookings
        .where((b) => b.status == BookingStatus.completed)
        .fold<double>(0, (s, b) => s + b.total);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.pageBg,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AdaptiveHeader(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                child: Row(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.heroGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.business_center_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مرحباً، ${user?.name ?? 'مؤسس الشركة'} 👋',
                            style: TextStyle(
                              color: context.mutedText,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            companyName,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: context.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isVerified
                                    ? AppColors.success.withValues(alpha: 0.14)
                                    : AppColors.warning.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isVerified ? '✔ حساب موثّق' : '⏳ قيد التوثيق',
                                style: TextStyle(
                                    color: isVerified ? AppColors.success : AppColors.warning,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                            if (sub.isActive) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: .12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  sub.tier.arabicLabel,
                                  style: const TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 196,
                      child: PageView.builder(
                        controller: _bannerController,
                        onPageChanged: (i) {
                          if (!mounted) return;
                          setState(() => _currentBannerIndex = i);
                        },
                        itemCount: _banners.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: GestureDetector(
                            onTap: () => _onBannerCta(i),
                            child:
                                _CompanyHeroBanner(data: _banners[i]),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _banners.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _currentBannerIndex == i ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentBannerIndex == i
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Text(
                      'إحصائيات سريعة',
                      style: TextStyle(
                        color: context.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'اليوم',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                delegate: SliverChildListDelegate([
                   _StatCard(
                    title: 'طلبات جديدة',
                    value: '$pendingCount',
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.primary,
                  ),
                  _StatCard(
                    title: 'مكتمل اليوم',
                    value: '$completedCount',
                    icon: Icons.verified_rounded,
                    color: AppColors.success,
                  ),
                  _StatCard(
                    title: 'فريق متاح',
                    value: '$availableWorkers/${workers.length}',
                    icon: Icons.groups_rounded,
                    color: AppColors.accent,
                  ),
                  _StatCard(
                    title: 'الإيرادات',
                    value: currency.format(todayRevenue),
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.primary,
                  ),
                ]),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.55,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                child: Text(
                  'إجراءات سريعة',
                  style: TextStyle(
                    color: context.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 122,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    if (flags.companyBookingsTabVisible) ...[
                    _QuickActionCard(
                      title: 'الطلبات الواردة',
                      icon: Icons.inbox_rounded,
                      color: const Color(0xFFFFEDD5),
                      iconColor: const Color(0xFFEA580C),
                      onTap: () => _push(const CompanyBookingsScreen()),
                    ),
                    const SizedBox(width: 10),
                    ],
                    if (flags.companyWorkersTabVisible) ...[
                    _QuickActionCard(
                      title: 'إدارة الفِرق',
                      icon: Icons.manage_accounts_rounded,
                      color: const Color(0xFFEDE9FE),
                      iconColor: const Color(0xFF5B21B6),
                      onTap: () => _push(const CompanyWorkersScreen()),
                    ),
                    const SizedBox(width: 10),
                    ],
                    if (flags.companyServicesVisible) ...[
                    _QuickActionCard(
                      title: 'خدماتنا وأسعارنا',
                      icon: Icons.sell_rounded,
                      color: const Color(0xFFDBEAFE),
                      iconColor: const Color(0xFF1D4ED8),
                      onTap: () => _push(const CompanyServicesScreen()),
                    ),
                    const SizedBox(width: 10),
                    ],
                    if (flags.companyAnalyticsVisible) ...[
                    _QuickActionCard(
                      title: 'تقارير الأداء',
                      icon: Icons.insights_rounded,
                      color: const Color(0xFFDCFCE7),
                      iconColor: const Color(0xFF166534),
                      onTap: () => _push(const CompanyAnalyticsScreen()),
                    ),
                    const SizedBox(width: 10),
                    ],
                    _QuickActionCard(
                      title: 'إعدادات الشركة',
                      icon: Icons.settings_rounded,
                      color: const Color(0xFFF1F5F9),
                      iconColor: const Color(0xFF334155),
                      onTap: () => _push(const CompanySettingsScreen()),
                    ),
                    if (flags.companyBillingVisible) ...[
                    const SizedBox(width: 10),
                    _QuickActionCard(
                      title: 'الفواتير والتسوية',
                      icon: Icons.receipt_long_rounded,
                      color: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFF92400E),
                      onTap: () => _push(const CompanyBillingScreen()),
                    ),
                    ],
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                child: Text(
                  'آخر التحديثات',
                  style: TextStyle(
                    color: context.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList.list(
                children: [
                  const _UpdateTile(
                    title: 'تم اعتماد 5 طلبات جديدة',
                    subtitle: 'آخر تحديث قبل 9 دقائق',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 10),
                  const _UpdateTile(
                    title: 'تنبيه: تأخير في فريق المنطقة الغربية',
                    subtitle: 'آخر تحديث قبل 25 دقيقة',
                    icon: Icons.warning_rounded,
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: 10),
                  const _UpdateTile(
                    title: 'تحصيل دفعة شهرية بنجاح',
                    subtitle: 'آخر تحديث قبل ساعة',
                    icon: Icons.paid_rounded,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class company_dashboard_screen extends CompanyDashboardScreen {
  const company_dashboard_screen({super.key});
}

class _CompanyBannerData {
  final String title;
  final String subtitle;
  final String chip;
  final String cta;
  final IconData icon;
  final LinearGradient gradient;

  const _CompanyBannerData({
    required this.title,
    required this.subtitle,
    required this.chip,
    required this.cta,
    required this.icon,
    required this.gradient,
  });
}

class _CompanyHeroBanner extends StatelessWidget {
  final _CompanyBannerData data;

  const _CompanyHeroBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: data.gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x334F46E5),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -26,
            top: -24,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -12,
            bottom: -20,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        data.chip,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(data.icon, color: Colors.white, size: 22),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  data.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      data.cta,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
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

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
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
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.mutedText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
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
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback? onTap;

  const _QuickActionCard({
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
      child: Container(
        width: 124,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 27),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                maxLines: 1,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdateTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _UpdateTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ProCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_left_rounded, color: AppColors.textHint),
        ],
      ),
    );
  }
}

