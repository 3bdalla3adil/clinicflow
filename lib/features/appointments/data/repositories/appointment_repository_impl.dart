import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_datasource.dart';
import '../datasources/appointment_local_datasource.dart';
import '../models/appointment_model.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;
  final AppointmentLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AppointmentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Appointment>>> getUpcomingAppointments(
    String patientId,
  ) async {
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      try {
        final remote =
            await remoteDataSource.getUpcomingAppointments(patientId);
        await localDataSource.cacheAppointments(patientId, remote);
        return Right(remote);
      } catch (e) {
        final cached =
            localDataSource.getCachedAppointments(patientId);
        if (cached != null) return Right(cached);
        return Left(ErrorHandler.handleException(e));
      }
    } else {
      final cached = localDataSource.getCachedAppointments(patientId);
      if (cached != null) return Right(cached);
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<Appointment>>> getPastAppointments(
    String patientId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final remote = await remoteDataSource.getPastAppointments(
        patientId,
        page: page,
        pageSize: pageSize,
      );
      return Right(remote);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Appointment>> getAppointmentById(
    String id,
  ) async {
    try {
      return Right(await remoteDataSource.getAppointmentById(id));
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Appointment>> bookAppointment(
    BookingParams params,
  ) async {
    try {
      return Right(await remoteDataSource.bookAppointment(params));
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Appointment>> rescheduleAppointment(
    String id,
    DateTime newDateTime,
  ) async {
    try {
      return Right(
        await remoteDataSource.rescheduleAppointment(id, newDateTime),
      );
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelAppointment(
    String id, {
    String? reason,
  }) async {
    try {
      await remoteDataSource.cancelAppointment(id, reason: reason);
      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<TimeSlot>>> getAvailableSlots(
    String doctorId,
    DateTime date,
  ) async {
    try {
      return Right(
        await remoteDataSource.getAvailableSlots(doctorId, date),
      );
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
