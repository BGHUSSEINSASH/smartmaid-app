import 'package:flutter/material.dart';
import '../features/auth/domain/app_role.dart';

export '../features/auth/domain/app_role.dart';

enum BookingType { daily, weekly, monthly, annual }

enum KycStatus { none, pending, approved, rejected }

enum SubscriptionPlan { basic, pro, enterprise }

enum AccountStatus { active, suspended, deleted }

// ─── Customer Extra Info ──────────────────────────────────────────
class CustomerInfo {
  final String nationality;
  final String dateOfBirth;
  final String gender;
  final String? referralCode;
  final String? referredBy;
  final int loyaltyPoints;
  final double totalSpent;
  final int totalBookings;

  const CustomerInfo({
    this.nationality = '',
    this.dateOfBirth = '',
    this.gender = '',
    this.referralCode,
    this.referredBy,
    this.loyaltyPoints = 0,
    this.totalSpent = 0,
    this.totalBookings = 0,
  });

  CustomerInfo copyWith({
    String? nationality,
    String? dateOfBirth,
    String? gender,
    String? referralCode,
    String? referredBy,
    int? loyaltyPoints,
    double? totalSpent,
    int? totalBookings,
  }) =>
      CustomerInfo(
        nationality: nationality ?? this.nationality,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        gender: gender ?? this.gender,
        referralCode: referralCode ?? this.referralCode,
        referredBy: referredBy ?? this.referredBy,
        loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
        totalSpent: totalSpent ?? this.totalSpent,
        totalBookings: totalBookings ?? this.totalBookings,
      );
}

// ─── Worker Extra Info ────────────────────────────────────────────
class WorkerInfo {
  final String nationality;
  final String passportNumber;
  final String passportExpiry;
  final String nationalId;
  final List<String> skills;
  final int experienceYears;
  final String bio;
  final double hourlyRate;
  final double dailyRate;
  final double monthlyRate;
  final String? companyId;
  final KycStatus kycStatus;
  final String bankName;
  final String iban;
  final double totalEarnings;
  final double rating;
  final int reviewCount;
  final List<String> availableDays;
  final String timeFrom;
  final String timeTo;

  const WorkerInfo({
    this.nationality = '',
    this.passportNumber = '',
    this.passportExpiry = '',
    this.nationalId = '',
    this.skills = const [],
    this.experienceYears = 0,
    this.bio = '',
    this.hourlyRate = 0,
    this.dailyRate = 0,
    this.monthlyRate = 0,
    this.companyId,
    this.kycStatus = KycStatus.none,
    this.bankName = '',
    this.iban = '',
    this.totalEarnings = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.availableDays = const [],
    this.timeFrom = '08:00',
    this.timeTo = '20:00',
  });

  WorkerInfo copyWith({
    String? nationality,
    String? passportNumber,
    String? passportExpiry,
    String? nationalId,
    List<String>? skills,
    int? experienceYears,
    String? bio,
    double? hourlyRate,
    double? dailyRate,
    double? monthlyRate,
    String? companyId,
    KycStatus? kycStatus,
    String? bankName,
    String? iban,
    double? totalEarnings,
    double? rating,
    int? reviewCount,
    List<String>? availableDays,
    String? timeFrom,
    String? timeTo,
  }) =>
      WorkerInfo(
        nationality: nationality ?? this.nationality,
        passportNumber: passportNumber ?? this.passportNumber,
        passportExpiry: passportExpiry ?? this.passportExpiry,
        nationalId: nationalId ?? this.nationalId,
        skills: skills ?? this.skills,
        experienceYears: experienceYears ?? this.experienceYears,
        bio: bio ?? this.bio,
        hourlyRate: hourlyRate ?? this.hourlyRate,
        dailyRate: dailyRate ?? this.dailyRate,
        monthlyRate: monthlyRate ?? this.monthlyRate,
        companyId: companyId ?? this.companyId,
        kycStatus: kycStatus ?? this.kycStatus,
        bankName: bankName ?? this.bankName,
        iban: iban ?? this.iban,
        totalEarnings: totalEarnings ?? this.totalEarnings,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        availableDays: availableDays ?? this.availableDays,
        timeFrom: timeFrom ?? this.timeFrom,
        timeTo: timeTo ?? this.timeTo,
      );
}

// ─── Company Extra Info ───────────────────────────────────────────
class CompanyInfo {
  final String companyName;
  final String commercialRegNo;
  final String contactPerson;
  final String contactPhone;
  final String address;
  final String city;
  final double commissionRate;
  final SubscriptionPlan subscriptionPlan;
  final int maxWorkers;
  final double totalRevenue;
  final double monthlyRevenue;
  final AccountStatus status;
  final String logoUrl;
  final String contractDocUrl;

  const CompanyInfo({
    this.companyName = '',
    this.commercialRegNo = '',
    this.contactPerson = '',
    this.contactPhone = '',
    this.address = '',
    this.city = '',
    this.commissionRate = 0.20,
    this.subscriptionPlan = SubscriptionPlan.basic,
    this.maxWorkers = 5,
    this.totalRevenue = 0,
    this.monthlyRevenue = 0,
    this.status = AccountStatus.active,
    this.logoUrl = '',
    this.contractDocUrl = '',
  });

  CompanyInfo copyWith({
    String? companyName,
    String? commercialRegNo,
    String? contactPerson,
    String? contactPhone,
    String? address,
    String? city,
    double? commissionRate,
    SubscriptionPlan? subscriptionPlan,
    int? maxWorkers,
    double? totalRevenue,
    double? monthlyRevenue,
    AccountStatus? status,
    String? logoUrl,
    String? contractDocUrl,
  }) =>
      CompanyInfo(
        companyName: companyName ?? this.companyName,
        commercialRegNo: commercialRegNo ?? this.commercialRegNo,
        contactPerson: contactPerson ?? this.contactPerson,
        contactPhone: contactPhone ?? this.contactPhone,
        address: address ?? this.address,
        city: city ?? this.city,
        commissionRate: commissionRate ?? this.commissionRate,
        subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
        maxWorkers: maxWorkers ?? this.maxWorkers,
        totalRevenue: totalRevenue ?? this.totalRevenue,
        monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
        status: status ?? this.status,
        logoUrl: logoUrl ?? this.logoUrl,
        contractDocUrl: contractDocUrl ?? this.contractDocUrl,
      );
}

// ─── Admin Extra Info ─────────────────────────────────────────────
class AdminInfo {
  final List<String> permissions;
  final String lastLoginIp;
  final int actionCount;

  const AdminInfo({
    this.permissions = const ['SUPER'],
    this.lastLoginIp = '',
    this.actionCount = 0,
  });

  AdminInfo copyWith({
    List<String>? permissions,
    String? lastLoginIp,
    int? actionCount,
  }) =>
      AdminInfo(
        permissions: permissions ?? this.permissions,
        lastLoginIp: lastLoginIp ?? this.lastLoginIp,
        actionCount: actionCount ?? this.actionCount,
      );
}

// ─── App User (موسّع) ─────────────────────────────────────────────
class AppUser {
  final String id;
  final String name;
  final String email;
  final String imageUrl;
  final AppRole role;
  final String phone;
  final String location;
  final bool isVerified;
  final bool isActive;
  final AccountStatus accountStatus;
  final DateTime? joinedAt;

  // بيانات مخصّصة لكل دور
  final CustomerInfo? customerInfo;
  final WorkerInfo? workerInfo;
  final CompanyInfo? companyInfo;
  final AdminInfo? adminInfo;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.role,
    this.phone = '',
    this.location = '',
    this.isVerified = false,
    this.isActive = true,
    this.accountStatus = AccountStatus.active,
    this.joinedAt,
    this.customerInfo,
    this.workerInfo,
    this.companyInfo,
    this.adminInfo,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? imageUrl,
    AppRole? role,
    String? phone,
    String? location,
    bool? isVerified,
    bool? isActive,
    AccountStatus? accountStatus,
    DateTime? joinedAt,
    CustomerInfo? customerInfo,
    WorkerInfo? workerInfo,
    CompanyInfo? companyInfo,
    AdminInfo? adminInfo,
  }) =>
      AppUser(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        imageUrl: imageUrl ?? this.imageUrl,
        role: role ?? this.role,
        phone: phone ?? this.phone,
        location: location ?? this.location,
        isVerified: isVerified ?? this.isVerified,
        isActive: isActive ?? this.isActive,
        accountStatus: accountStatus ?? this.accountStatus,
        joinedAt: joinedAt ?? this.joinedAt,
        customerInfo: customerInfo ?? this.customerInfo,
        workerInfo: workerInfo ?? this.workerInfo,
        companyInfo: companyInfo ?? this.companyInfo,
        adminInfo: adminInfo ?? this.adminInfo,
      );
}

class ExtraService {
  final String id;
  final String name;
  final String icon;
  final double priceUsd;

  const ExtraService({
    required this.id,
    required this.name,
    required this.icon,
    required this.priceUsd,
  });
}

class WorkerModel {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final int jobsCompleted;
  final double hourlyRate;
  final String location;
  final bool isAvailable;
  final List<String> skills;
  final String about;
  final String? companyId;
  final bool verified;
  final String? nationalityCountry;

  const WorkerModel({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.jobsCompleted,
    required this.hourlyRate,
    required this.location,
    required this.isAvailable,
    required this.skills,
    required this.about,
    this.companyId,
    this.verified = false,
    this.nationalityCountry,
  });

  String get image => imageUrl;
  int get experienceYears => (jobsCompleted / 28).ceil();
}

class CompanyModel {
  final String id;
  final String name;
  final String logoUrl;
  final String description;
  final String location;
  final bool isPro;
  final double rating;
  final int workerCount;
  final List<String> specialties;
  final String contactEmail;
  final String contactPhone;
  final double commissionRate;

  const CompanyModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.description,
    required this.location,
    this.isPro = false,
    required this.rating,
    required this.workerCount,
    required this.specialties,
    required this.contactEmail,
    required this.contactPhone,
    this.commissionRate = 0.20,
  });

  double netRevenue(double totalBookingValue) =>
      totalBookingValue * (1 - commissionRate);

  double platformCommission(double totalBookingValue) =>
      totalBookingValue * commissionRate;

  CompanyModel copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? description,
    String? location,
    bool? isPro,
    double? rating,
    int? workerCount,
    List<String>? specialties,
    String? contactEmail,
    String? contactPhone,
    double? commissionRate,
  }) =>
      CompanyModel(
        id: id ?? this.id,
        name: name ?? this.name,
        logoUrl: logoUrl ?? this.logoUrl,
        description: description ?? this.description,
        location: location ?? this.location,
        isPro: isPro ?? this.isPro,
        rating: rating ?? this.rating,
        workerCount: workerCount ?? this.workerCount,
        specialties: specialties ?? this.specialties,
        contactEmail: contactEmail ?? this.contactEmail,
        contactPhone: contactPhone ?? this.contactPhone,
        commissionRate: commissionRate ?? this.commissionRate,
      );
}

class InvoiceData {
  final String invoiceNumber;
  final DateTime date;
  final String customerName;
  final String workerName;
  final String workerImage;
  final String companyName;
  final String service;
  final String bookingType;
  final String duration;
  final String timeSlot;
  final double baseTotal;
  final double extrasTotal;
  final double total;
  final List<String> extras;

  const InvoiceData({
    required this.invoiceNumber,
    required this.date,
    required this.customerName,
    required this.workerName,
    required this.workerImage,
    this.companyName = '',
    required this.service,
    required this.bookingType,
    required this.duration,
    required this.timeSlot,
    required this.baseTotal,
    required this.extrasTotal,
    required this.total,
    required this.extras,
  });
}

enum BookingStatus { pending, confirmed, inProgress, completed, cancelled }

enum PaymentStatus { unpaid, held, paid, refunded }

class BookingModel {
  final String id;
  final String workerId;
  final String workerName;
  final String workerImage;
  final String userId;
  final DateTime date;
  final String timeSlot;
  final String service;
  final double total;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String notes;
  final String cancelReason;
  final bool expressFee;
  final bool needTools;
  final DateTime? arrivalTime;
  final List<String> beforeAfterPhotos;

  const BookingModel({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.workerImage,
    required this.userId,
    required this.date,
    required this.timeSlot,
    required this.service,
    required this.total,
    required this.status,
    required this.paymentStatus,
    this.notes = '',
    this.cancelReason = '',
    this.expressFee = false,
    this.needTools = false,
    this.arrivalTime,
    this.beforeAfterPhotos = const [],
  });

  BookingModel copyWith({
    String? id,
    String? workerId,
    String? workerName,
    String? workerImage,
    String? userId,
    DateTime? date,
    String? timeSlot,
    String? service,
    double? total,
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    String? notes,
    String? cancelReason,
    bool? expressFee,
    bool? needTools,
    DateTime? arrivalTime,
    List<String>? beforeAfterPhotos,
  }) =>
      BookingModel(
        id: id ?? this.id,
        workerId: workerId ?? this.workerId,
        workerName: workerName ?? this.workerName,
        workerImage: workerImage ?? this.workerImage,
        userId: userId ?? this.userId,
        date: date ?? this.date,
        timeSlot: timeSlot ?? this.timeSlot,
        service: service ?? this.service,
        total: total ?? this.total,
        status: status ?? this.status,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        notes: notes ?? this.notes,
        cancelReason: cancelReason ?? this.cancelReason,
        expressFee: expressFee ?? this.expressFee,
        needTools: needTools ?? this.needTools,
        arrivalTime: arrivalTime ?? this.arrivalTime,
        beforeAfterPhotos: beforeAfterPhotos ?? this.beforeAfterPhotos,
      );
}

class ReviewModel {
  final String id;
  final String reviewerName;
  final String reviewerImage;
  final double rating;
  final String comment;
  final DateTime date;
  final List<String> photos;

  const ReviewModel({
    required this.id,
    required this.reviewerName,
    required this.reviewerImage,
    required this.rating,
    required this.comment,
    required this.date,
    this.photos = const [],
  });
}

class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isRead = true,
  });
}

class AppCommission {
  static const double platformRate = 0.20;
  static const double companyRate = 0.80;
}

class Conversation {
  final String id;
  final WorkerModel worker;
  final List<MessageModel> messages;

  const Conversation({
    required this.id,
    required this.worker,
    required this.messages,
  });

  MessageModel? get lastMessage => messages.isNotEmpty ? messages.last : null;
  int get unreadCount => messages.where((m) => !m.isRead).length;
}

// ─── Discount / Coupon ────────────────────────────────────────────
class DiscountModel {
  final String id;
  final String code;
  final String title;
  final double discountPercent;
  final double minTotal;
  final int maxUses;
  final int usedCount;
  final bool isActive;
  final String? targetRole; // null = كل الأدوار
  final DateTime? expiresAt;

  const DiscountModel({
    required this.id,
    required this.code,
    required this.title,
    required this.discountPercent,
    this.minTotal = 0,
    this.maxUses = 9999,
    this.usedCount = 0,
    this.isActive = true,
    this.targetRole,
    this.expiresAt,
  });

  DiscountModel copyWith({
    String? id,
    String? code,
    String? title,
    double? discountPercent,
    double? minTotal,
    int? maxUses,
    int? usedCount,
    bool? isActive,
    String? targetRole,
    DateTime? expiresAt,
  }) =>
      DiscountModel(
        id: id ?? this.id,
        code: code ?? this.code,
        title: title ?? this.title,
        discountPercent: discountPercent ?? this.discountPercent,
        minTotal: minTotal ?? this.minTotal,
        maxUses: maxUses ?? this.maxUses,
        usedCount: usedCount ?? this.usedCount,
        isActive: isActive ?? this.isActive,
        targetRole: targetRole ?? this.targetRole,
        expiresAt: expiresAt ?? this.expiresAt,
      );
}

// ─── System Settings ──────────────────────────────────────────────
class SystemSettings {
  final double defaultCommissionRate;
  final double minWithdrawal;
  final double maxCouponDiscount;
  final bool maintenanceMode;
  final String maintenanceMessage;
  final bool loyaltyEnabled;
  final bool referralEnabled;

  const SystemSettings({
    this.defaultCommissionRate = 0.20,
    this.minWithdrawal = 50,
    this.maxCouponDiscount = 0.50,
    this.maintenanceMode = false,
    this.maintenanceMessage = 'التطبيق تحت الصيانة، نعود قريباً',
    this.loyaltyEnabled = true,
    this.referralEnabled = true,
  });

  SystemSettings copyWith({
    double? defaultCommissionRate,
    double? minWithdrawal,
    double? maxCouponDiscount,
    bool? maintenanceMode,
    String? maintenanceMessage,
    bool? loyaltyEnabled,
    bool? referralEnabled,
  }) =>
      SystemSettings(
        defaultCommissionRate:
            defaultCommissionRate ?? this.defaultCommissionRate,
        minWithdrawal: minWithdrawal ?? this.minWithdrawal,
        maxCouponDiscount: maxCouponDiscount ?? this.maxCouponDiscount,
        maintenanceMode: maintenanceMode ?? this.maintenanceMode,
        maintenanceMessage: maintenanceMessage ?? this.maintenanceMessage,
        loyaltyEnabled: loyaltyEnabled ?? this.loyaltyEnabled,
        referralEnabled: referralEnabled ?? this.referralEnabled,
      );
}

// ─── Payment Card ─────────────────────────────────────────────────
enum CardBrand { visa, mastercard, amex, other }

class PaymentCard {
  final String id;
  final String lastFour;
  final CardBrand brand;
  final String holderName;
  final String expiryMonth;
  final String expiryYear;
  final bool isDefault;

  const PaymentCard({
    required this.id,
    required this.lastFour,
    required this.brand,
    required this.holderName,
    required this.expiryMonth,
    required this.expiryYear,
    this.isDefault = false,
  });

  String get brandName => switch (brand) {
    CardBrand.visa => 'Visa',
    CardBrand.mastercard => 'Mastercard',
    CardBrand.amex => 'Amex',
    CardBrand.other => 'Card',
  };

  PaymentCard copyWith({
    String? id, String? lastFour, CardBrand? brand,
    String? holderName, String? expiryMonth, String? expiryYear, bool? isDefault,
  }) => PaymentCard(
    id: id ?? this.id, lastFour: lastFour ?? this.lastFour,
    brand: brand ?? this.brand, holderName: holderName ?? this.holderName,
    expiryMonth: expiryMonth ?? this.expiryMonth,
    expiryYear: expiryYear ?? this.expiryYear,
    isDefault: isDefault ?? this.isDefault,
  );
}

// ─── Staff Member ─────────────────────────────────────────────────
enum StaffRole {
  superAdmin,
  operationsManager,
  supportAgent,
  financeOfficer,
  contentManager,
  workerManager,
}

enum StaffPermission {
  // === إدارة المستخدمين ===
  manageUsers,
  suspendUsers,
  deleteUsers,
  viewUserDetails,

  // === إدارة الشركات ===
  manageCompanies,
  approveCompanies,
  createCompany,

  // === العاملات ===
  manageWorkers,
  approveKyc,
  controlWorkerSection,

  // === المالية ===
  manageFinance,
  processWithdrawals,
  issueCompensations,
  manageCommissions,

  // === الاشتراكات ===
  manageSubscriptions,
  grantProAccess,
  revokeSubscriptions,

  // === المحتوى والتواصل ===
  manageDiscounts,
  respondToChats,
  sendBroadcast,

  // === النظام ===
  changeSystemSettings,
  viewAuditLog,
  managePlatformFlags,
}

extension StaffRoleX on StaffRole {
  String get arabicLabel => switch (this) {
    StaffRole.superAdmin => 'مدير أعلى',
    StaffRole.operationsManager => 'مدير عمليات',
    StaffRole.supportAgent => 'وكيل دعم',
    StaffRole.financeOfficer => 'مسؤول مالي',
    StaffRole.contentManager => 'مدير المحتوى',
    StaffRole.workerManager => 'مدير العاملات',
  };
  List<StaffPermission> get defaultPermissions => switch (this) {
    StaffRole.superAdmin => StaffPermission.values,
    StaffRole.operationsManager => [
        StaffPermission.manageUsers, StaffPermission.suspendUsers,
        StaffPermission.manageWorkers, StaffPermission.approveKyc,
        StaffPermission.manageCompanies, StaffPermission.approveCompanies,
        StaffPermission.viewUserDetails, StaffPermission.viewAuditLog,
      ],
    StaffRole.supportAgent => [
        StaffPermission.respondToChats, StaffPermission.viewUserDetails,
        StaffPermission.viewAuditLog,
      ],
    StaffRole.financeOfficer => [
        StaffPermission.manageFinance, StaffPermission.processWithdrawals,
        StaffPermission.issueCompensations, StaffPermission.manageCommissions,
        StaffPermission.viewAuditLog,
      ],
    StaffRole.contentManager => [
        StaffPermission.manageDiscounts, StaffPermission.sendBroadcast,
        StaffPermission.managePlatformFlags,
      ],
    StaffRole.workerManager => [
        StaffPermission.manageWorkers, StaffPermission.approveKyc,
        StaffPermission.controlWorkerSection, StaffPermission.viewUserDetails,
      ],
  };
}

class StaffMember {
  final String id;
  final String name;
  final String email;
  final StaffRole role;
  final List<StaffPermission> permissions;
  final bool isActive;
  final DateTime? lastLogin;

  const StaffMember({
    required this.id, required this.name, required this.email,
    required this.role, required this.permissions,
    this.isActive = true, this.lastLogin,
  });

  StaffMember copyWith({
    String? id, String? name, String? email, StaffRole? role,
    List<StaffPermission>? permissions, bool? isActive, DateTime? lastLogin,
  }) => StaffMember(
    id: id ?? this.id, name: name ?? this.name,
    email: email ?? this.email, role: role ?? this.role,
    permissions: permissions ?? this.permissions,
    isActive: isActive ?? this.isActive, lastLogin: lastLogin ?? this.lastLogin,
  );
}

// ─── Auto Reply Rule ──────────────────────────────────────────────
class AutoReplyRule {
  final String id;
  final String keyword;
  final String response;
  final List<AppRole> targetRoles; // empty = all
  final bool isActive;
  final int priority; // higher = checked first

  const AutoReplyRule({
    required this.id, required this.keyword, required this.response,
    this.targetRoles = const [], this.isActive = true, this.priority = 0,
  });

  AutoReplyRule copyWith({
    String? id, String? keyword, String? response,
    List<AppRole>? targetRoles, bool? isActive, int? priority,
  }) => AutoReplyRule(
    id: id ?? this.id, keyword: keyword ?? this.keyword,
    response: response ?? this.response,
    targetRoles: targetRoles ?? this.targetRoles,
    isActive: isActive ?? this.isActive, priority: priority ?? this.priority,
  );
}

// ─── Compensation ─────────────────────────────────────────────────
enum CompensationType { walletCredit, subscriptionDays, coupon, manualRefund }

extension CompensationTypeX on CompensationType {
  String get arabicLabel => switch (this) {
    CompensationType.walletCredit => 'رصيد محفظة',
    CompensationType.subscriptionDays => 'أيام اشتراك مجانية',
    CompensationType.coupon => 'كوبون خصم',
    CompensationType.manualRefund => 'استرداد يدوي',
  };
}

class CompensationModel {
  final String id;
  final String userId;
  final String userName;
  final CompensationType type;
  final double? amount;
  final int? subscriptionDays;
  final String? couponCode;
  final String reason;
  final String issuedBy; // staff id
  final String issuedByName;
  final DateTime issuedAt;

  const CompensationModel({
    required this.id, required this.userId, required this.userName,
    required this.type, this.amount, this.subscriptionDays,
    this.couponCode, required this.reason,
    required this.issuedBy, required this.issuedByName,
    required this.issuedAt,
  });
}

// ─── Subscription Extended ────────────────────────────────────────
enum SubscriptionSource { userPaid, adminGranted, trial, promo }

class AdminSubscriptionEntry {
  final String userId;
  final String userName;
  final String userEmail;
  final AppRole userRole;
  // tier info comes from subscription_provider per user
  final SubscriptionSource source;
  final int? grantedDays;
  final String? grantedBy;
  final String? grantReason;
  final DateTime grantedAt;
  final DateTime? expiresAt;

  const AdminSubscriptionEntry({
    required this.userId, required this.userName, required this.userEmail,
    required this.userRole, required this.source,
    this.grantedDays, this.grantedBy, this.grantReason,
    required this.grantedAt, this.expiresAt,
  });
}

// ─── Support Ticket enhanced ──────────────────────────────────────
enum TicketPriority { low, normal, high, urgent }

extension TicketPriorityX on TicketPriority {
  String get arabicLabel => switch (this) {
    TicketPriority.low => 'منخفض',
    TicketPriority.normal => 'عادي',
    TicketPriority.high => 'عالي',
    TicketPriority.urgent => 'عاجل',
  };
  Color get color => switch (this) {
    TicketPriority.low => const Color(0xFF94A3B8),
    TicketPriority.normal => const Color(0xFF4F46E5),
    TicketPriority.high => const Color(0xFFF59E0B),
    TicketPriority.urgent => const Color(0xFFEF4444),
  };
}



