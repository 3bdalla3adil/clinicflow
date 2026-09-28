class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic data;
  const AppException({required this.message, this.code, this.data});
  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

class NetworkException extends AppException {
  final int? statusCode;
  const NetworkException({
    required super.message,
    super.code,
    this.statusCode,
    super.data,
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Unauthorized',
    super.code = '401',
  });
}

class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'Forbidden',
    super.code = '403',
  });
}

class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Not found',
    super.code = '404',
  });
}

class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;
  const ValidationException({
    required super.message,
    super.code = '422',
    this.fieldErrors,
  });
}

class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Request timed out',
    super.code = 'TIMEOUT',
  });
}

class NoInternetException extends AppException {
  const NoInternetException({
    super.message = 'No internet connection',
    super.code = 'NO_INTERNET',
  });
}

class CacheException extends AppException {
  const CacheException({required super.message, super.code = 'CACHE_ERROR'});
}

class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code = 'STORAGE_ERROR',
  });
}

class EncryptionException extends AppException {
  const EncryptionException({
    required super.message,
    super.code = 'ENCRYPTION_ERROR',
  });
}

class BiometricException extends AppException {
  const BiometricException({required super.message, super.code});
}

class SessionExpiredException extends AppException {
  const SessionExpiredException({
    super.message = 'Session expired',
    super.code = 'SESSION_EXPIRED',
  });
}
