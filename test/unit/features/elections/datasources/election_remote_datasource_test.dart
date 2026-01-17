import 'package:flutter_test/flutter_test.dart';
import 'package:philadelphia_mansue/core/constants/api_constants.dart';
import 'package:philadelphia_mansue/core/errors/exceptions.dart';
import 'package:philadelphia_mansue/features/elections/data/datasources/election_remote_datasource.dart';
import 'package:philadelphia_mansue/features/elections/domain/entities/election.dart';

import '../../../../helpers/mocks/mock_api_client.dart';

void main() {
  late ElectionRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = ElectionRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  // Sample election response matching API format
  Map<String, dynamic> createElectionResponse({
    String id = 'election-123',
    String name = 'Test Election',
    String description = 'Test Description',
    String status = 'ongoing',
    int requiredVotesCount = 3,
    bool hasVoted = false,
    List<Map<String, dynamic>>? candidates,
  }) {
    return {
      'data': {
        'id': id,
        'name': name,
        'description': description,
        'status': status,
        'start_date': '2025-01-01T00:00:00.000Z',
        'end_date': '2025-12-31T23:59:59.000Z',
        'required_votes_count': requiredVotesCount,
        'has_voted': hasVoted,
        'candidates': candidates ??
            [
              {
                'id': 'candidate-1',
                'first_name': 'John',
                'last_name': 'Doe',
                'bio': 'Bio 1',
                'photo_url': 'https://example.com/photo1.jpg',
              },
              {
                'id': 'candidate-2',
                'first_name': 'Jane',
                'last_name': 'Smith',
                'bio': 'Bio 2',
                'photo_url': 'https://example.com/photo2.jpg',
              },
            ],
      },
    };
  }

  group('getElectionById', () {
    const testElectionId = 'election-123';
    final electionPath = '${ApiConstants.electionsEndpoint}/$testElectionId';

    test('returns ElectionModel on 200', () async {
      // Arrange
      mockApiClient.stubGet(electionPath, createElectionResponse());

      // Act
      final result = await dataSource.getElectionById(testElectionId);

      // Assert
      expect(result.id, 'election-123');
      expect(result.name, 'Test Election');
      expect(result.description, 'Test Description');
      expect(result.status, ElectionStatus.ongoing);
      expect(result.requiredVotesCount, 3);
      expect(result.hasVoted, false);
      expect(result.candidates.length, 2);
    });

    test('parses candidates correctly', () async {
      // Arrange
      mockApiClient.stubGet(electionPath, createElectionResponse());

      // Act
      final result = await dataSource.getElectionById(testElectionId);

      // Assert
      expect(result.candidates[0].id, 'candidate-1');
      expect(result.candidates[0].firstName, 'John');
      expect(result.candidates[0].lastName, 'Doe');
      expect(result.candidates[1].id, 'candidate-2');
      expect(result.candidates[1].firstName, 'Jane');
    });

    test('throws ServerException with "NOT_PREVALIDATED" on 403', () async {
      // Arrange
      mockApiClient.stubGetError(
        electionPath,
        createDioException(403, message: 'NOT_PREVALIDATED'),
      );

      // Act & Assert
      expect(
        () => dataSource.getElectionById(testElectionId),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'NOT_PREVALIDATED',
          ),
        ),
      );
    });

    test('throws ServerException with "Session expired" on 401', () async {
      // Arrange
      mockApiClient.stubGetError(
        electionPath,
        createDioException(401),
      );

      // Act & Assert
      expect(
        () => dataSource.getElectionById(testElectionId),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Session expired'),
          ),
        ),
      );
    });

    test('throws ServerException on other DioException', () async {
      // Arrange
      mockApiClient.stubGetError(
        electionPath,
        createDioException(500, message: 'Internal server error'),
      );

      // Act & Assert
      expect(
        () => dataSource.getElectionById(testElectionId),
        throwsA(isA<ServerException>()),
      );
    });

    test('parses different election statuses correctly', () async {
      // Arrange - Test "ended" status
      mockApiClient.stubGet(
        electionPath,
        createElectionResponse(status: 'ended'),
      );

      // Act
      final endedResult = await dataSource.getElectionById(testElectionId);

      // Assert
      expect(endedResult.status, ElectionStatus.ended);
    });

    test('parses hasVoted flag correctly', () async {
      // Arrange
      mockApiClient.stubGet(
        electionPath,
        createElectionResponse(hasVoted: true),
      );

      // Act
      final result = await dataSource.getElectionById(testElectionId);

      // Assert
      expect(result.hasVoted, true);
    });
  });

  group('hasActiveElection', () {
    test('returns true when has_active_election is true', () async {
      // Arrange
      mockApiClient.stubGet(
        ApiConstants.electionsActive,
        {'has_active_election': true},
      );

      // Act
      final result = await dataSource.hasActiveElection();

      // Assert
      expect(result, true);
    });

    test('returns false when has_active_election is false', () async {
      // Arrange
      mockApiClient.stubGet(
        ApiConstants.electionsActive,
        {'has_active_election': false},
      );

      // Act
      final result = await dataSource.hasActiveElection();

      // Assert
      expect(result, false);
    });

    test('returns false when has_active_election is null', () async {
      // Arrange
      mockApiClient.stubGet(
        ApiConstants.electionsActive,
        {'has_active_election': null},
      );

      // Act
      final result = await dataSource.hasActiveElection();

      // Assert
      expect(result, false);
    });

    test('throws ServerException on DioException', () async {
      // Arrange - Implementation uses DioException.message as fallback
      mockApiClient.stubGetError(
        ApiConstants.electionsActive,
        createDioException(500),
      );

      // Act & Assert
      expect(
        () => dataSource.hasActiveElection(),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Failed to check active elections',
          ),
        ),
      );
    });

    test('throws ServerException on network timeout', () async {
      // Arrange
      mockApiClient.stubGetError(
        ApiConstants.electionsActive,
        createTimeoutException(),
      );

      // Act & Assert
      expect(
        () => dataSource.hasActiveElection(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getOngoingElection', () {
    test('returns null when no elections exist', () async {
      // Arrange
      mockApiClient.stubGet(ApiConstants.electionsEndpoint, []);

      // Act
      final result = await dataSource.getOngoingElection();

      // Assert
      expect(result, isNull);
    });

    test('returns null when data is null', () async {
      // Arrange
      mockApiClient.stubGet(ApiConstants.electionsEndpoint, null);

      // Act
      final result = await dataSource.getOngoingElection();

      // Assert
      expect(result, isNull);
    });

    test('handles list response format', () async {
      // Arrange - First call returns list of elections
      mockApiClient.stubGet(ApiConstants.electionsEndpoint, [
        {'id': 'election-123'},
      ]);
      // Second call gets full election details
      mockApiClient.stubGet(
        '${ApiConstants.electionsEndpoint}/election-123',
        createElectionResponse(),
      );

      // Act
      final result = await dataSource.getOngoingElection();

      // Assert
      expect(result, isNotNull);
      expect(result!.id, 'election-123');
    });

    test('handles wrapped list response format', () async {
      // Arrange - First call returns wrapped list
      mockApiClient.stubGet(ApiConstants.electionsEndpoint, {
        'data': [
          {'id': 'election-456'},
        ],
      });
      // Second call gets full election details
      mockApiClient.stubGet(
        '${ApiConstants.electionsEndpoint}/election-456',
        createElectionResponse(id: 'election-456'),
      );

      // Act
      final result = await dataSource.getOngoingElection();

      // Assert
      expect(result, isNotNull);
      expect(result!.id, 'election-456');
    });

    test('handles single election response format', () async {
      // Arrange
      mockApiClient.stubGet(
        ApiConstants.electionsEndpoint,
        createElectionResponse(id: 'single-election'),
      );

      // Act
      final result = await dataSource.getOngoingElection();

      // Assert
      expect(result, isNotNull);
      expect(result!.id, 'single-election');
    });

    test('throws ServerException on 401', () async {
      // Arrange
      mockApiClient.stubGetError(
        ApiConstants.electionsEndpoint,
        createDioException(401),
      );

      // Act & Assert
      expect(
        () => dataSource.getOngoingElection(),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Session expired'),
          ),
        ),
      );
    });

    test('rethrows ServerException from getElectionById', () async {
      // Arrange
      mockApiClient.stubGet(ApiConstants.electionsEndpoint, [
        {'id': 'election-789'},
      ]);
      mockApiClient.stubGetError(
        '${ApiConstants.electionsEndpoint}/election-789',
        createDioException(403, message: 'NOT_PREVALIDATED'),
      );

      // Act & Assert
      expect(
        () => dataSource.getOngoingElection(),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'NOT_PREVALIDATED',
          ),
        ),
      );
    });
  });
}
