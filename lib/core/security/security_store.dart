import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// تخزين آمن لإعدادات الأمان (قفل PIN). كلمة السر تُخزّن مجزّأة (SHA-256 + salt)
/// ولا تُحفظ أبداً بنص صريح.
class SecurityStore {
  SecurityStore._();

  static const _kEnabled = 'smart_maid.security.lock_enabled';
  static const _kHash = 'smart_maid.security.pin_hash';
  static const _kSalt = 'smart_maid.security.pin_salt';
  static const _kBiometric = 'smart_maid.security.biometric';

  static String _hash(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt::$pin')).toString();

  static String _newSalt() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(16) +
      (100000 + DateTime.now().millisecond).toString();

  static Future<bool> isLockEnabled() async {
    try {
      final sp = await SharedPreferences.getInstance();
      return sp.getBool(_kEnabled) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> hasPin() async {
    try {
      final sp = await SharedPreferences.getInstance();
      return sp.getString(_kHash) != null;
    } catch (_) {
      return false;
    }
  }

  /// يعيّن رمز PIN جديد ويفعّل القفل.
  static Future<void> setPin(String pin) async {
    final sp = await SharedPreferences.getInstance();
    final salt = _newSalt();
    await sp.setString(_kSalt, salt);
    await sp.setString(_kHash, _hash(pin, salt));
    await sp.setBool(_kEnabled, true);
  }

  static Future<bool> verifyPin(String pin) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final hash = sp.getString(_kHash);
      final salt = sp.getString(_kSalt);
      if (hash == null || salt == null) return false;
      return _hash(pin, salt) == hash;
    } catch (_) {
      return false;
    }
  }

  static Future<void> disableLock() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kEnabled, false);
    await sp.remove(_kHash);
    await sp.remove(_kSalt);
  }

  static Future<bool> biometricEnabled() async {
    try {
      final sp = await SharedPreferences.getInstance();
      return sp.getBool(_kBiometric) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setBiometric(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kBiometric, v);
  }
}
