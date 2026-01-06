import 'package:equatable/equatable.dart';

class Vote extends Equatable {
  final String id;
  final String electionId;
  final List<String> selectedCandidateIds;
  final DateTime timestamp;

  const Vote({
    required this.id,
    required this.electionId,
    required this.selectedCandidateIds,
    required this.timestamp,
  });

  /// Check if vote is valid for the given required count
  bool isValidForCount(int requiredCount) =>
      selectedCandidateIds.length == requiredCount;

  @override
  List<Object?> get props => [id, electionId, selectedCandidateIds, timestamp];
}
