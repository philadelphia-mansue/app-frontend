import 'package:equatable/equatable.dart';
import '../../../candidates/domain/entities/candidate.dart';

enum ElectionStatus { upcoming, ongoing, ended }

class Election extends Equatable {
  final String id;
  final String name;
  final String description;
  final ElectionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final int requiredVotesCount;
  final List<Candidate> candidates;
  final bool hasVoted;

  const Election({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.requiredVotesCount,
    required this.candidates,
    this.hasVoted = false,
  });

  bool get isActive => status == ElectionStatus.ongoing;

  Election copyWith({
    String? id,
    String? name,
    String? description,
    ElectionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int? requiredVotesCount,
    List<Candidate>? candidates,
    bool? hasVoted,
  }) {
    return Election(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      requiredVotesCount: requiredVotesCount ?? this.requiredVotesCount,
      candidates: candidates ?? this.candidates,
      hasVoted: hasVoted ?? this.hasVoted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        status,
        startDate,
        endDate,
        requiredVotesCount,
        candidates,
        hasVoted,
      ];
}
