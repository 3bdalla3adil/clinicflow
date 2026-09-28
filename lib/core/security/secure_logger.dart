import 'package:logger/logger.dart';
import 'phi_redactor.dart';

class SecureLogger {
  static SecureLogger? _i;
  static SecureLogger get instance => _i ??= SecureLogger._();
  late final Logger _log;
  bool _ready = false;
  SecureLogger._();

  Future<void> init() async {
    _log = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        lineLength: 100,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      filter: _ProductionFilter(),
    );
    _ready = true;
  }

  void info(String m) {
    if (_ready) _log.i(PhiRedactor.redact(m));
  }

  void debug(String m) {
    if (_ready) _log.d(PhiRedactor.redact(m));
  }

  void warning(String m) {
    if (_ready) _log.w(PhiRedactor.redact(m));
  }

  void error(String m, [dynamic e, StackTrace? s]) {
    if (_ready) {
      _log.e(
        PhiRedactor.redact(m),
        error: e?.runtimeType,
        stackTrace: s,
      );
    }
  }

  void audit(String event) {
    if (_ready) _log.i('[AUDIT] ${PhiRedactor.redact(event)}');
  }
}

class _ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    const isProd = bool.fromEnvironment('dart.vm.product');
    return isProd ? event.level.index >= Level.warning.index : true;
  }
}
