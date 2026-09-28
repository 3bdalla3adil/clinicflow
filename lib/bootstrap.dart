import 'package:flutter/widgets.dart';
import 'core/di/dependency_injection.dart';
import 'core/security/secure_logger.dart';
import 'core/storage/database_initializer.dart';
import 'app/app.dart';

Future<void> bootstrap() async {
  await SecureLogger.instance.init();
  await DatabaseInitializer.init();
  await configureDependencies();
  SecureLogger.instance.info('ClinicFlow bootstrap complete');
  runApp(const ClinicFlowApp());
}
