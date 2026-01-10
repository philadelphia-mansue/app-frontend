import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/usecases/usecase.dart';
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
          // Shuffle candidates to prevent position bias
          final shuffledCandidates = List.of(election.candidates)..shuffle();
          state = state.copyWith(
            status: ElectionLoadStatus.loaded,
            election: election.copyWith(candidates: shuffledCandidates),
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
        // Shuffle candidates to prevent position bias
        final shuffledCandidates = List.of(election.candidates)..shuffle();
        state = state.copyWith(
          status: ElectionLoadStatus.loaded,
          election: election.copyWith(candidates: shuffledCandidates),
        );
      },
    );
  }

  void reset() {
    if (!mounted) return;
    state = const ElectionState();
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
