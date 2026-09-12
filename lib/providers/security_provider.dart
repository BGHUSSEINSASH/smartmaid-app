import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/security/security_store.dart';

class SecurityState {
  final bool lockEnabled;
  final bool biometricEnabled;
  final bool isUnlocked; // خلال الجلسة الحالية
  final bool loaded;

  const SecurityState({
    this.lockEnabled = false,
    this.biometricEnabled = false,
    this.isUnlocked = false,
    this.loaded = false,
  });

  SecurityState copyWith({
    bool? lockEnabled,
    bool? biometricEnabled,
    bool? isUnlocked,
    bool? loaded,
  }) =>
      SecurityState(
        lockEnabled: lockEnabled ?? this.lockEnabled,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        loaded: loaded ?? this.loaded,
      );

  /// هل يجب عرض شاشة القفل الآن؟
  bool get mustUnlock => lockEnabled && !isUnlocked;
}

class SecurityNotifier extends StateNotifier<SecurityState> {
  SecurityNotifier() : super(const SecurityState());

  Future<void> load() async {
    final enabled = await SecurityStore.isLockEnabled();
    final bio = await SecurityStore.biometricEnabled();
    state = state.copyWith(
      lockEnabled: enabled,
      biometricEnabled: bio,
      // إن كان القفل مفعّلاً يبدأ التطبيق مقفولاً.
      isUnlocked: !enabled,
      loaded: true,
    );
  }

  Future<bool> verifyPin(String pin) async {
    final ok = await SecurityStore.verifyPin(pin);
    if (ok) state = state.copyWith(isUnlocked: true);
    return ok;
  }

  Future<void> setPin(String pin) async {
    await SecurityStore.setPin(pin);
    state = state.copyWith(lockEnabled: true, isUnlocked: true);
  }

  Future<void> disableLock() async {
    await SecurityStore.disableLock();
    state = state.copyWith(lockEnabled: false, isUnlocked: true);
  }

  Future<void> setBiometric(bool v) async {
    await SecurityStore.setBiometric(v);
    state = state.copyWith(biometricEnabled: v);
  }

  /// يقفل التطبيق (عند العودة من الخلفية مثلاً أو يدوياً).
  void lock() {
    if (state.lockEnabled) state = state.copyWith(isUnlocked: false);
  }

  void unlock() => state = state.copyWith(isUnlocked: true);
}

final securityProvider =
    StateNotifierProvider<SecurityNotifier, SecurityState>(
  (ref) => SecurityNotifier(),
);
