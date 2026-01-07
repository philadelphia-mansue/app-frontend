import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/candidate.dart';
import '../../domain/repositories/candidate_repository.dart';
import '../../domain/usecases/get_candidates.dart';
import 'candidates_providers.dart';

/// Public API contract for the Candidates feature.
///
/// Use this feature bundle for clear dependency management and better
/// discoverability of available providers.
///
/// Example usage:
/// ```dart
/// final candidates = ref.watch(candidatesFeature.candidates);
/// final isLoading = ref.watch(candidatesFeature.isLoading);
/// ref.read(candidatesFeature.notifier.notifier).loadCandidates();
/// ```
abstract class CandidatesFeature {
  // Domain layer
  Provider<CandidateRepository> get repository;
  Provider<GetCandidates> get getCandidatesUseCase;

  // Presentation layer
  StateNotifierProvider<CandidatesNotifier, CandidatesState> get notifier;

  // Convenience selectors
  Provider<List<Candidate>> get candidates;
  Provider<bool> get isLoading;
}

class _CandidatesFeatureImpl implements CandidatesFeature {
  @override
  Provider<CandidateRepository> get repository => candidateRepositoryProvider;

  @override
  Provider<GetCandidates> get getCandidatesUseCase =>
      getCandidatesUseCaseProvider;

  @override
  StateNotifierProvider<CandidatesNotifier, CandidatesState> get notifier =>
      candidatesNotifierProvider;

  @override
  Provider<List<Candidate>> get candidates => candidatesListProvider;

  @override
  Provider<bool> get isLoading => candidatesLoadingProvider;
}

/// Singleton instance for the Candidates feature.
///
/// Import this to access candidates-related providers:
/// ```dart
/// import 'candidates_feature.dart';
///
/// // In your widget or provider:
/// final candidates = ref.watch(candidatesFeature.candidates);
/// ```
final candidatesFeature = _CandidatesFeatureImpl();
