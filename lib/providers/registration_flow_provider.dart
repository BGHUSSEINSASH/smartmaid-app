import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models.dart';

/// حالة تدفق التسجيل — تحمل البيانات المُدخلة عبر الخطوات
class RegistrationFlowState {
  final AppRole role;
  final int step;
  final bool isSocialFlow; // true = قادم من Google/Apple

  // بيانات مشتركة
  final String name;
  final String email;
  final String phone;
  final String password;

  // customer
  final String nationality;
  final String dateOfBirth;
  final String gender;
  final String referralCode;

  // worker
  final String passportNumber;
  final String passportExpiry;
  final List<String> skills;
  final int experienceYears;
  final String bio;
  final double hourlyRate;
  final double dailyRate;
  final double monthlyRate;
  final String bankName;
  final String iban;

  // company
  final String companyName;
  final String commercialRegNo;
  final String contactPerson;
  final String city;
  final String address;
  final SubscriptionPlan subscriptionPlan;

  const RegistrationFlowState({
    this.role = AppRole.customer,
    this.step = 0,
    this.isSocialFlow = false,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.nationality = '',
    this.dateOfBirth = '',
    this.gender = 'ذكر',
    this.referralCode = '',
    this.passportNumber = '',
    this.passportExpiry = '',
    this.skills = const [],
    this.experienceYears = 1,
    this.bio = '',
    this.hourlyRate = 30,
    this.dailyRate = 120,
    this.monthlyRate = 1500,
    this.bankName = '',
    this.iban = '',
    this.companyName = '',
    this.commercialRegNo = '',
    this.contactPerson = '',
    this.city = '',
    this.address = '',
    this.subscriptionPlan = SubscriptionPlan.basic,
  });

  RegistrationFlowState copyWith({
    AppRole? role,
    int? step,
    bool? isSocialFlow,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? nationality,
    String? dateOfBirth,
    String? gender,
    String? referralCode,
    String? passportNumber,
    String? passportExpiry,
    List<String>? skills,
    int? experienceYears,
    String? bio,
    double? hourlyRate,
    double? dailyRate,
    double? monthlyRate,
    String? bankName,
    String? iban,
    String? companyName,
    String? commercialRegNo,
    String? contactPerson,
    String? city,
    String? address,
    SubscriptionPlan? subscriptionPlan,
  }) =>
      RegistrationFlowState(
        role: role ?? this.role,
        step: step ?? this.step,
        isSocialFlow: isSocialFlow ?? this.isSocialFlow,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        password: password ?? this.password,
        nationality: nationality ?? this.nationality,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        gender: gender ?? this.gender,
        referralCode: referralCode ?? this.referralCode,
        passportNumber: passportNumber ?? this.passportNumber,
        passportExpiry: passportExpiry ?? this.passportExpiry,
        skills: skills ?? this.skills,
        experienceYears: experienceYears ?? this.experienceYears,
        bio: bio ?? this.bio,
        hourlyRate: hourlyRate ?? this.hourlyRate,
        dailyRate: dailyRate ?? this.dailyRate,
        monthlyRate: monthlyRate ?? this.monthlyRate,
        bankName: bankName ?? this.bankName,
        iban: iban ?? this.iban,
        companyName: companyName ?? this.companyName,
        commercialRegNo: commercialRegNo ?? this.commercialRegNo,
        contactPerson: contactPerson ?? this.contactPerson,
        city: city ?? this.city,
        address: address ?? this.address,
        subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      );
}

class RegistrationFlowNotifier
    extends StateNotifier<RegistrationFlowState> {
  RegistrationFlowNotifier() : super(const RegistrationFlowState());

  void reset([AppRole role = AppRole.customer]) =>
      state = RegistrationFlowState(role: role);

  void setRole(AppRole role) => state = state.copyWith(role: role, step: 0);
  void nextStep() => state = state.copyWith(step: state.step + 1);
  void prevStep() =>
      state = state.copyWith(step: (state.step - 1).clamp(0, 10));

  void update(RegistrationFlowState Function(RegistrationFlowState) fn) =>
      state = fn(state);
}

final registrationFlowProvider =
    StateNotifierProvider<RegistrationFlowNotifier, RegistrationFlowState>(
  (ref) => RegistrationFlowNotifier(),
);
