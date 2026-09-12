import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/session/session_store.dart';
import '../data/demo_data.dart';
import '../data/models.dart';
import '../features/auth/data/auth_service.dart';
import 'audit_log_provider.dart';

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isLoggedIn => user != null;

  AuthState copyWith({AppUser? user, bool? isLoading, String? error}) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

final authServiceProvider = Provider<AuthService>((ref) => MockAuthService());

// OTP storage in-memory
final _phoneOtpCodes = <String, String>{};

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _service;
  final Ref _ref;
  AuthNotifier(this._service, this._ref) : super(const AuthState());

  Future<void> restoreSession() async {
    final user = await SessionStore.loadUser();
    final token = await SessionStore.loadToken();
    if (token != null) ApiClient.setToken(token);
    if (user != null) state = state.copyWith(user: user);
  }

  // ── Phone OTP auth ────────────────────────────────────────────

  /// يرسل OTP للرقم (محاكاة). يعيد رمز التطوير.
  Future<String?> sendPhoneOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 800));
    final code = (100000 + DateTime.now().millisecondsSinceEpoch % 900000)
        .toString()
        .substring(0, 6);
    _phoneOtpCodes[phone] = code;
    state = state.copyWith(isLoading: false);
    return code; // dev only
  }

  /// يتحقق من الـ OTP ويُسجّل الدخول.
  Future<bool> verifyPhoneOtp(String phone, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 600));
    final expected = _phoneOtpCodes[phone];
    if (expected == null || expected != code.trim()) {
      state = state.copyWith(isLoading: false, error: 'رمز التحقق غير صحيح');
      return false;
    }
    _phoneOtpCodes.remove(phone);
    final user = _findOrCreateByPhone(phone);
    return _apply(AuthResult.success(user));
  }

  AppUser _findOrCreateByPhone(String phone) {
    for (final u in [
      DemoData.customer,
      DemoData.workerUser,
      DemoData.admin,
      DemoData.companyUser,
    ]) {
      if (u.phone.replaceAll(' ', '') == phone.replaceAll(' ', '')) return u;
    }
    return AppUser(
      id: 'ph_${DateTime.now().millisecondsSinceEpoch}',
      name: 'مستخدم جديد',
      email: '$phone@phone.com',
      imageUrl: DemoData.customer.imageUrl,
      role: AppRole.customer,
      phone: phone,
      joinedAt: DateTime.now(),
    );
  }

  // ── Quick login by role (dev) ─────────────────────────────────
  Future<void> loginByRole(String role) async {
    final user = switch (role) {
      'worker' => DemoData.workerUser,
      'company' => DemoData.companyUser,
      'admin' => DemoData.admin,
      _ => DemoData.customer,
    };
    await loginAs(user);
  }

  // ── Email/password (legacy) ───────────────────────────────────
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final res = await _service.signInWithEmail(email, password);
    return _apply(res);
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required AppRole role,
    String phone = '',
    Map<String, dynamic> extraData = const {},
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final res = await _service.signUp(
      name: name,
      email: email,
      password: password,
      role: role,
      phone: phone,
      extraData: extraData,
    );
    return _apply(res);
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    return _apply(await _service.signInWithGoogle());
  }

  Future<bool> signInWithApple() async {
    state = state.copyWith(isLoading: true, error: null);
    return _apply(await _service.signInWithApple());
  }

  Future<String?> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    final res = await _service.sendPasswordReset(email);
    if (res.error != null) {
      state = state.copyWith(isLoading: false, error: res.error);
      return null;
    }
    state = state.copyWith(isLoading: false);
    return res.token;
  }

  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final res = await _service.resetPassword(
        email: email, code: code, newPassword: newPassword);
    if (res.error != null) {
      state = state.copyWith(isLoading: false, error: res.error);
      return false;
    }
    state = state.copyWith(isLoading: false);
    return true;
  }

  Future<bool> _apply(AuthResult res) async {
    if (res.ok) {
      ApiClient.setToken(res.token);
      await SessionStore.saveUser(res.user!, token: res.token);
      state = AuthState(user: res.user);
      _audit(
        AuditAction.sessionLogin,
        'دخول ${res.user!.name} (${res.user!.role.arabicLabel})',
        userId: res.user!.id,
      );
      return true;
    }
    state = state.copyWith(
        isLoading: false, error: res.error ?? 'تعذر تسجيل الدخول');
    return false;
  }

  void _audit(AuditAction action, String desc, {String? userId}) {
    try {
      _ref.read(auditLogProvider.notifier).log(action, desc, userId: userId);
    } catch (_) {}
  }

  Future<void> loginAs(AppUser user) async {
    await SessionStore.saveUser(user, token: 'demo-token-${user.id}');
    ApiClient.setToken('demo-token-${user.id}');
    state = AuthState(user: user);
  }

  Future<void> updateProfile(AppUser user) async {
    if (state.user == null) return;
    await SessionStore.saveUser(user);
    state = state.copyWith(user: user);
  }

  Future<void> logout() async {
    final u = state.user;
    if (u != null) {
      _audit(AuditAction.sessionLogout, 'خروج ${u.name}', userId: u.id);
    }
    ApiClient.setToken(null);
    await SessionStore.clear();
    state = const AuthState();
  }

  void clearError() => state = state.copyWith(error: null);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authServiceProvider), ref),
);
