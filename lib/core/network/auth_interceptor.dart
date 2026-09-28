import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../security/secure_storage.dart';
import '../security/secure_logger.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final SecureStorageService secureStorage;
  bool _isRefreshing = false;
  final List<RequestOptions> _pending = [];

  AuthInterceptor({required this.dio, required this.secureStorage});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }
    if (_isRefreshing) {
      _pending.add(err.requestOptions);
      return;
    }
    _isRefreshing = true;
    try {
      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken == null) {
        _expire(handler, err);
        return;
      }
      final resp = await dio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );
      final newAccess = resp.data['access_token'] as String?;
      if (newAccess == null) {
        _expire(handler, err);
        return;
      }
      await secureStorage.saveAccessToken(newAccess);
      final newRefresh = resp.data['refresh_token'] as String?;
      if (newRefresh != null) {
        await secureStorage.saveRefreshToken(newRefresh);
      }
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
      handler.resolve(await dio.fetch(err.requestOptions));
      for (final p in _pending) {
        p.headers['Authorization'] = 'Bearer $newAccess';
        await dio.fetch(p);
      }
      _pending.clear();
    } catch (e) {
      SecureLogger.instance.warning('Token refresh failed — clearing session');
      _expire(handler, err);
    } finally {
      _isRefreshing = false;
    }
  }

  void _expire(ErrorInterceptorHandler handler, DioException err) {
    secureStorage.clearAuthData();
    _pending.clear();
    handler.next(err);
  }
}
