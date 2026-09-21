import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../data/repositories/clinic_repository.dart';

final firebaseAvailableProvider=Provider<bool>((_)=>Firebase.apps.isNotEmpty);
final clinicRepositoryProvider=Provider<ClinicRepository>((ref)=>Firebase.apps.isNotEmpty?FirebaseClinicRepository():DemoClinicRepository());
final currentUserProvider=StreamProvider<AppUser?>((ref)=>ref.watch(clinicRepositoryProvider).watchCurrentUser());
final doctorsProvider=FutureProvider<List<Doctor>>((ref)=>ref.watch(clinicRepositoryProvider).getDoctors());
final servicesProvider=FutureProvider<List<MedicalService>>((ref)=>ref.watch(clinicRepositoryProvider).getServices());
final appointmentsProvider=FutureProvider<List<Appointment>>((ref)=>ref.watch(clinicRepositoryProvider).getAppointments(patientId:ref.watch(clinicRepositoryProvider).currentUser?.id));
