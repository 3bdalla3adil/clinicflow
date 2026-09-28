import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/invoice.dart';
import '../repositories/billing_repository.dart';

class GetInvoicesUseCase {
  final BillingRepository repository;
  const GetInvoicesUseCase(this.repository);
  Future<Either<Failure, List<Invoice>>> call(
    String patientId, {
    InvoiceStatus? status,
  }) =>
      repository.getInvoices(patientId, status: status);
}
