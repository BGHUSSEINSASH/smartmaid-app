import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// نظام أعلام الميزات الموسّع — تحكم كامل من الإدارة في كل شيء.
class PlatformFlags {
  // ──── أقسام عامة ────────────────────────────────────────────
  final bool offersEnabled;
  final bool loyaltyEnabled;
  final bool referralEnabled;
  final bool walletEnabled;
  final bool subscriptionsEnabled;
  final bool compareEnabled;
  final bool sosEnabled;
  final bool chatEnabled;
  final bool tipsEnabled;

  // ──── ميزات متقدمة ──────────────────────────────────────────
  final bool aiChatEnabled;
  final bool voiceSearchEnabled;
  final bool annualBookingEnabled;
  final bool promoCodesEnabled;
  final bool cashPaymentEnabled;
  final bool reviewsEnabled;
  final bool requireReviewAfterBooking;

  // ──── قسم العاملات (مخفي افتراضياً) ────────────────────────
  final bool workerSectionVisible;
  final bool workerSearchVisible;
  final bool workerProfilesVisible;
  final bool workerRegistrationOpen;
  final bool workerScheduleTabVisible;
  final bool workerRequestsTabVisible;
  final bool workerEarningsVisible;
  final bool workerCanSetOwnRate;
  final bool workerNightShiftEnabled;
  final int workerMaxDailyBookings;

  // ──── أقسام العميل ──────────────────────────────────────────
  final bool customerSearchTabVisible;
  final bool customerBookingsTabVisible;
  final bool customerWalletVisible;
  final bool customerOffersVisible;
  final bool customerLoyaltyVisible;

  // ──── أقسام الشركة ──────────────────────────────────────────
  final bool companyBookingsTabVisible;
  final bool companyWorkersTabVisible;
  final bool companyServicesVisible;
  final bool companyAnalyticsVisible;
  final bool companyBillingVisible;

  // ──── التسجيل ───────────────────────────────────────────────
  final bool customerSignupEnabled;
  final bool workerSignupEnabled;
  final bool companySignupEnabled;
  final bool allSignupsBlocked;
  final String signupBlockedMessage;

  // ──── الدفع والمصادقة ────────────────────────────────────────
  final bool googleSignInEnabled;
  final bool appleSignInEnabled;
  final bool walletPaymentEnabled;
  final bool cardPaymentEnabled;
  final double minimumWalletTopup;
  final double maximumBookingAmount;

  // ──── التحقق والأمان ─────────────────────────────────────────
  final bool requireKycBeforeBooking;
  final bool requireWorkerKycPublic;
  final bool requireCompanyKyc;
  final bool twoFactorEnabled;
  final int maxLoginAttempts;
  final String accountSuspensionMessage;

  // ──── المكافآت ───────────────────────────────────────────────
  final double referralBonusAmount;
  final int loyaltyPointsPerBooking;
  final double loyaltyRedemptionRate;
  final double minRatingToAppear;

  // ──── صيانة ─────────────────────────────────────────────────
  final bool maintenanceMode;
  final String maintenanceMessage;
  final String maintenanceEndTime;

  const PlatformFlags({
    // عامة
    this.offersEnabled = true,
    this.loyaltyEnabled = true,
    this.referralEnabled = true,
    this.walletEnabled = true,
    this.subscriptionsEnabled = true,
    this.compareEnabled = true,
    this.sosEnabled = true,
    this.chatEnabled = true,
    this.tipsEnabled = true,
    // ميزات متقدمة
    this.aiChatEnabled = true,
    this.voiceSearchEnabled = true,
    this.annualBookingEnabled = true,
    this.promoCodesEnabled = true,
    this.cashPaymentEnabled = false,
    this.reviewsEnabled = true,
    this.requireReviewAfterBooking = false,
    // عاملات — مخفية افتراضياً
    this.workerSectionVisible = false,
    this.workerSearchVisible = false,
    this.workerProfilesVisible = false,
    this.workerRegistrationOpen = false,
    this.workerScheduleTabVisible = true,
    this.workerRequestsTabVisible = true,
    this.workerEarningsVisible = true,
    this.workerCanSetOwnRate = true,
    this.workerNightShiftEnabled = false,
    this.workerMaxDailyBookings = 5,
    // عميل — كل شيء مفعّل
    this.customerSearchTabVisible = true,
    this.customerBookingsTabVisible = true,
    this.customerWalletVisible = true,
    this.customerOffersVisible = true,
    this.customerLoyaltyVisible = true,
    // شركة — كل شيء مفعّل
    this.companyBookingsTabVisible = true,
    this.companyWorkersTabVisible = true,
    this.companyServicesVisible = true,
    this.companyAnalyticsVisible = true,
    this.companyBillingVisible = true,
    // تسجيل
    this.customerSignupEnabled = true,
    this.workerSignupEnabled = true,
    this.companySignupEnabled = true,
    this.allSignupsBlocked = false,
    this.signupBlockedMessage = 'التسجيل مغلق مؤقتاً. يُرجى المحاولة لاحقاً.',
    // دفع
    this.googleSignInEnabled = true,
    this.appleSignInEnabled = true,
    this.walletPaymentEnabled = true,
    this.cardPaymentEnabled = true,
    this.minimumWalletTopup = 10.0,
    this.maximumBookingAmount = 2000.0,
    // أمان
    this.requireKycBeforeBooking = false,
    this.requireWorkerKycPublic = false,
    this.requireCompanyKyc = true,
    this.twoFactorEnabled = false,
    this.maxLoginAttempts = 5,
    this.accountSuspensionMessage = 'تم تعليق حسابك مؤقتاً. تواصل مع الدعم للمساعدة.',
    // مكافآت
    this.referralBonusAmount = 15.0,
    this.loyaltyPointsPerBooking = 10,
    this.loyaltyRedemptionRate = 0.01,
    this.minRatingToAppear = 3.0,
    // صيانة
    this.maintenanceMode = false,
    this.maintenanceMessage = 'التطبيق في وضع الصيانة. سنعود قريباً!',
    this.maintenanceEndTime = '',
  });

  PlatformFlags copyWith({
    bool? offersEnabled, bool? loyaltyEnabled, bool? referralEnabled,
    bool? walletEnabled, bool? subscriptionsEnabled, bool? compareEnabled,
    bool? sosEnabled, bool? chatEnabled, bool? tipsEnabled,
    bool? aiChatEnabled, bool? voiceSearchEnabled, bool? annualBookingEnabled,
    bool? promoCodesEnabled, bool? cashPaymentEnabled,
    bool? reviewsEnabled, bool? requireReviewAfterBooking,
    bool? workerSectionVisible, bool? workerSearchVisible,
    bool? workerProfilesVisible, bool? workerRegistrationOpen,
    bool? workerScheduleTabVisible, bool? workerRequestsTabVisible,
    bool? workerEarningsVisible, bool? workerCanSetOwnRate,
    bool? workerNightShiftEnabled, int? workerMaxDailyBookings,
    bool? customerSearchTabVisible, bool? customerBookingsTabVisible,
    bool? customerWalletVisible, bool? customerOffersVisible,
    bool? customerLoyaltyVisible,
    bool? companyBookingsTabVisible, bool? companyWorkersTabVisible,
    bool? companyServicesVisible, bool? companyAnalyticsVisible,
    bool? companyBillingVisible,
    bool? customerSignupEnabled, bool? workerSignupEnabled,
    bool? companySignupEnabled, bool? allSignupsBlocked,
    String? signupBlockedMessage,
    bool? googleSignInEnabled, bool? appleSignInEnabled,
    bool? walletPaymentEnabled, bool? cardPaymentEnabled,
    double? minimumWalletTopup, double? maximumBookingAmount,
    bool? requireKycBeforeBooking, bool? requireWorkerKycPublic,
    bool? requireCompanyKyc, bool? twoFactorEnabled,
    int? maxLoginAttempts, String? accountSuspensionMessage,
    double? referralBonusAmount, int? loyaltyPointsPerBooking,
    double? loyaltyRedemptionRate, double? minRatingToAppear,
    bool? maintenanceMode, String? maintenanceMessage,
    String? maintenanceEndTime,
  }) => PlatformFlags(
    offersEnabled: offersEnabled ?? this.offersEnabled,
    loyaltyEnabled: loyaltyEnabled ?? this.loyaltyEnabled,
    referralEnabled: referralEnabled ?? this.referralEnabled,
    walletEnabled: walletEnabled ?? this.walletEnabled,
    subscriptionsEnabled: subscriptionsEnabled ?? this.subscriptionsEnabled,
    compareEnabled: compareEnabled ?? this.compareEnabled,
    sosEnabled: sosEnabled ?? this.sosEnabled,
    chatEnabled: chatEnabled ?? this.chatEnabled,
    tipsEnabled: tipsEnabled ?? this.tipsEnabled,
    aiChatEnabled: aiChatEnabled ?? this.aiChatEnabled,
    voiceSearchEnabled: voiceSearchEnabled ?? this.voiceSearchEnabled,
    annualBookingEnabled: annualBookingEnabled ?? this.annualBookingEnabled,
    promoCodesEnabled: promoCodesEnabled ?? this.promoCodesEnabled,
    cashPaymentEnabled: cashPaymentEnabled ?? this.cashPaymentEnabled,
    reviewsEnabled: reviewsEnabled ?? this.reviewsEnabled,
    requireReviewAfterBooking: requireReviewAfterBooking ?? this.requireReviewAfterBooking,
    workerSectionVisible: workerSectionVisible ?? this.workerSectionVisible,
    workerSearchVisible: workerSearchVisible ?? this.workerSearchVisible,
    workerProfilesVisible: workerProfilesVisible ?? this.workerProfilesVisible,
    workerRegistrationOpen: workerRegistrationOpen ?? this.workerRegistrationOpen,
    workerScheduleTabVisible: workerScheduleTabVisible ?? this.workerScheduleTabVisible,
    workerRequestsTabVisible: workerRequestsTabVisible ?? this.workerRequestsTabVisible,
    workerEarningsVisible: workerEarningsVisible ?? this.workerEarningsVisible,
    workerCanSetOwnRate: workerCanSetOwnRate ?? this.workerCanSetOwnRate,
    workerNightShiftEnabled: workerNightShiftEnabled ?? this.workerNightShiftEnabled,
    workerMaxDailyBookings: workerMaxDailyBookings ?? this.workerMaxDailyBookings,
    customerSearchTabVisible: customerSearchTabVisible ?? this.customerSearchTabVisible,
    customerBookingsTabVisible: customerBookingsTabVisible ?? this.customerBookingsTabVisible,
    customerWalletVisible: customerWalletVisible ?? this.customerWalletVisible,
    customerOffersVisible: customerOffersVisible ?? this.customerOffersVisible,
    customerLoyaltyVisible: customerLoyaltyVisible ?? this.customerLoyaltyVisible,
    companyBookingsTabVisible: companyBookingsTabVisible ?? this.companyBookingsTabVisible,
    companyWorkersTabVisible: companyWorkersTabVisible ?? this.companyWorkersTabVisible,
    companyServicesVisible: companyServicesVisible ?? this.companyServicesVisible,
    companyAnalyticsVisible: companyAnalyticsVisible ?? this.companyAnalyticsVisible,
    companyBillingVisible: companyBillingVisible ?? this.companyBillingVisible,
    customerSignupEnabled: customerSignupEnabled ?? this.customerSignupEnabled,
    workerSignupEnabled: workerSignupEnabled ?? this.workerSignupEnabled,
    companySignupEnabled: companySignupEnabled ?? this.companySignupEnabled,
    allSignupsBlocked: allSignupsBlocked ?? this.allSignupsBlocked,
    signupBlockedMessage: signupBlockedMessage ?? this.signupBlockedMessage,
    googleSignInEnabled: googleSignInEnabled ?? this.googleSignInEnabled,
    appleSignInEnabled: appleSignInEnabled ?? this.appleSignInEnabled,
    walletPaymentEnabled: walletPaymentEnabled ?? this.walletPaymentEnabled,
    cardPaymentEnabled: cardPaymentEnabled ?? this.cardPaymentEnabled,
    minimumWalletTopup: minimumWalletTopup ?? this.minimumWalletTopup,
    maximumBookingAmount: maximumBookingAmount ?? this.maximumBookingAmount,
    requireKycBeforeBooking: requireKycBeforeBooking ?? this.requireKycBeforeBooking,
    requireWorkerKycPublic: requireWorkerKycPublic ?? this.requireWorkerKycPublic,
    requireCompanyKyc: requireCompanyKyc ?? this.requireCompanyKyc,
    twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
    maxLoginAttempts: maxLoginAttempts ?? this.maxLoginAttempts,
    accountSuspensionMessage: accountSuspensionMessage ?? this.accountSuspensionMessage,
    referralBonusAmount: referralBonusAmount ?? this.referralBonusAmount,
    loyaltyPointsPerBooking: loyaltyPointsPerBooking ?? this.loyaltyPointsPerBooking,
    loyaltyRedemptionRate: loyaltyRedemptionRate ?? this.loyaltyRedemptionRate,
    minRatingToAppear: minRatingToAppear ?? this.minRatingToAppear,
    maintenanceMode: maintenanceMode ?? this.maintenanceMode,
    maintenanceMessage: maintenanceMessage ?? this.maintenanceMessage,
    maintenanceEndTime: maintenanceEndTime ?? this.maintenanceEndTime,
  );
}

class PlatformFlagsNotifier extends StateNotifier<PlatformFlags> {
  PlatformFlagsNotifier() : super(const PlatformFlags()) {
    _load();
  }

  // ─── Persistence ─────────────────────────────────────────────
  Future<void> _load() async {
    try {
      final sp = await SharedPreferences.getInstance();
      // فقط نُحدّث إذا كانت القيم محفوظة
      bool? b(String k) => sp.containsKey('pf.$k') ? sp.getBool('pf.$k') : null;
      int? i(String k) => sp.containsKey('pf.$k') ? sp.getInt('pf.$k') : null;
      double? d(String k) => sp.containsKey('pf.$k') ? sp.getDouble('pf.$k') : null;
      String? s(String k) => sp.containsKey('pf.$k') ? sp.getString('pf.$k') : null;
      state = state.copyWith(
        offersEnabled: b('offers'),
        loyaltyEnabled: b('loyalty'),
        referralEnabled: b('referral'),
        walletEnabled: b('wallet'),
        subscriptionsEnabled: b('subscriptions'),
        compareEnabled: b('compare'),
        sosEnabled: b('sos'),
        chatEnabled: b('chat'),
        tipsEnabled: b('tips'),
        aiChatEnabled: b('aiChat'),
        voiceSearchEnabled: b('voiceSearch'),
        annualBookingEnabled: b('annualBooking'),
        promoCodesEnabled: b('promoCodes'),
        cashPaymentEnabled: b('cashPayment'),
        reviewsEnabled: b('reviews'),
        requireReviewAfterBooking: b('requireReview'),
        workerSectionVisible: b('workerSection'),
        workerSearchVisible: b('workerSearch'),
        workerProfilesVisible: b('workerProfiles'),
        workerRegistrationOpen: b('workerReg'),
        workerScheduleTabVisible: b('workerSchedule'),
        workerRequestsTabVisible: b('workerRequests'),
        workerEarningsVisible: b('workerEarnings'),
        workerCanSetOwnRate: b('workerOwnRate'),
        workerNightShiftEnabled: b('workerNightShift'),
        workerMaxDailyBookings: i('workerMaxDaily'),
        customerSearchTabVisible: b('customerSearch'),
        customerBookingsTabVisible: b('customerBookings'),
        customerWalletVisible: b('customerWallet'),
        customerOffersVisible: b('customerOffers'),
        customerLoyaltyVisible: b('customerLoyalty'),
        companyBookingsTabVisible: b('companyBookings'),
        companyWorkersTabVisible: b('companyWorkers'),
        companyServicesVisible: b('companyServices'),
        companyAnalyticsVisible: b('companyAnalytics'),
        companyBillingVisible: b('companyBilling'),
        customerSignupEnabled: b('customerSignup'),
        workerSignupEnabled: b('workerSignup'),
        companySignupEnabled: b('companySignup'),
        allSignupsBlocked: b('allSignups'),
        signupBlockedMessage: s('signupMsg'),
        googleSignInEnabled: b('googleSignIn'),
        appleSignInEnabled: b('appleSignIn'),
        walletPaymentEnabled: b('walletPayment'),
        cardPaymentEnabled: b('cardPayment'),
        minimumWalletTopup: d('minTopup'),
        maximumBookingAmount: d('maxBooking'),
        requireKycBeforeBooking: b('requireKyc'),
        requireWorkerKycPublic: b('requireWorkerKycPublic'),
        requireCompanyKyc: b('requireCompanyKyc'),
        twoFactorEnabled: b('2fa'),
        maxLoginAttempts: i('maxLogin'),
        accountSuspensionMessage: s('suspendMsg'),
        referralBonusAmount: d('referralBonus'),
        loyaltyPointsPerBooking: i('loyaltyPoints'),
        loyaltyRedemptionRate: d('loyaltyRate'),
        minRatingToAppear: d('minRating'),
        maintenanceMode: b('maintenance'),
        maintenanceMessage: s('maintenanceMsg'),
        maintenanceEndTime: s('maintenanceEnd'),
      );
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final f = state;
      await sp.setBool('pf.offers', f.offersEnabled);
      await sp.setBool('pf.loyalty', f.loyaltyEnabled);
      await sp.setBool('pf.referral', f.referralEnabled);
      await sp.setBool('pf.wallet', f.walletEnabled);
      await sp.setBool('pf.subscriptions', f.subscriptionsEnabled);
      await sp.setBool('pf.compare', f.compareEnabled);
      await sp.setBool('pf.sos', f.sosEnabled);
      await sp.setBool('pf.chat', f.chatEnabled);
      await sp.setBool('pf.tips', f.tipsEnabled);
      await sp.setBool('pf.aiChat', f.aiChatEnabled);
      await sp.setBool('pf.voiceSearch', f.voiceSearchEnabled);
      await sp.setBool('pf.annualBooking', f.annualBookingEnabled);
      await sp.setBool('pf.promoCodes', f.promoCodesEnabled);
      await sp.setBool('pf.cashPayment', f.cashPaymentEnabled);
      await sp.setBool('pf.reviews', f.reviewsEnabled);
      await sp.setBool('pf.requireReview', f.requireReviewAfterBooking);
      await sp.setBool('pf.workerSection', f.workerSectionVisible);
      await sp.setBool('pf.workerSearch', f.workerSearchVisible);
      await sp.setBool('pf.workerProfiles', f.workerProfilesVisible);
      await sp.setBool('pf.workerReg', f.workerRegistrationOpen);
      await sp.setBool('pf.workerSchedule', f.workerScheduleTabVisible);
      await sp.setBool('pf.workerRequests', f.workerRequestsTabVisible);
      await sp.setBool('pf.workerEarnings', f.workerEarningsVisible);
      await sp.setBool('pf.workerOwnRate', f.workerCanSetOwnRate);
      await sp.setBool('pf.workerNightShift', f.workerNightShiftEnabled);
      await sp.setInt('pf.workerMaxDaily', f.workerMaxDailyBookings);
      await sp.setBool('pf.customerSearch', f.customerSearchTabVisible);
      await sp.setBool('pf.customerBookings', f.customerBookingsTabVisible);
      await sp.setBool('pf.customerWallet', f.customerWalletVisible);
      await sp.setBool('pf.customerOffers', f.customerOffersVisible);
      await sp.setBool('pf.customerLoyalty', f.customerLoyaltyVisible);
      await sp.setBool('pf.companyBookings', f.companyBookingsTabVisible);
      await sp.setBool('pf.companyWorkers', f.companyWorkersTabVisible);
      await sp.setBool('pf.companyServices', f.companyServicesVisible);
      await sp.setBool('pf.companyAnalytics', f.companyAnalyticsVisible);
      await sp.setBool('pf.companyBilling', f.companyBillingVisible);
      await sp.setBool('pf.customerSignup', f.customerSignupEnabled);
      await sp.setBool('pf.workerSignup', f.workerSignupEnabled);
      await sp.setBool('pf.companySignup', f.companySignupEnabled);
      await sp.setBool('pf.allSignups', f.allSignupsBlocked);
      await sp.setString('pf.signupMsg', f.signupBlockedMessage);
      await sp.setBool('pf.googleSignIn', f.googleSignInEnabled);
      await sp.setBool('pf.appleSignIn', f.appleSignInEnabled);
      await sp.setBool('pf.walletPayment', f.walletPaymentEnabled);
      await sp.setBool('pf.cardPayment', f.cardPaymentEnabled);
      await sp.setDouble('pf.minTopup', f.minimumWalletTopup);
      await sp.setDouble('pf.maxBooking', f.maximumBookingAmount);
      await sp.setBool('pf.requireKyc', f.requireKycBeforeBooking);
      await sp.setBool('pf.requireWorkerKycPublic', f.requireWorkerKycPublic);
      await sp.setBool('pf.requireCompanyKyc', f.requireCompanyKyc);
      await sp.setBool('pf.2fa', f.twoFactorEnabled);
      await sp.setInt('pf.maxLogin', f.maxLoginAttempts);
      await sp.setString('pf.suspendMsg', f.accountSuspensionMessage);
      await sp.setDouble('pf.referralBonus', f.referralBonusAmount);
      await sp.setInt('pf.loyaltyPoints', f.loyaltyPointsPerBooking);
      await sp.setDouble('pf.loyaltyRate', f.loyaltyRedemptionRate);
      await sp.setDouble('pf.minRating', f.minRatingToAppear);
      await sp.setBool('pf.maintenance', f.maintenanceMode);
      await sp.setString('pf.maintenanceMsg', f.maintenanceMessage);
      await sp.setString('pf.maintenanceEnd', f.maintenanceEndTime);
    } catch (_) {}
  }

  // ─── Toggle Booleans ─────────────────────────────────────────
  void toggle(String key) {
    state = switch (key) {
      'offers'              => state.copyWith(offersEnabled: !state.offersEnabled),
      'loyalty'             => state.copyWith(loyaltyEnabled: !state.loyaltyEnabled),
      'referral'            => state.copyWith(referralEnabled: !state.referralEnabled),
      'wallet'              => state.copyWith(walletEnabled: !state.walletEnabled),
      'subscriptions'       => state.copyWith(subscriptionsEnabled: !state.subscriptionsEnabled),
      'compare'             => state.copyWith(compareEnabled: !state.compareEnabled),
      'sos'                 => state.copyWith(sosEnabled: !state.sosEnabled),
      'chat'                => state.copyWith(chatEnabled: !state.chatEnabled),
      'tips'                => state.copyWith(tipsEnabled: !state.tipsEnabled),
      'aiChat'              => state.copyWith(aiChatEnabled: !state.aiChatEnabled),
      'voiceSearch'         => state.copyWith(voiceSearchEnabled: !state.voiceSearchEnabled),
      'annualBooking'       => state.copyWith(annualBookingEnabled: !state.annualBookingEnabled),
      'promoCodes'          => state.copyWith(promoCodesEnabled: !state.promoCodesEnabled),
      'cashPayment'         => state.copyWith(cashPaymentEnabled: !state.cashPaymentEnabled),
      'reviews'             => state.copyWith(reviewsEnabled: !state.reviewsEnabled),
      'requireReview'       => state.copyWith(requireReviewAfterBooking: !state.requireReviewAfterBooking),
      'workerSection'       => state.copyWith(workerSectionVisible: !state.workerSectionVisible),
      'workerSearch'        => state.copyWith(workerSearchVisible: !state.workerSearchVisible),
      'workerProfiles'      => state.copyWith(workerProfilesVisible: !state.workerProfilesVisible),
      'workerReg'           => state.copyWith(workerRegistrationOpen: !state.workerRegistrationOpen),
      'workerSchedule'      => state.copyWith(workerScheduleTabVisible: !state.workerScheduleTabVisible),
      'workerRequests'      => state.copyWith(workerRequestsTabVisible: !state.workerRequestsTabVisible),
      'workerEarnings'      => state.copyWith(workerEarningsVisible: !state.workerEarningsVisible),
      'workerOwnRate'       => state.copyWith(workerCanSetOwnRate: !state.workerCanSetOwnRate),
      'workerNightShift'    => state.copyWith(workerNightShiftEnabled: !state.workerNightShiftEnabled),
      'customerSearch'      => state.copyWith(customerSearchTabVisible: !state.customerSearchTabVisible),
      'customerBookings'    => state.copyWith(customerBookingsTabVisible: !state.customerBookingsTabVisible),
      'customerWallet'      => state.copyWith(customerWalletVisible: !state.customerWalletVisible),
      'customerOffers'      => state.copyWith(customerOffersVisible: !state.customerOffersVisible),
      'customerLoyalty'     => state.copyWith(customerLoyaltyVisible: !state.customerLoyaltyVisible),
      'companyBookings'     => state.copyWith(companyBookingsTabVisible: !state.companyBookingsTabVisible),
      'companyWorkers'      => state.copyWith(companyWorkersTabVisible: !state.companyWorkersTabVisible),
      'companyServices'     => state.copyWith(companyServicesVisible: !state.companyServicesVisible),
      'companyAnalytics'    => state.copyWith(companyAnalyticsVisible: !state.companyAnalyticsVisible),
      'companyBilling'      => state.copyWith(companyBillingVisible: !state.companyBillingVisible),
      'customerSignup'      => state.copyWith(customerSignupEnabled: !state.customerSignupEnabled),
      'workerSignup'        => state.copyWith(workerSignupEnabled: !state.workerSignupEnabled),
      'companySignup'       => state.copyWith(companySignupEnabled: !state.companySignupEnabled),
      'allSignups'          => state.copyWith(allSignupsBlocked: !state.allSignupsBlocked),
      'googleSignIn'        => state.copyWith(googleSignInEnabled: !state.googleSignInEnabled),
      'appleSignIn'         => state.copyWith(appleSignInEnabled: !state.appleSignInEnabled),
      'walletPayment'       => state.copyWith(walletPaymentEnabled: !state.walletPaymentEnabled),
      'cardPayment'         => state.copyWith(cardPaymentEnabled: !state.cardPaymentEnabled),
      'requireKyc'          => state.copyWith(requireKycBeforeBooking: !state.requireKycBeforeBooking),
      'requireWorkerKyc'    => state.copyWith(requireWorkerKycPublic: !state.requireWorkerKycPublic),
      'requireCompanyKyc'   => state.copyWith(requireCompanyKyc: !state.requireCompanyKyc),
      '2fa'                 => state.copyWith(twoFactorEnabled: !state.twoFactorEnabled),
      'maintenance'         => state.copyWith(maintenanceMode: !state.maintenanceMode),
      _                     => state,
    };
    _save();
  }

  // ─── Numeric Setters ─────────────────────────────────────────
  void setWorkerMaxDailyBookings(int v) {
    state = state.copyWith(workerMaxDailyBookings: v.clamp(1, 20));
    _save();
  }
  void setMinimumWalletTopup(double v) {
    state = state.copyWith(minimumWalletTopup: v.clamp(1, 500));
    _save();
  }
  void setMaximumBookingAmount(double v) {
    state = state.copyWith(maximumBookingAmount: v.clamp(50, 10000));
    _save();
  }
  void setMaxLoginAttempts(int v) {
    state = state.copyWith(maxLoginAttempts: v.clamp(3, 10));
    _save();
  }
  void setReferralBonusAmount(double v) {
    state = state.copyWith(referralBonusAmount: v.clamp(0, 200));
    _save();
  }
  void setLoyaltyPointsPerBooking(int v) {
    state = state.copyWith(loyaltyPointsPerBooking: v.clamp(0, 100));
    _save();
  }
  void setLoyaltyRedemptionRate(double v) {
    state = state.copyWith(loyaltyRedemptionRate: v.clamp(0.001, 0.1));
    _save();
  }
  void setMinRatingToAppear(double v) {
    state = state.copyWith(minRatingToAppear: v.clamp(1.0, 5.0));
    _save();
  }

  // ─── String Setters ──────────────────────────────────────────
  void setSignupBlockedMessage(String msg) {
    state = state.copyWith(signupBlockedMessage: msg);
    _save();
  }
  void setAccountSuspensionMessage(String msg) {
    state = state.copyWith(accountSuspensionMessage: msg);
    _save();
  }
  void setMaintenanceMessage(String msg) {
    state = state.copyWith(maintenanceMessage: msg);
    _save();
  }
  void setMaintenanceEndTime(String t) {
    state = state.copyWith(maintenanceEndTime: t);
    _save();
  }

  // ─── Bulk Actions ────────────────────────────────────────────
  void blockAllSignups({String? message}) {
    state = state.copyWith(
      allSignupsBlocked: true,
      signupBlockedMessage: message ?? state.signupBlockedMessage,
    );
    _save();
  }
  void allowAllSignups() {
    state = state.copyWith(allSignupsBlocked: false);
    _save();
  }
  void enableWorkerSection() {
    state = state.copyWith(
      workerSectionVisible: true, workerSearchVisible: true,
      workerProfilesVisible: true, workerRegistrationOpen: true,
      workerScheduleTabVisible: true, workerRequestsTabVisible: true,
    );
    _save();
  }
  void disableWorkerSection() {
    state = state.copyWith(
      workerSectionVisible: false, workerSearchVisible: false,
      workerProfilesVisible: false, workerRegistrationOpen: false,
    );
    _save();
  }
  void enableMaintenance({String? message, String? endTime}) {
    state = state.copyWith(
      maintenanceMode: true,
      maintenanceMessage: message ?? state.maintenanceMessage,
      maintenanceEndTime: endTime ?? state.maintenanceEndTime,
    );
    _save();
  }
  void disableMaintenance() {
    state = state.copyWith(maintenanceMode: false, maintenanceEndTime: '');
    _save();
  }
  void resetToDefaults() {
    state = const PlatformFlags();
    _save();
  }
}

final platformFlagsProvider =
    StateNotifierProvider<PlatformFlagsNotifier, PlatformFlags>(
  (ref) => PlatformFlagsNotifier(),
);
