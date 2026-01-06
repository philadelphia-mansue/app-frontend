import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vote.dart';
import '../repositories/vote_repository.dart';

class SubmitVote implements UseCase<Vote, Vote> {
  final VoteRepository repository;

  SubmitVote(this.repository);

  @override
  Future<Either<Failure, Vote>> call(Vote vote) async {
    // Basic client-side validation
    if (vote.selectedCandidateIds.isEmpty) {
      return const Left(ValidationFailure('No candidates selected'));
    }

    if (vote.electionId.isEmpty) {
      return const Left(ValidationFailure('Election ID is required'));
    }

    // Check for duplicates locally
    final uniqueIds = vote.selectedCandidateIds.toSet();
    if (uniqueIds.length != vote.selectedCandidateIds.length) {
      return const Left(DuplicateCandidatesFailure('Duplicate candidates detected'));
    }

    // Let API handle final validation (exact count, election state, etc.)
    return await repository.submitVote(vote);
  }
}
