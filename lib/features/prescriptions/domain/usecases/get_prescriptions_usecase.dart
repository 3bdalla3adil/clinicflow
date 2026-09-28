import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/prescription.dart';
import '../repositories/prescription_repository.dart';

class GetPrescriptionsUseCase {
  final PrescriptionRepository repository;
  const GetPrescriptionsUseCase(this.repository);
  Future<Either<Failure, List<Prescription>>> call(
    String patientId, {
    PrescriptionStatus? status,
  }) =>
      repository.getPrescriptions(patientId, status: status);
}
