import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../flow_state.dart';
import '../voting_flow_orchestrator.dart';

// Main orchestrator provider
final votingFlowOrchestratorProvider =
    StateNotifierProvider<VotingFlowOrchestrator, VotingFlowState>((ref) {
  return VotingFlowOrchestrator(ref);
});

// Convenience selectors
final currentFlowStepProvider = Provider<VotingFlowStep>((ref) {
  return ref.watch(votingFlowOrchestratorProvider).currentStep;
});

final isFlowAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(votingFlowOrchestratorProvider).isAuthenticated;
});

final canProceedToConfirmationProvider = Provider<bool>((ref) {
  final orchestrator = ref.read(votingFlowOrchestratorProvider.notifier);
  return orchestrator.canProceedToConfirmation();
});

final isFlowSubmittingProvider = Provider<bool>((ref) {
  return ref.watch(votingFlowOrchestratorProvider).isSubmitting;
});

final flowErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(votingFlowOrchestratorProvider).errorMessage;
});
