import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_result.dart';
import '../entities/user.dart';
import '../entities/voter.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> sendOtp(String phoneNumber);
  Future<Either<Failure, AuthResult>> verifyOtp(String verificationId, String otp);
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, Voter>> getCurrentVoter();
  Future<Either<Failure, void>> signOut();
  Future<bool> isAuthenticated();

  /// Ping the server to verify authentication is still valid.
  /// Returns Right(true) if authenticated, Left(Failure) if not.
  Future<Either<Failure, bool>> ping();

  /// Check if a phone number is registered as a voter.
  /// Returns Right(true) if phone exists, Right(false) if not.
  Future<Either<Failure, bool>> checkPhone(String phone);

  /// Stream of Firebase auth state changes.
  /// Emits user ID when signed in, null when signed out.
  /// Fires immediately with current state, then on every sign-in/sign-out.
  Stream<String?> authStateChanges();
}
