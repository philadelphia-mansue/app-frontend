import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/auth_interceptor.dart';
import '../network/network_info.dart';
import '../services/token_storage_service.dart';
import '../services/session_timer_service.dart';
import '../services/deep_link_service.dart';
import '../constants/api_constants.dart';

// Secure Storage Provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
});

// Token Storage Service Provider
final tokenStorageServiceProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageServiceImpl(storage: ref.watch(secureStorageProvider));
});

// Callback for unauthorized responses (will be set by auth module)
final onUnauthorizedCallbackProvider = StateProvider<void Function()?>((ref) => null);

// Dio Provider with Auth Interceptor
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add auth interceptor
  dio.interceptors.add(
    AuthInterceptor(
      tokenStorage: ref.watch(tokenStorageServiceProvider),
      onUnauthorized: ref.watch(onUnauthorizedCallbackProvider),
    ),
  );

  // Add logging interceptor
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
    ),
  );

  return dio;
});

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

// Network Info Provider
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});
