import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/doctor.dart';
import '../repositories/doctor_repository.dart';

class GetDoctorsParams {
  final String? specialization;
  final String? clinicId;
  final String? query;
  final int page;
  const GetDoctorsParams({
    this.specialization,
    this.clinicId,
    this.query,
    this.page = 1,
  });
}

class GetDoctorsUseCase {
  final DoctorRepository repository;
  const GetDoctorsUseCase(this.repository);
  Future<Either<Failure, List<Doctor>>> call(GetDoctorsParams params) =>
      repository.getDoctors(
        specialization: params.specialization,
        clinicId: params.clinicId,
        query: params.query,
        page: params.page,
      );
}
