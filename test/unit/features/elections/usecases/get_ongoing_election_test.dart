import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:philadelphia_mansue/core/errors/failures.dart';
import 'package:philadelphia_mansue/core/usecases/usecase.dart';
import 'package:philadelphia_mansue/features/elections/domain/entities/election.dart';
import 'package:philadelphia_mansue/features/elections/domain/usecases/get_ongoing_election.dart';

import '../../../../helpers/fixtures/election_fixture.dart';
import '../../../../helpers/mocks/mock_repositories.dart';

void main() {
  late MockElectionRepository mockRepository;
  late GetOngoingElection useCase;

  setUp(() {
    mockRepository = MockElectionRepository();
    useCase = GetOngoingElection(mockRepository);
  });

  group('GetOngoingElection UseCase', () {
    final activeElection = createActiveElection();

    test('should return Right(Election) when active election exists', () async {
      // Arrange
      mockGetOngoingElectionSuccess(mockRepository, activeElection);

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return Right'),
        (election) {
          expect(election, equals(activeElection));
          expect(election!.isActive, isTrue);
        },
      );
    });

    test('should return Right(null) when no active election', () async {
      // Arrange
      mockGetOngoingElectionSuccess(mockRepository, null);

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return Right'),
        (election) => expect(election, isNull),
      );
    });

    test('should return Left(ServerFailure) on server error', () async {
      // Arrange
      const failure = ServerFailure('Server error');
      mockGetOngoingElectionFailure(mockRepository, failure);

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, equals(const Left(failure)));
    });

    test('should return Left(NetworkFailure) on network error', () async {
      // Arrange
      const failure = NetworkFailure('No connection');
      mockGetOngoingElectionFailure(mockRepository, failure);

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return election with correct properties', () async {
      // Arrange
      final election = createTestElection(
        id: 'e1',
        name: 'Test Election 2024',
        requiredVotesCount: 10,
        status: ElectionStatus.ongoing,
        hasVoted: false,
      );
      mockGetOngoingElectionSuccess(mockRepository, election);

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return Right'),
        (election) {
          expect(election!.id, equals('e1'));
          expect(election.name, equals('Test Election 2024'));
          expect(election.requiredVotesCount, equals(10));
          expect(election.isActive, isTrue);
          expect(election.hasVoted, isFalse);
          expect(election.candidates, isNotEmpty);
        },
      );
    });

    test('should correctly identify inactive (ended) election', () async {
      // Arrange
      final endedElection = createEndedElection();
      mockGetOngoingElectionSuccess(mockRepository, endedElection);

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return Right'),
        (election) => expect(election!.isActive, isFalse),
      );
    });
  });
}
