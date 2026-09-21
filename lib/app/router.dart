import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/login_page.dart';
import '../features/home/dashboard_page.dart';
import '../features/appointments/booking_page.dart';
import '../features/appointments/appointments_page.dart';
import '../features/profile/profile_page.dart';

final routerProvider = Provider<GoRouter>((ref) => GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
    GoRoute(path: '/appointments', builder: (_, __) => const AppointmentsPage()),
    GoRoute(path: '/book', builder: (_, __) => const BookingPage()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
  ],
));
