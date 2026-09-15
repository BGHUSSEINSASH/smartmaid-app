import 'dart:ui';
import '../widgets/ai_chat_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/health_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/platform_control_provider.dart';
import '../providers/reminders_provider.dart';
import 'address_screen.dart';
import 'admin_companies_screen.dart';
import 'admin_disputes_screen.dart';
import 'admin_finance_screen.dart';
import 'admin_screen.dart';
import 'booking_screen.dart';
import 'chat_list_screen.dart';
import 'company_bookings_screen.dart';
import 'company_dashboard_screen.dart';
import 'company_workers_screen.dart';
import 'faq_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'loyalty_screen.dart';
import 'my_bookings_screen.dart';
import 'offers_screen.dart';
import 'profile_screen.dart';
import 'subscription_screen.dart';
import 'tips_screen.dart';
import 'support_ticket_screen.dart';
import 'accessibility_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'unified_settings_screen.dart';
import 'wallet_screen.dart';
import 'worker_dashboard_screen.dart';
import 'worker_requests_screen.dart';
import 'worker_schedule_screen.dart';
import 'worker_section_closed_screen.dart';
import 'sos_screen.dart';
import 'kyc_screen.dart';
import 'settlements_screen.dart';
import '../widgets/suspended_banner.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationsBus.sink = (title, body, icon) {
        ref.read(notificationsProvider.notifier).addNotification(
              AppNotification(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: title,
                body: body,
                icon: icon,
                time: DateTime.now(),
              ),
            );
      };
      for (final p in NotificationsBus.drain()) {
        NotificationsBus.sink!(p.title, p.body, p.icon);
      }
      ref
          .read(remindersProvider.notifier)
          .scanUpcoming(ref.read(myBookingsProvider));
    });
  }

  void _openBooking() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const BookingScreen()));
  }

  void _openMyBookings() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
  }

  void _openSettings() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const UnifiedSettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (authState.user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = authState.user!;
    final tabs = _tabsForRole(user.role);
    final safeIndex = _index < tabs.length ? _index : 0;
    final showFab = user.role == AppRole.customer;
    final health = ref.watch(backendHealthProvider);
    final showOfflineBanner = !health.reachable;

    // إصلاح M8: البحث الصحيح عن index تبويب Profile
    final profileIndex = tabs.indexWhere((t) => t.screen is ProfileScreen);

    return SuspendedBanner(
      child: Scaffold(
      backgroundColor: context.pageBg,
      appBar: showOfflineBanner
          ? PreferredSize(
              preferredSize: const Size.fromHeight(34),
              child: OfflineBar(
                onRetry: () =>
                    ref.read(backendHealthProvider.notifier).check(),
              ),
            )
          : null,
      drawer: _AppDrawer(
        user: user,
        onHome: () => setState(() => _index = 0),
        onSearch: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SearchScreen())),
        onBookings: _openMyBookings,
        onBooking: _openBooking,
        onFavorites: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
        onWallet: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const WalletScreen())),
        onLoyalty: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const LoyaltyScreen())),
        onOffers: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const OffersScreen())),
        onAddresses: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddressScreen())),
        onFaq: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen())),
        onSettings: _openSettings,
        // إصلاح M8: استخدام profileIndex بدل tabs.length - 1
        onProfile: () => setState(() => _index = profileIndex >= 0 ? profileIndex : 0),
      ),
      body: IndexedStack(
        index: safeIndex,
        children: tabs.map((t) => t.screen).toList(),
      ),
      extendBody: true,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // زر AI — لكل الأدوار
          _AiFab(onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AiChatSheet(),
          )),
          if (showFab) ...[
            const SizedBox(height: 10),
            _BookingFab(onTap: _openBooking),
          ],
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _FloatingNavBar(
        tabs: tabs,
        selectedIndex: safeIndex,
        onTap: (i) => setState(() => _index = i),
      ),
    ),
    );
  }

  List<_Tab> _tabsForRole(AppRole role) {
    final t = AppLocalizations.of(context)!;
    final flags = ref.watch(platformFlagsProvider);
    switch (role) {
      case AppRole.customer:
        return [
          _Tab(t.tabHome, Icons.home_outlined, Icons.home_rounded, const HomeScreen()),
          if (flags.customerSearchTabVisible)
            _Tab(t.tabServices, Icons.search_rounded, Icons.manage_search_rounded, const SearchScreen()),
          if (flags.customerBookingsTabVisible)
            _Tab(t.tabBookings, Icons.book_online_outlined, Icons.book_online_rounded, const MyBookingsScreen()),
          _Tab(t.tabChat, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, const ChatListScreen()),
          _Tab(t.tabProfile, Icons.person_outline_rounded, Icons.person_rounded, const ProfileScreen()),
        ];
      case AppRole.worker:
        if (!flags.workerSectionVisible) {
          // إصلاح M11: استخدام مفاتيح الترجمة بدل النصوص المكررة
          return [
            _Tab(t.tabHome, Icons.home_outlined, Icons.home_rounded, const WorkerSectionClosedScreen()),
            _Tab(t.tabProfile, Icons.person_outline_rounded, Icons.person_rounded, const ProfileScreen()),
          ];
        }
        return [
          _Tab(t.tabDashboard, Icons.dashboard_outlined, Icons.dashboard_rounded, const WorkerDashboardScreen()),
          if (flags.workerScheduleTabVisible)
            _Tab(t.tabSchedule, Icons.calendar_month_outlined, Icons.calendar_month_rounded, const WorkerScheduleScreen()),
          if (flags.workerRequestsTabVisible)
            _Tab(t.tabRequests, Icons.mark_email_unread_outlined, Icons.mark_email_read_rounded, const WorkerRequestsScreen()),
          _Tab(t.tabChat, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, const ChatListScreen()),
          _Tab(t.tabProfile, Icons.person_outline_rounded, Icons.person_rounded, const ProfileScreen()),
        ];
      case AppRole.company:
        return [
          _Tab(t.tabDashboard, Icons.dashboard_outlined, Icons.dashboard_rounded, const CompanyDashboardScreen()),
          if (flags.companyBookingsTabVisible)
            _Tab(t.tabIncoming, Icons.inbox_outlined, Icons.inbox_rounded, const CompanyBookingsScreen()),
          if (flags.companyWorkersTabVisible)
            _Tab(t.tabWorkers, Icons.groups_outlined, Icons.groups_rounded, const CompanyWorkersScreen()),
          _Tab(t.tabChat, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, const ChatListScreen()),
          _Tab(t.tabProfile, Icons.person_outline_rounded, Icons.person_rounded, const ProfileScreen()),
        ];
      case AppRole.admin:
        return [
          _Tab(t.tabDashboard, Icons.admin_panel_settings_outlined, Icons.admin_panel_settings_rounded, const AdminScreen()),
          _Tab(t.tabCompanies, Icons.domain_outlined, Icons.domain_rounded, const AdminCompaniesScreen()),
          _Tab(t.tabFinance, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, const AdminFinanceScreen()),
          _Tab(t.tabDisputes, Icons.gavel_outlined, Icons.gavel_rounded, const AdminDisputesScreen()),
          _Tab(t.tabProfile, Icons.person_outline_rounded, Icons.person_rounded, const ProfileScreen()),
        ];
    }
  }
}

class _Tab {
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final Widget screen;

  const _Tab(
    this.label,
    this.icon,
    this.selectedIcon,
    this.screen,
  );
}

class OfflineBar extends StatelessWidget {
  final VoidCallback onRetry;
  const OfflineBar({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.warning.withValues(alpha: 0.15),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 34,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 14, color: AppColors.warning),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'لا يوجد اتصال بالخادم — يعمل التطبيق ببيانات تجريبية',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11.5, fontWeight: FontWeight.w700, color: context.ink),
                ),
              ),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero),
                child: const Text('إعادة المحاولة',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final List<_Tab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ألوان متمايزة بين light و dark
    final bgColor = isDark
        ? const Color(0xFF0D0D35)   // كحلي داكن في dark mode
        : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : const Color(0xFFE8EDF8);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.40),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: const Color(0xFF03045A).withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 68,
              child: Row(
                children: [
                  for (var i = 0; i < tabs.length; i++)
                    Expanded(
                      child: _NavItem(
                        tab: tabs[i],
                        selected: selectedIndex == i,
                        isDark: isDark,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onTap(i);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── زر الـ AI العائم ───────────────────────────────────────────
class _AiFab extends StatelessWidget {
  final VoidCallback onTap;
  const _AiFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0353A4), Color(0xFF03045A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0353A4).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
      ),
    );
  }
}

// ── زر الحجز السريع العائم ─────────────────────────────────────
class _BookingFab extends StatelessWidget {
  final VoidCallback onTap;
  const _BookingFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF03045A), Color(0xFF023E8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF03045A).withValues(alpha: 0.40),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}

/// عنصر تبويب — تصميم ثابت متناسق بدون layout shift
class _NavItem extends StatelessWidget {
  final _Tab tab;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // إصلاح M6: ألوان واضحة في كلا الوضعين — withOpacity بدلاً من withValues
    final activeColor   = isDark ? Colors.white         : const Color(0xFF03045A);
    final inactiveColor = isDark
        ? Colors.white.withOpacity(0.42)
        : const Color(0xFF8FA3C0);
    final dotColor = isDark ? Colors.white : const Color(0xFF03045A);
    final pillBg   = isDark
        ? Colors.white.withOpacity(0.12)
        : const Color(0xFF03045A).withOpacity(0.09);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 68,
        // ── Layout ثابت دائماً: Column(dot + icon + text) ─────────────
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dot مؤشر أعلى الأيقونة
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              width:  selected ? 5.0 : 0.0,
              height: selected ? 5.0 : 0.0,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),

            // ── الأيقونة مع Pill خلفية ──────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: selected ? 12.0 : 0.0,
                vertical:   4.0,
              ),
              decoration: BoxDecoration(
                color: selected ? pillBg : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // الأيقونة — نفس الحجم دائماً
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: selected ? 1.08 : 1.0),
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutBack,
                    builder: (_, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: Icon(
                      selected ? (tab.selectedIcon ?? tab.icon) : tab.icon,
                      size: 22,
                      color: selected ? activeColor : inactiveColor,
                    ),
                  ),
                  // النص داخل الـ Pill (يظهر فقط للنشط)
                  if (selected) ...[
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: activeColor,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 3),

            // ── النص الصغير أسفل الأيقونة (لغير النشط) ─────────────
            SizedBox(
              height: 12,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: selected ? 0.0 : 1.0,
                child: Text(
                  tab.label,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: inactiveColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppDrawer extends ConsumerWidget {
  final AppUser user;
  final VoidCallback onHome;
  final VoidCallback onSearch;
  final VoidCallback onBookings;
  final VoidCallback onBooking;
  final VoidCallback onFavorites;
  final VoidCallback onWallet;
  final VoidCallback onLoyalty;
  final VoidCallback onOffers;
  final VoidCallback onAddresses;
  final VoidCallback onFaq;
  final VoidCallback onSettings;
  final VoidCallback onProfile;

  const _AppDrawer({
    required this.user,
    required this.onHome,
    required this.onSearch,
    required this.onBookings,
    required this.onBooking,
    required this.onFavorites,
    required this.onWallet,
    required this.onLoyalty,
    required this.onOffers,
    required this.onAddresses,
    required this.onFaq,
    required this.onSettings,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final flags = ref.watch(platformFlagsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surface = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    return Drawer(
      backgroundColor: bg,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppColors.heroGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(user.imageUrl),
                  ),
                  const SizedBox(height: 12),
                  Text(user.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(user.email,
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _DrawerItem(icon: Icons.home_rounded, label: t.tabHome, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onHome(); }),
            _DrawerItem(icon: Icons.search_rounded, label: t.tabServices, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onSearch(); }),
            _DrawerItem(icon: Icons.add_circle_rounded, label: t.newBooking, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onBooking(); }),
            _DrawerItem(icon: Icons.receipt_long_rounded, label: t.myBookings, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onBookings(); }),
            _DrawerItem(icon: Icons.favorite_rounded, label: t.favorites, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onFavorites(); }),
            if (flags.walletEnabled)
              _DrawerItem(icon: Icons.account_balance_wallet_rounded, label: t.wallet, surface: surface, textColor: textColor,
                  onTap: () { Navigator.pop(context); onWallet(); }),
            if (flags.loyaltyEnabled)
              _DrawerItem(icon: Icons.emoji_events_rounded, label: t.loyaltyPoints, surface: surface, textColor: textColor,
                  onTap: () { Navigator.pop(context); onLoyalty(); }),
            if (flags.subscriptionsEnabled)
              _DrawerItem(icon: Icons.workspace_premium_rounded, label: 'SmartGold', surface: surface, textColor: textColor,
                  onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())); }),
            if (flags.offersEnabled)
              _DrawerItem(icon: Icons.card_giftcard_rounded, label: t.offersCoupons, surface: surface, textColor: textColor,
                  onTap: () { Navigator.pop(context); onOffers(); }),
            _DrawerItem(icon: Icons.location_on_rounded, label: t.myAddresses, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onAddresses(); }),
            if (flags.tipsEnabled)
              _DrawerItem(icon: Icons.lightbulb_rounded, label: 'نصائح التنظيف', surface: surface, textColor: textColor,
                  onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const TipsScreen())); }),
            if (flags.sosEnabled)
              _DrawerItem(icon: Icons.emergency_rounded, label: 'زر الطوارئ', surface: surface, textColor: textColor,
                  onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SosScreen())); }),
            _DrawerItem(icon: Icons.verified_user_rounded, label: 'توثيق الهوية (KYC)', surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const KycScreen())); }),
            _DrawerItem(icon: Icons.savings_rounded, label: 'أرباحي ومستحقاتي', surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SettlementsScreen())); }),
            _DrawerItem(icon: Icons.support_agent_rounded, label: 'تذكرة دعم', surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportTicketScreen())); }),
            _DrawerItem(icon: Icons.help_outline_rounded, label: t.faq, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onFaq(); }),
            _DrawerItem(icon: Icons.accessibility_new_rounded, label: 'الإتاحة', surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AccessibilityScreen())); }),
            _DrawerItem(icon: Icons.person_rounded, label: t.tabProfile, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onProfile(); }),
            _DrawerItem(icon: Icons.settings_rounded, label: t.settings, surface: surface, textColor: textColor,
                onTap: () { Navigator.pop(context); onSettings(); }),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color surface;
  final Color textColor;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.surface,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Text(label,
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: textColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

