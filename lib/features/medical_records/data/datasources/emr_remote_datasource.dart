import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/medical_record_model.dart';
import '../../domain/entities/medical_record.dart';

abstract class EmrRemoteDataSource {
  Future<List<MedicalRecordModel>> getMedicalRecords(
    String patientId, {
    RecordType? type,
    int page = 1,
  });
  Future<MedicalRecordModel> getRecordById(String id);
}

class EmrRemoteDataSourceImpl implements EmrRemoteDataSource {
  final DioClient dioClient;
  EmrRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<MedicalRecordModel>> getMedicalRecords(
    String patientId, {
    RecordType? type,
    int page = 1,
  }) async {
    try {
      final resp = await dioClient.get(
        ApiConstants.medicalRecords,
        queryParameters: {
          'patient_id': patientId,
          if (type != null) 'type': type.name,
          'page': page,
        },
      );
      final list = resp.data as List<dynamic>;
      return list
          .map((e) =>
              MedicalRecordModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e is AppException ? e : AppException(message: e.toString());
    }
  }

  @override
  Future<MedicalRecordModel> getRecordById(String id) async {
    try {
      final resp = await dioClient.get(
        '${ApiConstants.medicalRecords}/$id',
      );
      return MedicalRecordModel.fromJson(
        resp.data as Map<String, dynamic>,
      );
    } catch (e) {
      throw e is AppException ? e : AppException(message: e.toString());
    }
  }
}
