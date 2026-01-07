import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/voter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import 'auth_providers.dart';
import 'auth_state.dart';

/// Public API contract for the Auth feature.
///
/// Use this feature bundle for clear dependency management and better
/// discoverability of available providers.
///
/// Example usage:
/// ```dart
/// final isAuthenticated = ref.watch(authFeature.isAuthenticated);
/// final voter = ref.watch(authFeature.currentVoter);
/// ref.read(authFeature.notifier.notifier).sendOtp(phoneNumber);
/// ```
abstract class AuthFeature {
  // Domain layer
  Provider<AuthRepository> get repository;
  Provider<SendOtp> get sendOtpUseCase;
  Provider<VerifyOtp> get verifyOtpUseCase;

  // Presentation layer
  StateNotifierProvider<AuthNotifier, AuthState> get notifier;

  // Convenience selectors
  Provider<bool> get isAuthenticated;
  Provider<Voter?> get currentVoter;
  Provider<bool> get isFirebaseSignedIn;
  StreamProvider<String?> get currentUserId;
}

class _AuthFeatureImpl implements AuthFeature {
  @override
  Provider<AuthRepository> get repository => authRepositoryProvider;

  @override
  Provider<SendOtp> get sendOtpUseCase => sendOtpUseCaseProvider;

  @override
  Provider<VerifyOtp> get verifyOtpUseCase => verifyOtpUseCaseProvider;

  @override
  StateNotifierProvider<AuthNotifier, AuthState> get notifier =>
      authNotifierProvider;

  @override
  Provider<bool> get isAuthenticated => isAuthenticatedProvider;

  @override
  Provider<Voter?> get currentVoter => currentVoterProvider;

  @override
  Provider<bool> get isFirebaseSignedIn => isFirebaseSignedInProvider;

  @override
  StreamProvider<String?> get currentUserId => currentUserIdProvider;
}

/// Singleton instance for the Auth feature.
///
/// Import this to access auth-related providers:
/// ```dart
/// import 'auth_feature.dart';
///
/// // In your widget or provider:
/// final isAuth = ref.watch(authFeature.isAuthenticated);
/// ```
final authFeature = _AuthFeatureImpl();
