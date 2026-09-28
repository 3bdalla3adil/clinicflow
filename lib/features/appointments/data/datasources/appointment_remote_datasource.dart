import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/appointment_model.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../domain/entities/appointment.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<AppointmentModel>> getUpcomingAppointments(
    String patientId,
  );
  Future<List<AppointmentModel>> getPastAppointments(
    String patientId, {
    int page = 1,
    int pageSize = 20,
  });
  Future<AppointmentModel> getAppointmentById(String id);
  Future<AppointmentModel> bookAppointment(BookingParams params);
  Future<AppointmentModel> rescheduleAppointment(
    String id,
    DateTime newDateTime,
  );
  Future<void> cancelAppointment(String id, {String? reason});
  Future<List<TimeSlot>> getAvailableSlots(
    String doctorId,
    DateTime date,
  );
}

class AppointmentRemoteDataSourceImpl
    implements AppointmentRemoteDataSource {
  final DioClient dioClient;
  AppointmentRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<AppointmentModel>> getUpcomingAppointments(
    String patientId,
  ) async {
    try {
      final resp = await dioClient.get(
        ApiConstants.patientAppointments(patientId),
        queryParameters: {'status': 'upcoming'},
      );
      final list = resp.data as List<dynamic>;
      return list
          .map(
            (e) =>
                AppointmentModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw e is AppException ? e : AppException(message: e.toString());
    }
  }

  @override
  Future<List<AppointmentModel>> getPastAppointments(
    String patientId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final resp = await dioClient.get(
        ApiConstants.patientAppointments(patientId),
        queryParameters: {
          'status': 'past',
          'page': page,
          'page_size': pageSize,
        },
      );
      final list = resp.data as List<dynamic>;
      return list
          .map(
            (e) =>
                AppointmentModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw e is AppException ? e : AppException(message: e.toString());
    }
  }

  @override
  Future<AppointmentModel> getAppointmentById(String id) async {
    try {
      final resp = await dioClient.get(ApiConstants.appointment(id));
      return AppointmentModel.fromJson(
        resp.data as Map<String, dynamic>,
      );
    } catch (e) {
      throw e is AppException ? e : AppException(message: e.toString());
    }
  }

  @override
  Future<AppointmentModel> bookAppointment(BookingParams params) async {
    try {
      final resp = await dioClient.post(
        ApiConstants.appointments,
        data: {
          'patient_id': params.patientId,
          'doctor_id': params.doctorId,
          'clinic_id': params.clinicId,
          'scheduled_at': params.scheduledAt.toIso8601String(),
          'type': params.type.name,
          if (params.symptoms != null) 'symptoms': params.symptoms,
          if (params.notes != null) 'notes': params.notes,
        },
      );
      return AppointmentModel.fromJson(
        resp.data as Map<String, dynamic>,
      );
    } catch (e) {
      throw e is AppException ? e : AppException(message: e.toString());
    }
  }

  @override
  Future<AppointmentModel> rescheduleAppointment(
    String id,
    DateTime newDateTime,
  ) async {
    try {
      final resp = await dioClient.patch(
        ApiConstants.reschedule(id),
        data: {'scheduled_at': newDateTime.toIso8601String()},
      );
      return AppointmentModel.fromJson(
        resp.data as Map<String, dynamic>,
      );
    } catch (e) {
      throw e is AppException ? e : AppException(message: e.toString());
    }
  }

  @override
  Future<void> cancelAppointment(String id, {String? reason}) async {
    try {
      await dioClient.patch(
        ApiConstants.cancelAppointment(id),
        data: {if (reason != null) 'reason': reason},
      );
    } catch (e) {
      throw e is AppException ? e : AppException(message: e.toString());
    }
  }

  @override
  Future<List<TimeSlot>> getAvailableSlots(
    String doctorId,
    DateTime date,
  ) async {
    try {
      final resp = await dioClient.get(
        ApiConstants.doctorSlots(doctorId),
        queryParameters: {'date': date.toIso8601String().split('T')[0]},
      );
      final list = resp.data as List<dynamic>;
      return list.map((e) {
        final slot = e as Map<String, dynamic>;
        return TimeSlot(
          startTime: DateTime.parse(slot['start_time'] as String),
          endTime: DateTime.parse(slot['end_time'] as String),
          isAvailable: slot['is_available'] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      throw e is AppException ? e : AppException(message: e.toString());
    }
  }
}
