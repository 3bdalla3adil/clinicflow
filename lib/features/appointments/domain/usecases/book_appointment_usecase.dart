import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';

class BookAppointmentUseCase {
  final AppointmentRepository repository;
  const BookAppointmentUseCase(this.repository);
  Future<Either<Failure, Appointment>> call(BookingParams params) =>
      repository.bookAppointment(params);
}
