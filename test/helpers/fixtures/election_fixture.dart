import 'package:philadelphia_mansue/features/elections/domain/entities/election.dart';
import 'package:philadelphia_mansue/features/candidates/domain/entities/candidate.dart';
import 'candidate_fixture.dart';

/// Creates a test Election with customizable properties
Election createTestElection({
  String id = 'election-1',
  String name = 'Test Election',
  String description = 'Test Description',
  ElectionStatus status = ElectionStatus.ongoing,
  DateTime? startDate,
  DateTime? endDate,
  int requiredVotesCount = 10,
  List<Candidate>? candidates,
  bool hasVoted = false,
}) {
  return Election(
    id: id,
    name: name,
    description: description,
    status: status,
    startDate: startDate ?? DateTime.now().subtract(const Duration(days: 1)),
    endDate: endDate ?? DateTime.now().add(const Duration(days: 7)),
    requiredVotesCount: requiredVotesCount,
    candidates: candidates ?? createTestCandidates(15),
    hasVoted: hasVoted,
  );
}

/// Creates an active (ongoing) election
Election createActiveElection({
  String id = 'election-active',
  int requiredVotesCount = 10,
  List<Candidate>? candidates,
  bool hasVoted = false,
}) {
  return createTestElection(
    id: id,
    name: 'Active Election',
    status: ElectionStatus.ongoing,
    requiredVotesCount: requiredVotesCount,
    candidates: candidates,
    hasVoted: hasVoted,
  );
}

/// Creates an ended election
Election createEndedElection({
  String id = 'election-ended',
  bool hasVoted = true,
}) {
  return createTestElection(
    id: id,
    name: 'Ended Election',
    status: ElectionStatus.ended,
    startDate: DateTime.now().subtract(const Duration(days: 14)),
    endDate: DateTime.now().subtract(const Duration(days: 7)),
    hasVoted: hasVoted,
  );
}

/// Creates an upcoming election
Election createUpcomingElection({
  String id = 'election-upcoming',
}) {
  return createTestElection(
    id: id,
    name: 'Upcoming Election',
    status: ElectionStatus.upcoming,
    startDate: DateTime.now().add(const Duration(days: 7)),
    endDate: DateTime.now().add(const Duration(days: 14)),
  );
}
