import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/prescription_model.dart';
import '../../domain/entities/prescription.dart';

abstract class PrescriptionRemoteDataSource {
  Future<List<PrescriptionModel>> getPrescriptions(
    String patientId, {
    PrescriptionStatus? status,
    int page = 1,
  });
}

class PrescriptionRemoteDataSourceImpl
    implements PrescriptionRemoteDataSource {
  final DioClient dioClient;
  PrescriptionRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<PrescriptionModel>> getPrescriptions(
    String patientId, {
    PrescriptionStatus? status,
    int page = 1,
  }) async {
    try {
      final resp = await dioClient.get(
        ApiConstants.prescriptions,
        queryParameters: {
          'patient_id': patientId,
          if (status != null) 'status': status.name,
          'page': page,
        },
      );
      final list = resp.data as List<dynamic>;
      return list
          .map((e) =>
              PrescriptionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e is AppException ? e : AppException(message: e.toString());
    }
  }
}
