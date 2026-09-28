import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clinicflow/features/appointments/domain/entities/appointment.dart';
import 'package:clinicflow/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:clinicflow/features/appointments/domain/usecases/get_upcoming_appointments_usecase.dart';
import 'package:clinicflow/features/appointments/domain/usecases/book_appointment_usecase.dart';
import 'package:clinicflow/features/appointments/domain/usecases/cancel_appointment_usecase.dart';
import 'package:clinicflow/features/appointments/domain/usecases/reschedule_appointment_usecase.dart';
import 'package:clinicflow/features/appointments/presentation/bloc/appointment_bloc.dart';
import 'package:clinicflow/core/errors/failures.dart';

class MockGetUpcomingAppointmentsUseCase extends Mock
    implements GetUpcomingAppointmentsUseCase {}

class MockBookAppointmentUseCase extends Mock
    implements BookAppointmentUseCase {}

class MockCancelAppointmentUseCase extends Mock
    implements CancelAppointmentUseCase {}

class MockRescheduleAppointmentUseCase extends Mock
    implements RescheduleAppointmentUseCase {}

void main() {
  late AppointmentBloc bloc;
  late MockGetUpcomingAppointmentsUseCase mockGetUpcoming;
  late MockBookAppointmentUseCase mockBook;
  late MockCancelAppointmentUseCase mockCancel;
  late MockRescheduleAppointmentUseCase mockReschedule;

  setUp(() {
    mockGetUpcoming = MockGetUpcomingAppointmentsUseCase();
    mockBook = MockBookAppointmentUseCase();
    mockCancel = MockCancelAppointmentUseCase();
    mockReschedule = MockRescheduleAppointmentUseCase();
    bloc = AppointmentBloc(
      getUpcoming: mockGetUpcoming,
      bookAppointment: mockBook,
      cancelAppointment: mockCancel,
      rescheduleAppointment: mockReschedule,
    );
  });

  tearDown(() => bloc.close());

  final tAppointment = Appointment(
    id: '1',
    patientId: 'p1',
    doctorId: 'd1',
    doctorName: 'Dr. Smith',
    doctorSpecialization: 'Cardiology',
    clinicId: 'c1',
    clinicName: 'Heart Clinic',
    scheduledAt: DateTime.now().add(const Duration(days: 1)),
    status: AppointmentStatus.confirmed,
    type: AppointmentType.inPerson,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('LoadUpcomingAppointmentsEvent', () {
    blocTest<AppointmentBloc, AppointmentState>(
      'emits [Loading, Loaded] on success',
      build: () {
        when(() => mockGetUpcoming('p1'))
            .thenAnswer((_) async => Right([tAppointment]));
        return bloc;
      },
      act: (b) => b.add(const LoadUpcomingAppointmentsEvent('p1')),
      expect: () => [
        AppointmentLoading(),
        AppointmentLoaded(appointments: [tAppointment]),
      ],
    );

    blocTest<AppointmentBloc, AppointmentState>(
      'emits [Loading, Empty] when no appointments',
      build: () {
        when(() => mockGetUpcoming('p1'))
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (b) => b.add(const LoadUpcomingAppointmentsEvent('p1')),
      expect: () => [
        AppointmentLoading(),
        AppointmentEmpty(),
      ],
    );

    blocTest<AppointmentBloc, AppointmentState>(
      'emits [Loading, Error] on failure',
      build: () {
        when(() => mockGetUpcoming('p1')).thenAnswer(
          (_) async => const Left(
            NoInternetFailure(),
          ),
        );
        return bloc;
      },
      act: (b) => b.add(const LoadUpcomingAppointmentsEvent('p1')),
      expect: () => [
        AppointmentLoading(),
        const AppointmentError(
          message: 'No internet connection',
          isOffline: true,
        ),
      ],
    );
  });
}
