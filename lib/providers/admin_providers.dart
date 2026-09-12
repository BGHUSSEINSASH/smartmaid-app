import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models.dart';
import '../data/demo_data.dart';

// ── System Settings Provider ─────────────────────────────────────
class SystemSettingsNotifier extends StateNotifier<SystemSettings> {
  SystemSettingsNotifier() : super(const SystemSettings());

  void setCommissionRate(double v) =>
      state = state.copyWith(defaultCommissionRate: v.clamp(0.01, 0.50));
  void setMinWithdrawal(double v) =>
      state = state.copyWith(minWithdrawal: v);
  void setMaxCouponDiscount(double v) =>
      state = state.copyWith(maxCouponDiscount: v.clamp(0.01, 1.0));
  void setMaintenance(bool v, {String? msg}) =>
      state = state.copyWith(maintenanceMode: v,
          maintenanceMessage: msg ?? state.maintenanceMessage);
  void toggleLoyalty() =>
      state = state.copyWith(loyaltyEnabled: !state.loyaltyEnabled);
  void toggleReferral() =>
      state = state.copyWith(referralEnabled: !state.referralEnabled);
}

final systemSettingsProvider =
    StateNotifierProvider<SystemSettingsNotifier, SystemSettings>(
  (ref) => SystemSettingsNotifier(),
);

// ── Discounts Provider ────────────────────────────────────────────
class DiscountsNotifier extends StateNotifier<List<DiscountModel>> {
  DiscountsNotifier()
      : super(const [
          DiscountModel(
              id: 'd1', code: 'SMART50', title: 'خصم النصف',
              discountPercent: 50, minTotal: 50, maxUses: 500, usedCount: 128),
          DiscountModel(
              id: 'd2', code: 'SAVE15', title: 'وفّر 15%',
              discountPercent: 15, minTotal: 30, maxUses: 1000, usedCount: 344),
          DiscountModel(
              id: 'd3', code: 'MONTHLY10', title: 'باقة الشهر',
              discountPercent: 10, minTotal: 200, maxUses: 200,
              usedCount: 67, isActive: true),
        ]);

  void add(DiscountModel d) => state = [d, ...state];

  void toggle(String id) => state = state.map((d) =>
      d.id == id ? d.copyWith(isActive: !d.isActive) : d).toList();

  void remove(String id) => state = state.where((d) => d.id != id).toList();

  void update(DiscountModel updated) => state =
      state.map((d) => d.id == updated.id ? updated : d).toList();
}

final discountsProvider =
    StateNotifierProvider<DiscountsNotifier, List<DiscountModel>>(
  (ref) => DiscountsNotifier(),
);

// ── Company Commissions Provider ───────────────────────────────────
class CompanyCommissionsNotifier
    extends StateNotifier<Map<String, double>> {
  CompanyCommissionsNotifier()
      : super({
          'co1': 0.20,
          'co2': 0.18,
          'co3': 0.22,
          'co4': 0.20,
        });

  void setRate(String companyId, double rate) =>
      state = {...state, companyId: rate.clamp(0.01, 0.50)};

  void resetAll(double rate) =>
      state = state.map((k, _) => MapEntry(k, rate));
}

final companyCommissionsProvider =
    StateNotifierProvider<CompanyCommissionsNotifier, Map<String, double>>(
  (ref) => CompanyCommissionsNotifier(),
);

// ── User Management Provider ──────────────────────────────────────
class UsersManagementNotifier extends StateNotifier<List<AppUser>> {
  UsersManagementNotifier() : super(_seedUsers);

  static final _seedUsers = <AppUser>[
    const AppUser(id: 'u1', name: 'أحمد محمد', email: 'customer@demo.com',
        imageUrl: 'https://i.pravatar.cc/150?img=68',
        role: AppRole.customer, phone: '+966501234567',
        isVerified: true, accountStatus: AccountStatus.active),
    const AppUser(id: 'u2', name: 'ماريا سانتوس', email: 'worker@demo.com',
        imageUrl: 'https://i.pravatar.cc/150?img=47',
        role: AppRole.worker, phone: '+966559876543',
        isVerified: true, accountStatus: AccountStatus.active,
        workerInfo: WorkerInfo(kycStatus: KycStatus.approved,
            skills: ['تنظيف عام', 'كواء'])),
    const AppUser(id: 'u3', name: 'مدير النظام', email: 'admin@demo.com',
        imageUrl: 'https://i.pravatar.cc/150?img=70',
        role: AppRole.admin, isVerified: true,
        accountStatus: AccountStatus.active),
    const AppUser(id: 'u4', name: 'شركة النظافة المثالية',
        email: 'company@demo.com',
        imageUrl: 'https://i.pravatar.cc/150?img=60',
        role: AppRole.company, phone: '+96611222333',
        isVerified: true, accountStatus: AccountStatus.active,
        companyInfo: CompanyInfo(
            companyName: 'النظافة المثالية',
            commercialRegNo: 'CR-4512', city: 'الرياض',
            commissionRate: 0.20,
            subscriptionPlan: SubscriptionPlan.pro)),
    const AppUser(id: 'u5', name: 'فاطمة علي', email: 'fatima@demo.com',
        imageUrl: 'https://i.pravatar.cc/150?img=45',
        role: AppRole.worker, phone: '+966551112222',
        workerInfo: WorkerInfo(kycStatus: KycStatus.pending,
            skills: ['طبخ', 'رعاية أطفال'])),
    const AppUser(id: 'u6', name: 'سارة القحطاني', email: 'sara@demo.com',
        imageUrl: 'https://i.pravatar.cc/150?img=25',
        role: AppRole.customer, phone: '+966501234999',
        accountStatus: AccountStatus.suspended),
  ];

  void suspend(String id) => state = state.map((u) =>
      u.id == id ? u.copyWith(accountStatus: AccountStatus.suspended,
          isActive: false) : u).toList();

  void activate(String id) => state = state.map((u) =>
      u.id == id ? u.copyWith(accountStatus: AccountStatus.active,
          isActive: true) : u).toList();

  void delete(String id) => state = state.map((u) =>
      u.id == id ? u.copyWith(accountStatus: AccountStatus.deleted) : u).toList();

  void approveKyc(String id) => state = state.map((u) {
    if (u.id != id) return u;
    final wi = u.workerInfo ?? const WorkerInfo();
    return u.copyWith(
        isVerified: true,
        workerInfo: wi.copyWith(kycStatus: KycStatus.approved));
  }).toList();

  void rejectKyc(String id) => state = state.map((u) {
    if (u.id != id) return u;
    final wi = u.workerInfo ?? const WorkerInfo();
    return u.copyWith(
        workerInfo: wi.copyWith(kycStatus: KycStatus.rejected));
  }).toList();
}

final usersManagementProvider =
    StateNotifierProvider<UsersManagementNotifier, List<AppUser>>(
  (ref) => UsersManagementNotifier(),
);

// ── Admin-managed Companies Provider ──────────────────────────────
class AdminCompaniesNotifier extends StateNotifier<List<CompanyModel>> {
  AdminCompaniesNotifier() : super(List.of(DemoData.companies));

  void addCompany(CompanyModel company) => state = [company, ...state];

  void togglePro(String id) => state = state
      .map((c) => c.id == id ? c.copyWith(isPro: !c.isPro) : c)
      .toList();

  void setCommission(String id, double rate) => state = state
      .map((c) => c.id == id ? c.copyWith(commissionRate: rate) : c)
      .toList();

  void remove(String id) => state = state.where((c) => c.id != id).toList();
}

final adminCompaniesProvider =
    StateNotifierProvider<AdminCompaniesNotifier, List<CompanyModel>>(
  (ref) => AdminCompaniesNotifier(),
);
