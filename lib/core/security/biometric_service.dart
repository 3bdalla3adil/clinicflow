import 'package:local_auth/local_auth.dart';
import '../errors/exceptions.dart';
import 'secure_logger.dart';

class BiometricService {
  final _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      return await _auth.canCheckBiometrics &&
          await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> availableTypes() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  Future<bool> authenticate({
    String localizedReason = 'Authenticate to access ClinicFlow',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      SecureLogger.instance
          .warning('Biometric auth failed: ${e.runtimeType}');
      throw BiometricException(message: 'Biometric authentication failed');
    }
  }
}
