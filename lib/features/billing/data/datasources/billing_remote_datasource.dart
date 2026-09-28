import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/invoice_model.dart';
import '../../domain/entities/invoice.dart';

abstract class BillingRemoteDataSource {
  Future<List<InvoiceModel>> getInvoices(
    String patientId, {
    InvoiceStatus? status,
    int page = 1,
  });
}

class BillingRemoteDataSourceImpl implements BillingRemoteDataSource {
  final DioClient dioClient;
  BillingRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<InvoiceModel>> getInvoices(
    String patientId, {
    InvoiceStatus? status,
    int page = 1,
  }) async {
    try {
      final resp = await dioClient.get(
        ApiConstants.invoices,
        queryParameters: {
          'patient_id': patientId,
          if (status != null) 'status': status.name,
          'page': page,
        },
      );
      final list = resp.data as List<dynamic>;
      return list
          .map((e) =>
              InvoiceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e is AppException ? e : AppException(message: e.toString());
    }
  }
}
