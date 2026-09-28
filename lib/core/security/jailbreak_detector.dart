import 'dart:io';

/// Jailbreak/root detection — extension point.
/// Production: integrate flutter_jailbreak_detection or freeRASP.
class JailbreakDetector {
  static Future<bool> isCompromised() async {
    if (Platform.isAndroid) return _checkAndroid();
    if (Platform.isIOS) return _checkIos();
    return false;
  }

  static Future<bool> _checkAndroid() async {
    final paths = [
      '/system/app/Superuser.apk',
      '/sbin/su',
      '/system/bin/su',
      '/system/xbin/su',
      '/data/local/xbin/su',
      '/data/local/bin/su',
    ];
    for (final path in paths) {
      if (await File(path).exists()) return true;
    }
    return false;
  }

  static Future<bool> _checkIos() async {
    final paths = [
      '/Applications/Cydia.app',
      '/Library/MobileSubstrate/MobileSubstrate.dylib',
      '/bin/bash',
      '/usr/sbin/sshd',
      '/etc/apt',
      '/private/var/lib/apt/',
    ];
    for (final path in paths) {
      if (await File(path).exists()) return true;
    }
    return false;
  }
}
