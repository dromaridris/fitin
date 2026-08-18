import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Permanent, offline FITIN licensing.
///
/// A private Ed25519 key is kept only in the owner's License Manager.
/// The app embeds the matching public key and can VERIFY licenses, but it
/// cannot generate valid licenses itself.
class LicenseService {
  static const _installIdKey = 'fitin_install_id_v2';
  static const _licenseKey = 'fitin_offline_license_v1';

  // Ed25519 public key matching the private key in FITIN_License_Manager.html.
  // Public keys are safe to embed in the application.
  static const _publicKeyBase64 =
      'LKC7e4RQStuXeKDbO4VQpJ7Ig8vWXUj2JWDUjarTc0U=';

  static final Ed25519 _algorithm = Ed25519();

  /// Stable for this installation. Reinstalling/clearing app data intentionally
  /// creates a new installation ID and therefore a new device code.
  static Future<String> _installId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_installIdKey);
    if (id == null || id.length < 16) {
      id = const Uuid().v4();
      await prefs.setString(_installIdKey, id);
    }
    return id;
  }

  /// Human-friendly code the customer sends to the app owner.
  /// Example: A1B2-C3D4-E5F6-7890-ABCD
  static Future<String> deviceCode() async {
    final raw = (await _installId()).replaceAll('-', '').toUpperCase();
    final code = raw.substring(0, 20);
    return [
      code.substring(0, 4),
      code.substring(4, 8),
      code.substring(8, 12),
      code.substring(12, 16),
      code.substring(16, 20),
    ].join('-');
  }

  static Future<String?> storedLicense() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_licenseKey);
  }

  /// Compatibility for the API client. Offline licensing no longer sends
  /// license tokens or device IDs to a server.
  static Future<Map<String, String>> authHeaders() async => <String, String>{};

  static Future<bool> validate() async {
    final license = await storedLicense();
    if (license == null || license.trim().isEmpty) return false;
    return verifyLicense(license);
  }

  static Future<void> activate(String licenseKey) async {
    final normalized = licenseKey.trim();
    if (!await verifyLicense(normalized)) {
      throw Exception('Invalid license for this device.');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_licenseKey, normalized);
  }

  static Future<bool> verifyLicense(String licenseKey) async {
    try {
      final parts = licenseKey.trim().split('.');
      if (parts.length != 3 || parts[0] != 'FITIN1') return false;

      final licensedDevice = parts[1].toUpperCase();
      final currentDevice = (await deviceCode()).toUpperCase();
      if (licensedDevice != currentDevice) return false;

      final signatureBytes = _decodeBase64Url(parts[2]);
      if (signatureBytes.length != 64) return false;

      final publicKeyBytes = base64Decode(_publicKeyBase64);
      final publicKey = SimplePublicKey(
        publicKeyBytes,
        type: KeyPairType.ed25519,
      );
      final signature = Signature(signatureBytes, publicKey: publicKey);
      final message = utf8.encode(_messageFor(licensedDevice));

      return await _algorithm.verify(message, signature: signature);
    } catch (_) {
      return false;
    }
  }

  static String _messageFor(String deviceCode) =>
      'FITIN|1|${deviceCode.toUpperCase()}|PERMANENT';

  static List<int> _decodeBase64Url(String value) {
    var normalized = value.replaceAll('-', '+').replaceAll('_', '/');
    while (normalized.length % 4 != 0) {
      normalized += '=';
    }
    return base64Decode(normalized);
  }

  /// For support/testing: clears the local activation only. It does not change
  /// the installation ID, so the same signed license can reactivate the app.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_licenseKey);
  }
}
