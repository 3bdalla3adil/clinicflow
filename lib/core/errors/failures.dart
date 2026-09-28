import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;
  const Failure({required this.message, this.code});
  @override
  List<Object?> get props => [message, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network connection error',
    super.code,
  });
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'Request timed out', super.code});
}

class NoInternetFailure extends Failure {
  const NoInternetFailure({
    super.message = 'No internet connection',
    super.code,
  });
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({required super.message, super.code, this.statusCode});
  @override
  List<Object?> get props => [...super.props, statusCode];
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Unauthorized. Please sign in again.',
    super.code = '401',
  });
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.message = 'Access denied.', super.code = '403'});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Resource not found.',
    super.code = '404',
  });
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;
  final int? statusCode;
  const ValidationFailure({
    required super.message,
    super.code = '422',
    this.fieldErrors,
    this.statusCode,
  });
  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

class RateLimitFailure extends Failure {
  const RateLimitFailure({
    super.message = 'Too many requests. Please wait.',
    super.code = '429',
  });
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Local cache error', super.code});
}

class StorageFailure extends Failure {
  const StorageFailure({
    super.message = 'Storage operation failed',
    super.code,
  });
}

class EncryptionFailure extends Failure {
  const EncryptionFailure({
    super.message = 'Encryption/decryption failed',
    super.code,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

class BiometricFailure extends Failure {
  const BiometricFailure({required super.message, super.code});
}

class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure({
    super.message = 'Session expired.',
    super.code = 'SESSION_EXPIRED',
  });
}

class SlotUnavailableFailure extends Failure {
  const SlotUnavailableFailure({
    super.message = 'Selected time slot is no longer available.',
    super.code = 'SLOT_UNAVAILABLE',
  });
}

class AppointmentConflictFailure extends Failure {
  const AppointmentConflictFailure({
    super.message = 'You already have an appointment at this time.',
    super.code = 'APPOINTMENT_CONFLICT',
  });
}

class PaymentFailure extends Failure {
  const PaymentFailure({required super.message, super.code});
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred.',
    super.code,
  });
}
