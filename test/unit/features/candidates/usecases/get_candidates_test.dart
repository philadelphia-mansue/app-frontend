import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:philadelphia_mansue/core/errors/failures.dart';
import 'package:philadelphia_mansue/core/usecases/usecase.dart';
import 'package:philadelphia_mansue/features/candidates/domain/usecases/get_candidates.dart';

import '../../../../helpers/fixtures/candidate_fixture.dart';
import '../../../../helpers/mocks/mock_repositories.dart';

void main() {
  late MockCandidateRepository mockRepository;
  late GetCandidates useCase;

  setUp(() {
    mockRepository = MockCandidateRepository();
    useCase = GetCandidates(mockRepository);
  });

  group('GetCandidates UseCase', () {
    final testCandidates = createTestCandidates(15);

    test('should return Right(List<Candidate>) on success', () async {
      // Arrange
      mockGetCandidatesSuccess(mockRepository, testCandidates);

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return Right'),
        (candidates) {
          expect(candidates, equals(testCandidates));
          expect(candidates.length, equals(15));
        },
      );
    });

    test('should return empty list when no candidates', () async {
      // Arrange
      mockGetCandidatesSuccess(mockRepository, []);

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return Right'),
        (candidates) => expect(candidates, isEmpty),
      );
    });

    test('should return Left(ServerFailure) on server error', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      mockGetCandidatesFailure(mockRepository, failure);

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, equals(const Left(failure)));
    });

    test('should return Left(NetworkFailure) on network error', () async {
      // Arrange
      const failure = NetworkFailure('No connection');
      mockGetCandidatesFailure(mockRepository, failure);

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return candidates with all required properties', () async {
      // Arrange
      final candidates = [
        createTestCandidate(
          id: 'c1',
          firstName: 'John',
          lastName: 'Doe',
          photoUrl: 'https://example.com/john.jpg',
        ),
      ];
      mockGetCandidatesSuccess(mockRepository, candidates);

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return Right'),
        (candidates) {
          final candidate = candidates.first;
          expect(candidate.id, equals('c1'));
          expect(candidate.firstName, equals('John'));
          expect(candidate.lastName, equals('Doe'));
          expect(candidate.photoUrl, equals('https://example.com/john.jpg'));
          expect(candidate.fullName, equals('John Doe'));
        },
      );
    });
  });
}
