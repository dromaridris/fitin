import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../config/app_config.dart';

class LicenseService {
  static const _deviceIdKey = 'fitin_device_id_v1';
  static const _tokenKey = 'fitin_license_token_v1';

  static Future<String> deviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_deviceIdKey);
    if (id == null || id.length < 16) {
      id = const Uuid().v4();
      await prefs.setString(_deviceIdKey, id);
    }
    return id;
  }

  static Future<String?> token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<Map<String, String>> authHeaders() async {
    final id = await deviceId();
    final t = await token();
    if (t == null || t.isEmpty) return {'X-FITIN-Device-ID': id};
    return {
      'X-FITIN-Device-ID': id,
      'X-FITIN-License-Token': t,
    };
  }

  static Future<bool> validate() async {
    final t = await token();
    if (t == null || t.isEmpty) return false;
    final id = await deviceId();
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/license/validate'),
        headers: {
          'Content-Type': 'application/json',
          'X-FITIN-License-Token': t,
        },
        body: jsonEncode({'device_id': id}),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  static Future<void> activate(String licenseKey) async {
    final id = await deviceId();
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/license/activate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'license_key': licenseKey.trim(),
        'device_id': id,
      }),
    );
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map
          ? (decoded['detail'] ?? 'License activation failed.').toString()
          : 'License activation failed.';
      throw Exception(message);
    }
    final token = decoded?['data']?['activation_token']?.toString();
    if (token == null || token.isEmpty) {
      throw Exception('The server did not return an activation token.');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
