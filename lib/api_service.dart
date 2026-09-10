import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static const _tokenKey = 'auth_token';

  static Future<String?> get token async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final t = await token;
      if (t != null) headers['Authorization'] = 'Bearer $t';
    }
    return headers;
  }

  static Map<String, dynamic> _decode(http.Response res) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Unexpected server response (HTTP ${res.statusCode}).');
    }
    if (res.statusCode >= 400 || body['success'] == false) {
      throw ApiException(body['message'] ?? 'Something went wrong.');
    }
    return body;
  }

  static Future<Map<String, dynamic>> get(String path, {bool auth = false}) async {
    final res = await http.get(Uri.parse('${AppConfig.apiUrl}/$path'), headers: await _headers(auth: auth));
    return _decode(res);
  }

  static Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data, {bool auth = false}) async {
    final res = await http.post(
      Uri.parse('${AppConfig.apiUrl}/$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(data),
    );
    return _decode(res);
  }
}
