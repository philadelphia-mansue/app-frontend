import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/auth/presentation/providers/auth_state.dart';
import '../features/voting/presentation/providers/selection_notifier.dart';
import '../features/voting/presentation/providers/voting_providers.dart';
import 'flow_state.dart';

class VotingFlowOrchestrator extends StateNotifier<VotingFlowState> {
  final Ref _ref;

  VotingFlowOrchestrator(this._ref) : super(VotingFlowState.initial()) {
    // Listen to auth state changes
    _ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        onAuthenticationComplete();
      } else if (next.status == AuthStatus.unauthenticated) {
        state = state.copyWith(
          currentStep: VotingFlowStep.authentication,
          isAuthenticated: false,
        );
      }
    });

    // Listen to selection changes
    _ref.listen<Set<String>>(selectionNotifierProvider, (previous, next) {
      state = state.copyWith(selectedCandidateIds: next.toList());
    });

    // Listen to voting state
    _ref.listen<VotingState>(votingNotifierProvider, (previous, next) {
      if (next.status == VotingStatus.submitting) {
        state = state.copyWith(
          currentStep: VotingFlowStep.submitting,
          isSubmitting: true,
        );
      } else if (next.status == VotingStatus.success) {
        state = state.copyWith(
          currentStep: VotingFlowStep.success,
          isSubmitting: false,
          voteId: next.vote?.id,
        );
      } else if (next.status == VotingStatus.error) {
        state = state.copyWith(
          currentStep: VotingFlowStep.error,
          isSubmitting: false,
          errorMessage: next.errorMessage,
        );
      }
    });
  }

  void onAuthenticationComplete() {
    state = state.copyWith(
      currentStep: VotingFlowStep.candidateListing,
      isAuthenticated: true,
    );
  }

  void updateSelection(List<String> candidateIds) {
    state = state.copyWith(selectedCandidateIds: candidateIds);
  }

  bool canProceedToConfirmation() {
    return state.selectedCandidateIds.length == AppConstants.maxVotes;
  }

  void proceedToConfirmation() {
    if (canProceedToConfirmation()) {
      state = state.copyWith(currentStep: VotingFlowStep.confirmation);
    }
  }

  void goBack() {
    switch (state.currentStep) {
      case VotingFlowStep.confirmation:
        state = state.copyWith(currentStep: VotingFlowStep.candidateListing);
        break;
      case VotingFlowStep.error:
        state = state.copyWith(
          currentStep: VotingFlowStep.confirmation,
          errorMessage: null,
        );
        break;
      default:
        break;
    }
  }

  void resetFlow() {
    _ref.read(selectionNotifierProvider.notifier).clearSelections();
    _ref.read(votingNotifierProvider.notifier).reset();
    _ref.read(authNotifierProvider.notifier).reset();
    state = VotingFlowState.initial();
  }
}
