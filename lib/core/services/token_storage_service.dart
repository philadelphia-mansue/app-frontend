import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorageService {
  /// Session timeout duration - matches Firebase token expiry with buffer
  static const sessionTimeoutDuration = Duration(minutes: 55);

  // Token methods
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<bool> hasToken();

  // Session timestamp methods
  Future<void> saveSessionTimestamp(DateTime timestamp);
  Future<DateTime?> getSessionTimestamp();
  Future<bool> isSessionExpired();

  // Election ID methods
  Future<void> saveCurrentElectionId(String electionId);
  Future<String?> getCurrentElectionId();
  Future<void> deleteCurrentElectionId();

  // Clear all session data
  Future<void> clearAll();
}

class TokenStorageServiceImpl implements TokenStorageService {
  static const _tokenKey = 'bearer_token';
  static const _sessionTimestampKey = 'session_timestamp';
  static const _currentElectionIdKey = 'current_election_id';

  final FlutterSecureStorage _storage;

  TokenStorageServiceImpl({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  @override
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  @override
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Session timestamp methods

  @override
  Future<void> saveSessionTimestamp(DateTime timestamp) async {
    await _storage.write(
      key: _sessionTimestampKey,
      value: timestamp.millisecondsSinceEpoch.toString(),
    );
  }

  @override
  Future<DateTime?> getSessionTimestamp() async {
    final timestampStr = await _storage.read(key: _sessionTimestampKey);
    if (timestampStr == null) return null;
    final millis = int.tryParse(timestampStr);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  @override
  Future<bool> isSessionExpired() async {
    final timestamp = await getSessionTimestamp();
    if (timestamp == null) return true; // No timestamp means expired
    final elapsed = DateTime.now().difference(timestamp);
    return elapsed >= TokenStorageService.sessionTimeoutDuration;
  }

  // Election ID methods

  @override
  Future<void> saveCurrentElectionId(String electionId) async {
    await _storage.write(key: _currentElectionIdKey, value: electionId);
  }

  @override
  Future<String?> getCurrentElectionId() async {
    return await _storage.read(key: _currentElectionIdKey);
  }

  @override
  Future<void> deleteCurrentElectionId() async {
    await _storage.delete(key: _currentElectionIdKey);
  }

  // Clear all session data

  @override
  Future<void> clearAll() async {
    await Future.wait([
      deleteToken(),
      _storage.delete(key: _sessionTimestampKey),
      deleteCurrentElectionId(),
    ]);
  }
}
