import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/medical_record.dart';
import '../repositories/emr_repository.dart';

class GetMedicalRecordsUseCase {
  final EmrRepository repository;
  const GetMedicalRecordsUseCase(this.repository);
  Future<Either<Failure, List<MedicalRecord>>> call(
    String patientId, {
    RecordType? type,
  }) =>
      repository.getMedicalRecords(patientId, type: type);
}
