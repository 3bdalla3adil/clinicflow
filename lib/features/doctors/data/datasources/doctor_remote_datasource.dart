import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/doctor_model.dart';
import '../../../appointments/domain/repositories/appointment_repository.dart';

abstract class DoctorRemoteDataSource {
  Future<List<DoctorModel>> getDoctors({
    String? specialization,
    String? clinicId,
    String? query,
    int page = 1,
  });
  Future<DoctorModel> getDoctorById(String id);
  Future<List<TimeSlot>> getDoctorSchedule(
    String doctorId,
    DateTime date,
  );
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final DioClient dioClient;
  DoctorRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<DoctorModel>> getDoctors({
    String? specialization,
    String? clinicId,
    String? query,
    int page = 1,
  }) async {
    try {
      final resp = await dioClient.get(
        ApiConstants.doctors,
        queryParameters: {
          if (specialization != null)
            'specialization': specialization,
          if (clinicId != null) 'clinic_id': clinicId,
          if (query != null) 'q': query,
          'page': page,
        },
      );
      final list = resp.data as List<dynamic>;
      return list
          .map((e) =>
              DoctorModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e is AppException ? e : AppException(message: e.toString());
    }
  }

  @override
  Future<DoctorModel> getDoctorById(String id) async {
    try {
      final resp = await dioClient.get(ApiConstants.doctor(id));
      return DoctorModel.fromJson(
        resp.data as Map<String, dynamic>,
      );
    } catch (e) {
      throw e is AppException ? e : AppException(message: e.toString());
    }
  }

  @override
  Future<List<TimeSlot>> getDoctorSchedule(
    String doctorId,
    DateTime date,
  ) async {
    try {
      final resp = await dioClient.get(
        ApiConstants.doctorSlots(doctorId),
        queryParameters: {
          'date': date.toIso8601String().split('T')[0],
        },
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
