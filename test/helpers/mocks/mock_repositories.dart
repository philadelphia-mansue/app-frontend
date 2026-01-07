import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:philadelphia_mansue/core/errors/failures.dart';
import 'package:philadelphia_mansue/features/auth/domain/entities/user.dart';
import 'package:philadelphia_mansue/features/auth/domain/entities/voter.dart';
import 'package:philadelphia_mansue/features/auth/domain/repositories/auth_repository.dart';
import 'package:philadelphia_mansue/features/candidates/domain/entities/candidate.dart';
import 'package:philadelphia_mansue/features/candidates/domain/repositories/candidate_repository.dart';
import 'package:philadelphia_mansue/features/elections/domain/entities/election.dart';
import 'package:philadelphia_mansue/features/elections/domain/repositories/election_repository.dart';
import 'package:philadelphia_mansue/features/voting/domain/entities/vote.dart';
import 'package:philadelphia_mansue/features/voting/domain/repositories/vote_repository.dart';

// =============================================================================
// MOCK CLASSES - Manually implement for null safety compatibility
// =============================================================================

class MockAuthRepository extends Mock implements AuthRepository {
  Either<Failure, String>? sendOtpResult;
  Either<Failure, Voter>? verifyOtpResult;
  Either<Failure, User?>? getCurrentUserResult;
  Either<Failure, Voter>? getCurrentVoterResult;
  Either<Failure, void>? signOutResult;
  bool isAuthenticatedResult = false;
  String? authStateChangesResult;

  @override
  Future<Either<Failure, String>> sendOtp(String phoneNumber) async {
    return sendOtpResult ?? const Right('verification-id');
  }

  @override
  Future<Either<Failure, Voter>> verifyOtp(String verificationId, String otp) async {
    return verifyOtpResult ?? Right(const Voter(id: 'id', firstName: 'First', lastName: 'Last', phone: '+1234567890'));
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    return getCurrentUserResult ?? const Right(null);
  }

  @override
  Future<Either<Failure, Voter>> getCurrentVoter() async {
    return getCurrentVoterResult ?? Right(const Voter(id: 'id', firstName: 'First', lastName: 'Last', phone: '+1234567890'));
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    return signOutResult ?? const Right(null);
  }

  @override
  Future<bool> isAuthenticated() async {
    return isAuthenticatedResult;
  }

  @override
  Stream<String?> authStateChanges() {
    return Stream.value(authStateChangesResult);
  }
}

class MockCandidateRepository extends Mock implements CandidateRepository {
  Either<Failure, List<Candidate>>? getCandidatesResult;

  @override
  Future<Either<Failure, List<Candidate>>> getCandidates() async {
    return getCandidatesResult ?? const Right([]);
  }
}

class MockElectionRepository extends Mock implements ElectionRepository {
  Either<Failure, Election?>? getOngoingElectionResult;
  Either<Failure, Election>? getElectionByIdResult;

  @override
  Future<Either<Failure, Election?>> getOngoingElection() async {
    return getOngoingElectionResult ?? const Right(null);
  }

  @override
  Future<Either<Failure, Election>> getElectionById(String id) async {
    return getElectionByIdResult ?? Left(const ServerFailure('Not found'));
  }
}

class MockVoteRepository extends Mock implements VoteRepository {
  Either<Failure, Vote>? submitVoteResult;

  @override
  Future<Either<Failure, Vote>> submitVote(Vote vote) async {
    return submitVoteResult ?? Right(vote);
  }
}

// =============================================================================
// AUTH REPOSITORY MOCK HELPERS
// =============================================================================

void mockSendOtpSuccess(MockAuthRepository mock, String verificationId) {
  mock.sendOtpResult = Right(verificationId);
}

void mockSendOtpFailure(MockAuthRepository mock, Failure failure) {
  mock.sendOtpResult = Left(failure);
}

void mockVerifyOtpSuccess(MockAuthRepository mock, Voter voter) {
  mock.verifyOtpResult = Right(voter);
}

void mockVerifyOtpFailure(MockAuthRepository mock, Failure failure) {
  mock.verifyOtpResult = Left(failure);
}

void mockGetCurrentUserSuccess(MockAuthRepository mock, User? user) {
  mock.getCurrentUserResult = Right(user);
}

void mockGetCurrentVoterSuccess(MockAuthRepository mock, Voter voter) {
  mock.getCurrentVoterResult = Right(voter);
}

void mockGetCurrentVoterFailure(MockAuthRepository mock, Failure failure) {
  mock.getCurrentVoterResult = Left(failure);
}

void mockSignOutSuccess(MockAuthRepository mock) {
  mock.signOutResult = const Right(null);
}

void mockSignOutFailure(MockAuthRepository mock, Failure failure) {
  mock.signOutResult = Left(failure);
}

void mockIsAuthenticated(MockAuthRepository mock, bool value) {
  mock.isAuthenticatedResult = value;
}

void mockAuthStateChanges(MockAuthRepository mock, String? userId) {
  mock.authStateChangesResult = userId;
}

// =============================================================================
// CANDIDATE REPOSITORY MOCK HELPERS
// =============================================================================

void mockGetCandidatesSuccess(MockCandidateRepository mock, List<Candidate> candidates) {
  mock.getCandidatesResult = Right(candidates);
}

void mockGetCandidatesFailure(MockCandidateRepository mock, Failure failure) {
  mock.getCandidatesResult = Left(failure);
}

// =============================================================================
// ELECTION REPOSITORY MOCK HELPERS
// =============================================================================

void mockGetOngoingElectionSuccess(MockElectionRepository mock, Election? election) {
  mock.getOngoingElectionResult = Right(election);
}

void mockGetOngoingElectionFailure(MockElectionRepository mock, Failure failure) {
  mock.getOngoingElectionResult = Left(failure);
}

void mockGetElectionByIdSuccess(MockElectionRepository mock, Election election) {
  mock.getElectionByIdResult = Right(election);
}

void mockGetElectionByIdFailure(MockElectionRepository mock, Failure failure) {
  mock.getElectionByIdResult = Left(failure);
}

// =============================================================================
// VOTE REPOSITORY MOCK HELPERS
// =============================================================================

void mockSubmitVoteSuccess(MockVoteRepository mock, Vote vote) {
  mock.submitVoteResult = Right(vote);
}

void mockSubmitVoteFailure(MockVoteRepository mock, Failure failure) {
  mock.submitVoteResult = Left(failure);
}
