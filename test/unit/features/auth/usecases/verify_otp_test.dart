import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:philadelphia_mansue/core/errors/failures.dart';
import 'package:philadelphia_mansue/features/auth/domain/usecases/verify_otp.dart';

import '../../../../helpers/fixtures/voter_fixture.dart';
import '../../../../helpers/mocks/mock_repositories.dart';

void main() {
  late MockAuthRepository mockRepository;
  late VerifyOtp useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = VerifyOtp(mockRepository);
  });

  group('VerifyOtp UseCase', () {
    const testVerificationId = 'verification-123';
    const testOtp = '123456';
    final testVoter = createTestVoter();

    test('should return Right(Voter) on success', () async {
      // Arrange
      mockVerifyOtpSuccess(mockRepository, testVoter);

      // Act
      final result = await useCase(
        const VerifyOtpParams(
          verificationId: testVerificationId,
          otp: testOtp,
        ),
      );

      // Assert
      expect(result, equals(Right(testVoter)));
    });

    test('should return Left(AuthFailure) on invalid OTP', () async {
      // Arrange
      const failure = AuthFailure('Invalid OTP code');
      mockVerifyOtpFailure(mockRepository, failure);

      // Act
      final result = await useCase(
        const VerifyOtpParams(
          verificationId: testVerificationId,
          otp: 'wrong-otp',
        ),
      );

      // Assert
      expect(result, equals(const Left(failure)));
    });

    test('should return Left(AuthFailure) on expired verification ID', () async {
      // Arrange
      const failure = AuthFailure('Verification ID expired');
      mockVerifyOtpFailure(mockRepository, failure);

      // Act
      final result = await useCase(
        const VerifyOtpParams(
          verificationId: 'expired-id',
          otp: testOtp,
        ),
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, contains('expired')),
        (_) => fail('Should return Left'),
      );
    });

    test('should return Left(NetworkFailure) on network error', () async {
      // Arrange
      const failure = NetworkFailure('Network error');
      mockVerifyOtpFailure(mockRepository, failure);

      // Act
      final result = await useCase(
        const VerifyOtpParams(
          verificationId: testVerificationId,
          otp: testOtp,
        ),
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
      const failure = ServerFailure('Server error');
      mockVerifyOtpFailure(mockRepository, failure);

      // Act
      final result = await useCase(
        const VerifyOtpParams(
          verificationId: testVerificationId,
          otp: testOtp,
        ),
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return voter with correct properties', () async {
      // Arrange
      final customVoter = createTestVoter(
        id: 'custom-voter-id',
        firstName: 'Jane',
        lastName: 'Doe',
        phone: '+9876543210',
      );
      mockVerifyOtpSuccess(mockRepository, customVoter);

      // Act
      final result = await useCase(
        const VerifyOtpParams(
          verificationId: testVerificationId,
          otp: testOtp,
        ),
      );

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return Right'),
        (voter) {
          expect(voter.id, equals('custom-voter-id'));
          expect(voter.firstName, equals('Jane'));
          expect(voter.lastName, equals('Doe'));
          expect(voter.phone, equals('+9876543210'));
        },
      );
    });

    test('should successfully call with custom parameters', () async {
      // Arrange
      mockVerifyOtpSuccess(mockRepository, testVoter);

      // Act
      final result = await useCase(
        const VerifyOtpParams(
          verificationId: 'custom-verification-id',
          otp: '654321',
        ),
      );

      // Assert
      expect(result.isRight(), isTrue);
    });

    test('should handle rate limiting failure', () async {
      // Arrange
      const failure = AuthFailure('Too many attempts. Please try again later.');
      mockVerifyOtpFailure(mockRepository, failure);

      // Act
      final result = await useCase(
        const VerifyOtpParams(
          verificationId: testVerificationId,
          otp: testOtp,
        ),
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, contains('Too many')),
        (_) => fail('Should return Left'),
      );
    });
  });
}
