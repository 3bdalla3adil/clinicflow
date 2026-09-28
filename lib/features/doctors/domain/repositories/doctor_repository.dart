import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/doctor.dart';
import '../../../appointments/domain/repositories/appointment_repository.dart';

abstract class DoctorRepository {
  Future<Either<Failure, List<Doctor>>> getDoctors({
    String? specialization,
    String? clinicId,
    String? query,
    int page = 1,
  });
  Future<Either<Failure, Doctor>> getDoctorById(String id);
  Future<Either<Failure, List<TimeSlot>>> getDoctorSchedule(
    String doctorId,
    DateTime date,
  );
}
