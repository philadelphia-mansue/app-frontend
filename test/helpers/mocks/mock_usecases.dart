import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:philadelphia_mansue/core/errors/failures.dart';
import 'package:philadelphia_mansue/core/usecases/usecase.dart';
import 'package:philadelphia_mansue/features/auth/domain/entities/voter.dart';
import 'package:philadelphia_mansue/features/auth/domain/usecases/send_otp.dart';
import 'package:philadelphia_mansue/features/auth/domain/usecases/verify_otp.dart';
import 'package:philadelphia_mansue/features/candidates/domain/entities/candidate.dart';
import 'package:philadelphia_mansue/features/candidates/domain/usecases/get_candidates.dart';
import 'package:philadelphia_mansue/features/elections/domain/entities/election.dart';
import 'package:philadelphia_mansue/features/elections/domain/usecases/get_ongoing_election.dart';
import 'package:philadelphia_mansue/features/voting/domain/entities/vote.dart';
import 'package:philadelphia_mansue/features/voting/domain/usecases/submit_vote.dart';
import 'package:philadelphia_mansue/features/voting/domain/usecases/validate_selection.dart';

// =============================================================================
// MOCK CLASSES - Manually implement for null safety compatibility
// =============================================================================

class MockSendOtp extends Mock implements SendOtp {
  Either<Failure, String>? result;

  @override
  Future<Either<Failure, String>> call(SendOtpParams params) async {
    return result ?? const Right('verification-id');
  }
}

class MockVerifyOtp extends Mock implements VerifyOtp {
  Either<Failure, Voter>? result;

  @override
  Future<Either<Failure, Voter>> call(VerifyOtpParams params) async {
    return result ?? Right(const Voter(id: 'id', firstName: 'First', lastName: 'Last', phone: '+1234567890'));
  }
}

class MockGetCandidates extends Mock implements GetCandidates {
  Either<Failure, List<Candidate>>? result;

  @override
  Future<Either<Failure, List<Candidate>>> call(NoParams params) async {
    return result ?? const Right([]);
  }
}

class MockGetOngoingElection extends Mock implements GetOngoingElection {
  Either<Failure, Election?>? result;

  @override
  Future<Either<Failure, Election?>> call(NoParams params) async {
    return result ?? const Right(null);
  }
}

class MockSubmitVote extends Mock implements SubmitVote {
  Either<Failure, Vote>? result;
  Vote? lastVote;

  @override
  Future<Either<Failure, Vote>> call(Vote vote) async {
    lastVote = vote;
    return result ?? Right(vote);
  }
}

class MockValidateSelection extends Mock implements ValidateSelection {
  Either<Failure, bool>? result;

  @override
  Future<Either<Failure, bool>> call(ValidateSelectionParams params) async {
    return result ?? const Right(true);
  }
}

// =============================================================================
// SEND OTP MOCK HELPERS
// =============================================================================

void mockSendOtpUseCaseSuccess(MockSendOtp mock, String verificationId) {
  mock.result = Right(verificationId);
}

void mockSendOtpUseCaseFailure(MockSendOtp mock, Failure failure) {
  mock.result = Left(failure);
}

// =============================================================================
// VERIFY OTP MOCK HELPERS
// =============================================================================

void mockVerifyOtpUseCaseSuccess(MockVerifyOtp mock, Voter voter) {
  mock.result = Right(voter);
}

void mockVerifyOtpUseCaseFailure(MockVerifyOtp mock, Failure failure) {
  mock.result = Left(failure);
}

// =============================================================================
// GET CANDIDATES MOCK HELPERS
// =============================================================================

void mockGetCandidatesUseCaseSuccess(MockGetCandidates mock, List<Candidate> candidates) {
  mock.result = Right(candidates);
}

void mockGetCandidatesUseCaseFailure(MockGetCandidates mock, Failure failure) {
  mock.result = Left(failure);
}

// =============================================================================
// GET ONGOING ELECTION MOCK HELPERS
// =============================================================================

void mockGetOngoingElectionUseCaseSuccess(MockGetOngoingElection mock, Election? election) {
  mock.result = Right(election);
}

void mockGetOngoingElectionUseCaseFailure(MockGetOngoingElection mock, Failure failure) {
  mock.result = Left(failure);
}

// =============================================================================
// SUBMIT VOTE MOCK HELPERS
// =============================================================================

void mockSubmitVoteUseCaseSuccess(MockSubmitVote mock, Vote vote) {
  mock.result = Right(vote);
}

void mockSubmitVoteUseCaseFailure(MockSubmitVote mock, Failure failure) {
  mock.result = Left(failure);
}

// =============================================================================
// VALIDATE SELECTION MOCK HELPERS
// =============================================================================

void mockValidateSelectionUseCaseSuccess(MockValidateSelection mock) {
  mock.result = const Right(true);
}

void mockValidateSelectionUseCaseFailure(MockValidateSelection mock, Failure failure) {
  mock.result = Left(failure);
}
