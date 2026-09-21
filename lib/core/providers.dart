import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/clinic_repository.dart';
import '../data/models/models.dart';

final clinicRepositoryProvider =
    Provider<ClinicRepository>((_) => DemoClinicRepository());
final doctorsProvider = FutureProvider<List<Doctor>>(
    (ref) => ref.watch(clinicRepositoryProvider).getDoctors());
final servicesProvider = FutureProvider<List<MedicalService>>(
    (ref) => ref.watch(clinicRepositoryProvider).getServices());
final appointmentsProvider = FutureProvider<List<Appointment>>(
    (ref) => ref.watch(clinicRepositoryProvider).getAppointments());
