enum VotingFlowStep {
  authentication,
  candidateListing,
  confirmation,
  submitting,
  success,
  error,
}

class VotingFlowState {
  final VotingFlowStep currentStep;
  final bool isAuthenticated;
  final List<String> selectedCandidateIds;
  final bool isSubmitting;
  final String? errorMessage;
  final String? voteId;

  const VotingFlowState({
    this.currentStep = VotingFlowStep.authentication,
    this.isAuthenticated = false,
    this.selectedCandidateIds = const [],
    this.isSubmitting = false,
    this.errorMessage,
    this.voteId,
  });

  VotingFlowState copyWith({
    VotingFlowStep? currentStep,
    bool? isAuthenticated,
    List<String>? selectedCandidateIds,
    bool? isSubmitting,
    String? errorMessage,
    String? voteId,
  }) {
    return VotingFlowState(
      currentStep: currentStep ?? this.currentStep,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      selectedCandidateIds: selectedCandidateIds ?? this.selectedCandidateIds,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
      voteId: voteId ?? this.voteId,
    );
  }

  factory VotingFlowState.initial() => const VotingFlowState();
}
