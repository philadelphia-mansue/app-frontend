import 'package:philadelphia_mansue/features/candidates/domain/entities/candidate.dart';

/// Creates a test Candidate with customizable properties
Candidate createTestCandidate({
  String id = 'candidate-1',
  String firstName = 'Jane',
  String lastName = 'Smith',
  String photoUrl = 'https://example.com/photo.jpg',
}) {
  return Candidate(
    id: id,
    firstName: firstName,
    lastName: lastName,
    photoUrl: photoUrl,
  );
}

/// Creates a list of test candidates
List<Candidate> createTestCandidates(int count) {
  return List.generate(
    count,
    (i) => createTestCandidate(
      id: 'candidate-${i + 1}',
      firstName: 'Candidate',
      lastName: '${i + 1}',
      photoUrl: 'https://example.com/photo${i + 1}.jpg',
    ),
  );
}

/// Creates candidate IDs for testing
List<String> createTestCandidateIds(int count) {
  return List.generate(count, (i) => 'candidate-${i + 1}');
}
