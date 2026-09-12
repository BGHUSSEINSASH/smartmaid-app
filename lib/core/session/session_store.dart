import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models.dart';

class SessionStore {
  SessionStore._();

  static const _kUser = 'smart_maid.session.user';
  static const _kToken = 'smart_maid.session.token';

  static Future<AppUser?> loadUser() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_kUser);
      if (raw == null) return null;
      return _userFromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveUser(AppUser user, {String? token}) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_kUser, jsonEncode(_userToJson(user)));
      if (token != null) await sp.setString(_kToken, token);
    } catch (_) {}
  }

  static Future<String?> loadToken() async {
    try {
      final sp = await SharedPreferences.getInstance();
      return sp.getString(_kToken);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_kUser);
      await sp.remove(_kToken);
    } catch (_) {}
  }

  static Map<String, dynamic> _userToJson(AppUser u) => {
    'id': u.id,
    'name': u.name,
    'email': u.email,
    'imageUrl': u.imageUrl,
    'role': u.role.name,
    'phone': u.phone,
    'location': u.location,
  };

  static AppUser _userFromJson(Map<String, dynamic> j) => AppUser(
    id: j['id']?.toString() ?? '',
    name: j['name']?.toString() ?? '',
    email: j['email']?.toString() ?? '',
    imageUrl: j['imageUrl']?.toString() ?? '',
    role: AppRole.values.firstWhere(
      (r) => r.name == j['role'],
      orElse: () => AppRole.customer,
    ),
    phone: j['phone']?.toString() ?? '',
    location: j['location']?.toString() ?? '',
  );
}

mixin SettingsPersistence {
  static const kDark = 'smart_maid.settings.dark';
  static const kLang = 'smart_maid.settings.lang';
  static const kNotif = 'smart_maid.settings.notif';
  static const kCurrency = 'smart_maid.settings.currency';
  static const kOnboarded = 'smart_maid.onboarding.done';
  static const kSystem = 'smart_maid.settings.system';

  static Future<void> saveBool(String key, bool v) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setBool(key, v);
    } catch (_) {}
  }

  static Future<void> saveString(String key, String v) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(key, v);
    } catch (_) {}
  }

  static Future<bool> loadBool(String key, {bool fallback = false}) async {
    try {
      final sp = await SharedPreferences.getInstance();
      return sp.getBool(key) ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  static Future<String> loadString(String key, {String fallback = ''}) async {
    try {
      final sp = await SharedPreferences.getInstance();
      return sp.getString(key) ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  static Future<void> saveDouble(String key, double v) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setDouble(key, v);
    } catch (_) {}
  }

  static Future<double> loadDouble(String key, {double fallback = 0.0}) async {
    try {
      final sp = await SharedPreferences.getInstance();
      return sp.getDouble(key) ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}

