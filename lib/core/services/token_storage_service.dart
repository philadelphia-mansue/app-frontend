import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorageService {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<bool> hasToken();
}

class TokenStorageServiceImpl implements TokenStorageService {
  static const _tokenKey = 'bearer_token';

  final FlutterSecureStorage _storage;

  /// In-memory cache to avoid FlutterSecureStorage timing issues
  /// where a just-saved token might not be immediately readable.
  String? _cachedToken;

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
    _cachedToken = token; // Update cache immediately
    await _storage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    // Return cached token if available (faster, avoids timing issues)
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await _storage.read(key: _tokenKey);
    return _cachedToken;
  }

  @override
  Future<void> deleteToken() async {
    _cachedToken = null; // Clear cache
    await _storage.delete(key: _tokenKey);
  }

  @override
  Future<bool> hasToken() async {
    if (_cachedToken != null) return true;
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
