import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class GetUpcomingAppointmentsUseCase {
  final AppointmentRepository repository;
  const GetUpcomingAppointmentsUseCase(this.repository);
  Future<Either<Failure, List<Appointment>>> call(String patientId) =>
      repository.getUpcomingAppointments(patientId);
}
