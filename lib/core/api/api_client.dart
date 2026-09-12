import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000/api/v1',
  );

  static const bool demoOnly = bool.fromEnvironment('USE_DEMO_ONLY');

  static String? _token;
  static void setToken(String? t) => _token = t;

  static Future<Map<String, dynamic>?> get(
    String path, {
    Duration timeout = const Duration(seconds: 4),
  }) async {
    if (demoOnly) return null;
    try {
      final res = await http
          .get(_uri(path), headers: _headers())
          .timeout(timeout);
      return _decode(res);
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> post(
    String path,
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 6),
  }) async {
    if (demoOnly) return null;
    try {
      final res = await http
          .post(_uri(path), headers: _headers(), body: jsonEncode(body))
          .timeout(timeout);
      return _decode(res);
    } catch (_) {
      return null;
    }
  }

  static Uri _uri(String path) =>
      Uri.parse(baseUrl.endsWith('/') ? '$baseUrl$path' : '$baseUrl/$path');

  static Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static Map<String, dynamic>? _decode(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static bool get likelyReachable => !demoOnly;
}
