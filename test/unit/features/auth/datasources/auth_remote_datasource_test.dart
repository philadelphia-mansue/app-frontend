import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:philadelphia_mansue/core/constants/api_constants.dart';
import 'package:philadelphia_mansue/core/errors/exceptions.dart';
import 'package:philadelphia_mansue/core/services/token_storage_service.dart';
import 'package:philadelphia_mansue/features/auth/data/datasources/auth_remote_datasource.dart';

import '../../../../helpers/mocks/mock_api_client.dart'
    hide FakeTokenStorageService;

@GenerateMocks([firebase.FirebaseAuth, firebase.User, TokenStorageService])
import 'auth_remote_datasource_test.mocks.dart';

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockTokenStorageService mockTokenStorage;

  setUp(() {
    mockApiClient = MockApiClient();
    mockFirebaseAuth = MockFirebaseAuth();
    mockTokenStorage = MockTokenStorageService();

    dataSource = AuthRemoteDataSourceImpl(
      firebaseAuth: mockFirebaseAuth,
      apiClient: mockApiClient,
      tokenStorage: mockTokenStorage,
    );
  });

  group('checkPhone', () {
    const testPhone = '+393331234567';

    test('returns true when phone exists', () async {
      // Arrange
      mockApiClient.stubPost(
        ApiConstants.checkPhone,
        {'exists': true},
      );

      // Act
      final result = await dataSource.checkPhone(testPhone);

      // Assert
      expect(result, true);
    });

    test('returns false when phone does not exist', () async {
      // Arrange
      mockApiClient.stubPost(
        ApiConstants.checkPhone,
        {'exists': false},
      );

      // Act
      final result = await dataSource.checkPhone(testPhone);

      // Assert
      expect(result, false);
    });

    test('returns false when response has null exists field', () async {
      // Arrange
      mockApiClient.stubPost(
        ApiConstants.checkPhone,
        {'exists': null},
      );

      // Act
      final result = await dataSource.checkPhone(testPhone);

      // Assert
      expect(result, false);
    });

    test('throws AuthException on network error', () async {
      // Arrange
      mockApiClient.stubPostError(
        ApiConstants.checkPhone,
        createTimeoutException(),
      );

      // Act & Assert
      expect(
        () => dataSource.checkPhone(testPhone),
        throwsA(isA<AuthException>()),
      );
    });

    test('throws AuthException with fallback message on DioException', () async {
      // Arrange - Implementation uses DioException.message, which is null for our mock
      mockApiClient.stubPostError(
        ApiConstants.checkPhone,
        createDioException(500),
      );

      // Act & Assert
      expect(
        () => dataSource.checkPhone(testPhone),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Failed to check phone number',
          ),
        ),
      );
    });
  });

  group('ping', () {
    test('returns true on 200 response', () async {
      // Arrange
      mockApiClient.stubGet(ApiConstants.ping, {'status': 'ok'});

      // Act
      final result = await dataSource.ping();

      // Assert
      expect(result, true);
    });

    test('throws AuthException with "Session expired" on 401', () async {
      // Arrange
      mockApiClient.stubGetError(
        ApiConstants.ping,
        createDioException(401),
      );

      // Act & Assert
      expect(
        () => dataSource.ping(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Session expired',
          ),
        ),
      );
    });

    test('throws AuthException on network timeout', () async {
      // Arrange
      mockApiClient.stubGetError(
        ApiConstants.ping,
        createTimeoutException(),
      );

      // Act & Assert
      expect(
        () => dataSource.ping(),
        throwsA(isA<AuthException>()),
      );
    });

    test('throws AuthException on connection error', () async {
      // Arrange
      mockApiClient.stubGetError(
        ApiConstants.ping,
        createConnectionException(),
      );

      // Act & Assert
      expect(
        () => dataSource.ping(),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('exchangeTokenWithBackend', () {
    const testFirebaseToken = 'firebase-id-token-123';
    final successResponse = {
      'token': 'bearer-token-456',
      'token_type': 'Bearer',
      'voter': {
        'id': 'voter-id-789',
        'first_name': 'John',
        'last_name': 'Doe',
        'phone': '+393331234567',
      },
    };

    test('returns AuthResponseModel on 200', () async {
      // Arrange
      mockApiClient.stubPost(ApiConstants.votersLogin, successResponse);
      when(mockTokenStorage.saveToken(any)).thenAnswer((_) async {});

      // Act
      final result =
          await dataSource.exchangeTokenWithBackend(testFirebaseToken);

      // Assert
      expect(result.token, 'bearer-token-456');
      expect(result.tokenType, 'Bearer');
      expect(result.voter.id, 'voter-id-789');
      expect(result.voter.firstName, 'John');
      expect(result.voter.lastName, 'Doe');
    });

    test('stores token via TokenStorageService on success', () async {
      // Arrange
      mockApiClient.stubPost(ApiConstants.votersLogin, successResponse);
      when(mockTokenStorage.saveToken(any)).thenAnswer((_) async {});

      // Act
      await dataSource.exchangeTokenWithBackend(testFirebaseToken);

      // Assert
      verify(mockTokenStorage.saveToken('bearer-token-456')).called(1);
    });

    test('throws "Invalid Firebase token" on 401', () async {
      // Arrange
      mockApiClient.stubPostError(
        ApiConstants.votersLogin,
        createDioException(401),
      );

      // Act & Assert
      expect(
        () => dataSource.exchangeTokenWithBackend(testFirebaseToken),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Invalid Firebase token',
          ),
        ),
      );
    });

    test('throws "Phone number not registered as voter" on 404', () async {
      // Arrange
      mockApiClient.stubPostError(
        ApiConstants.votersLogin,
        createDioException(404),
      );

      // Act & Assert
      expect(
        () => dataSource.exchangeTokenWithBackend(testFirebaseToken),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Phone number not registered as voter',
          ),
        ),
      );
    });

    test('throws "Validation failed" on 422', () async {
      // Arrange
      mockApiClient.stubPostError(
        ApiConstants.votersLogin,
        createDioException(422),
      );

      // Act & Assert
      expect(
        () => dataSource.exchangeTokenWithBackend(testFirebaseToken),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Validation failed',
          ),
        ),
      );
    });

    test('throws AuthException with message on other DioException', () async {
      // Arrange
      mockApiClient.stubPostError(
        ApiConstants.votersLogin,
        createDioException(500, message: 'Internal server error'),
      );

      // Act & Assert
      expect(
        () => dataSource.exchangeTokenWithBackend(testFirebaseToken),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('getCurrentVoter', () {
    test('returns VoterModel on 200', () async {
      // Arrange
      mockApiClient.stubGet(ApiConstants.votersMe, {
        'id': 'voter-id-123',
        'first_name': 'Jane',
        'last_name': 'Smith',
        'phone': '+393339876543',
        'qr_code': 'QR123',
      });

      // Act
      final result = await dataSource.getCurrentVoter();

      // Assert
      expect(result.id, 'voter-id-123');
      expect(result.firstName, 'Jane');
      expect(result.lastName, 'Smith');
      expect(result.phone, '+393339876543');
      expect(result.qrCode, 'QR123');
    });

    test('throws "Session expired" on 401', () async {
      // Arrange
      mockApiClient.stubGetError(
        ApiConstants.votersMe,
        createDioException(401),
      );

      // Act & Assert
      expect(
        () => dataSource.getCurrentVoter(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Session expired',
          ),
        ),
      );
    });

    test('throws AuthException with fallback message on other errors', () async {
      // Arrange - Implementation uses DioException.message, not response data message
      // When DioException.message is null, fallback is 'Failed to get voter profile'
      mockApiClient.stubGetError(
        ApiConstants.votersMe,
        createDioException(500),
      );

      // Act & Assert
      expect(
        () => dataSource.getCurrentVoter(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Failed to get voter profile',
          ),
        ),
      );
    });
  });

  group('impersonateUser', () {
    const testPhone = '+393331234567';
    const testMagicToken = 'magic-token-123';
    final successResponse = {
      'token': 'bearer-token-impersonate',
      'token_type': 'Bearer',
      'voter': {
        'id': 'voter-id-impersonate',
        'first_name': 'Test',
        'last_name': 'User',
        'phone': testPhone,
      },
    };

    test('returns AuthResponseModel on success', () async {
      // Arrange
      mockApiClient.stubPost(ApiConstants.votersImpersonate, successResponse);
      when(mockTokenStorage.deleteToken()).thenAnswer((_) async {});
      when(mockTokenStorage.saveToken(any)).thenAnswer((_) async {});

      // Act
      final result = await dataSource.impersonateUser(
        phone: testPhone,
        magicToken: testMagicToken,
      );

      // Assert
      expect(result.token, 'bearer-token-impersonate');
      expect(result.voter.id, 'voter-id-impersonate');
    });

    test('clears existing token before impersonation', () async {
      // Arrange
      mockApiClient.stubPost(ApiConstants.votersImpersonate, successResponse);
      when(mockTokenStorage.deleteToken()).thenAnswer((_) async {});
      when(mockTokenStorage.saveToken(any)).thenAnswer((_) async {});

      // Act
      await dataSource.impersonateUser(
        phone: testPhone,
        magicToken: testMagicToken,
      );

      // Assert
      verify(mockTokenStorage.deleteToken()).called(1);
    });

    test('throws "Invalid magic token" on 401', () async {
      // Arrange
      when(mockTokenStorage.deleteToken()).thenAnswer((_) async {});
      mockApiClient.stubPostError(
        ApiConstants.votersImpersonate,
        createDioException(401),
      );

      // Act & Assert
      expect(
        () => dataSource.impersonateUser(
          phone: testPhone,
          magicToken: testMagicToken,
        ),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Invalid magic token',
          ),
        ),
      );
    });

    test('throws "Phone number not found" on 404', () async {
      // Arrange
      when(mockTokenStorage.deleteToken()).thenAnswer((_) async {});
      mockApiClient.stubPostError(
        ApiConstants.votersImpersonate,
        createDioException(404),
      );

      // Act & Assert
      expect(
        () => dataSource.impersonateUser(
          phone: testPhone,
          magicToken: testMagicToken,
        ),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Phone number not found',
          ),
        ),
      );
    });
  });
}
