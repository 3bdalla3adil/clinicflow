import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clinicflow/features/authentication/domain/entities/user.dart';
import 'package:clinicflow/features/authentication/domain/repositories/auth_repository.dart';
import 'package:clinicflow/features/authentication/domain/usecases/login_usecase.dart';
import 'package:clinicflow/core/errors/failures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = LoginUseCase(mockRepo);
  });

  final tUser = User(
    id: '1',
    email: 'test@example.com',
    fullName: 'Test User',
    role: UserRole.patient,
    createdAt: DateTime(2024),
  );

  group('LoginUseCase', () {
    test('returns User on success', () async {
      when(() => mockRepo.login(any(), any()))
          .thenAnswer((_) async => Right(tUser));
      final result = await useCase(
        const LoginParams(
          email: 'test@example.com',
          password: 'password123',
        ),
      );
      expect(result, Right(tUser));
    });

    test('returns AuthFailure on wrong credentials', () async {
      when(() => mockRepo.login(any(), any())).thenAnswer(
        (_) async =>
            const Left(AuthFailure(message: 'Invalid credentials')),
      );
      final result = await useCase(
        const LoginParams(
          email: 'test@example.com',
          password: 'wrong',
        ),
      );
      expect(result.isLeft(), true);
    });

    test('returns UnauthorizedFailure on 401', () async {
      when(() => mockRepo.login(any(), any())).thenAnswer(
        (_) async => const Left(UnauthorizedFailure()),
      );
      final result = await useCase(
        const LoginParams(
          email: 'test@example.com',
          password: 'password123',
        ),
      );
      expect(result, const Left(UnauthorizedFailure()));
    });
  });
}
