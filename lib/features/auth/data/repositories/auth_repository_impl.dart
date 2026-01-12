import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/voter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorageService tokenStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<Either<Failure, String>> sendOtp(String phoneNumber) async {
    try {
      final verificationId = await remoteDataSource.sendOtp(phoneNumber);
      return Right(verificationId);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> verifyOtp(String verificationId, String otp) async {
    try {
      // Step 1: Verify OTP with Firebase
      await remoteDataSource.verifyOtp(verificationId, otp);

      // Step 2: Get Firebase ID token
      final firebaseIdToken = await remoteDataSource.getFirebaseIdToken();

      // Step 3: Exchange with backend for Bearer token
      final authResponse = await remoteDataSource.exchangeTokenWithBackend(firebaseIdToken);

      // Return auth result with voter
      return Right(AuthResult(
        voter: authResponse.voter,
      ));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Voter>> getCurrentVoter() async {
    try {
      final voter = await remoteDataSource.getCurrentVoter();
      return Right(voter);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await tokenStorage.hasToken();
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<String?> authStateChanges() => remoteDataSource.authStateChanges();
}
