import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/storage_keys.dart';
import '../security/secure_logger.dart';

class DatabaseInitializer {
  static Future<void> init() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(dir.path);
      await Future.wait([
        Hive.openBox<dynamic>(StorageKeys.settingsBox),
        Hive.openBox<dynamic>(StorageKeys.userBox),
        Hive.openBox<dynamic>(StorageKeys.appointmentsBox),
        Hive.openBox<dynamic>(StorageKeys.doctorsBox),
        Hive.openBox<dynamic>(StorageKeys.medicalRecordsBox),
        Hive.openBox<dynamic>(StorageKeys.prescriptionsBox),
        Hive.openBox<dynamic>(StorageKeys.syncQueueBox),
        Hive.openBox<dynamic>(StorageKeys.cacheMetaBox),
      ]);
      SecureLogger.instance.info('Database initialized');
    } catch (e) {
      SecureLogger.instance.error('Database init failed', e);
      rethrow;
    }
  }

  static Future<void> clearAll() async {
    for (final box in Hive.boxes.values) {
      await box.clear();
    }
  }
}
