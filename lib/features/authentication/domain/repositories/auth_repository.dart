import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String? dateOfBirth,
    String? gender,
  });
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, Unit>> forgotPassword(String email);
  Future<Either<Failure, Unit>> verifyOtp(String email, String otp);
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, String>> refreshToken(String refreshToken);
  Future<bool> isAuthenticated();
}
