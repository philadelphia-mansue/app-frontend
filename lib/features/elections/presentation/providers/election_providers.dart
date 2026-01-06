import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../candidates/domain/entities/candidate.dart';
import '../../data/datasources/election_remote_datasource.dart';
import '../../data/repositories/election_repository_impl.dart';
import '../../domain/entities/election.dart';
import '../../domain/repositories/election_repository.dart';
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

  int get requiredVotesCount => election?.requiredVotesCount ?? 10;
  List<Candidate> get candidates => election?.candidates ?? [];
  bool get hasActiveElection => election != null && election!.isActive;

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

  ElectionNotifier({required GetOngoingElection getOngoingElection})
      : _getOngoingElection = getOngoingElection,
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
  return ref.watch(electionNotifierProvider).requiredVotesCount;
});

final electionCandidatesProvider = Provider<List<Candidate>>((ref) {
  return ref.watch(electionNotifierProvider).candidates;
});

final hasActiveElectionProvider = Provider<bool>((ref) {
  return ref.watch(electionNotifierProvider).hasActiveElection;
});

final electionLoadingProvider = Provider<bool>((ref) {
  return ref.watch(electionNotifierProvider).status == ElectionLoadStatus.loading;
});

final hasVotedProvider = Provider<bool>((ref) {
  return ref.watch(electionNotifierProvider).election?.hasVoted ?? false;
});
