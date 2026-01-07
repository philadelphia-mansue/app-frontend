import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:philadelphia_mansue/core/errors/failures.dart';
import 'package:philadelphia_mansue/features/voting/domain/usecases/validate_selection.dart';

import '../../../../helpers/fixtures/candidate_fixture.dart';

void main() {
  late ValidateSelection useCase;

  setUp(() {
    useCase = ValidateSelection();
  });

  group('ValidateSelection UseCase', () {
    test('should return Right(true) when exactly 10 unique candidates selected', () async {
      // Arrange
      final candidateIds = createTestCandidateIds(10);

      // Act
      final result = await useCase(
        ValidateSelectionParams(candidateIds: candidateIds),
      );

      // Assert
      expect(result, equals(const Right(true)));
    });

    test('should return Left(ValidationFailure) when less than 10 candidates selected', () async {
      // Arrange - 9 candidates
      final candidateIds = createTestCandidateIds(9);

      // Act
      final result = await useCase(
        ValidateSelectionParams(candidateIds: candidateIds),
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('exactly 10'));
          expect(failure.message, contains('9'));
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should return Left(ValidationFailure) when more than 10 candidates selected', () async {
      // Arrange - 11 candidates
      final candidateIds = createTestCandidateIds(11);

      // Act
      final result = await useCase(
        ValidateSelectionParams(candidateIds: candidateIds),
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('exactly 10'));
          expect(failure.message, contains('11'));
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should return Left(ValidationFailure) when empty selection', () async {
      // Arrange
      final candidateIds = <String>[];

      // Act
      final result = await useCase(
        ValidateSelectionParams(candidateIds: candidateIds),
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('0'));
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should return Left(ValidationFailure) when duplicates exist', () async {
      // Arrange - 10 items but with duplicates
      final candidateIds = [
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
      ];

      // Act
      final result = await useCase(
        ValidateSelectionParams(candidateIds: candidateIds),
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('Duplicate'));
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should return Left when 5 candidates selected', () async {
      // Arrange
      final candidateIds = createTestCandidateIds(5);

      // Act
      final result = await useCase(
        ValidateSelectionParams(candidateIds: candidateIds),
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, contains('5')),
        (_) => fail('Should return Left'),
      );
    });

    test('should return Left when 1 candidate selected', () async {
      // Arrange
      final candidateIds = createTestCandidateIds(1);

      // Act
      final result = await useCase(
        ValidateSelectionParams(candidateIds: candidateIds),
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, contains('1')),
        (_) => fail('Should return Left'),
      );
    });

    test('should handle candidate IDs with special characters', () async {
      // Arrange - all unique IDs with special chars
      final candidateIds = List.generate(
        10,
        (i) => 'candidate_${i}_special-chars.test',
      );

      // Act
      final result = await useCase(
        ValidateSelectionParams(candidateIds: candidateIds),
      );

      // Assert
      expect(result, equals(const Right(true)));
    });
  });
}
