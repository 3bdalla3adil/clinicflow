import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';
import 'secure_logger.dart';

class SecureStorageService {
  static const _androidOpts = AndroidOptions(
    encryptedSharedPreferences: true,
  );
  static const _iosOpts = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
    synchronizable: false,
  );

  final _storage = const FlutterSecureStorage(
    aOptions: _androidOpts,
    iOptions: _iosOpts,
  );

  Future<void> saveAccessToken(String t) => _w(StorageKeys.accessToken, t);
  Future<String?> getAccessToken() => _r(StorageKeys.accessToken);
  Future<void> saveRefreshToken(String t) =>
      _w(StorageKeys.refreshToken, t);
  Future<String?> getRefreshToken() => _r(StorageKeys.refreshToken);
  Future<void> saveUserId(String id) => _w(StorageKeys.userId, id);
  Future<String?> getUserId() => _r(StorageKeys.userId);
  Future<void> saveUserRole(String role) => _w(StorageKeys.userRole, role);
  Future<String?> getUserRole() => _r(StorageKeys.userRole);
  Future<void> saveEncryptionKey(String key) =>
      _w(StorageKeys.encryptionKey, key);
  Future<String?> getEncryptionKey() => _r(StorageKeys.encryptionKey);
  Future<void> setBiometricEnabled(bool v) =>
      _w(StorageKeys.biometricEnabled, v.toString());
  Future<bool> isBiometricEnabled() async =>
      (await _r(StorageKeys.biometricEnabled)) == 'true';

  Future<void> clearAuthData() async {
    await _d(StorageKeys.accessToken);
    await _d(StorageKeys.refreshToken);
    await _d(StorageKeys.sessionId);
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (_) {
      SecureLogger.instance.warning('SecureStorage clearAll failed');
    }
  }

  Future<void> _w(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      SecureLogger.instance.warning('SecureStorage write failed: $key');
    }
  }

  Future<String?> _r(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      SecureLogger.instance.warning('SecureStorage read failed: $key');
      return null;
    }
  }

  Future<void> _d(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {}
  }
}
