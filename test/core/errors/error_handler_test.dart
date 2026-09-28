import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clinicflow/core/errors/error_handler.dart';
import 'package:clinicflow/core/errors/failures.dart';
import 'package:clinicflow/core/errors/exceptions.dart';

void main() {
  group('ErrorHandler', () {
    test('maps UnauthorizedException to UnauthorizedFailure', () {
      final result = ErrorHandler.handleException(
        const UnauthorizedException(),
      );
      expect(result, isA<UnauthorizedFailure>());
    });

    test('maps NotFoundException to NotFoundFailure', () {
      final result = ErrorHandler.handleException(
        const NotFoundException(),
      );
      expect(result, isA<NotFoundFailure>());
    });

    test('maps NoInternetException to NoInternetFailure', () {
      final result = ErrorHandler.handleException(
        const NoInternetException(),
      );
      expect(result, isA<NoInternetFailure>());
    });

    test('maps CacheException to CacheFailure', () {
      final result = ErrorHandler.handleException(
        const CacheException(message: 'Cache error'),
      );
      expect(result, isA<CacheFailure>());
    });

    test('maps unknown exception to UnknownFailure', () {
      final result = ErrorHandler.handleException(
        Exception('Unknown'),
      );
      expect(result, isA<UnknownFailure>());
    });
  });
}
