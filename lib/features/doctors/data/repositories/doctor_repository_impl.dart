import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../../../appointments/domain/repositories/appointment_repository.dart';
import '../datasources/doctor_remote_datasource.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  DoctorRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Doctor>>> getDoctors({
    String? specialization,
    String? clinicId,
    String? query,
    int page = 1,
  }) async {
    try {
      final doctors = await remoteDataSource.getDoctors(
        specialization: specialization,
        clinicId: clinicId,
        query: query,
        page: page,
      );
      return Right(doctors);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Doctor>> getDoctorById(String id) async {
    try {
      return Right(await remoteDataSource.getDoctorById(id));
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<TimeSlot>>> getDoctorSchedule(
    String doctorId,
    DateTime date,
  ) async {
    try {
      return Right(
        await remoteDataSource.getDoctorSchedule(doctorId, date),
      );
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
