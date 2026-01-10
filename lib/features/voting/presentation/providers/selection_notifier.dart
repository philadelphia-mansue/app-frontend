import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/selection_storage.dart';
import '../../../elections/presentation/providers/election_providers.dart';

enum SelectionResult {
  selected,
  deselected,
  maxReached,
  alreadyAtMax,
}

class SelectionNotifier extends StateNotifier<Set<String>> {
  final int _maxVotes;
  final String? _electionId;

  SelectionNotifier(this._maxVotes, this._electionId) : super({}) {
    _loadSelections();
  }

  /// Load selections from sessionStorage on web
  void _loadSelections() {
    if (_electionId == null) return;
    final saved = getStoredSelections(_electionId);
    if (saved.isNotEmpty && mounted) {
      state = saved;
    }
  }

  /// Save selections to sessionStorage on web
  void _saveSelections() {
    if (_electionId == null) return;
    saveStoredSelections(_electionId, state);
  }

  int get selectionCount => state.length;
  int get maxVotes => _maxVotes;
  int get remainingSelections => _maxVotes - state.length;
  bool get canSubmit => state.length == _maxVotes;

  SelectionResult toggleSelection(String candidateId) {
    if (state.contains(candidateId)) {
      // Deselect
      state = {...state}..remove(candidateId);
      _saveSelections();
      return SelectionResult.deselected;
    } else if (state.length < _maxVotes) {
      // Select
      state = {...state, candidateId};
      _saveSelections();

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
    if (_electionId != null) {
      clearStoredSelections(_electionId);
    }
  }
}

// Provider - uses dynamic maxVotes from election and electionId for storage
final selectionNotifierProvider =
    StateNotifierProvider<SelectionNotifier, Set<String>>((ref) {
  final maxVotes = ref.watch(requiredVotesCountProvider);
  final electionId = ref.watch(currentElectionIdProvider);
  return SelectionNotifier(maxVotes, electionId);
});

// Convenience selectors
final selectionCountProvider = Provider<int>((ref) {
  return ref.watch(selectionNotifierProvider).length;
});

final canSubmitVoteProvider = Provider<bool>((ref) {
  final maxVotes = ref.watch(requiredVotesCountProvider);
  return ref.watch(selectionNotifierProvider).length == maxVotes;
});
