import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'exceptions.dart';
import 'failures.dart';
import '../security/secure_logger.dart';

class ErrorHandler {
  static Failure handleException(dynamic exception) {
    if (exception is DioException) return _handleDio(exception);
    if (exception is UnauthorizedException) return const UnauthorizedFailure();
    if (exception is ForbiddenException) return const ForbiddenFailure();
    if (exception is NotFoundException) return const NotFoundFailure();
    if (exception is ValidationException) {
      return ValidationFailure(
        message: exception.message,
        fieldErrors: exception.fieldErrors,
      );
    }
    if (exception is NoInternetException) return const NoInternetFailure();
    if (exception is TimeoutException) return const TimeoutFailure();
    if (exception is CacheException) {
      return CacheFailure(message: exception.message);
    }
    if (exception is StorageException) {
      return StorageFailure(message: exception.message);
    }
    if (exception is EncryptionException) {
      return EncryptionFailure(message: exception.message);
    }
    if (exception is SessionExpiredException) {
      return const SessionExpiredFailure();
    }
    if (exception is BiometricException) {
      return BiometricFailure(message: exception.message);
    }
    if (exception is NetworkException) {
      return ServerFailure(
        message: exception.message,
        statusCode: exception.statusCode,
      );
    }
    if (exception is AppException) {
      return ServerFailure(message: exception.message, code: exception.code);
    }
    SecureLogger.instance.warning(
      'Unhandled exception: ${exception.runtimeType}',
    );
    return const UnknownFailure();
  }

  static Failure _handleDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
        return const NoInternetFailure();
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        final msg = _extractMsg(e.response?.data) ?? 'Server error';
        switch (code) {
          case 401:
            return const UnauthorizedFailure();
          case 403:
            return const ForbiddenFailure();
          case 404:
            return const NotFoundFailure();
          case 429:
            return const RateLimitFailure();
          default:
            SecureLogger.instance.warning('HTTP $code error');
            return ServerFailure(
              message: msg,
              statusCode: code,
              code: code?.toString(),
            );
        }
      case DioExceptionType.cancel:
        return const NetworkFailure(message: 'Request was cancelled');
      default:
        return const NetworkFailure();
    }
  }

  static String? _extractMsg(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          data['detail']?.toString();
    }
    return null;
  }
}

extension EitherExtensions<T> on Future<T> {
  Future<Either<Failure, T>> toEither() async {
    try {
      return Right(await this);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
