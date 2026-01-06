import '../../domain/entities/vote.dart';

class VoteModel extends Vote {
  const VoteModel({
    required super.id,
    required super.electionId,
    required super.selectedCandidateIds,
    required super.timestamp,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    return VoteModel(
      id: json['id'] as String? ?? '',
      electionId: json['election_id'] as String,
      selectedCandidateIds: List<String>.from(json['candidates'] as List),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  /// Converts to API request format
  /// Matches: {"election_id": "uuid", "candidates": ["uuid-1", "uuid-2"]}
  Map<String, dynamic> toApiRequest() {
    return {
      'election_id': electionId,
      'candidates': selectedCandidateIds,
    };
  }

  /// Full JSON representation (for local storage/logging)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'election_id': electionId,
      'candidates': selectedCandidateIds,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory VoteModel.fromEntity(Vote vote) {
    return VoteModel(
      id: vote.id,
      electionId: vote.electionId,
      selectedCandidateIds: vote.selectedCandidateIds,
      timestamp: vote.timestamp,
    );
  }
}
