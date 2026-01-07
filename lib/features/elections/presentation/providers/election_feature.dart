import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../candidates/domain/entities/candidate.dart';
import '../../domain/entities/election.dart';
import '../../domain/repositories/election_repository.dart';
import '../../domain/usecases/get_ongoing_election.dart';
import 'election_providers.dart';

/// Public API contract for the Election feature.
///
/// Use this feature bundle for clear dependency management and better
/// discoverability of available providers.
///
/// Example usage:
/// ```dart
/// final election = ref.watch(electionFeature.currentElection);
/// final hasVoted = ref.watch(electionFeature.hasVoted);
/// ref.read(electionFeature.notifier.notifier).loadOngoingElection();
/// ```
abstract class ElectionFeature {
  // Domain layer
  Provider<ElectionRepository> get repository;
  Provider<GetOngoingElection> get getOngoingElectionUseCase;

  // Presentation layer
  StateNotifierProvider<ElectionNotifier, ElectionState> get notifier;

  // Convenience selectors
  Provider<Election?> get currentElection;
  Provider<String?> get currentElectionId;
  Provider<int> get requiredVotesCount;
  Provider<List<Candidate>> get candidates;
  Provider<bool> get hasActiveElection;
  Provider<bool> get hasVoted;
  Provider<bool> get isLoading;
}

class _ElectionFeatureImpl implements ElectionFeature {
  @override
  Provider<ElectionRepository> get repository => electionRepositoryProvider;

  @override
  Provider<GetOngoingElection> get getOngoingElectionUseCase =>
      getOngoingElectionUseCaseProvider;

  @override
  StateNotifierProvider<ElectionNotifier, ElectionState> get notifier =>
      electionNotifierProvider;

  @override
  Provider<Election?> get currentElection => currentElectionProvider;

  @override
  Provider<String?> get currentElectionId => currentElectionIdProvider;

  @override
  Provider<int> get requiredVotesCount => requiredVotesCountProvider;

  @override
  Provider<List<Candidate>> get candidates => electionCandidatesProvider;

  @override
  Provider<bool> get hasActiveElection => hasActiveElectionProvider;

  @override
  Provider<bool> get hasVoted => hasVotedProvider;

  @override
  Provider<bool> get isLoading => electionLoadingProvider;
}

/// Singleton instance for the Election feature.
///
/// Import this to access election-related providers:
/// ```dart
/// import 'election_feature.dart';
///
/// // In your widget or provider:
/// final election = ref.watch(electionFeature.currentElection);
/// ```
final electionFeature = _ElectionFeatureImpl();
