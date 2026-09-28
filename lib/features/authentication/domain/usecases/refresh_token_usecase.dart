import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository repository;
  const RefreshTokenUseCase(this.repository);
  Future<Either<Failure, String>> call(String token) =>
      repository.refreshToken(token);
}
