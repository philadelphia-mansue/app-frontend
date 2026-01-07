import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:philadelphia_mansue/core/errors/failures.dart';
import 'package:philadelphia_mansue/features/voting/domain/usecases/submit_vote.dart';

import '../../../../helpers/fixtures/vote_fixture.dart';
import '../../../../helpers/mocks/mock_repositories.dart';

void main() {
  late MockVoteRepository mockRepository;
  late SubmitVote useCase;

  setUp(() {
    mockRepository = MockVoteRepository();
    useCase = SubmitVote(mockRepository);
  });

  group('SubmitVote UseCase', () {
    final testVote = createTestVote();

    test('should return Right(Vote) on success', () async {
      // Arrange
      mockSubmitVoteSuccess(mockRepository, testVote);

      // Act
      final result = await useCase(testVote);

      // Assert
      expect(result, equals(Right(testVote)));
    });

    test('should return Left(ValidationFailure) when no candidates selected', () async {
      // Arrange
      final emptyVote = createVoteWithNoCandidates();

      // Act
      final result = await useCase(emptyVote);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('No candidates'));
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should return Left(ValidationFailure) when election ID is empty', () async {
      // Arrange
      final invalidVote = createVoteWithEmptyElectionId();

      // Act
      final result = await useCase(invalidVote);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Election ID'));
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should return Left(DuplicateCandidatesFailure) when duplicates exist', () async {
      // Arrange
      final duplicateVote = createVoteWithDuplicates();

      // Act
      final result = await useCase(duplicateVote);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<DuplicateCandidatesFailure>());
          expect(failure.message, contains('Duplicate'));
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should return Left(AlreadyVotedFailure) from repository', () async {
      // Arrange
      const failure = AlreadyVotedFailure('Already voted');
      mockSubmitVoteFailure(mockRepository, failure);

      // Act
      final result = await useCase(testVote);

      // Assert
      expect(result, equals(const Left(failure)));
    });

    test('should return Left(ElectionNotActiveFailure) from repository', () async {
      // Arrange
      const failure = ElectionNotActiveFailure('Election ended');
      mockSubmitVoteFailure(mockRepository, failure);

      // Act
      final result = await useCase(testVote);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ElectionNotActiveFailure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return Left(InvalidCandidateCountFailure) from repository', () async {
      // Arrange
      const failure = InvalidCandidateCountFailure('Wrong count');
      mockSubmitVoteFailure(mockRepository, failure);

      // Act
      final result = await useCase(testVote);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<InvalidCandidateCountFailure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return Left(NetworkFailure) on network error', () async {
      // Arrange
      const failure = NetworkFailure('Network error');
      mockSubmitVoteFailure(mockRepository, failure);

      // Act
      final result = await useCase(testVote);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return Left(AuthFailure) on auth error', () async {
      // Arrange
      const failure = AuthFailure('Not authenticated');
      mockSubmitVoteFailure(mockRepository, failure);

      // Act
      final result = await useCase(testVote);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });
}
