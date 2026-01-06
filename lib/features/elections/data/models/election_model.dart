import '../../../candidates/data/models/candidate_model.dart';
import '../../domain/entities/election.dart';

class ElectionModel extends Election {
  const ElectionModel({
    required super.id,
    required super.name,
    required super.description,
    required super.status,
    required super.startDate,
    required super.endDate,
    required super.requiredVotesCount,
    required super.candidates,
    super.hasVoted,
  });

  /// API response format:
  /// { "data": { "id", "name", "description", "status",
  ///   "start_date", "end_date", "required_votes_count", "has_voted", "candidates": [...] } }
  factory ElectionModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return ElectionModel(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String? ?? '',
      status: _parseStatus(data['status'] as String),
      startDate: DateTime.parse(data['start_date'] as String),
      endDate: DateTime.parse(data['end_date'] as String),
      requiredVotesCount: data['required_votes_count'] as int,
      hasVoted: data['has_voted'] as bool? ?? false,
      candidates: (data['candidates'] as List<dynamic>?)
              ?.map((c) => CandidateModel.fromElectionJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static ElectionStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return ElectionStatus.ongoing;
      case 'ended':
      case 'completed':
        return ElectionStatus.ended;
      case 'upcoming':
      default:
        return ElectionStatus.upcoming;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'required_votes_count': requiredVotesCount,
      'candidates': candidates
          .map((c) => CandidateModel.fromEntity(c).toJson())
          .toList(),
    };
  }
}
