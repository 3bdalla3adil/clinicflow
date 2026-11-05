import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../features/auth/login_page.dart';
import '../features/auth/guest_start_page.dart';
import '../features/home/dashboard_page.dart';
import '../features/appointments/booking_page.dart';
import '../features/appointments/appointments_page.dart';
import '../features/profile/profile_page.dart';
import '../features/settings/settings_page.dart';
import '../features/staff/staff_workspace_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.listen(currentUserProvider, (_, __) => refresh.refresh());

  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(currentUserProvider);
      // Do not redirect while Firebase is restoring an existing session or
      // resolving the profile document after sign-in / guest provisioning.
      if (session.isLoading) return null;

      final location = state.matchedLocation;
      final isAuthEntryRoute = location == '/login' || location == '/guest';
      // Settings is also intentionally reachable from the signed-out screen.
      final isAllowedWhileSignedOut =
          isAuthEntryRoute || location == '/settings';
      final user = session.valueOrNull;

      if (user == null && !isAllowedWhileSignedOut) return '/login';
      if (user != null && isAuthEntryRoute) {
        return '/dashboard';
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('ClinicFlow')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 12),
              const Text('This page could not be opened.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.go('/login'),
                child: const Text('Return to sign in'),
              ),
            ],
          ),
        ),
      ),
    ),
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/guest', builder: (_, __) => const GuestStartPage()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
      GoRoute(path: '/appointments', builder: (_, __) => const AppointmentsPage()),
      GoRoute(path: '/book', builder: (_, __) => const BookingPage()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      GoRoute(path: '/staff', builder: (_, __) => const StaffWorkspacePage()),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

class _RouterRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}
