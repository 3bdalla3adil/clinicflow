import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/repositories/billing_repository.dart';
import '../datasources/billing_remote_datasource.dart';

class BillingRepositoryImpl implements BillingRepository {
  final BillingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  BillingRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Invoice>>> getInvoices(
    String patientId, {
    InvoiceStatus? status,
    int page = 1,
  }) async {
    try {
      final invoices = await remoteDataSource.getInvoices(
        patientId,
        status: status,
        page: page,
      );
      return Right(invoices);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Invoice>> getInvoiceById(String id) async {
    return const Left(ServerFailure(message: 'Not implemented'));
  }
}
