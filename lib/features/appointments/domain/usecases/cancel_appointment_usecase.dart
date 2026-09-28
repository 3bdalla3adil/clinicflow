import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/appointment_repository.dart';

class CancelAppointmentUseCase {
  final AppointmentRepository repository;
  const CancelAppointmentUseCase(this.repository);
  Future<Either<Failure, Unit>> call(String id, {String? reason}) =>
      repository.cancelAppointment(id, reason: reason);
}
