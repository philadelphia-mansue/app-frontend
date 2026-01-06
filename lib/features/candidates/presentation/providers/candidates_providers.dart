import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/candidate_mock_datasource.dart';
import '../../data/repositories/candidate_repository_impl.dart';
import '../../domain/entities/candidate.dart';
import '../../domain/repositories/candidate_repository.dart';
import '../../domain/usecases/get_candidates.dart';

// Data Sources
final candidateMockDataSourceProvider = Provider<CandidateMockDataSource>((ref) {
  return CandidateMockDataSourceImpl();
});

// Repository
final candidateRepositoryProvider = Provider<CandidateRepository>((ref) {
  return CandidateRepositoryImpl(
    mockDataSource: ref.watch(candidateMockDataSourceProvider),
  );
});

// Use Cases
final getCandidatesUseCaseProvider = Provider<GetCandidates>((ref) {
  return GetCandidates(ref.watch(candidateRepositoryProvider));
});

// State
enum CandidatesStatus { initial, loading, loaded, error }

class CandidatesState {
  final CandidatesStatus status;
  final List<Candidate> candidates;
  final String? errorMessage;

  const CandidatesState({
    this.status = CandidatesStatus.initial,
    this.candidates = const [],
    this.errorMessage,
  });

  CandidatesState copyWith({
    CandidatesStatus? status,
    List<Candidate>? candidates,
    String? errorMessage,
  }) {
    return CandidatesState(
      status: status ?? this.status,
      candidates: candidates ?? this.candidates,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Notifier
class CandidatesNotifier extends StateNotifier<CandidatesState> {
  final GetCandidates _getCandidates;

  CandidatesNotifier({required GetCandidates getCandidates})
      : _getCandidates = getCandidates,
        super(const CandidatesState());

  Future<void> loadCandidates() async {
    state = state.copyWith(status: CandidatesStatus.loading);

    final result = await _getCandidates(const NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        status: CandidatesStatus.error,
        errorMessage: failure.message,
      ),
      (candidates) => state = state.copyWith(
        status: CandidatesStatus.loaded,
        candidates: candidates,
      ),
    );
  }
}

// Provider
final candidatesNotifierProvider =
    StateNotifierProvider<CandidatesNotifier, CandidatesState>((ref) {
  return CandidatesNotifier(
    getCandidates: ref.watch(getCandidatesUseCaseProvider),
  );
});

// Convenience selectors
final candidatesListProvider = Provider<List<Candidate>>((ref) {
  return ref.watch(candidatesNotifierProvider).candidates;
});

final candidatesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(candidatesNotifierProvider).status == CandidatesStatus.loading;
});
