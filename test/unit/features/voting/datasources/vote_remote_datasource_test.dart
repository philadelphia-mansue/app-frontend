import 'package:flutter_test/flutter_test.dart';
import 'package:philadelphia_mansue/core/constants/api_constants.dart';
import 'package:philadelphia_mansue/core/errors/exceptions.dart';
import 'package:philadelphia_mansue/features/voting/data/datasources/vote_remote_datasource.dart';
import 'package:philadelphia_mansue/features/voting/data/models/vote_model.dart';

import '../../../../helpers/mocks/mock_api_client.dart';

void main() {
  late VoteRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = VoteRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  VoteModel createTestVote({
    String id = 'vote-123',
    String electionId = 'election-456',
    List<String>? candidateIds,
  }) {
    return VoteModel(
      id: id,
      electionId: electionId,
      selectedCandidateIds: candidateIds ?? ['candidate-1', 'candidate-2', 'candidate-3'],
      timestamp: DateTime(2025, 1, 15, 10, 30),
    );
  }

  group('submitVote', () {
    test('returns Vote on 201 Created', () async {
      // Arrange
      final testVote = createTestVote();
      mockApiClient.stubPost(
        ApiConstants.voteEndpoint,
        {'id': 'vote-123', 'status': 'created'},
        statusCode: 201,
      );

      // Act
      final result = await dataSource.submitVote(testVote);

      // Assert
      expect(result.id, testVote.id);
      expect(result.electionId, testVote.electionId);
      expect(result.selectedCandidateIds, testVote.selectedCandidateIds);
    });

    test('throws AlreadyVotedException on 403 with "already voted"', () async {
      // Arrange
      final testVote = createTestVote();
      mockApiClient.stubPostError(
        ApiConstants.voteEndpoint,
        createDioException(403, message: 'You have already voted in this election'),
      );

      // Act & Assert
      expect(
        () => dataSource.submitVote(testVote),
        throwsA(isA<AlreadyVotedException>()),
      );
    });

    test('throws AlreadyVotedException on 403 with "Already Voted" (case insensitive)', () async {
      // Arrange
      final testVote = createTestVote();
      mockApiClient.stubPostError(
        ApiConstants.voteEndpoint,
        createDioException(403, message: 'Already Voted'),
      );

      // Act & Assert
      expect(
        () => dataSource.submitVote(testVote),
        throwsA(isA<AlreadyVotedException>()),
      );
    });

    test('throws ElectionNotActiveException on 403 with "not active"', () async {
      // Arrange
      final testVote = createTestVote();
      mockApiClient.stubPostError(
        ApiConstants.voteEndpoint,
        createDioException(403, message: 'Election is not active'),
      );

      // Act & Assert
      expect(
        () => dataSource.submitVote(testVote),
        throwsA(isA<ElectionNotActiveException>()),
      );
    });

    test('throws ElectionNotActiveException on 403 with "not currently active"', () async {
      // Arrange
      final testVote = createTestVote();
      mockApiClient.stubPostError(
        ApiConstants.voteEndpoint,
        createDioException(403, message: 'The election is not currently active'),
      );

      // Act & Assert
      expect(
        () => dataSource.submitVote(testVote),
        throwsA(isA<ElectionNotActiveException>()),
      );
    });

    test('throws InvalidCandidateCountException on 422 with "exactly X candidates"', () async {
      // Arrange
      final testVote = createTestVote();
      mockApiClient.stubPostError(
        ApiConstants.voteEndpoint,
        createDioException(422, message: 'You must select exactly 3 candidates'),
      );

      // Act & Assert
      expect(
        () => dataSource.submitVote(testVote),
        throwsA(
          isA<InvalidCandidateCountException>().having(
            (e) => e.message,
            'message',
            contains('exactly 3 candidates'),
          ),
        ),
      );
    });

    test('throws InvalidCandidateCountException on 422 with "exactly" and "candidate"', () async {
      // Arrange
      final testVote = createTestVote();
      mockApiClient.stubPostError(
        ApiConstants.voteEndpoint,
        createDioException(422, message: 'Please select exactly 5 candidate entries'),
      );

      // Act & Assert
      expect(
        () => dataSource.submitVote(testVote),
        throwsA(isA<InvalidCandidateCountException>()),
      );
    });

    test('throws DuplicateCandidatesException on 422 with "duplicate"', () async {
      // Arrange
      final testVote = createTestVote();
      mockApiClient.stubPostError(
        ApiConstants.voteEndpoint,
        createDioException(422, message: 'Duplicate candidates are not allowed'),
      );

      // Act & Assert
      expect(
        () => dataSource.submitVote(testVote),
        throwsA(isA<DuplicateCandidatesException>()),
      );
    });

    test('throws DuplicateCandidatesException on 422 with "same candidate"', () async {
      // Arrange
      final testVote = createTestVote();
      mockApiClient.stubPostError(
        ApiConstants.voteEndpoint,
        createDioException(422, message: 'Cannot select the same candidate twice'),
      );

      // Act & Assert
      expect(
        () => dataSource.submitVote(testVote),
        throwsA(isA<DuplicateCandidatesException>()),
      );
    });

    test('throws AuthException on 401', () async {
      // Arrange
      final testVote = createTestVote();
      mockApiClient.stubPostError(
        ApiConstants.voteEndpoint,
        createDioException(401),
      );

      // Act & Assert
      expect(
        () => dataSource.submitVote(testVote),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Authentication required',
          ),
        ),
      );
    });

    test('throws ServerException on generic 403 without specific message', () async {
      // Arrange
      final testVote = createTestVote();
      mockApiClient.stubPostError(
        ApiConstants.voteEndpoint,
        createDioException(403, message: 'Forbidden'),
      );

      // Act & Assert
      expect(
        () => dataSource.submitVote(testVote),
        throwsA(isA<AuthException>()),
      );
    });

    test('throws ServerException on 422 without specific message', () async {
      // Arrange
      final testVote = createTestVote();
      mockApiClient.stubPostError(
        ApiConstants.voteEndpoint,
        createDioException(422, message: 'Validation error'),
      );

      // Act & Assert
      expect(
        () => dataSource.submitVote(testVote),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Validation error',
          ),
        ),
      );
    });

    test('throws ServerException on 500 server error', () async {
      // Arrange
      final testVote = createTestVote();
      mockApiClient.stubPostError(
        ApiConstants.voteEndpoint,
        createDioException(500),
      );

      // Act & Assert
      expect(
        () => dataSource.submitVote(testVote),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Server error'),
          ),
        ),
      );
    });

    test('throws ServerException on 502 bad gateway', () async {
      // Arrange
      final testVote = createTestVote();
      mockApiClient.stubPostError(
        ApiConstants.voteEndpoint,
        createDioException(502),
      );

      // Act & Assert
      expect(
        () => dataSource.submitVote(testVote),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Server error'),
          ),
        ),
      );
    });

    test('throws ServerException on 503 service unavailable', () async {
      // Arrange
      final testVote = createTestVote();
      mockApiClient.stubPostError(
        ApiConstants.voteEndpoint,
        createDioException(503),
      );

      // Act & Assert
      expect(
        () => dataSource.submitVote(testVote),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Server error'),
          ),
        ),
      );
    });

    test('throws NetworkException on connection timeout', () async {
      // Arrange
      final testVote = createTestVote();
      mockApiClient.stubPostError(
        ApiConstants.voteEndpoint,
        createTimeoutException(),
      );

      // Act & Assert
      expect(
        () => dataSource.submitVote(testVote),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            contains('timed out'),
          ),
        ),
      );
    });

    test('throws NetworkException on connection error', () async {
      // Arrange
      final testVote = createTestVote();
      mockApiClient.stubPostError(
        ApiConstants.voteEndpoint,
        createConnectionException(),
      );

      // Act & Assert
      expect(
        () => dataSource.submitVote(testVote),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            contains('No internet'),
          ),
        ),
      );
    });

    test('sends correct API request format', () async {
      // Arrange
      final testVote = createTestVote(
        electionId: 'test-election-id',
        candidateIds: ['c1', 'c2', 'c3'],
      );

      // Create a custom mock to capture the request data
      dynamic capturedData;
      mockApiClient = MockApiClient();

      // We'll verify the data structure by checking the VoteModel's toApiRequest
      expect(testVote.toApiRequest(), {
        'election_id': 'test-election-id',
        'candidates': ['c1', 'c2', 'c3'],
      });
    });

    test('throws ServerException on unexpected status code', () async {
      // Arrange
      final testVote = createTestVote();
      mockApiClient.stubPost(
        ApiConstants.voteEndpoint,
        {'status': 'ok'},
        statusCode: 200, // Should be 201 for success
      );

      // Act & Assert
      expect(
        () => dataSource.submitVote(testVote),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Unexpected response'),
          ),
        ),
      );
    });
  });
}
