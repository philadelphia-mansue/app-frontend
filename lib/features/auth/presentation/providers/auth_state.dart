import '../../domain/entities/voter.dart';

enum AuthStatus {
  initial,
  loading,
  otpSent,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final Voter? voter;
  final String? verificationId;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.voter,
    this.verificationId,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    Voter? voter,
    String? verificationId,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      voter: voter ?? this.voter,
      verificationId: verificationId ?? this.verificationId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory AuthState.initial() => const AuthState();

  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);

  factory AuthState.otpSent(String verificationId) => AuthState(
        status: AuthStatus.otpSent,
        verificationId: verificationId,
      );

  factory AuthState.authenticated(Voter voter) => AuthState(
        status: AuthStatus.authenticated,
        voter: voter,
      );

  factory AuthState.unauthenticated() => const AuthState(
        status: AuthStatus.unauthenticated,
      );

  factory AuthState.error(String message) => AuthState(
        status: AuthStatus.error,
        errorMessage: message,
      );
}
