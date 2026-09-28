import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/doctor_repository.dart';
import '../../../appointments/domain/repositories/appointment_repository.dart';

class GetDoctorScheduleUseCase {
  final DoctorRepository repository;
  const GetDoctorScheduleUseCase(this.repository);
  Future<Either<Failure, List<TimeSlot>>> call(
    String doctorId,
    DateTime date,
  ) =>
      repository.getDoctorSchedule(doctorId, date);
}
