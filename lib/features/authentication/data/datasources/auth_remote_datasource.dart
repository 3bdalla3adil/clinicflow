import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String? dateOfBirth,
    String? gender,
  });
  Future<void> logout(String accessToken);
  Future<void> forgotPassword(String email);
  Future<void> verifyOtp(String email, String otp);
  Future<Map<String, dynamic>> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;
  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final resp = await dioClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return resp.data as Map<String, dynamic>;
    } catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    String? dateOfBirth,
    String? gender,
  }) async {
    try {
      final resp = await dioClient.post(
        ApiConstants.register,
        data: {
          'full_name': fullName,
          'email': email,
          'password': password,
          'phone': phone,
          if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
          if (gender != null) 'gender': gender,
        },
      );
      return resp.data as Map<String, dynamic>;
    } catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<void> logout(String accessToken) async {
    try {
      await dioClient.post(ApiConstants.logout);
    } catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await dioClient.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
    } catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<void> verifyOtp(String email, String otp) async {
    try {
      await dioClient.post(
        ApiConstants.verifyOtp,
        data: {'email': email, 'otp': otp},
      );
    } catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String token) async {
    try {
      final resp = await dioClient.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': token},
      );
      return resp.data as Map<String, dynamic>;
    } catch (e) {
      throw _map(e);
    }
  }

  AppException _map(dynamic e) =>
      e is AppException ? e : AppException(message: e.toString());
}
