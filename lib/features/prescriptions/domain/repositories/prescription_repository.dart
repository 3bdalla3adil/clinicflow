import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/prescription.dart';

abstract class PrescriptionRepository {
  Future<Either<Failure, List<Prescription>>> getPrescriptions(
    String patientId, {
    PrescriptionStatus? status,
    int page = 1,
  });
  Future<Either<Failure, Prescription>> getPrescriptionById(String id);
}
