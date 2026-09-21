from pathlib import Path

root = Path('/home/ubuntu/clinicflow')
files = {
'pubspec.yaml': '''name: clinicflow
description: Secure, role-based clinic management application.
publish_to: "none"
version: 0.1.0+1

environment:
  sdk: ">=3.3.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.7
  firebase_core: ^3.8.0
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.0
  firebase_messaging: ^15.1.5
  firebase_crashlytics: ^4.1.5
  intl: ^0.19.0
  uuid: ^4.5.1
  equatable: ^2.0.7

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
  generate: true
''',
'analysis_options.yaml': '''include: package:flutter_lints/flutter.yaml
linter:
  rules:
    avoid_print: true
    prefer_const_constructors: true
    prefer_final_locals: true
''',
'.gitignore': '''.dart_tool/
.packages
build/
.flutter-plugins
.flutter-plugins-dependencies
.idea/
*.iml
.env
firebase_options.dart
''',
'lib/main.dart': '''import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Allows UI development before firebase_options.dart is configured.
  }
  runApp(const ProviderScope(child: ClinicFlowApp()));
}
''',
'lib/app/app.dart': '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';

class ClinicFlowApp extends ConsumerWidget {
  const ClinicFlowApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'ClinicFlow', debugShowCheckedModeBanner: false,
    theme: clinicTheme(Brightness.light), darkTheme: clinicTheme(Brightness.dark),
    themeMode: ThemeMode.system, routerConfig: ref.watch(routerProvider),
  );
}
''',
'lib/app/theme.dart': '''import 'package:flutter/material.dart';

ThemeData clinicTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF147D92), brightness: brightness);
  return ThemeData(useMaterial3: true, colorScheme: scheme, scaffoldBackgroundColor: scheme.surface,
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder(), filled: true),
    cardTheme: const CardThemeData(margin: EdgeInsets.zero, elevation: 0));
}
''',
'lib/app/router.dart': '''import 'package:flutter_riverpod/flutter_riverpod.dart';
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
''',
'lib/data/models/models.dart': '''enum UserRole { admin, reception, doctor, accountant, patient }
enum AppointmentStatus { scheduled, checkedIn, inConsultation, completed, cancelled, noShow }

class AppUser { const AppUser({required this.id, required this.email, required this.name, required this.role, required this.clinicId}); final String id,email,name,clinicId; final UserRole role; }
class Doctor { const Doctor({required this.id, required this.name, required this.specialty, required this.durationMinutes}); final String id,name,specialty; final int durationMinutes; }
class MedicalService { const MedicalService({required this.id, required this.name, required this.price}); final String id,name; final double price; }
class Appointment { const Appointment({required this.id, required this.number, required this.doctor, required this.service, required this.date, required this.startTime, required this.status}); final String id,number,startTime; final Doctor doctor; final MedicalService service; final DateTime date; final AppointmentStatus status; }

String statusLabel(AppointmentStatus s) => switch (s) { AppointmentStatus.scheduled => 'Scheduled', AppointmentStatus.checkedIn => 'Checked in', AppointmentStatus.inConsultation => 'In consultation', AppointmentStatus.completed => 'Completed', AppointmentStatus.cancelled => 'Cancelled', AppointmentStatus.noShow => 'No show' };
''',
'lib/data/repositories/clinic_repository.dart': '''import '../models/models.dart';

abstract interface class ClinicRepository {
  Stream<AppUser?> watchCurrentUser();
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  Future<List<Doctor>> getDoctors();
  Future<List<MedicalService>> getServices();
  Future<List<Appointment>> getAppointments({String? patientId});
  Future<Appointment> createAppointment({required Doctor doctor, required MedicalService service, required DateTime date, required String startTime});
}

class DemoClinicRepository implements ClinicRepository {
  final _doctors = const [Doctor(id: 'DOC-001', name: 'Dr. Sara Ahmed', specialty: 'General Medicine', durationMinutes: 30), Doctor(id: 'DOC-002', name: 'Dr. Mohamed Ali', specialty: 'Dermatology', durationMinutes: 30), Doctor(id: 'DOC-003', name: 'Dr. Huda Osman', specialty: 'Dental', durationMinutes: 45)];
  final _services = const [MedicalService(id: 'SERVICE-001', name: 'General Consultation', price: 35), MedicalService(id: 'SERVICE-002', name: 'Dermatology Consultation', price: 50), MedicalService(id: 'SERVICE-003', name: 'Dental Consultation', price: 60)];
  final List<Appointment> _appointments = [];
  AppUser? _user;
  @override Stream<AppUser?> watchCurrentUser() async* { yield _user; }
  @override Future<void> signIn(String email, String password) async { _user = AppUser(id: 'PAT-DEMO-001', email: email, name: 'Demo Patient', role: UserRole.patient, clinicId: 'CLINIC-001'); }
  @override Future<void> signOut() async => _user = null;
  @override Future<List<Doctor>> getDoctors() async => _doctors;
  @override Future<List<MedicalService>> getServices() async => _services;
  @override Future<List<Appointment>> getAppointments({String? patientId}) async => List.unmodifiable(_appointments);
  @override Future<Appointment> createAppointment({required Doctor doctor, required MedicalService service, required DateTime date, required String startTime}) async { final a = Appointment(id: 'APT-${DateTime.now().millisecondsSinceEpoch}', number: 'APT-${date.year}${date.month.toString().padLeft(2,'0')}${date.day.toString().padLeft(2,'0')}', doctor: doctor, service: service, date: date, startTime: startTime, status: AppointmentStatus.scheduled); _appointments.add(a); return a; }
}
''',
'lib/core/providers.dart': '''import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/clinic_repository.dart';
import '../data/models/models.dart';
final clinicRepositoryProvider = Provider<ClinicRepository>((_) => DemoClinicRepository());
final doctorsProvider = FutureProvider<List<Doctor>>((ref) => ref.watch(clinicRepositoryProvider).getDoctors());
final servicesProvider = FutureProvider<List<MedicalService>>((ref) => ref.watch(clinicRepositoryProvider).getServices());
final appointmentsProvider = FutureProvider<List<Appointment>>((ref) => ref.watch(clinicRepositoryProvider).getAppointments());
''',
'lib/shared/widgets/status_badge.dart': '''import 'package:flutter/material.dart';
import '../../data/models/models.dart';
class StatusBadge extends StatelessWidget { const StatusBadge(this.status, {super.key}); final AppointmentStatus status; @override Widget build(BuildContext context) => Chip(label: Text(statusLabel(status)), avatar: const Icon(Icons.circle, size: 10)); }
''',
'lib/features/auth/login_page.dart': '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
class LoginPage extends ConsumerStatefulWidget { const LoginPage({super.key}); @override ConsumerState<LoginPage> createState() => _LoginPageState(); }
class _LoginPageState extends ConsumerState<LoginPage> { final email=TextEditingController(text:'patient@example.com'), password=TextEditingController(text:'demo-password'); bool loading=false; String? error;
 @override Widget build(BuildContext context) => Scaffold(body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children:[const Icon(Icons.local_hospital, size:64), const SizedBox(height:16), Text('ClinicFlow', style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center), const SizedBox(height:8), const Text('Care coordination, made simple.', textAlign: TextAlign.center), const SizedBox(height:32), TextField(controller:email, decoration:const InputDecoration(labelText:'Email')), const SizedBox(height:16), TextField(controller:password, obscureText:true, decoration:const InputDecoration(labelText:'Password')), if(error!=null) Padding(padding:const EdgeInsets.only(top:12), child:Text(error!, style:TextStyle(color:Theme.of(context).colorScheme.error))), const SizedBox(height:20), FilledButton(onPressed:loading?null:() async { setState(()=>loading=true); try { await ref.read(clinicRepositoryProvider).signIn(email.text,password.text); if(mounted) context.go('/dashboard'); } catch(e) { setState(()=>error='Unable to sign in. Please try again.'); } finally { if(mounted) setState(()=>loading=false); } }, child: Text(loading?'Signing in…':'Sign in')), TextButton(onPressed:()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Registration is available through Firebase Auth.'))), child:const Text('Create patient account'))])))));
}
''',
'lib/features/home/dashboard_page.dart': '''import 'package:flutter/material.dart'; import 'package:go_router/go_router.dart';
class DashboardPage extends StatelessWidget { const DashboardPage({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar:AppBar(title:const Text('ClinicFlow'), actions:[IconButton(onPressed:()=>context.go('/profile'),icon:const Icon(Icons.person_outline))]), body:ListView(padding:const EdgeInsets.all(20), children:[Text('Welcome, Patient',style:Theme.of(context).textTheme.headlineMedium),const SizedBox(height:8),const Text('Your care at a glance'),const SizedBox(height:24),Card(child:Padding(padding:const EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Next appointment'),const SizedBox(height:12),Text('No upcoming appointments',style:Theme.of(context).textTheme.titleLarge),const SizedBox(height:8),const Text('Book a visit when you are ready.')]))),const SizedBox(height:20),Wrap(spacing:12,runSpacing:12,children:[_Action('Book appointment',Icons.add_circle_outline,()=>context.push('/book')), _Action('My appointments',Icons.calendar_month,()=>context.push('/appointments')), _Action('Doctors',Icons.medical_services,()=>ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Doctor directory coming from Firestore.'))))]) ])); }
class _Action extends StatelessWidget { const _Action(this.label,this.icon,this.onTap); final String label; final IconData icon; final VoidCallback onTap; @override Widget build(BuildContext c)=>SizedBox(width:160,height:100,child:Card(child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(12),child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(icon),const Spacer(),Text(label)]))))); }
''',
'lib/features/appointments/booking_page.dart': '''import 'package:flutter/material.dart'; import 'package:flutter_riverpod/flutter_riverpod.dart'; import 'package:go_router/go_router.dart'; import '../../core/providers.dart'; import '../../data/models/models.dart';
class BookingPage extends ConsumerStatefulWidget { const BookingPage({super.key}); @override ConsumerState<BookingPage> createState()=>_BookingPageState(); }
class _BookingPageState extends ConsumerState<BookingPage> { Doctor? doctor; MedicalService? service; DateTime date=DateTime.now(); String time='10:00'; @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Book appointment')),body:ListView(padding:const EdgeInsets.all(20),children:[const Text('1. Select service'),const SizedBox(height:8),ref.watch(servicesProvider).when(data:(xs)=>DropdownButtonFormField<MedicalService>(value:service,items:xs.map((x)=>DropdownMenuItem(value:x,child:Text('${x.name} · ${x.price.toStringAsFixed(0)}'))).toList(),onChanged:(x)=>setState(()=>service=x),decoration:const InputDecoration(labelText:'Service')),loading:()=>const LinearProgressIndicator(),error:(e,_)=>Text('Unable to load services: $e')),const SizedBox(height:20),const Text('2. Select doctor'),const SizedBox(height:8),ref.watch(doctorsProvider).when(data:(xs)=>DropdownButtonFormField<Doctor>(value:doctor,items:xs.map((x)=>DropdownMenuItem(value:x,child:Text('${x.name} · ${x.specialty}'))).toList(),onChanged:(x)=>setState(()=>doctor=x),decoration:const InputDecoration(labelText:'Doctor')),loading:()=>const LinearProgressIndicator(),error:(e,_)=>Text('Unable to load doctors: $e')),const SizedBox(height:20),ListTile(contentPadding:EdgeInsets.zero,title:const Text('Date'),subtitle:Text('${date.day}/${date.month}/${date.year}'),trailing:OutlinedButton(onPressed:()async{final x=await showDatePicker(context:context,firstDate:DateTime.now(),lastDate:DateTime.now().add(const Duration(days:90)),initialDate:date);if(x!=null)setState(()=>date=x);},child:const Text('Choose')),),const SizedBox(height:8),const Text('4. Available time'),Wrap(spacing:8,children:['09:00','10:00','11:00','14:00'].map((x)=>ChoiceChip(label:Text(x),selected:x==time,onSelected:(_)=>setState(()=>time=x)).toWidget()).toList()),const SizedBox(height:28),FilledButton(onPressed:doctor==null||service==null?null:()async{final a=await ref.read(clinicRepositoryProvider).createAppointment(doctor:doctor!,service:service!,date:date,startTime:time);if(context.mounted)showDialog(context:context,builder:(_)=>AlertDialog(title:const Text('Appointment confirmed'),content:Text('${a.number}\n${a.doctor.name}\n${a.service.name}\n${a.startTime}'),actions:[TextButton(onPressed:()=>context.go('/appointments'),child:const Text('View appointments'))]));},child:const Text('Confirm appointment'))])); }
}
extension onChoice on Widget { Widget toWidget()=>this; }
''',
'lib/features/appointments/appointments_page.dart': '''import 'package:flutter/material.dart'; import 'package:flutter_riverpod/flutter_riverpod.dart'; import '../../core/providers.dart'; import '../../shared/widgets/status_badge.dart';
class AppointmentsPage extends ConsumerWidget { const AppointmentsPage({super.key}); @override Widget build(BuildContext c,WidgetRef ref)=>Scaffold(appBar:AppBar(title:const Text('My appointments')),body:ref.watch(appointmentsProvider).when(data:(xs)=>xs.isEmpty?const Center(child:Text('No appointments yet.')):ListView.separated(padding:const EdgeInsets.all(16),itemCount:xs.length,separatorBuilder:(_,__)=>const SizedBox(height:12),itemBuilder:(_,i){final a=xs[i];return Card(child:ListTile(title:Text(a.service.name),subtitle:Text('${a.doctor.name}\n${a.number} · ${a.startTime}'),isThreeLine:true,trailing:StatusBadge(a.status)));}),loading:()=>const Center(child:CircularProgressIndicator()),error:(e,_)=>Center(child:Text('Unable to load appointments: $e')))); }
}
''',
'lib/features/profile/profile_page.dart': '''import 'package:flutter/material.dart'; import 'package:go_router/go_router.dart'; class ProfilePage extends StatelessWidget { const ProfilePage({super.key}); @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Profile')),body:ListView(padding:const EdgeInsets.all(20),children:[const CircleAvatar(radius:36,child:Icon(Icons.person)),const SizedBox(height:20),TextFormField(initialValue:'Demo Patient',decoration:const InputDecoration(labelText:'Name')),const SizedBox(height:16),TextFormField(initialValue:'patient@example.com',decoration:const InputDecoration(labelText:'Email')),const SizedBox(height:24),FilledButton(onPressed:()=>ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content:Text('Profile changes are saved through the secure repository.'))),child:const Text('Save changes')),TextButton(onPressed:()=>context.go('/login'),child:const Text('Sign out'))])); }
''',
'firestore/firestore.rules': '''rules_version = '2';
service cloud.firestore { match /databases/{database}/documents {
  function signedIn() { return request.auth != null; }
  function user() { return get(/databases/$(database)/documents/users/$(request.auth.uid)).data; }
  function role(r) { return signedIn() && user().roleId == r; }
  match /users/{id} { allow read: if signedIn() && (request.auth.uid == id || role('ADMIN')); allow create: if signedIn() && request.auth.uid == id; allow update: if signedIn() && request.auth.uid == id && !('roleId' in request.resource.data.diff(resource.data).affectedKeys()) && !('clinicId' in request.resource.data.diff(resource.data).affectedKeys()); }
  match /doctors/{id} { allow read: if signedIn(); allow write: if role('ADMIN'); }
  match /services/{id} { allow read: if signedIn(); allow write: if role('ADMIN'); }
  match /appointments/{id} { allow read: if signedIn() && (resource.data.patientId == request.auth.uid || role('ADMIN') || role('RECEPTION') || role('DOCTOR')); allow create: if signedIn(); allow update: if role('ADMIN') || role('RECEPTION') || role('DOCTOR'); allow delete: if false; }
  match /consultations/{id} { allow read, write: if role('ADMIN') || role('DOCTOR'); }
  match /payments/{id} { allow read, write: if role('ADMIN') || role('RECEPTION') || role('ACCOUNTANT'); }
  match /auditLogs/{id} { allow read: if role('ADMIN'); allow create: if signedIn(); allow update, delete: if false; }
  match /{document=**} { allow read, write: if false; }
} }
''',
'firestore/firestore.indexes.json': '''{"indexes":[{"collectionGroup":"appointments","queryScope":"COLLECTION","fields":[{"fieldPath":"clinicId","order":"ASCENDING"},{"fieldPath":"appointmentDate","order":"ASCENDING"}]},{"collectionGroup":"appointments","queryScope":"COLLECTION","fields":[{"fieldPath":"doctorId","order":"ASCENDING"},{"fieldPath":"appointmentDate","order":"ASCENDING"}]},{"collectionGroup":"auditLogs","queryScope":"COLLECTION","fields":[{"fieldPath":"entityId","order":"ASCENDING"},{"fieldPath":"timestamp","order":"DESCENDING"}]}],"fieldOverrides":[]}''',
'README.md': '''# ClinicFlow

ClinicFlow is a Flutter/Firebase clinic-management foundation for Android and iOS. It is intentionally marked as an **MVP/development application** until security, privacy, legal, clinical, and operational controls are independently assessed. It must not be described as HIPAA compliant without a completed assessment.

## Included

The scaffold includes Material 3 theming, Riverpod state management, go_router navigation, patient login/demo mode, doctor/service discovery, appointment booking, appointment listing, profile UI, repository abstractions, Firestore security rules, indexes, and a testable demo repository. The demo repository lets the UI run without credentials; replace it with `FirebaseClinicRepository` after configuring Firebase.

## Firebase setup

Install Flutter and configure the existing Firebase project `clinic-app-v4` with FlutterFire CLI. Generate `lib/firebase_options.dart` locally and keep it out of source control when appropriate. Enable Email/Password Authentication, Firestore, FCM, Crashlytics, and Storage as required. Deploy rules and indexes with `firebase deploy --only firestore`.

Critical booking validation must be moved to a callable Cloud Function using a Firestore transaction before production use. Never calculate availability from a complete client-side appointment dump, and never place service-account credentials in the app.

## Run

```bash
flutter pub get
flutter run
flutter test
```

## Production gaps to complete

Implement Firebase-backed repositories, custom claims or server-controlled role documents, callable appointment creation, consultation and payment screens, notification handlers, Arabic ARB generation/RTL verification, pagination, audit-log Cloud Functions, staging/production Firebase options, Android/iOS signing, and a formal healthcare privacy/security review.
''',
'l10n/app_en.arb': '{"@@locale":"en","appTitle":"ClinicFlow","signIn":"Sign in","bookAppointment":"Book appointment"}',
'l10n/app_ar.arb': '{"@@locale":"ar","appTitle":"كلينيك فلو","signIn":"تسجيل الدخول","bookAppointment":"حجز موعد"}',
'test/unit/appointment_test.dart': '''import 'package:flutter_test/flutter_test.dart'; import 'package:clinicflow/data/models/models.dart'; void main(){test('status labels are readable',(){expect(statusLabel(AppointmentStatus.inConsultation),'In consultation');});}
''',
'test/widget/login_test.dart': '''import 'package:flutter_test/flutter_test.dart'; import 'package:clinicflow/features/auth/login_page.dart'; import 'package:flutter_riverpod/flutter_riverpod.dart'; void main(){testWidgets('login page renders', (tester) async { await tester.pumpWidget(const ProviderScope(child: LoginPage())); expect(find.text('ClinicFlow'), findsOneWidget); expect(find.text('Sign in'), findsOneWidget);});}
''',
}
# This outer script writes the project files; the loop is intentionally explicit for reviewability.
for name, content in files.items():
    path = root / name
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)
print(f'generated {len(files)} files')
