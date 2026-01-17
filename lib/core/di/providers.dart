import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/auth_interceptor.dart';
import '../network/network_info.dart';
import '../services/token_storage_service.dart';
import '../services/vote_cache_service.dart';
import '../services/reverb_service.dart';
import '../events/voter_enabled_event.dart';
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

// Vote Cache Service Provider
final voteCacheServiceProvider = Provider<VoteCacheService>((ref) {
  return VoteCacheServiceImpl(storage: ref.watch(secureStorageProvider));
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

  // Add logging interceptor (DEBUG MODE ONLY)
  // SECURITY: Disable in production to prevent Bearer tokens and voter data
  // from being logged to console/crash reports
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
  }

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

// Reverb WebSocket Service Provider
// Uses a separate Dio instance to avoid auth interceptor conflicts during channel auth
final reverbServiceProvider = Provider<ReverbService>((ref) {
  final tokenStorage = ref.watch(tokenStorageServiceProvider);
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
  final service = ReverbServiceImpl(
    dio: dio,
    tokenStorage: tokenStorage,
  );

  ref.onDispose(() {
    debugPrint('[Provider] Disposing ReverbService');
    service.dispose();
  });

  return service;
});

// Voter Enabled Stream Provider
// Provides a stream of voter.enabled events for the prevalidation screen
final voterEnabledStreamProvider = StreamProvider.autoDispose<VoterEnabledEvent>((ref) {
  final reverb = ref.watch(reverbServiceProvider);
  return reverb.voterEnabledStream;
});
