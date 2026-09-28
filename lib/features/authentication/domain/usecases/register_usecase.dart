import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String fullName;
  final String email;
  final String password;
  final String phone;
  final String? dateOfBirth;
  final String? gender;
  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.password,
    required this.phone,
    this.dateOfBirth,
    this.gender,
  });
}

class RegisterUseCase {
  final AuthRepository repository;
  const RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call(RegisterParams p) =>
      repository.register(
        fullName: p.fullName,
        email: p.email,
        password: p.password,
        phone: p.phone,
        dateOfBirth: p.dateOfBirth,
        gender: p.gender,
      );
}
