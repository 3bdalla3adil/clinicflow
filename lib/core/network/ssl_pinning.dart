import 'package:dio/dio.dart';

/// SSL Pinning — Extension Point.
/// To enable: load cert bytes from assets/certs/, create an HttpClient
/// with badCertificateCallback verifying against pinned certs, then
/// wrap in an IOHttpClientAdapter. Requires flutter_certificate_pinning or
/// manual X.509 comparison. Never disable for PHI traffic in production.
class SslPinning {
  static bool _enabled = false;

  static void configure(Dio dio, {bool enabled = false}) {
    _enabled = enabled;
    if (!_enabled) return;
    // TODO: Implement certificate pinning
    // dio.httpClientAdapter = IOHttpClientAdapter(
    //   createHttpClient: () {
    //     final client = HttpClient();
    //     client.badCertificateCallback = (cert, host, port) {
    //       // Compare cert.pem against pinned cert bytes
    //       return false;
    //     };
    //     return client;
    //   },
    // );
  }

  static bool get isEnabled => _enabled;
}
