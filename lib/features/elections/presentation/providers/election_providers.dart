import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/selection_storage.dart';
import '../../../candidates/domain/entities/candidate.dart';
import '../../data/datasources/election_remote_datasource.dart';
import '../../data/repositories/election_repository_impl.dart';
import '../../domain/entities/election.dart';
import '../../domain/repositories/election_repository.dart';
import '../../domain/usecases/get_election_by_id.dart';
import '../../domain/usecases/get_ongoing_election.dart';

// Data Sources
final electionRemoteDataSourceProvider = Provider<ElectionRemoteDataSource>((ref) {
  return ElectionRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

// Repository
final electionRepositoryProvider = Provider<ElectionRepository>((ref) {
  return ElectionRepositoryImpl(
    remoteDataSource: ref.watch(electionRemoteDataSourceProvider),
  );
});

// Use Cases
final getOngoingElectionUseCaseProvider = Provider<GetOngoingElection>((ref) {
  return GetOngoingElection(ref.watch(electionRepositoryProvider));
});

final getElectionByIdUseCaseProvider = Provider<GetElectionById>((ref) {
  return GetElectionById(ref.watch(electionRepositoryProvider));
});

// URL Election ID - stores election_id from URL query params
final urlElectionIdProvider = StateProvider<String?>((ref) => null);

// State
enum ElectionLoadStatus { initial, loading, loaded, noElection, error }

class ElectionState {
  final ElectionLoadStatus status;
  final Election? election;
  final String? errorMessage;

  const ElectionState({
    this.status = ElectionLoadStatus.initial,
    this.election,
    this.errorMessage,
  });

  ElectionState copyWith({
    ElectionLoadStatus? status,
    Election? election,
    String? errorMessage,
  }) {
    return ElectionState(
      status: status ?? this.status,
      election: election ?? this.election,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Notifier
class ElectionNotifier extends StateNotifier<ElectionState> {
  final GetOngoingElection _getOngoingElection;
  final GetElectionById _getElectionById;

  ElectionNotifier({
    required GetOngoingElection getOngoingElection,
    required GetElectionById getElectionById,
  })  : _getOngoingElection = getOngoingElection,
        _getElectionById = getElectionById,
        super(const ElectionState());

  Future<void> loadOngoingElection() async {
    if (!mounted) return;
    state = state.copyWith(status: ElectionLoadStatus.loading);

    final result = await _getOngoingElection(const NoParams());

    if (!mounted) return;
    result.fold(
      (failure) => state = state.copyWith(
        status: ElectionLoadStatus.error,
        errorMessage: failure.message,
      ),
      (election) {
        if (election == null) {
          state = state.copyWith(status: ElectionLoadStatus.noElection);
        } else {
          // Use stored order if available, otherwise shuffle and save
          final orderedCandidates = _getOrderedCandidates(
            election.id,
            election.candidates,
          );
          state = state.copyWith(
            status: ElectionLoadStatus.loaded,
            election: election.copyWith(candidates: orderedCandidates),
          );
        }
      },
    );
  }

  Future<void> loadElectionById(String id) async {
    if (!mounted) return;
    state = state.copyWith(status: ElectionLoadStatus.loading);

    final result = await _getElectionById(GetElectionByIdParams(id: id));

    if (!mounted) return;
    result.fold(
      (failure) => state = state.copyWith(
        status: ElectionLoadStatus.error,
        errorMessage: failure.message,
      ),
      (election) {
        debugPrint('[Election] Loaded election: id=${election.id}, hasVoted=${election.hasVoted}');
        // Use stored order if available, otherwise shuffle and save
        final orderedCandidates = _getOrderedCandidates(
          election.id,
          election.candidates,
        );
        state = state.copyWith(
          status: ElectionLoadStatus.loaded,
          election: election.copyWith(candidates: orderedCandidates),
        );
      },
    );
  }

  /// Gets candidates in stored order, or shuffles and saves order if none exists.
  /// This ensures consistent order across page refreshes on web.
  List<Candidate> _getOrderedCandidates(
    String electionId,
    List<Candidate> candidates,
  ) {
    // Check for stored order
    final storedOrder = getStoredCandidateOrder(electionId);

    if (storedOrder != null && storedOrder.length == candidates.length) {
      // Reorder candidates based on stored order
      final candidateMap = {for (var c in candidates) c.id: c};
      final ordered = <Candidate>[];
      for (final id in storedOrder) {
        final candidate = candidateMap[id];
        if (candidate != null) {
          ordered.add(candidate);
        }
      }
      // Only use stored order if all candidates were found
      if (ordered.length == candidates.length) {
        return ordered;
      }
    }

    // Shuffle and save the order
    final shuffled = List.of(candidates)..shuffle();
    saveStoredCandidateOrder(electionId, shuffled.map((c) => c.id).toList());
    return shuffled;
  }

  void reset() {
    if (!mounted) return;
    state = const ElectionState();
  }

  /// Mark the current election as voted in local state.
  /// Called after successful vote submission to update the router's hasVoted check.
  void markAsVoted() {
    if (!mounted) return;
    final election = state.election;
    if (election == null) return;

    debugPrint('[Election] Marking election as voted locally');
    state = state.copyWith(
      election: election.copyWith(hasVoted: true),
    );
  }
}

// Provider
final electionNotifierProvider =
    StateNotifierProvider<ElectionNotifier, ElectionState>((ref) {
  return ElectionNotifier(
    getOngoingElection: ref.watch(getOngoingElectionUseCaseProvider),
    getElectionById: ref.watch(getElectionByIdUseCaseProvider),
  );
});

// Convenience selectors
final currentElectionProvider = Provider<Election?>((ref) {
  return ref.watch(electionNotifierProvider).election;
});

final currentElectionIdProvider = Provider<String?>((ref) {
  return ref.watch(electionNotifierProvider).election?.id;
});

final requiredVotesCountProvider = Provider<int>((ref) {
  return ref.watch(electionNotifierProvider).election?.requiredVotesCount ?? 10;
});

final electionCandidatesProvider = Provider<List<Candidate>>((ref) {
  return ref.watch(electionNotifierProvider).election?.candidates ?? [];
});

final hasActiveElectionProvider = Provider<bool>((ref) {
  final state = ref.watch(electionNotifierProvider);
  return state.election != null && state.election!.isActive;
});

final electionLoadingProvider = Provider<bool>((ref) {
  return ref.watch(electionNotifierProvider).status == ElectionLoadStatus.loading;
});

final hasVotedProvider = Provider<bool>((ref) {
  return ref.watch(electionNotifierProvider).election?.hasVoted ?? false;
});

// ============================================================================
// Available Elections State (Multi-Election Support)
// ============================================================================

enum AvailableElectionsStatus { initial, loading, loaded, noElections, error }

class AvailableElectionsState {
  final AvailableElectionsStatus status;
  final List<Election> elections;
  final String? errorMessage;

  const AvailableElectionsState({
    this.status = AvailableElectionsStatus.initial,
    this.elections = const [],
    this.errorMessage,
  });

  /// Elections that can be voted in (active and not yet voted)
  List<Election> get pendingElections =>
      elections.where((e) => !e.hasVoted && e.isActive).toList();

  /// Elections already voted in
  List<Election> get completedElections =>
      elections.where((e) => e.hasVoted).toList();

  /// Elections not yet open
  List<Election> get upcomingElections =>
      elections.where((e) => e.status == ElectionStatus.upcoming).toList();

  /// Elections that have ended (and not voted in)
  List<Election> get endedElections =>
      elections.where((e) => e.status == ElectionStatus.ended && !e.hasVoted).toList();

  int get remainingCount => pendingElections.length;
  bool get hasRemainingElections => remainingCount > 0;

  AvailableElectionsState copyWith({
    AvailableElectionsStatus? status,
    List<Election>? elections,
    String? errorMessage,
  }) {
    return AvailableElectionsState(
      status: status ?? this.status,
      elections: elections ?? this.elections,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AvailableElectionsNotifier extends StateNotifier<AvailableElectionsState> {
  final ElectionRepository _repository;

  AvailableElectionsNotifier({required ElectionRepository repository})
      : _repository = repository,
        super(const AvailableElectionsState());

  Future<void> loadAll() async {
    if (!mounted) return;
    state = state.copyWith(status: AvailableElectionsStatus.loading);

    final result = await _repository.getAllOngoingElections();

    if (!mounted) return;
    result.fold(
      (failure) => state = state.copyWith(
        status: AvailableElectionsStatus.error,
        errorMessage: failure.message,
      ),
      (elections) {
        if (elections.isEmpty) {
          state = state.copyWith(status: AvailableElectionsStatus.noElections);
        } else {
          state = state.copyWith(
            status: AvailableElectionsStatus.loaded,
            elections: elections,
          );
        }
      },
    );
  }

  /// Refresh elections (e.g., after voting to update hasVoted flags)
  Future<void> refresh() async {
    await loadAll();
  }

  /// Mark an election as voted locally (optimistic update)
  void markElectionAsVoted(String electionId) {
    if (!mounted) return;
    final updatedElections = state.elections.map((e) {
      if (e.id == electionId) {
        return e.copyWith(hasVoted: true);
      }
      return e;
    }).toList();

    state = state.copyWith(elections: updatedElections);
  }

  void reset() {
    if (!mounted) return;
    state = const AvailableElectionsState();
  }
}

// Provider
final availableElectionsNotifierProvider =
    StateNotifierProvider<AvailableElectionsNotifier, AvailableElectionsState>((ref) {
  return AvailableElectionsNotifier(
    repository: ref.watch(electionRepositoryProvider),
  );
});

// Convenience providers
final hasRemainingElectionsProvider = Provider<bool>((ref) {
  return ref.watch(availableElectionsNotifierProvider).hasRemainingElections;
});

final remainingElectionsCountProvider = Provider<int>((ref) {
  return ref.watch(availableElectionsNotifierProvider).remainingCount;
});

final pendingElectionsProvider = Provider<List<Election>>((ref) {
  return ref.watch(availableElectionsNotifierProvider).pendingElections;
});

final completedElectionsProvider = Provider<List<Election>>((ref) {
  return ref.watch(availableElectionsNotifierProvider).completedElections;
});
