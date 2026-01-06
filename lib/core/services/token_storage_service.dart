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
}
