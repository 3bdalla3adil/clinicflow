import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/prescription.dart';
import '../../domain/repositories/prescription_repository.dart';
import '../datasources/prescription_remote_datasource.dart';

class PrescriptionRepositoryImpl implements PrescriptionRepository {
  final PrescriptionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PrescriptionRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Prescription>>> getPrescriptions(
    String patientId, {
    PrescriptionStatus? status,
    int page = 1,
  }) async {
    try {
      final prescriptions = await remoteDataSource.getPrescriptions(
        patientId,
        status: status,
        page: page,
      );
      return Right(prescriptions);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Prescription>> getPrescriptionById(
    String id,
  ) async {
    return const Left(
      ServerFailure(message: 'Not implemented'),
    );
  }
}
