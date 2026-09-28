import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/medical_record.dart';

abstract class EmrRepository {
  Future<Either<Failure, List<MedicalRecord>>> getMedicalRecords(
    String patientId, {
    RecordType? type,
    int page = 1,
  });
  Future<Either<Failure, MedicalRecord>> getRecordById(String id);
}
