import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/dashboard/presentation/pages/patient_dashboard_page.dart';
import '../../features/appointments/presentation/pages/appointments_page.dart';
import '../../features/appointments/presentation/pages/book_appointment_page.dart';
import '../../features/appointments/presentation/pages/appointment_details_page.dart';
import '../../features/doctors/presentation/pages/doctors_list_page.dart';
import '../../features/doctors/presentation/pages/doctor_profile_page.dart';
import '../../features/medical_records/presentation/pages/medical_records_page.dart';
import '../../features/prescriptions/presentation/pages/prescriptions_page.dart';
import '../../features/billing/presentation/pages/billing_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../core/widgets/error_view.dart';
import 'route_guards.dart';
import 'route_names.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    redirect: AuthGuard.redirect,
    errorBuilder: (context, state) => Scaffold(
      body: AppErrorView(
        message: state.error?.message ?? 'Page not found',
        onRetry: () => context.go(RouteNames.patientDashboard),
      ),
    ),
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (_, __) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.patientDashboard,
        builder: (_, __) => const PatientDashboardPage(),
      ),
      GoRoute(
        path: RouteNames.appointments,
        builder: (_, __) => const AppointmentsPage(),
        routes: [
          GoRoute(
            path: 'book',
            builder: (_, __) => const BookAppointmentPage(),
          ),
          GoRoute(
            path: ':id',
            builder: (_, state) => AppointmentDetailsPage(
              appointmentId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.doctors,
        builder: (_, __) => const DoctorsListPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) => DoctorProfilePage(
              doctorId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.emrRecords,
        builder: (_, __) => const MedicalRecordsPage(),
      ),
      GoRoute(
        path: RouteNames.prescriptions,
        builder: (_, __) => const PrescriptionsPage(),
      ),
      GoRoute(
        path: RouteNames.billing,
        builder: (_, __) => const BillingPage(),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (_, __) => const SettingsPage(),
      ),
      GoRoute(
        path: '/patient/profile',
        builder: (_, __) => const ProfilePage(),
      ),
    ],
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) context.go(RouteNames.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                size: 56,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'كلينيك فلو',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ClinicFlow',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
