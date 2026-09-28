import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/medical_record.dart';
import '../../domain/repositories/emr_repository.dart';
import '../datasources/emr_remote_datasource.dart';

class EmrRepositoryImpl implements EmrRepository {
  final EmrRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  EmrRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<MedicalRecord>>> getMedicalRecords(
    String patientId, {
    RecordType? type,
    int page = 1,
  }) async {
    try {
      final records = await remoteDataSource.getMedicalRecords(
        patientId,
        type: type,
        page: page,
      );
      return Right(records);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, MedicalRecord>> getRecordById(
    String id,
  ) async {
    try {
      return Right(await remoteDataSource.getRecordById(id));
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
