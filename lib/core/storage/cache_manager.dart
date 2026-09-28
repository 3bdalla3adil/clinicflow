import 'package:hive/hive.dart';
import '../constants/storage_keys.dart';
import '../security/secure_logger.dart';

class CacheManager {
  Box<dynamic> get _meta => Hive.box(StorageKeys.cacheMetaBox);

  Future<void> write(
    String boxName,
    String key,
    dynamic value, {
    Duration? ttl,
  }) async {
    try {
      final box = Hive.box<dynamic>(boxName);
      await box.put(key, value);
      if (ttl != null) {
        await _meta.put(
          '$boxName:$key:expiry',
          DateTime.now().add(ttl).millisecondsSinceEpoch,
        );
      }
    } catch (e) {
      SecureLogger.instance.warning('CacheManager write failed: $key');
    }
  }

  T? read<T>(String boxName, String key) {
    try {
      if (_isExpired(boxName, key)) {
        invalidate(boxName, key);
        return null;
      }
      final box = Hive.box<dynamic>(boxName);
      return box.get(key) as T?;
    } catch (_) {
      return null;
    }
  }

  List<T> readAll<T>(String boxName) {
    try {
      final box = Hive.box<dynamic>(boxName);
      return box.values.whereType<T>().toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> invalidate(String boxName, String key) async {
    try {
      final box = Hive.box<dynamic>(boxName);
      await box.delete(key);
      await _meta.delete('$boxName:$key:expiry');
    } catch (_) {}
  }

  Future<void> clearBox(String boxName) async {
    try {
      await Hive.box<dynamic>(boxName).clear();
    } catch (_) {}
  }

  bool _isExpired(String boxName, String key) {
    final expiry = _meta.get('$boxName:$key:expiry') as int?;
    if (expiry == null) return false;
    return DateTime.now().millisecondsSinceEpoch > expiry;
  }
}
