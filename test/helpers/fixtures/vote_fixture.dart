import 'package:philadelphia_mansue/features/voting/domain/entities/vote.dart';
import 'candidate_fixture.dart';

/// Creates a test Vote with customizable properties
Vote createTestVote({
  String id = 'vote-1',
  String electionId = 'election-1',
  List<String>? selectedCandidateIds,
  DateTime? timestamp,
}) {
  return Vote(
    id: id,
    electionId: electionId,
    selectedCandidateIds: selectedCandidateIds ?? createTestCandidateIds(10),
    timestamp: timestamp ?? DateTime.now(),
  );
}

/// Creates a vote with specific candidate count
Vote createVoteWithCandidateCount(int count, {
  String id = 'vote-1',
  String electionId = 'election-1',
}) {
  return Vote(
    id: id,
    electionId: electionId,
    selectedCandidateIds: createTestCandidateIds(count),
    timestamp: DateTime.now(),
  );
}

/// Creates a vote with duplicate candidate IDs
Vote createVoteWithDuplicates({
  String id = 'vote-duplicate',
  String electionId = 'election-1',
}) {
  return Vote(
    id: id,
    electionId: electionId,
    selectedCandidateIds: [
      'candidate-1',
      'candidate-1', // duplicate
      'candidate-2',
      'candidate-3',
      'candidate-4',
      'candidate-5',
      'candidate-6',
      'candidate-7',
      'candidate-8',
      'candidate-9',
    ],
    timestamp: DateTime.now(),
  );
}

/// Creates a vote with empty election ID
Vote createVoteWithEmptyElectionId() {
  return Vote(
    id: 'vote-empty-election',
    electionId: '',
    selectedCandidateIds: createTestCandidateIds(10),
    timestamp: DateTime.now(),
  );
}

/// Creates a vote with no candidates
Vote createVoteWithNoCandidates() {
  return Vote(
    id: 'vote-no-candidates',
    electionId: 'election-1',
    selectedCandidateIds: [],
    timestamp: DateTime.now(),
  );
}
