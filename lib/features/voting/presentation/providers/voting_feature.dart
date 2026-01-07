import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/builders/vote_submission_builder.dart';
import '../../domain/repositories/vote_repository.dart';
import '../../domain/usecases/submit_vote.dart';
import '../../domain/usecases/validate_selection.dart';
import 'voting_providers.dart';

/// Public API contract for the Voting feature.
///
/// Use this feature bundle for clear dependency management and better
/// discoverability of available providers.
///
/// Example usage:
/// ```dart
/// final status = ref.watch(votingFeature.notifier).status;
/// ref.read(votingFeature.notifier.notifier).submitVote(candidateIds, sessionId);
/// ```
abstract class VotingFeature {
  // Domain layer
  Provider<VoteRepository> get repository;
  Provider<SubmitVote> get submitVoteUseCase;
  Provider<ValidateSelection> get validateSelectionUseCase;
  Provider<VoteSubmissionBuilder> get voteBuilder;

  // Presentation layer
  StateNotifierProvider<VotingNotifier, VotingState> get notifier;
}

class _VotingFeatureImpl implements VotingFeature {
  @override
  Provider<VoteRepository> get repository => voteRepositoryProvider;

  @override
  Provider<SubmitVote> get submitVoteUseCase => submitVoteUseCaseProvider;

  @override
  Provider<ValidateSelection> get validateSelectionUseCase =>
      validateSelectionUseCaseProvider;

  @override
  Provider<VoteSubmissionBuilder> get voteBuilder => voteBuilderProvider;

  @override
  StateNotifierProvider<VotingNotifier, VotingState> get notifier =>
      votingNotifierProvider;
}

/// Singleton instance for the Voting feature.
///
/// Import this to access voting-related providers:
/// ```dart
/// import 'voting_feature.dart';
///
/// // In your widget or provider:
/// final votingState = ref.watch(votingFeature.notifier);
/// ```
final votingFeature = _VotingFeatureImpl();
