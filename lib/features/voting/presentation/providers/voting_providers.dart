import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/errors/failures.dart';
import '../../../elections/presentation/providers/election_providers.dart';
import '../../data/datasources/vote_remote_datasource.dart';
import '../../data/repositories/vote_repository_impl.dart';
import '../../domain/entities/vote.dart';
import '../../domain/repositories/vote_repository.dart';
import '../../domain/usecases/submit_vote.dart';
import '../../domain/usecases/validate_selection.dart';
import '../../domain/builders/vote_submission_builder.dart';

// Data Sources - with API client
final voteRemoteDataSourceProvider = Provider<VoteRemoteDataSource>((ref) {
  return VoteRemoteDataSourceImpl(
    apiClient: ref.watch(apiClientProvider),
  );
});

// Repository
final voteRepositoryProvider = Provider<VoteRepository>((ref) {
  return VoteRepositoryImpl(
    remoteDataSource: ref.watch(voteRemoteDataSourceProvider),
  );
});

// Use Cases
final submitVoteUseCaseProvider = Provider<SubmitVote>((ref) {
  return SubmitVote(ref.watch(voteRepositoryProvider));
});

final validateSelectionUseCaseProvider = Provider<ValidateSelection>((ref) {
  return ValidateSelection();
});

// Builder - with dynamic maxVotes from election
final voteBuilderProvider = Provider<VoteSubmissionBuilder>((ref) {
  final maxVotes = ref.watch(requiredVotesCountProvider);
  return VoteSubmissionBuilder(maxVotes: maxVotes);
});

// State
enum VotingStatus { initial, validating, submitting, success, error }

// Error types for UI differentiation
enum VotingErrorType {
  general,
  alreadyVoted,
  electionNotActive,
  validationError,
  networkError,
  authError,
}

class VotingState {
  final VotingStatus status;
  final Vote? vote;
  final String? errorMessage;
  final VotingErrorType? errorType;

  const VotingState({
    this.status = VotingStatus.initial,
    this.vote,
    this.errorMessage,
    this.errorType,
  });

  VotingState copyWith({
    VotingStatus? status,
    Vote? vote,
    String? errorMessage,
    VotingErrorType? errorType,
  }) {
    return VotingState(
      status: status ?? this.status,
      vote: vote ?? this.vote,
      errorMessage: errorMessage ?? this.errorMessage,
      errorType: errorType ?? this.errorType,
    );
  }
}

// Notifier
class VotingNotifier extends StateNotifier<VotingState> {
  final ValidateSelection _validateSelection;
  final SubmitVote _submitVote;
  final VoteSubmissionBuilder _voteBuilder;
  final String? _electionId;

  VotingNotifier({
    required ValidateSelection validateSelection,
    required SubmitVote submitVote,
    required VoteSubmissionBuilder voteBuilder,
    required String? electionId,
  })  : _validateSelection = validateSelection,
        _submitVote = submitVote,
        _voteBuilder = voteBuilder,
        _electionId = electionId,
        super(const VotingState());

  Future<bool> validateSelection(List<String> candidateIds) async {
    state = state.copyWith(status: VotingStatus.validating);

    final result = await _validateSelection(
      ValidateSelectionParams(candidateIds: candidateIds),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: VotingStatus.error,
          errorMessage: failure.message,
          errorType: VotingErrorType.validationError,
        );
        return false;
      },
      (isValid) {
        state = state.copyWith(status: VotingStatus.initial);
        return isValid;
      },
    );
  }

  Future<void> submitVote(List<String> candidateIds, String sessionId) async {
    if (_electionId == null) {
      state = state.copyWith(
        status: VotingStatus.error,
        errorMessage: 'No active election found',
        errorType: VotingErrorType.electionNotActive,
      );
      return;
    }

    state = state.copyWith(status: VotingStatus.submitting);

    try {
      final vote = _voteBuilder
          .setSessionId(sessionId)
          .setElectionId(_electionId)
          .addCandidates(candidateIds)
          .setTimestamp(DateTime.now())
          .build();

      final result = await _submitVote(vote);

      result.fold(
        (failure) {
          state = state.copyWith(
            status: VotingStatus.error,
            errorMessage: failure.message,
            errorType: _mapFailureToErrorType(failure),
          );
        },
        (submittedVote) {
          state = state.copyWith(
            status: VotingStatus.success,
            vote: submittedVote,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: VotingStatus.error,
        errorMessage: e.toString(),
        errorType: VotingErrorType.general,
      );
    } finally {
      _voteBuilder.reset();
    }
  }

  VotingErrorType _mapFailureToErrorType(Failure failure) {
    if (failure is AlreadyVotedFailure) return VotingErrorType.alreadyVoted;
    if (failure is ElectionNotActiveFailure) {
      return VotingErrorType.electionNotActive;
    }
    if (failure is ValidationFailure ||
        failure is InvalidCandidateCountFailure ||
        failure is DuplicateCandidatesFailure) {
      return VotingErrorType.validationError;
    }
    if (failure is NetworkFailure) return VotingErrorType.networkError;
    if (failure is AuthFailure) return VotingErrorType.authError;
    return VotingErrorType.general;
  }

  void reset() {
    _voteBuilder.reset();
    state = const VotingState();
  }
}

// Provider - with election ID from election context
final votingNotifierProvider =
    StateNotifierProvider<VotingNotifier, VotingState>((ref) {
  return VotingNotifier(
    validateSelection: ref.watch(validateSelectionUseCaseProvider),
    submitVote: ref.watch(submitVoteUseCaseProvider),
    voteBuilder: ref.watch(voteBuilderProvider),
    electionId: ref.watch(currentElectionIdProvider),
  );
});
