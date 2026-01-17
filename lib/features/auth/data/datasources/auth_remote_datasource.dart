import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/token_storage_service.dart';
import '../models/user_model.dart';
import '../models/voter_model.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<String> sendOtp(String phoneNumber);
  Future<UserModel> verifyOtp(String verificationId, String otp);
  Future<UserModel?> getCurrentUser();
  Future<void> signOut();

  // Backend auth methods
  Future<String> getFirebaseIdToken();
  Future<AuthResponseModel> exchangeTokenWithBackend(String firebaseIdToken);
  Future<VoterModel> getCurrentVoter();

  /// Ping the server to verify authentication is still valid.
  /// Returns true if authenticated, throws if 401.
  Future<bool> ping();

  /// Check if a phone number is registered as a voter.
  /// Returns true if the phone exists in the system.
  Future<bool> checkPhone(String phone);

  // Debug impersonate (debug mode only)
  Future<AuthResponseModel> impersonateUser({
    required String phone,
    required String magicToken,
  });

  /// Stream of Firebase auth state changes.
  /// Emits user ID when signed in, null when signed out.
  /// Fires immediately with current state, then on every sign-in/sign-out.
  Stream<String?> authStateChanges();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase.FirebaseAuth _firebaseAuth;
  final ApiClient _apiClient;
  final TokenStorageService _tokenStorage;

  // Web-specific: stores the confirmation result for OTP verification
  firebase.ConfirmationResult? _webConfirmationResult;

  AuthRemoteDataSourceImpl({
    firebase.FirebaseAuth? firebaseAuth,
    required ApiClient apiClient,
    required TokenStorageService tokenStorage,
  })  : _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
        _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  @override
  Future<String> sendOtp(String phoneNumber) async {
    debugPrint('[AuthDataSource] sendOtp called');
    debugPrint('[AuthDataSource] Platform is web: $kIsWeb');

    try {
      if (kIsWeb) {
        // Web platform: use signInWithPhoneNumber
        // Firebase manages reCAPTCHA automatically (invisible mode)
        debugPrint('[AuthDataSource] Calling signInWithPhoneNumber...');

        _webConfirmationResult = await _firebaseAuth.signInWithPhoneNumber(
          phoneNumber,
        );
        debugPrint('[AuthDataSource] signInWithPhoneNumber succeeded');
        return 'web-verification';
      }

      // Native platforms (iOS/Android): use verifyPhoneNumber
      final completer = Completer<String>();

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (firebase.PhoneAuthCredential credential) async {
          // Auto-verification on Android - codeSent still fires, so let it handle completion
        },
        verificationFailed: (firebase.FirebaseAuthException e) {
          if (!completer.isCompleted) {
            String message;
            switch (e.code) {
              case 'invalid-phone-number':
                message = 'Invalid phone number format';
                break;
              case 'too-many-requests':
                message = 'Too many attempts. Please try again later.';
                break;
              case 'quota-exceeded':
                message = 'SMS quota exceeded. Please try again later.';
                break;
              default:
                message = e.message ?? 'Verification failed: ${e.code}';
            }
            completer.completeError(AuthException(message: message));
          }
        },
        codeSent: (String verId, int? resendToken) {
          if (!completer.isCompleted) {
            completer.complete(verId);
          }
        },
        codeAutoRetrievalTimeout: (String verId) {
          if (!completer.isCompleted) {
            completer.complete(verId);
          }
        },
      );

      return await completer.future;
    } on firebase.FirebaseAuthException catch (e) {
      debugPrint('[AuthDataSource] FirebaseAuthException: ${e.code} - ${e.message}');
      throw AuthException(message: _mapFirebaseError(e));
    } on AuthException {
      rethrow;
    } catch (e) {
      debugPrint('[AuthDataSource] Unexpected error: $e');
      throw AuthException(message: e.toString());
    }
  }

  String _mapFirebaseError(firebase.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'captcha-check-failed':
      case 'invalid-app-credential':
        return 'reCAPTCHA verification failed. Please refresh and try again.';
      default:
        return e.message ?? 'Verification failed: ${e.code}';
    }
  }

  @override
  Future<UserModel> verifyOtp(String verificationId, String otp) async {
    debugPrint('[AuthDataSource] verifyOtp called with verificationId: $verificationId, otp: $otp');

    try {
      firebase.UserCredential userCredential;

      if (kIsWeb) {
        // Web platform: use confirmationResult.confirm()
        debugPrint('[AuthDataSource] Verifying OTP on web platform...');
        if (_webConfirmationResult == null) {
          debugPrint('[AuthDataSource] ERROR: _webConfirmationResult is null!');
          throw const AuthException(
            message: 'Verification session expired. Please request a new code.',
          );
        }
        debugPrint('[AuthDataSource] Calling confirmationResult.confirm()...');
        userCredential = await _webConfirmationResult!.confirm(otp);
        debugPrint('[AuthDataSource] OTP confirmed successfully');

        // Clear confirmation result after use
        _webConfirmationResult = null;
      } else {
        // Native platforms: use credential-based sign in
        final credential = firebase.PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: otp,
        );
        userCredential = await _firebaseAuth.signInWithCredential(credential);
      }

      final user = userCredential.user;

      if (user == null) {
        throw const AuthException(message: 'Failed to sign in');
      }

      debugPrint('[AuthDataSource] User authenticated successfully');

      return UserModel(
        id: user.uid,
        phoneNumber: user.phoneNumber ?? '',
      );
    } on firebase.FirebaseAuthException catch (e) {
      debugPrint('[AuthDataSource] FirebaseAuthException during OTP verify: ${e.code} - ${e.message}');
      String message;
      switch (e.code) {
        case 'invalid-verification-code':
          message = 'Invalid OTP code. Please check and try again.';
          break;
        case 'session-expired':
        case 'code-expired':
          message = 'Verification session expired. Please request a new code.';
          break;
        case 'missing-verification-id':
          message = 'Verification ID not found. Please request a new code.';
          break;
        default:
          message = e.message ?? 'Invalid OTP';
      }
      throw AuthException(message: message);
    } catch (e) {
      debugPrint('[AuthDataSource] Unexpected error during OTP verify: $e');
      if (e is AuthException) rethrow;
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    return UserModel(
      id: user.uid,
      phoneNumber: user.phoneNumber ?? '',
    );
  }

  @override
  Future<void> signOut() async {
    await _tokenStorage.deleteToken();
    await _firebaseAuth.signOut();
  }

  @override
  Future<String> getFirebaseIdToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthException(message: 'No authenticated user');
    }

    final idToken = await user.getIdToken(true); // Force refresh
    if (idToken == null) {
      throw const AuthException(message: 'Failed to get ID token');
    }

    debugPrint('[AuthDataSource] Got Firebase ID token');
    return idToken;
  }

  @override
  Future<AuthResponseModel> exchangeTokenWithBackend(String firebaseIdToken) async {
    try {
      debugPrint('[AuthDataSource] Exchanging Firebase token with backend...');

      final response = await _apiClient.post(
        ApiConstants.votersLogin,
        data: {'token': firebaseIdToken},
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Store the bearer token
      await _tokenStorage.saveToken(authResponse.token);

      debugPrint('[AuthDataSource] Backend auth successful, token stored');
      return authResponse;
    } on DioException catch (e) {
      debugPrint('[AuthDataSource] Backend auth failed: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw const AuthException(message: 'Invalid Firebase token');
      }
      if (e.response?.statusCode == 404) {
        throw const AuthException(message: 'Phone number not registered as voter');
      }
      if (e.response?.statusCode == 422) {
        throw const AuthException(message: 'Validation failed');
      }
      throw AuthException(message: e.message ?? 'Backend authentication failed');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<VoterModel> getCurrentVoter() async {
    try {
      final response = await _apiClient.get(ApiConstants.votersMe);
      return VoterModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthException(message: 'Session expired');
      }
      throw AuthException(message: e.message ?? 'Failed to get voter profile');
    }
  }

  @override
  Future<AuthResponseModel> impersonateUser({
    required String phone,
    required String magicToken,
  }) async {
    try {
      // Clear any existing token to prevent race conditions
      await _tokenStorage.deleteToken();
      debugPrint('[AuthDataSource] Impersonating user');

      final response = await _apiClient.post(
        ApiConstants.votersImpersonate,
        data: {
          'phone': phone,
          'magic_token': magicToken,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Store the bearer token
      await _tokenStorage.saveToken(authResponse.token);

      debugPrint('[AuthDataSource] Impersonate successful, token stored');
      return authResponse;
    } on DioException catch (e) {
      debugPrint('[AuthDataSource] Impersonate failed: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw const AuthException(message: 'Invalid magic token');
      }
      if (e.response?.statusCode == 404) {
        throw const AuthException(message: 'Phone number not found');
      }
      throw AuthException(message: e.message ?? 'Impersonate failed');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: e.toString());
    }
  }

  @override
  Stream<String?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) => user?.uid);
  }

  @override
  Future<bool> ping() async {
    try {
      debugPrint('[AuthDataSource] Pinging server to verify authentication...');
      await _apiClient.get(ApiConstants.ping);
      debugPrint('[AuthDataSource] Ping successful - user is authenticated');
      return true;
    } on DioException catch (e) {
      debugPrint('[AuthDataSource] Ping failed: ${e.response?.statusCode}');
      if (e.response?.statusCode == 401) {
        throw const AuthException(message: 'Session expired');
      }
      // Rethrow non-auth errors (network, server) so repository handles them as ServerFailure
      rethrow;
    }
  }

  @override
  Future<bool> checkPhone(String phone) async {
    try {
      debugPrint('[AuthDataSource] Checking if phone exists');
      final response = await _apiClient.post(
        ApiConstants.checkPhone,
        data: {'phone': phone},
      );
      final exists = response.data['exists'] as bool? ?? false;
      debugPrint('[AuthDataSource] Phone check result: $exists');
      return exists;
    } on DioException catch (e) {
      debugPrint('[AuthDataSource] Check phone failed: ${e.message}');
      throw AuthException(message: e.message ?? 'Failed to check phone number');
    }
  }
}
