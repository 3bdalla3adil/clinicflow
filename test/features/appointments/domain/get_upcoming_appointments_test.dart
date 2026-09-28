import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clinicflow/features/appointments/domain/entities/appointment.dart';
import 'package:clinicflow/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:clinicflow/features/appointments/domain/usecases/get_upcoming_appointments_usecase.dart';
import 'package:clinicflow/core/errors/failures.dart';

class MockAppointmentRepository extends Mock
    implements AppointmentRepository {}

void main() {
  late GetUpcomingAppointmentsUseCase useCase;
  late MockAppointmentRepository mockRepo;

  setUp(() {
    mockRepo = MockAppointmentRepository();
    useCase = GetUpcomingAppointmentsUseCase(mockRepo);
  });

  const tPatientId = 'patient_123';
  final tAppointment = Appointment(
    id: '1',
    patientId: tPatientId,
    doctorId: 'doc_1',
    doctorName: 'Dr. Ahmed',
    doctorSpecialization: 'General',
    clinicId: 'clinic_1',
    clinicName: 'Main Clinic',
    scheduledAt: DateTime.now().add(const Duration(days: 2)),
    status: AppointmentStatus.confirmed,
    type: AppointmentType.inPerson,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('GetUpcomingAppointmentsUseCase', () {
    test('returns list on success', () async {
      when(() => mockRepo.getUpcomingAppointments(tPatientId))
          .thenAnswer((_) async => Right([tAppointment]));
      final result = await useCase(tPatientId);
      expect(result, Right([tAppointment]));
      verify(() => mockRepo.getUpcomingAppointments(tPatientId))
          .called(1);
    });

    test('returns NoInternetFailure on no connection', () async {
      when(() => mockRepo.getUpcomingAppointments(tPatientId))
          .thenAnswer(
        (_) async => const Left(NoInternetFailure()),
      );
      final result = await useCase(tPatientId);
      expect(result, const Left(NoInternetFailure()));
    });

    test('returns empty list when no appointments', () async {
      when(() => mockRepo.getUpcomingAppointments(tPatientId))
          .thenAnswer((_) async => const Right([]));
      final result = await useCase(tPatientId);
      result.fold(
        (_) => fail('Expected Right'),
        (list) => expect(list, isEmpty),
      );
    });
  });
}
