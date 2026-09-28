import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/security/secure_storage.dart';
import '../../../../core/security/secure_logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, User>> login(
    String email,
    String password,
  ) async {
    try {
      final data = await remoteDataSource.login(email, password);
      final user =
          UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await secureStorage.saveAccessToken(
        data['access_token'] as String,
      );
      await secureStorage.saveRefreshToken(
        data['refresh_token'] as String,
      );
      await secureStorage.saveUserId(user.id);
      await secureStorage.saveUserRole(user.role.name);
      SecureLogger.instance.audit('Login — role: ${user.role.name}');
      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String? dateOfBirth,
    String? gender,
  }) async {
    try {
      final data = await remoteDataSource.register(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );
      final user =
          UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await secureStorage.saveAccessToken(
        data['access_token'] as String,
      );
      await secureStorage.saveRefreshToken(
        data['refresh_token'] as String,
      );
      await secureStorage.saveUserId(user.id);
      await secureStorage.saveUserRole(user.role.name);
      return Right(user);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      final token = await secureStorage.getAccessToken() ?? '';
      await remoteDataSource.logout(token);
      await secureStorage.clearAll();
      SecureLogger.instance.audit('Logout');
      return const Right(unit);
    } catch (e) {
      await secureStorage.clearAll();
      return const Right(unit);
    }
  }

  @override
  Future<Either<Failure, Unit>> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyOtp(
    String email,
    String otp,
  ) async {
    try {
      await remoteDataSource.verifyOtp(email, otp);
      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    final id = await secureStorage.getUserId();
    if (id == null) return const Right(null);
    return const Right(null);
  }

  @override
  Future<Either<Failure, String>> refreshToken(String token) async {
    try {
      final data = await remoteDataSource.refreshToken(token);
      final newToken = data['access_token'] as String;
      await secureStorage.saveAccessToken(newToken);
      return Right(newToken);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
