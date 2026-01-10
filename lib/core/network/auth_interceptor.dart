import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/token_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorageService _tokenStorage;
  final void Function()? onUnauthorized;

  AuthInterceptor({
    required TokenStorageService tokenStorage,
    this.onUnauthorized,
  }) : _tokenStorage = tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for login and impersonate endpoints
    if (options.path.contains('/voters/login') ||
        options.path.contains('/voters/inpersonate')) {
      return handler.next(options);
    }

    final token = await _tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    debugPrint('[AuthInterceptor] Request: ${options.method} ${options.path}');
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Don't trigger signout for:
      // - login/impersonate endpoints (401 = invalid credentials, not session expired)
      // - /voters/me endpoint (401 during session restore should not cause race condition)
      final path = err.requestOptions.path;
      final isAuthEndpoint = path.contains('/voters/login') ||
          path.contains('/voters/inpersonate') ||
          path.contains('/voters/me');

      if (!isAuthEndpoint) {
        debugPrint('[AuthInterceptor] Unauthorized - token may be expired');
        onUnauthorized?.call();
      } else {
        debugPrint('[AuthInterceptor] Auth/validation endpoint 401 - handled by caller');
      }
    }
    return handler.next(err);
  }
}
