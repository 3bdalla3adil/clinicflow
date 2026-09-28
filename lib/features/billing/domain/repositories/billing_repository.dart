import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/invoice.dart';

abstract class BillingRepository {
  Future<Either<Failure, List<Invoice>>> getInvoices(
    String patientId, {
    InvoiceStatus? status,
    int page = 1,
  });
  Future<Either<Failure, Invoice>> getInvoiceById(String id);
}
