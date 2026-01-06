import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../elections/presentation/providers/election_providers.dart';

enum SelectionResult {
  selected,
  deselected,
  maxReached,
  alreadyAtMax,
}

class SelectionNotifier extends StateNotifier<Set<String>> {
  final int _maxVotes;

  SelectionNotifier(this._maxVotes) : super({});

  int get selectionCount => state.length;
  int get maxVotes => _maxVotes;
  int get remainingSelections => _maxVotes - state.length;
  bool get canSubmit => state.length == _maxVotes;

  SelectionResult toggleSelection(String candidateId) {
    if (state.contains(candidateId)) {
      // Deselect
      state = {...state}..remove(candidateId);
      return SelectionResult.deselected;
    } else if (state.length < _maxVotes) {
      // Select
      state = {...state, candidateId};

      if (state.length == _maxVotes) {
        return SelectionResult.maxReached;
      }
      return SelectionResult.selected;
    } else {
      // Already at max
      return SelectionResult.alreadyAtMax;
    }
  }

  bool isSelected(String candidateId) => state.contains(candidateId);

  List<String> get selectedIds => state.toList();

  void clearSelections() {
    state = {};
  }
}

// Provider - uses dynamic maxVotes from election
final selectionNotifierProvider =
    StateNotifierProvider<SelectionNotifier, Set<String>>((ref) {
  final maxVotes = ref.watch(requiredVotesCountProvider);
  return SelectionNotifier(maxVotes);
});

// Convenience selectors
final selectionCountProvider = Provider<int>((ref) {
  return ref.watch(selectionNotifierProvider).length;
});

final canSubmitVoteProvider = Provider<bool>((ref) {
  final maxVotes = ref.watch(requiredVotesCountProvider);
  return ref.watch(selectionNotifierProvider).length == maxVotes;
});
