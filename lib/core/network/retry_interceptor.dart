import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  RetryInterceptor({required this.dio});

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retryCount =
        (err.requestOptions.extra['retryCount'] as int?) ?? 0;
    if (!_shouldRetry(err) || retryCount >= AppConstants.maxRetryAttempts) {
      handler.next(err);
      return;
    }
    await Future.delayed(AppConstants.retryDelay * (retryCount + 1));
    err.requestOptions.extra['retryCount'] = retryCount + 1;
    try {
      handler.resolve(await dio.fetch(err.requestOptions));
    } catch (_) {
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException e) =>
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.connectionError ||
      (e.response?.statusCode != null && e.response!.statusCode! >= 500);
}
