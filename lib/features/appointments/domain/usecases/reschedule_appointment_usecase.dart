import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class RescheduleAppointmentUseCase {
  final AppointmentRepository repository;
  const RescheduleAppointmentUseCase(this.repository);
  Future<Either<Failure, Appointment>> call(
    String id,
    DateTime newDateTime,
  ) =>
      repository.rescheduleAppointment(id, newDateTime);
}
