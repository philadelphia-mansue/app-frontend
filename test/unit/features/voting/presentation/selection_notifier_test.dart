import 'package:flutter_test/flutter_test.dart';
import 'package:philadelphia_mansue/features/voting/presentation/providers/selection_notifier.dart';

void main() {
  late SelectionNotifier notifier;

  setUp(() {
    notifier = SelectionNotifier(10, null);
  });

  group('SelectionNotifier', () {
    test('should start with empty selection', () {
      expect(notifier.selectionCount, equals(0));
      expect(notifier.canSubmit, isFalse);
      expect(notifier.remainingSelections, equals(10));
      expect(notifier.selectedIds, isEmpty);
    });

    test('should return maxVotes correctly', () {
      expect(notifier.maxVotes, equals(10));
    });

    group('toggleSelection', () {
      test('should add candidate and return selected', () {
        final result = notifier.toggleSelection('candidate-1');

        expect(result, equals(SelectionResult.selected));
        expect(notifier.selectionCount, equals(1));
        expect(notifier.isSelected('candidate-1'), isTrue);
      });

      test('should remove candidate and return deselected', () {
        notifier.toggleSelection('candidate-1');
        final result = notifier.toggleSelection('candidate-1');

        expect(result, equals(SelectionResult.deselected));
        expect(notifier.selectionCount, equals(0));
        expect(notifier.isSelected('candidate-1'), isFalse);
      });

      test('should return maxReached when adding 10th candidate', () {
        for (var i = 1; i <= 9; i++) {
          notifier.toggleSelection('candidate-$i');
        }

        final result = notifier.toggleSelection('candidate-10');

        expect(result, equals(SelectionResult.maxReached));
        expect(notifier.selectionCount, equals(10));
        expect(notifier.canSubmit, isTrue);
      });

      test('should return alreadyAtMax when trying to add 11th candidate', () {
        for (var i = 1; i <= 10; i++) {
          notifier.toggleSelection('candidate-$i');
        }

        final result = notifier.toggleSelection('candidate-11');

        expect(result, equals(SelectionResult.alreadyAtMax));
        expect(notifier.selectionCount, equals(10));
        expect(notifier.isSelected('candidate-11'), isFalse);
      });

      test('should allow deselection even at max', () {
        for (var i = 1; i <= 10; i++) {
          notifier.toggleSelection('candidate-$i');
        }

        final result = notifier.toggleSelection('candidate-1');

        expect(result, equals(SelectionResult.deselected));
        expect(notifier.selectionCount, equals(9));
        expect(notifier.canSubmit, isFalse);
      });

      test('should toggle same candidate multiple times', () {
        expect(notifier.toggleSelection('candidate-1'), equals(SelectionResult.selected));
        expect(notifier.toggleSelection('candidate-1'), equals(SelectionResult.deselected));
        expect(notifier.toggleSelection('candidate-1'), equals(SelectionResult.selected));
        expect(notifier.isSelected('candidate-1'), isTrue);
      });
    });

    group('isSelected', () {
      test('should return true for selected candidate', () {
        notifier.toggleSelection('candidate-1');
        expect(notifier.isSelected('candidate-1'), isTrue);
      });

      test('should return false for unselected candidate', () {
        expect(notifier.isSelected('candidate-1'), isFalse);
      });
    });

    group('selectedIds', () {
      test('should return list of selected IDs', () {
        notifier.toggleSelection('candidate-1');
        notifier.toggleSelection('candidate-3');
        notifier.toggleSelection('candidate-5');

        final ids = notifier.selectedIds;

        expect(ids.length, equals(3));
        expect(ids, contains('candidate-1'));
        expect(ids, contains('candidate-3'));
        expect(ids, contains('candidate-5'));
      });

      test('should return empty list when nothing selected', () {
        expect(notifier.selectedIds, isEmpty);
      });
    });

    group('clearSelections', () {
      test('should clear all selections', () {
        notifier.toggleSelection('candidate-1');
        notifier.toggleSelection('candidate-2');
        notifier.toggleSelection('candidate-3');

        notifier.clearSelections();

        expect(notifier.selectionCount, equals(0));
        expect(notifier.canSubmit, isFalse);
        expect(notifier.selectedIds, isEmpty);
      });
    });

    group('computed properties', () {
      test('remainingSelections should decrease as candidates are selected', () {
        expect(notifier.remainingSelections, equals(10));

        notifier.toggleSelection('candidate-1');
        expect(notifier.remainingSelections, equals(9));

        notifier.toggleSelection('candidate-2');
        expect(notifier.remainingSelections, equals(8));
      });

      test('canSubmit should be true only when exactly maxVotes selected', () {
        for (var i = 1; i < 10; i++) {
          notifier.toggleSelection('candidate-$i');
          expect(notifier.canSubmit, isFalse);
        }

        notifier.toggleSelection('candidate-10');
        expect(notifier.canSubmit, isTrue);

        notifier.toggleSelection('candidate-1'); // deselect
        expect(notifier.canSubmit, isFalse);
      });
    });

    group('with custom maxVotes', () {
      test('should work with maxVotes of 5', () {
        final smallNotifier = SelectionNotifier(5, null);

        for (var i = 1; i <= 5; i++) {
          smallNotifier.toggleSelection('candidate-$i');
        }

        expect(smallNotifier.canSubmit, isTrue);
        expect(smallNotifier.selectionCount, equals(5));
        expect(smallNotifier.toggleSelection('candidate-6'), equals(SelectionResult.alreadyAtMax));
      });
    });
  });
}
