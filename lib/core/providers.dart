import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import '../data/repositories/clinic_repository.dart';

/// Global UI/demo switch. Demo mode never instantiates the Firebase repository.
final demoModeProvider = StateProvider<bool>((ref) => false);

final firebaseAvailableProvider = Provider<bool>((_) => Firebase.apps.isNotEmpty);

final clinicRepositoryProvider = Provider<ClinicRepository>((ref) {
  if (ref.watch(demoModeProvider)) {
    return DemoClinicRepository();
  }
  if (!Firebase.apps.isNotEmpty) {
    return DemoClinicRepository();
  }
  return FirebaseClinicRepository();
});

final currentUserProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(clinicRepositoryProvider).watchCurrentUser(),
);

final doctorsProvider = FutureProvider<List<Doctor>>(
  (ref) => ref.watch(clinicRepositoryProvider).getDoctors(),
);

final servicesProvider = FutureProvider<List<MedicalService>>(
  (ref) => ref.watch(clinicRepositoryProvider).getServices(),
);

final appointmentsProvider = FutureProvider<List<Appointment>>((ref) {
  final repository = ref.watch(clinicRepositoryProvider);
  return repository.getAppointments(patientId: repository.currentUser?.id);
});
