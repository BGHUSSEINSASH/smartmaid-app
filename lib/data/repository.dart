import 'package:shared_preferences/shared_preferences.dart';

import '../core/api/api_client.dart';
import '../core/session/session_store.dart';

/// Remote trust & operations services with graceful demo fallback.
/// Every call degrades silently to demo behavior when the backend is
/// unreachable (mirrors ApiClient's demo-first philosophy).
class TrustRepository {
  TrustRepository._();

  // ---------- SOS ----------

  /// Sends an emergency alert. Returns the hot-line message on success.
  static Future<({bool ok, String message, String alertId})> sendSos({
    required String location,
    String message = 'طلب طوارئ',
  }) async {
    await _auth();
    final res = await ApiClient.post('/sos', {
      'location': location,
      'message': message,
    });
    if (res != null && res['ok'] == true) {
      return (
        ok: true,
        message: res['message']?.toString() ??
            'تم إرسال تنبيه الطوارئ — تواصل مع الخط الساخن: 911',
        alertId: res['alertId']?.toString() ?? '',
      );
    }
    return (
      ok: true,
      message: 'وضع تجريبي: تم تسجيل تنبيه الطوارئ محلياً — الخط الساخن: 911',
      alertId: 'sos_demo_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  // ---------- KYC ----------

  static Future<({bool ok, String message})> submitKyc({
    required String fullName,
    required String nationalId,
    String? selfieUrl,
  }) async {
    await _auth();
    final res = await ApiClient.post('/kyc/verify', {
      'fullName': fullName,
      'nationalId': nationalId,
      'selfieUrl': ?selfieUrl,
    });
    if (res != null && res['ok'] == true) {
      await _persistKycStatus('pending');
      return (
        ok: true,
        message: res['message']?.toString() ??
            'تم إرسال بيانات التحقق — ستتم المراجعة خلال 24 ساعة',
      );
    }
    await _persistKycStatus('pending');
    return (ok: true, message: 'وضع تجريبي: تم إرسال طلب التوثيق للمراجعة');
  }

  static Future<({String status, bool verified})> kycStatus() async {
    await _auth();
    final res = await ApiClient.get('/kyc/status');
    if (res != null && res['status'] != null) {
      final status = res['status'].toString();
      await _persistKycStatus(status);
      return (status: status, verified: res['verified'] == true);
    }
    final cached = await _loadKycStatus();
    return (status: cached, verified: cached == 'approved');
  }

  static const _kKycKey = 'sm.kyc.status';

  static Future<void> _persistKycStatus(String status) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_kKycKey, status);
    } catch (_) {}
  }

  static Future<String> _loadKycStatus() async {
    try {
      final sp = await SharedPreferences.getInstance();
      return sp.getString(_kKycKey) ?? 'none';
    } catch (_) {
      return 'none';
    }
  }
  // ---------- Settlements ----------

  static Future<List<SettlementRecord>> settlementHistory() async {
    await _auth();
    final res = await ApiClient.get(
      '/settlements/history',
      timeout: const Duration(seconds: 5),
    );
    if (res != null && res['records'] is List) {
      final list = (res['records'] as List)
          .whereType<Map<String, dynamic>>()
          .map(SettlementRecord.fromJson)
          .toList();
      if (list.isNotEmpty) return list;
    }
    // Demo fallback mirrors backend seed data
    return List.generate(3, (i) {
      final total = 1200.0 + i * 180;
      return SettlementRecord(
        month: DateTime(DateTime.now().year, DateTime.now().month - i)
            .toIso8601String()
            .substring(0, 7),
        totalEarnings: total,
        platformFee: total * 0.20,
        netPayout: total * 0.80,
        bookingsCount: 8 + i * 2,
        settled: true,
      );
    });
  }

  // ---------- AI Assistant ----------

  /// Sends a chat message to the backend AI endpoint (Ollama-backed with
  /// deterministic fallback). Returns null when the backend is unreachable
  /// so callers can use the local keyword engine.
  static Future<String?> askAi(String message) async {
    await _auth();
    final res = await ApiClient.post(
      '/ai/chat',
      {'message': message},
      timeout: const Duration(seconds: 22),
    );
    if (res != null && res['reply'] != null) {
      return res['reply'].toString();
    }
    return null;
  }

  // ---------- Disputes ----------

  static Future<({bool ok, String message})> openDispute({
    required String bookingId,
    required String category,
    required String subject,
    required String detail,
  }) async {
    await _auth();
    final res = await ApiClient.post('/disputes', {
      'bookingId': bookingId,
      'category': category,
      'subject': subject,
      'detail': detail,
    });
    if (res != null && res['ok'] == true) {
      return (ok: true, message: 'تم فتح النزاع وسيصلحه فريقنا خلال 48 ساعة');
    }
    return (
      ok: true,
      message: 'وضع تجريبي: تم تسجيل النزاع وسيصلحه فريقنا خلال 48 ساعة',
    );
  }

  static Future<void> _auth() async {
    final token = await SessionStore.loadToken();
    if (token != null) ApiClient.setToken(token);
  }
}

class SettlementRecord {
  final String month;
  final double totalEarnings;
  final double platformFee;
  final double netPayout;
  final int bookingsCount;
  final bool settled;

  const SettlementRecord({
    required this.month,
    required this.totalEarnings,
    required this.platformFee,
    required this.netPayout,
    required this.bookingsCount,
    this.settled = true,
  });

  factory SettlementRecord.fromJson(Map<String, dynamic> j) =>
      SettlementRecord(
        month: j['month']?.toString() ?? '',
        totalEarnings: (j['totalEarnings'] as num?)?.toDouble() ?? 0,
        platformFee: (j['platformFee'] as num?)?.toDouble() ?? 0,
        netPayout: (j['netPayout'] as num?)?.toDouble() ?? 0,
        bookingsCount: (j['bookingsCount'] as num?)?.toInt() ?? 0,
        settled: j['settled'] == true,
      );
}
