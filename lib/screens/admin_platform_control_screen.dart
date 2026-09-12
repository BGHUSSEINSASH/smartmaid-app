import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/adaptive.dart';
import '../providers/platform_control_provider.dart';
import '../widgets/pro_components.dart';

class AdminPlatformControlScreen extends ConsumerStatefulWidget {
  const AdminPlatformControlScreen({super.key});
  @override
  ConsumerState<AdminPlatformControlScreen> createState() =>
      _AdminPlatformControlState();
}

class _AdminPlatformControlState
    extends ConsumerState<AdminPlatformControlScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flags = ref.watch(platformFlagsProvider);
    final n = ref.read(platformFlagsProvider.notifier);

    return Scaffold(
      backgroundColor: context.pageBg,
      appBar: AppBar(
        title: const Text('التحكم بالمنصة'),
        actions: [
          // زر إعادة الافتراضيات
          IconButton(
            icon: const Icon(Icons.restore_rounded),
            tooltip: 'إعادة الإعدادات الافتراضية',
            onPressed: () => _confirmReset(context, n),
          ),
          // مؤشر وضع الصيانة
          if (flags.maintenanceMode)
            Container(
              margin: const EdgeInsets.only(left: 8, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(children: [
                Icon(Icons.construction_rounded, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text('صيانة', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ]),
            ),
        ],
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'عام'),
            Tab(text: 'العاملات'),
            Tab(text: 'الشركات'),
            Tab(text: 'العملاء'),
            Tab(text: 'الأمان'),
            Tab(text: 'المكافآت'),
            Tab(text: 'الصيانة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildGeneralTab(flags, n),
          _buildWorkersTab(flags, n),
          _buildCompaniesTab(flags, n),
          _buildCustomersTab(flags, n),
          _buildSecurityTab(flags, n),
          _buildRewardsTab(flags, n),
          _buildMaintenanceTab(flags, n, context),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // تبويب عام
  // ─────────────────────────────────────────────────────────────
  Widget _buildGeneralTab(PlatformFlags f, PlatformFlagsNotifier n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _header('ميزات التطبيق الأساسية',
            'تحكم في إظهار وإخفاء الميزات الرئيسية'),
        const SizedBox(height: 12),
        _group([
          _tile('العروض والخصومات', Icons.local_offer_rounded, f.offersEnabled, () => n.toggle('offers')),
          _tile('نقاط الولاء', Icons.star_rounded, f.loyaltyEnabled, () => n.toggle('loyalty')),
          _tile('برنامج الإحالات', Icons.people_alt_rounded, f.referralEnabled, () => n.toggle('referral')),
          _tile('المحفظة الرقمية', Icons.account_balance_wallet_rounded, f.walletEnabled, () => n.toggle('wallet')),
          _tile('الاشتراكات Pro', Icons.card_membership_rounded, f.subscriptionsEnabled, () => n.toggle('subscriptions')),
          _tile('مقارنة العاملات', Icons.compare_arrows_rounded, f.compareEnabled, () => n.toggle('compare')),
          _tile('زر الطوارئ SOS', Icons.emergency_rounded, f.sosEnabled, () => n.toggle('sos')),
          _tile('الدردشة', Icons.chat_rounded, f.chatEnabled, () => n.toggle('chat')),
          _tile('البقشيش للعاملات', Icons.volunteer_activism_rounded, f.tipsEnabled, () => n.toggle('tips')),
        ]),
        const SizedBox(height: 16),
        _header('الميزات المتقدمة', 'AI والبحث الصوتي والحجز السنوي'),
        const SizedBox(height: 12),
        _group([
          _tile('المساعد الذكي AI', Icons.smart_toy_rounded, f.aiChatEnabled, () => n.toggle('aiChat')),
          _tile('البحث الصوتي', Icons.mic_rounded, f.voiceSearchEnabled, () => n.toggle('voiceSearch')),
          _tile('الحجز السنوي', Icons.calendar_month_rounded, f.annualBookingEnabled, () => n.toggle('annualBooking')),
          _tile('كودات الخصم (Promo)', Icons.discount_rounded, f.promoCodesEnabled, () => n.toggle('promoCodes')),
          _tile('الدفع النقدي عند التسليم', Icons.money_rounded, f.cashPaymentEnabled, () => n.toggle('cashPayment')),
          _tile('المراجعات والتقييمات', Icons.rate_review_rounded, f.reviewsEnabled, () => n.toggle('reviews')),
          _tile('طلب مراجعة إجباري بعد الحجز', Icons.reviews_rounded, f.requireReviewAfterBooking, () => n.toggle('requireReview')),
        ]),
        const SizedBox(height: 16),
        _header('التسجيل والحسابات', 'تحكم في فتح وإغلاق التسجيل'),
        const SizedBox(height: 12),
        _buildSignupBlock(f, n),
        const SizedBox(height: 16),
        _header('طرق الدفع والمصادقة', null),
        const SizedBox(height: 12),
        _group([
          _tile('الدفع بالمحفظة', Icons.wallet_rounded, f.walletPaymentEnabled, () => n.toggle('walletPayment')),
          _tile('الدفع بالبطاقة', Icons.credit_card_rounded, f.cardPaymentEnabled, () => n.toggle('cardPayment')),
          _tile('تسجيل الدخول بـ Google', Icons.g_mobiledata_rounded, f.googleSignInEnabled, () => n.toggle('googleSignIn')),
          _tile('تسجيل الدخول بـ Apple', Icons.apple_rounded, f.appleSignInEnabled, () => n.toggle('appleSignIn')),
        ]),
        const SizedBox(height: 12),
        _numericCard(
          icon: Icons.money_rounded,
          title: 'الحد الأدنى لشحن المحفظة',
          value: f.minimumWalletTopup,
          min: 1, max: 500,
          unit: '\$',
          onChanged: n.setMinimumWalletTopup,
        ),
        const SizedBox(height: 10),
        _numericCard(
          icon: Icons.receipt_long_rounded,
          title: 'الحد الأقصى لمبلغ الحجز الواحد',
          value: f.maximumBookingAmount,
          min: 50, max: 10000,
          unit: '\$',
          onChanged: n.setMaximumBookingAmount,
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // تبويب العاملات
  // ─────────────────────────────────────────────────────────────
  Widget _buildWorkersTab(PlatformFlags f, PlatformFlagsNotifier n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // زر تفعيل/إغلاق الكل
        _workerMasterSwitch(f, n),
        const SizedBox(height: 16),
        _header('رؤية العاملات', null),
        const SizedBox(height: 12),
        _group([
          _tile('قسم العاملات الرئيسي', Icons.dashboard_rounded, f.workerSectionVisible, () => n.toggle('workerSection')),
          _tile('ظهور العاملات في بحث العملاء', Icons.search_rounded, f.workerSearchVisible, () => n.toggle('workerSearch')),
          _tile('بطاقات العاملات في الرئيسية', Icons.grid_view_rounded, f.workerProfilesVisible, () => n.toggle('workerProfiles')),
          _tile('تسجيل عاملات جديدة', Icons.person_add_rounded, f.workerRegistrationOpen, () => n.toggle('workerReg')),
        ]),
        const SizedBox(height: 16),
        _header('تبويبات شاشة العاملة', null),
        const SizedBox(height: 12),
        _group([
          _tile('تبويب الجدول', Icons.calendar_month_rounded, f.workerScheduleTabVisible, () => n.toggle('workerSchedule')),
          _tile('تبويب الطلبات الواردة', Icons.inbox_rounded, f.workerRequestsTabVisible, () => n.toggle('workerRequests')),
          _tile('عرض أرباح العاملة', Icons.payments_rounded, f.workerEarningsVisible, () => n.toggle('workerEarnings')),
        ]),
        const SizedBox(height: 16),
        _header('إعدادات العمل', null),
        const SizedBox(height: 12),
        _group([
          _tile('العاملة تضبط أسعارها بنفسها', Icons.price_change_rounded, f.workerCanSetOwnRate, () => n.toggle('workerOwnRate')),
          _tile('الوردية الليلية (10م - 6ص)', Icons.nightlight_rounded, f.workerNightShiftEnabled, () => n.toggle('workerNightShift')),
        ]),
        const SizedBox(height: 12),
        _intCard(
          icon: Icons.event_available_rounded,
          title: 'الحد الأقصى للحجوزات اليومية للعاملة',
          value: f.workerMaxDailyBookings,
          min: 1, max: 20,
          unit: 'حجز/يوم',
          onChanged: n.setWorkerMaxDailyBookings,
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // تبويب الشركات
  // ─────────────────────────────────────────────────────────────
  Widget _buildCompaniesTab(PlatformFlags f, PlatformFlagsNotifier n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _header('أقسام لوحة الشركة', 'تحكم فيما تراه الشركة في لوحتها'),
        const SizedBox(height: 12),
        _group([
          _tile('تبويب الطلبات الواردة', Icons.inbox_rounded, f.companyBookingsTabVisible, () => n.toggle('companyBookings')),
          _tile('تبويب إدارة الفريق', Icons.groups_rounded, f.companyWorkersTabVisible, () => n.toggle('companyWorkers')),
          _tile('قسم الخدمات والأسعار', Icons.sell_rounded, f.companyServicesVisible, () => n.toggle('companyServices')),
          _tile('تقارير الأداء والتحليلات', Icons.insights_rounded, f.companyAnalyticsVisible, () => n.toggle('companyAnalytics')),
          _tile('الفواتير والتسوية المالية', Icons.receipt_long_rounded, f.companyBillingVisible, () => n.toggle('companyBilling')),
        ]),
        const SizedBox(height: 16),
        _header('التحقق من الهوية (KYC)', 'متطلبات التحقق قبل الظهور للعملاء'),
        const SizedBox(height: 12),
        _group([
          _tile('الشركة تحتاج KYC قبل الظهور', Icons.verified_rounded, f.requireCompanyKyc, () => n.toggle('requireCompanyKyc')),
        ]),
        const SizedBox(height: 12),
        _infoBanner(
          icon: Icons.info_rounded,
          text: 'عند تفعيل KYC، لن تظهر أي شركة للعملاء حتى تُوافق الإدارة على مستنداتها.',
          color: AppColors.primary,
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // تبويب العملاء
  // ─────────────────────────────────────────────────────────────
  Widget _buildCustomersTab(PlatformFlags f, PlatformFlagsNotifier n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _header('أقسام شاشة العميل', null),
        const SizedBox(height: 12),
        _group([
          _tile('تبويب الخدمات والبحث', Icons.search_rounded, f.customerSearchTabVisible, () => n.toggle('customerSearch')),
          _tile('تبويب حجوزاتي', Icons.book_online_rounded, f.customerBookingsTabVisible, () => n.toggle('customerBookings')),
          _tile('المحفظة الرقمية', Icons.account_balance_wallet_rounded, f.customerWalletVisible, () => n.toggle('customerWallet')),
          _tile('العروض والكوبونات', Icons.local_offer_rounded, f.customerOffersVisible, () => n.toggle('customerOffers')),
          _tile('نقاط الولاء', Icons.star_rounded, f.customerLoyaltyVisible, () => n.toggle('customerLoyalty')),
        ]),
        const SizedBox(height: 16),
        _header('التحقق والجودة', null),
        const SizedBox(height: 12),
        _group([
          _tile('اشتراط إكمال البروفايل قبل الحجز الأول', Icons.person_rounded, f.requireKycBeforeBooking, () => n.toggle('requireKyc')),
        ]),
        const SizedBox(height: 12),
        _numericCard(
          icon: Icons.star_half_rounded,
          title: 'الحد الأدنى للتقييم لظهور العاملة',
          value: f.minRatingToAppear,
          min: 1.0, max: 5.0,
          unit: '★',
          divisions: 40,
          onChanged: n.setMinRatingToAppear,
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // تبويب الأمان
  // ─────────────────────────────────────────────────────────────
  Widget _buildSecurityTab(PlatformFlags f, PlatformFlagsNotifier n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _header('أمان تسجيل الدخول', null),
        const SizedBox(height: 12),
        _group([
          _tile('التحقق الثنائي (2FA) إجباري', Icons.security_rounded, f.twoFactorEnabled, () => n.toggle('2fa')),
          _tile('KYC العاملات إجباري للظهور العام', Icons.verified_user_rounded, f.requireWorkerKycPublic, () => n.toggle('requireWorkerKyc')),
        ]),
        const SizedBox(height: 12),
        _intCard(
          icon: Icons.lock_rounded,
          title: 'عدد محاولات الدخول قبل القفل',
          value: f.maxLoginAttempts,
          min: 3, max: 10,
          unit: 'محاولات',
          onChanged: n.setMaxLoginAttempts,
        ),
        const SizedBox(height: 16),
        _header('رسائل النظام', null),
        const SizedBox(height: 12),
        _textCard(
          icon: Icons.block_rounded,
          title: 'رسالة تعليق الحساب',
          subtitle: 'تظهر للمستخدم عند تعليق حسابه',
          value: f.accountSuspensionMessage,
          onSaved: n.setAccountSuspensionMessage,
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // تبويب المكافآت
  // ─────────────────────────────────────────────────────────────
  Widget _buildRewardsTab(PlatformFlags f, PlatformFlagsNotifier n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _header('برنامج الإحالة', null),
        const SizedBox(height: 12),
        _numericCard(
          icon: Icons.people_alt_rounded,
          title: 'مكافأة الإحالة للمُحيل',
          value: f.referralBonusAmount,
          min: 0, max: 200,
          unit: '\$',
          onChanged: n.setReferralBonusAmount,
        ),
        const SizedBox(height: 16),
        _header('نقاط الولاء', null),
        const SizedBox(height: 12),
        _intCard(
          icon: Icons.stars_rounded,
          title: 'نقاط لكل حجز مكتمل',
          value: f.loyaltyPointsPerBooking,
          min: 0, max: 100,
          unit: 'نقطة/حجز',
          onChanged: n.setLoyaltyPointsPerBooking,
        ),
        const SizedBox(height: 10),
        _numericCard(
          icon: Icons.currency_exchange_rounded,
          title: 'قيمة صرف النقاط',
          value: f.loyaltyRedemptionRate * 100,
          min: 0.1, max: 10.0,
          unit: '¢/100 نقطة',
          divisions: 99,
          onChanged: (v) => n.setLoyaltyRedemptionRate(v / 100),
        ),
        const SizedBox(height: 12),
        _infoBanner(
          icon: Icons.calculate_rounded,
          text: 'بمعدل ${(f.loyaltyRedemptionRate * 100).toStringAsFixed(1)}¢ لكل 100 نقطة، كل حجز يمنح ${f.loyaltyPointsPerBooking} نقطة = \$${(f.loyaltyPointsPerBooking * f.loyaltyRedemptionRate).toStringAsFixed(3)} خصم.',
          color: AppColors.warning,
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // تبويب الصيانة
  // ─────────────────────────────────────────────────────────────
  Widget _buildMaintenanceTab(
      PlatformFlags f, PlatformFlagsNotifier n, BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // مفتاح رئيسي بارز
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: f.maintenanceMode
                ? const LinearGradient(
                    colors: [Color(0xFFDC2626), Color(0xFF991B1B)])
                : AppColors.heroGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: [
            Icon(
              f.maintenanceMode ? Icons.construction_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              f.maintenanceMode ? 'التطبيق في وضع الصيانة' : 'التطبيق يعمل بشكل طبيعي',
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              f.maintenanceMode
                  ? 'جميع المستخدمين يرون شاشة الصيانة'
                  : 'لا توجد قيود حالياً',
              style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 13),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: f.maintenanceMode ? AppColors.error : AppColors.primary,
                ),
                icon: Icon(f.maintenanceMode ? Icons.power_settings_new_rounded : Icons.construction_rounded),
                label: Text(f.maintenanceMode ? 'إيقاف وضع الصيانة' : 'تفعيل وضع الصيانة'),
                onPressed: () => f.maintenanceMode
                    ? _confirmDisableMaintenance(context, n)
                    : _showMaintenanceSetup(context, n),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        _header('رسالة الصيانة', null),
        const SizedBox(height: 12),
        _textCard(
          icon: Icons.message_rounded,
          title: 'رسالة تظهر للمستخدمين',
          subtitle: 'تظهر في شاشة الصيانة',
          value: f.maintenanceMessage,
          onSaved: n.setMaintenanceMessage,
        ),
        const SizedBox(height: 10),
        _textCard(
          icon: Icons.schedule_rounded,
          title: 'وقت انتهاء الصيانة المتوقع',
          subtitle: 'مثال: الجمعة الساعة 3 صباحاً',
          value: f.maintenanceEndTime,
          onSaved: n.setMaintenanceEndTime,
        ),
        if (f.maintenanceMode) ...[
          const SizedBox(height: 12),
          _infoBanner(
            icon: Icons.warning_rounded,
            text: 'التطبيق حالياً في وضع الصيانة. كل المستخدمين (ما عدا المدير) يرون شاشة الصيانة.',
            color: AppColors.error,
          ),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────

  Widget _buildSignupBlock(PlatformFlags f, PlatformFlagsNotifier n) {
    return Column(children: [
      // مفتاح إيقاف الكل
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: f.allSignupsBlocked
              ? AppColors.error.withValues(alpha: .06)
              : AppColors.success.withValues(alpha: .06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: f.allSignupsBlocked
                ? AppColors.error.withValues(alpha: .3)
                : AppColors.success.withValues(alpha: .3),
          ),
        ),
        child: SwitchListTile(
          secondary: Icon(Icons.no_accounts_rounded,
              color: f.allSignupsBlocked ? AppColors.error : AppColors.success),
          title: Text(
            f.allSignupsBlocked ? '🔒 إيقاف كل التسجيلات' : '✅ التسجيل مفتوح',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                color: f.allSignupsBlocked ? AppColors.error : AppColors.success),
          ),
          subtitle: Text(
              f.allSignupsBlocked
                  ? 'لا يمكن لأي أحد التسجيل حالياً'
                  : 'الجميع يمكنهم التسجيل',
              style: const TextStyle(fontSize: 11.5)),
          value: f.allSignupsBlocked,
          onChanged: (_) {
            if (!f.allSignupsBlocked) {
              _showBlockSignupDialog(n);
            } else {
              n.allowAllSignups();
            }
          },
        ),
      ),
      const SizedBox(height: 10),
      _group([
        _tile('تسجيل العملاء', Icons.person_add_rounded, f.customerSignupEnabled, () => n.toggle('customerSignup')),
        _tile('تسجيل العاملات', Icons.woman_rounded, f.workerSignupEnabled, () => n.toggle('workerSignup')),
        _tile('تسجيل الشركات', Icons.domain_add_rounded, f.companySignupEnabled, () => n.toggle('companySignup')),
      ]),
    ]);
  }

  Widget _workerMasterSwitch(PlatformFlags f, PlatformFlagsNotifier n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: f.workerSectionVisible
            ? AppColors.success.withValues(alpha: .06)
            : AppColors.error.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: f.workerSectionVisible
              ? AppColors.success.withValues(alpha: .3)
              : AppColors.error.withValues(alpha: .3),
        ),
      ),
      child: Column(children: [
        Row(children: [
          Icon(Icons.woman_rounded,
              color: f.workerSectionVisible ? AppColors.success : AppColors.error),
          const SizedBox(width: 10),
          Text(
            f.workerSectionVisible ? '✅ قسم العاملات مفعّل' : '🔒 قسم العاملات مغلق',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                color: f.workerSectionVisible ? AppColors.success : AppColors.error,
                fontSize: 15),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            icon: const Icon(Icons.lock_open_rounded, size: 16),
            label: const Text('تفعيل الكل'),
            onPressed: () { n.enableWorkerSection(); _snack('✅ تم تفعيل قسم العاملات', AppColors.success); },
          )),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
            icon: const Icon(Icons.lock_rounded, size: 16),
            label: const Text('إغلاق الكل'),
            onPressed: () { n.disableWorkerSection(); _snack('🔒 تم إغلاق قسم العاملات', AppColors.error); },
          )),
        ]),
      ]),
    );
  }

  Widget _header(String title, String? subtitle) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
        ],
      );

  Widget _group(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.stroke),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      );

  Widget _tile(String label, IconData icon, bool value, VoidCallback onTap) =>
      SwitchListTile(
        secondary: Icon(icon, color: value ? AppColors.primary : AppColors.muted),
        title: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: value ? null : AppColors.muted)),
        subtitle: Text(value ? 'مفعّل' : 'معطّل',
            style: TextStyle(
                fontSize: 11.5,
                color: value ? AppColors.success : AppColors.error)),
        value: value,
        onChanged: (_) => onTap(),
      );

  Widget _numericCard({
    required IconData icon,
    required String title,
    required double value,
    required double min,
    required double max,
    required String unit,
    required void Function(double) onChanged,
    int divisions = 100,
  }) {
    return ProCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)} $unit',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 13)),
            ),
          ]),
          Slider(
            value: value.clamp(min, max),
            min: min, max: max,
            divisions: divisions,
            label: '${value.toStringAsFixed(1)} $unit',
            onChanged: onChanged,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('$min $unit', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
            Text('$max $unit', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          ]),
        ],
      ),
    );
  }

  Widget _intCard({
    required IconData icon,
    required String title,
    required int value,
    required int min,
    required int max,
    required String unit,
    required void Function(int) onChanged,
  }) {
    return ProCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$value $unit',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 13)),
            ),
          ]),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(), max: max.toDouble(),
            divisions: max - min,
            label: '$value $unit',
            onChanged: (v) => onChanged(v.round()),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('$min', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
            Text('$max', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          ]),
        ],
      ),
    );
  }

  Widget _textCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required void Function(String) onSaved,
  }) {
    final ctrl = TextEditingController(text: value);
    return ProCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          ]),
        ]),
        const SizedBox(height: 10),
        TextField(
          controller: ctrl,
          maxLines: 2,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.primaryLight.withValues(alpha: .5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(10),
          ),
          onChanged: onSaved,
        ),
      ]),
    );
  }

  Widget _infoBanner({required IconData icon, required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .25)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 12.5))),
      ]),
    );
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showBlockSignupDialog(PlatformFlagsNotifier n) {
    final ctrl = TextEditingController(
        text: ref.read(platformFlagsProvider).signupBlockedMessage);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إيقاف التسجيلات'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('سيتم منع جميع التسجيلات الجديدة.'),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            decoration: const InputDecoration(labelText: 'رسالة للمستخدمين'),
            maxLines: 3,
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              n.blockAllSignups(message: ctrl.text);
              Navigator.pop(context);
              _snack('🔒 تم إيقاف التسجيلات', AppColors.error);
            },
            child: const Text('إيقاف'),
          ),
        ],
      ),
    );
  }

  void _showMaintenanceSetup(BuildContext context, PlatformFlagsNotifier n) {
    final flags = ref.read(platformFlagsProvider);
    final msgCtrl = TextEditingController(text: flags.maintenanceMessage);
    final endCtrl = TextEditingController(text: flags.maintenanceEndTime);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.construction_rounded, color: AppColors.error),
          SizedBox(width: 8),
          Text('تفعيل وضع الصيانة'),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('جميع المستخدمين سيرون شاشة الصيانة فور التفعيل.'),
          const SizedBox(height: 14),
          TextField(
            controller: msgCtrl,
            decoration: const InputDecoration(labelText: 'رسالة الصيانة'),
            maxLines: 3,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: endCtrl,
            decoration: const InputDecoration(
              labelText: 'وقت الانتهاء المتوقع',
              hintText: 'مثال: الجمعة الساعة 3 صباحاً',
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              n.enableMaintenance(message: msgCtrl.text, endTime: endCtrl.text);
              Navigator.pop(context);
              _snack('⚠️ وضع الصيانة مفعّل', AppColors.error);
            },
            child: const Text('تفعيل الصيانة'),
          ),
        ],
      ),
    );
  }

  void _confirmDisableMaintenance(BuildContext context, PlatformFlagsNotifier n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إيقاف الصيانة'),
        content: const Text('سيعود التطبيق للعمل الطبيعي فوراً لجميع المستخدمين.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              n.disableMaintenance();
              Navigator.pop(context);
              _snack('✅ تم إيقاف وضع الصيانة', AppColors.success);
            },
            child: const Text('إيقاف الصيانة'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, PlatformFlagsNotifier n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إعادة الإعدادات الافتراضية'),
        content: const Text('سيتم إعادة جميع الإعدادات إلى الحالة الافتراضية. هذا الإجراء لا يمكن التراجع عنه.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              n.resetToDefaults();
              Navigator.pop(context);
              _snack('تم إعادة الإعدادات الافتراضية', AppColors.warning);
            },
            child: const Text('إعادة الافتراضيات'),
          ),
        ],
      ),
    );
  }
}
