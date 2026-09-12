import '../../../core/api/api_client.dart';
import '../../../data/demo_data.dart';
import '../../../data/models.dart';

/// نتيجة عملية مصادقة موحّدة.
class AuthResult {
  final AppUser? user;
  final String? token;
  final String? error;

  const AuthResult({this.user, this.token, this.error});

  bool get ok => user != null && error == null;

  factory AuthResult.success(AppUser user, {String? token}) =>
      AuthResult(user: user, token: token ?? 'local-token-${user.id}');

  factory AuthResult.failure(String error) => AuthResult(error: error);
}

/// واجهة مجرّدة للمصادقة — يمكن استبدال التطبيق المحلي بـ Firebase لاحقاً
/// دون تغيير أي شيء في طبقة الـ providers أو الواجهة.
abstract class AuthService {
  Future<AuthResult> signInWithEmail(String email, String password);
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    required AppRole role,
    String phone,
    Map<String, dynamic> extraData,
  });
  Future<AuthResult> signInWithGoogle();
  Future<AuthResult> signInWithApple();

  /// يرسل رمز التحقق إلى البريد (محاكاة). يعيد الرمز في وضع التطوير.
  Future<AuthResult> sendPasswordReset(String email);

  /// يتحقق من الرمز ويعيّن كلمة مرور جديدة.
  Future<AuthResult> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}

/// تطبيق محلي يعمل 100% بدون شبكة — مبني على الحسابات التجريبية،
/// مع دعم إنشاء حسابات جديدة في الذاكرة أثناء الجلسة.
class MockAuthService implements AuthService {
  MockAuthService();

  static const _delay = Duration(milliseconds: 700);

  // الحسابات المعروفة (بريد -> (مستخدم، كلمة مرور)).
  final Map<String, (AppUser, String)> _accounts = {
    DemoData.customer.email.toLowerCase(): (DemoData.customer, 'Passw0rd!'),
    DemoData.workerUser.email.toLowerCase(): (DemoData.workerUser, 'Passw0rd!'),
    DemoData.admin.email.toLowerCase(): (DemoData.admin, 'Passw0rd!'),
    DemoData.companyUser.email.toLowerCase(): (DemoData.companyUser, 'Passw0rd!'),
  };

  // رموز إعادة التعيين المؤقتة (بريد -> رمز).
  final Map<String, String> _resetCodes = {};

  String _imageForRole(AppRole role) {
    switch (role) {
      case AppRole.worker:
        return DemoData.workerUser.imageUrl;
      case AppRole.company:
        return DemoData.companyUser.imageUrl;
      case AppRole.admin:
        return DemoData.admin.imageUrl;
      case AppRole.customer:
        return DemoData.customer.imageUrl;
    }
  }

  bool _validEmail(String email) =>
      RegExp(r'^[\w.\-]+@[\w\-]+\.[\w.\-]+$').hasMatch(email.trim());

  AppRole _roleFromString(String? v) {
    switch ((v ?? '').toLowerCase()) {
      case 'worker':
        return AppRole.worker;
      case 'admin':
        return AppRole.admin;
      case 'company':
        return AppRole.company;
      default:
        return AppRole.customer;
    }
  }

  /// يحوّل استجابة الـ backend إلى AppResult.
  AuthResult _fromApi(Map<String, dynamic> res, {required String email}) {
    final u = res['user'] as Map<String, dynamic>?;
    if (u == null) return AuthResult.failure('استجابة غير صالحة من الخادم');
    final role = _roleFromString(u['role']?.toString());
    final user = AppUser(
      id: u['id']?.toString() ?? '',
      name: u['name']?.toString() ?? '',
      email: u['email']?.toString() ?? email.trim(),
      imageUrl: _imageForRole(role),
      role: role,
    );
    return AuthResult.success(user, token: res['token']?.toString());
  }

  @override
  Future<AuthResult> signInWithEmail(String email, String password) async {
    // نحاول الـ backend أولاً، ثم نرجع للحسابات المحلية عند الفشل.
    final api = await ApiClient.post('/auth/login', {
      'email': email.trim(),
      'password': password,
    });
    if (api != null && api['user'] != null) {
      return _fromApi(api, email: email);
    }
    await Future.delayed(_delay);
    final key = email.trim().toLowerCase();
    if (!_validEmail(email)) {
      return AuthResult.failure('صيغة البريد الإلكتروني غير صحيحة');
    }
    final entry = _accounts[key];
    if (entry == null) {
      return AuthResult.failure('لا يوجد حساب بهذا البريد الإلكتروني');
    }
    if (entry.$2 != password) {
      return AuthResult.failure('كلمة المرور غير صحيحة');
    }
    return AuthResult.success(entry.$1);
  }

  @override
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
    required AppRole role,
    String phone = '',
    Map<String, dynamic> extraData = const {},
  }) async {
    final api = await ApiClient.post('/auth/register', {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      'role': role.name,
    });
    if (api != null && api['user'] != null) {
      return _fromApi(api, email: email);
    }
    await Future.delayed(_delay);
    final key = email.trim().toLowerCase();
    if (name.trim().length < 2) {
      return AuthResult.failure('الرجاء إدخال الاسم كاملاً');
    }
    if (!_validEmail(email)) {
      return AuthResult.failure('صيغة البريد الإلكتروني غير صحيحة');
    }
    if (password.length < 8) {
      return AuthResult.failure('كلمة المرور يجب أن تكون 8 أحرف على الأقل');
    }
    if (_accounts.containsKey(key)) {
      return AuthResult.failure('هذا البريد مسجّل مسبقاً، سجّل الدخول');
    }
    final user = AppUser(
      id: 'new-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      imageUrl: _imageForRole(role),
      role: role,
      phone: phone,
      joinedAt: DateTime.now(),
      customerInfo: role == AppRole.customer ? CustomerInfo(
        nationality: extraData['nationality']?.toString() ?? '',
        gender: extraData['gender']?.toString() ?? '',
        referralCode: extraData['referralCode']?.toString(),
      ) : null,
      workerInfo: role == AppRole.worker ? WorkerInfo(
        nationality: extraData['nationality']?.toString() ?? '',
        passportNumber: extraData['passportNumber']?.toString() ?? '',
        passportExpiry: extraData['passportExpiry']?.toString() ?? '',
        skills: (extraData['skills'] as List?)?.cast<String>() ?? [],
        experienceYears: extraData['experienceYears'] is int
            ? extraData['experienceYears'] as int : 0,
        bio: extraData['bio']?.toString() ?? '',
        hourlyRate: (extraData['hourlyRate'] as num?)?.toDouble() ?? 0,
        dailyRate: (extraData['dailyRate'] as num?)?.toDouble() ?? 0,
        monthlyRate: (extraData['monthlyRate'] as num?)?.toDouble() ?? 0,
        bankName: extraData['bankName']?.toString() ?? '',
        iban: extraData['iban']?.toString() ?? '',
        kycStatus: KycStatus.pending,
      ) : null,
      companyInfo: role == AppRole.company ? CompanyInfo(
        companyName: extraData['companyName']?.toString() ?? '',
        commercialRegNo: extraData['commercialRegNo']?.toString() ?? '',
        city: extraData['city']?.toString() ?? '',
        address: extraData['address']?.toString() ?? '',
        contactPerson: extraData['contactPerson']?.toString() ?? '',
        subscriptionPlan: SubscriptionPlan.values.firstWhere(
          (p) => p.name == extraData['subscriptionPlan'],
          orElse: () => SubscriptionPlan.basic),
        status: AccountStatus.suspended, // تنتظر موافقة المدير
      ) : null,
    );
    _accounts[key] = (user, password);
    return AuthResult.success(user);
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    await Future.delayed(_delay);
    // محاكاة: يعيد حساب العميل التجريبي كأنه ناتج Google.
    return AuthResult.success(DemoData.customer, token: 'google-mock-token');
  }

  @override
  Future<AuthResult> signInWithApple() async {
    await Future.delayed(_delay);
    return AuthResult.success(DemoData.customer, token: 'apple-mock-token');
  }

  @override
  Future<AuthResult> sendPasswordReset(String email) async {
    final api = await ApiClient.post('/auth/forgot-password', {
      'email': email.trim(),
    });
    if (api != null) {
      final devCode = api['devCode']?.toString();
      _resetCodes[email.trim().toLowerCase()] = devCode ?? '';
      return AuthResult(token: devCode);
    }
    await Future.delayed(_delay);
    final key = email.trim().toLowerCase();
    if (!_validEmail(email)) {
      return AuthResult.failure('صيغة البريد الإلكتروني غير صحيحة');
    }
    if (!_accounts.containsKey(key)) {
      return AuthResult.failure('لا يوجد حساب بهذا البريد الإلكتروني');
    }
    // رمز ثابت في وضع التطوير لسهولة الاختبار.
    _resetCodes[key] = '1234';
    return const AuthResult(token: '1234'); // الرمز في التوكن (تطوير فقط)
  }

  @override
  Future<AuthResult> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final api = await ApiClient.post('/auth/reset-password', {
      'email': email.trim(),
      'code': code.trim(),
      'newPassword': newPassword,
    });
    if (api != null) {
      final key = email.trim().toLowerCase();
      _resetCodes.remove(key);
      final existing = _accounts[key];
      return AuthResult.success(existing?.$1 ?? DemoData.customer);
    }
    await Future.delayed(_delay);
    final key = email.trim().toLowerCase();
    if (_resetCodes[key] != code.trim()) {
      return AuthResult.failure('رمز التحقق غير صحيح');
    }
    if (newPassword.length < 8) {
      return AuthResult.failure('كلمة المرور يجب أن تكون 8 أحرف على الأقل');
    }
    final existing = _accounts[key];
    if (existing == null) {
      return AuthResult.failure('لا يوجد حساب بهذا البريد');
    }
    _accounts[key] = (existing.$1, newPassword);
    _resetCodes.remove(key);
    return AuthResult.success(existing.$1);
  }
}
