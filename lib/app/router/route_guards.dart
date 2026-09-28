import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/security/secure_storage.dart';
import 'route_names.dart';

class AuthGuard {
  static Future<String?> redirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final storage = getIt<SecureStorageService>();
    final token = await storage.getAccessToken();
    final isAuth = token != null && token.isNotEmpty;
    final onAuthRoute = state.matchedLocation.startsWith('/auth') ||
        state.matchedLocation == RouteNames.splash;
    if (!isAuth && !onAuthRoute) return RouteNames.login;
    if (isAuth &&
        onAuthRoute &&
        state.matchedLocation != RouteNames.splash) {
      return RouteNames.patientDashboard;
    }
    return null;
  }
}
