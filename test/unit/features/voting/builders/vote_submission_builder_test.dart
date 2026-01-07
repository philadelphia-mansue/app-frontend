import 'package:flutter_test/flutter_test.dart';
import 'package:philadelphia_mansue/features/voting/domain/builders/vote_submission_builder.dart';

void main() {
  late VoteSubmissionBuilder builder;

  setUp(() {
    builder = VoteSubmissionBuilder(maxVotes: 10);
  });

  group('VoteSubmissionBuilder', () {
    test('should start with default values', () {
      expect(builder.candidateCount, equals(0));
      expect(builder.maxVotes, equals(10));
      expect(builder.isValid, isFalse);
      expect(builder.candidateIds, isEmpty);
    });

    group('fluent API', () {
      test('should support method chaining', () {
        final result = builder
            .setSessionId('session-1')
            .setElectionId('election-1')
            .addCandidate('candidate-1');

        expect(result, same(builder));
      });

      test('setMaxVotes should update maxVotes', () {
        builder.setMaxVotes(5);
        expect(builder.maxVotes, equals(5));
      });

      test('setSessionId should set session ID', () {
        builder.setSessionId('session-123');
        // No direct getter, but affects isValid
        expect(builder.isValid, isFalse); // Still missing other requirements
      });

      test('setElectionId should set election ID', () {
        builder.setElectionId('election-123');
        expect(builder.isValid, isFalse); // Still missing other requirements
      });

      test('setTimestamp should set timestamp', () {
        final timestamp = DateTime(2024, 1, 1, 12, 0);
        builder.setTimestamp(timestamp);
        // Timestamp is used in build(), not directly accessible
      });
    });

    group('addCandidate', () {
      test('should add candidate when under max', () {
        builder.addCandidate('candidate-1');
        expect(builder.candidateCount, equals(1));
        expect(builder.candidateIds, contains('candidate-1'));
      });

      test('should not add duplicate candidate', () {
        builder.addCandidate('candidate-1');
        builder.addCandidate('candidate-1');
        expect(builder.candidateCount, equals(1));
      });

      test('should not add candidate when at max', () {
        for (var i = 1; i <= 10; i++) {
          builder.addCandidate('candidate-$i');
        }
        builder.addCandidate('candidate-11');
        expect(builder.candidateCount, equals(10));
        expect(builder.candidateIds, isNot(contains('candidate-11')));
      });
    });

    group('addCandidates', () {
      test('should add multiple candidates', () {
        builder.addCandidates(['candidate-1', 'candidate-2', 'candidate-3']);
        expect(builder.candidateCount, equals(3));
      });

      test('should respect max limit when adding batch', () {
        builder.setMaxVotes(5);
        builder.addCandidates([
          'candidate-1',
          'candidate-2',
          'candidate-3',
          'candidate-4',
          'candidate-5',
          'candidate-6',
          'candidate-7',
          'candidate-8',
        ]);
        expect(builder.candidateCount, equals(5));
      });

      test('should handle empty list', () {
        builder.addCandidates([]);
        expect(builder.candidateCount, equals(0));
      });

      test('should skip duplicates in batch', () {
        builder.addCandidates([
          'candidate-1',
          'candidate-1',
          'candidate-2',
          'candidate-2',
        ]);
        expect(builder.candidateCount, equals(2));
      });
    });

    group('removeCandidate', () {
      test('should remove existing candidate', () {
        builder.addCandidate('candidate-1');
        builder.addCandidate('candidate-2');

        builder.removeCandidate('candidate-1');

        expect(builder.candidateCount, equals(1));
        expect(builder.candidateIds, isNot(contains('candidate-1')));
        expect(builder.candidateIds, contains('candidate-2'));
      });

      test('should handle removing non-existent candidate', () {
        builder.addCandidate('candidate-1');
        builder.removeCandidate('non-existent');
        expect(builder.candidateCount, equals(1));
      });
    });

    group('isValid', () {
      test('should return true when all requirements met', () {
        builder
            .setSessionId('session-1')
            .setElectionId('election-1')
            .addCandidates(List.generate(10, (i) => 'candidate-$i'));

        expect(builder.isValid, isTrue);
      });

      test('should return false when missing sessionId', () {
        builder
            .setElectionId('election-1')
            .addCandidates(List.generate(10, (i) => 'candidate-$i'));

        expect(builder.isValid, isFalse);
      });

      test('should return false when missing electionId', () {
        builder
            .setSessionId('session-1')
            .addCandidates(List.generate(10, (i) => 'candidate-$i'));

        expect(builder.isValid, isFalse);
      });

      test('should return false when wrong candidate count', () {
        builder
            .setSessionId('session-1')
            .setElectionId('election-1')
            .addCandidates(List.generate(9, (i) => 'candidate-$i'));

        expect(builder.isValid, isFalse);
      });
    });

    group('build', () {
      test('should build valid vote', () {
        final timestamp = DateTime(2024, 1, 1, 12, 0);
        builder
            .setSessionId('session-1')
            .setElectionId('election-1')
            .addCandidates(List.generate(10, (i) => 'candidate-$i'))
            .setTimestamp(timestamp);

        final vote = builder.build();

        expect(vote.electionId, equals('election-1'));
        expect(vote.selectedCandidateIds.length, equals(10));
        expect(vote.timestamp, equals(timestamp));
        expect(vote.id, contains('session-1'));
      });

      test('should throw StateError when invalid', () {
        expect(
          () => builder.build(),
          throwsA(isA<StateError>()),
        );
      });

      test('should throw StateError with descriptive message', () {
        builder.setSessionId('session-1');
        // Missing electionId and candidates

        expect(
          () => builder.build(),
          throwsA(
            predicate<StateError>(
              (e) =>
                  e.message.contains('candidateCount') &&
                  e.message.contains('electionId'),
            ),
          ),
        );
      });

      test('should use DateTime.now() when no timestamp set', () {
        final beforeBuild = DateTime.now();

        builder
            .setSessionId('session-1')
            .setElectionId('election-1')
            .addCandidates(List.generate(10, (i) => 'candidate-$i'));

        final vote = builder.build();
        final afterBuild = DateTime.now();

        expect(
          vote.timestamp.isAfter(beforeBuild.subtract(const Duration(seconds: 1))),
          isTrue,
        );
        expect(
          vote.timestamp.isBefore(afterBuild.add(const Duration(seconds: 1))),
          isTrue,
        );
      });

      test('should generate unique vote IDs', () {
        builder
            .setSessionId('session-1')
            .setElectionId('election-1')
            .addCandidates(List.generate(10, (i) => 'candidate-$i'));

        final vote1 = builder.build();

        // Reset and rebuild
        builder.reset();
        builder
            .setSessionId('session-1')
            .setElectionId('election-1')
            .addCandidates(List.generate(10, (i) => 'candidate-$i'));

        final vote2 = builder.build();

        // IDs should be different (different timestamps)
        expect(vote1.id, isNot(equals(vote2.id)));
      });
    });

    group('reset', () {
      test('should clear all fields', () {
        builder
            .setSessionId('session-1')
            .setElectionId('election-1')
            .addCandidates(['candidate-1', 'candidate-2'])
            .setTimestamp(DateTime.now());

        builder.reset();

        expect(builder.candidateCount, equals(0));
        expect(builder.candidateIds, isEmpty);
        expect(builder.isValid, isFalse);
      });

      test('should preserve maxVotes after reset', () {
        builder.setMaxVotes(5);
        builder.reset();
        expect(builder.maxVotes, equals(5));
      });
    });

    group('candidateIds getter', () {
      test('should return unmodifiable list', () {
        builder.addCandidates(['candidate-1', 'candidate-2']);

        final ids = builder.candidateIds;

        expect(
          () => ids.add('candidate-3'),
          throwsUnsupportedError,
        );
      });
    });

    group('dynamic maxVotes', () {
      test('should allow more candidates after increasing maxVotes', () {
        builder.setMaxVotes(3);
        builder.addCandidates(['c1', 'c2', 'c3']);
        expect(builder.candidateCount, equals(3));

        builder.setMaxVotes(5);
        builder.addCandidates(['c4', 'c5']);
        expect(builder.candidateCount, equals(5));
      });
    });
  });
}
