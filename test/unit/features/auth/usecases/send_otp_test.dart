import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:philadelphia_mansue/core/errors/failures.dart';
import 'package:philadelphia_mansue/features/auth/domain/usecases/send_otp.dart';

import '../../../../helpers/mocks/mock_repositories.dart';

void main() {
  late MockAuthRepository mockRepository;
  late SendOtp useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SendOtp(mockRepository);
  });

  group('SendOtp UseCase', () {
    const testPhoneNumber = '+1234567890';
    const testVerificationId = 'verification-123';

    test('should return Right(verificationId) on success', () async {
      // Arrange
      mockSendOtpSuccess(mockRepository, testVerificationId);

      // Act
      final result = await useCase(
        const SendOtpParams(phoneNumber: testPhoneNumber),
      );

      // Assert
      expect(result, equals(const Right(testVerificationId)));
    });

    test('should return Left(AuthFailure) on invalid phone', () async {
      // Arrange
      const failure = AuthFailure('Invalid phone number');
      mockSendOtpFailure(mockRepository, failure);

      // Act
      final result = await useCase(
        const SendOtpParams(phoneNumber: 'invalid'),
      );

      // Assert
      expect(result, equals(const Left(failure)));
    });

    test('should return Left(NetworkFailure) on network error', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      mockSendOtpFailure(mockRepository, failure);

      // Act
      final result = await useCase(
        const SendOtpParams(phoneNumber: testPhoneNumber),
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return Left(ServerFailure) on server error', () async {
      // Arrange
      const failure = ServerFailure('Server unavailable');
      mockSendOtpFailure(mockRepository, failure);

      // Act
      final result = await useCase(
        const SendOtpParams(phoneNumber: testPhoneNumber),
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return Right for different phone numbers', () async {
      // Arrange
      const customPhone = '+9876543210';
      mockSendOtpSuccess(mockRepository, testVerificationId);

      // Act
      final result = await useCase(const SendOtpParams(phoneNumber: customPhone));

      // Assert
      expect(result.isRight(), isTrue);
    });

    test('should return failure for empty phone number', () async {
      // Arrange
      const failure = AuthFailure('Phone number is required');
      mockSendOtpFailure(mockRepository, failure);

      // Act
      final result = await useCase(const SendOtpParams(phoneNumber: ''));

      // Assert
      expect(result.isLeft(), isTrue);
    });
  });
}
