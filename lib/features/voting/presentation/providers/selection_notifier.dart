import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/selection_storage.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
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
  final bool _isAuthenticated;

  SelectionNotifier(this._maxVotes, this._electionId, this._isAuthenticated) : super({}) {
    _loadSelections();
  }

  /// Load selections from sessionStorage on web
  /// Only loads if user is authenticated (token validated)
  void _loadSelections() {
    if (_electionId == null) return;
    // Don't load cached data if not authenticated
    if (!_isAuthenticated) return;
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
// Only loads cached selections when user is authenticated (token validated)
final selectionNotifierProvider =
    StateNotifierProvider<SelectionNotifier, Set<String>>((ref) {
  final maxVotes = ref.watch(requiredVotesCountProvider);
  final electionId = ref.watch(currentElectionIdProvider);
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final notifier = SelectionNotifier(maxVotes, electionId, isAuthenticated);

  // Listen for hasVoted changes - clear selections when vote is deleted from backend
  ref.listen<bool>(hasVotedProvider, (previous, next) {
    // If hasVoted changed from true to false, vote was deleted - clear selections
    if (previous == true && next == false) {
      notifier.clearSelections();
    }
  });

  return notifier;
});

// Convenience selectors
final selectionCountProvider = Provider<int>((ref) {
  return ref.watch(selectionNotifierProvider).length;
});

final canSubmitVoteProvider = Provider<bool>((ref) {
  final maxVotes = ref.watch(requiredVotesCountProvider);
  return ref.watch(selectionNotifierProvider).length == maxVotes;
});
