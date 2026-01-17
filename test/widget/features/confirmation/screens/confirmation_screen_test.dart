import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luckyui/luckyui.dart';
import 'package:philadelphia_mansue/features/confirmation/presentation/screens/confirmation_screen.dart';
import 'package:philadelphia_mansue/features/confirmation/presentation/widgets/warning_banner.dart';
import 'package:philadelphia_mansue/features/confirmation/presentation/widgets/selected_candidates_list.dart';
import 'package:philadelphia_mansue/features/elections/presentation/providers/election_providers.dart';
import 'package:philadelphia_mansue/features/elections/domain/entities/election.dart';
import 'package:philadelphia_mansue/features/voting/presentation/providers/selection_notifier.dart';
import 'package:philadelphia_mansue/features/voting/presentation/providers/voting_providers.dart';
import 'package:philadelphia_mansue/features/auth/presentation/providers/auth_providers.dart';
import 'package:philadelphia_mansue/features/auth/presentation/providers/auth_state.dart';

import '../../../../helpers/test_wrapper.dart';
import '../../../../helpers/fixtures/candidate_fixture.dart';

// Helper to create a mock active election
Election _createActiveElection() => Election(
      id: 'test-election-1',
      name: 'Test Election',
      description: 'Test Description',
      status: ElectionStatus.ongoing,
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 1)),
      requiredVotesCount: 10,
      candidates: [],
    );

void main() {
  group('ConfirmationScreen', () {
    testWidgets('displays warning banner', (tester) async {
      final candidates = createTestCandidates(3);

      await tester.pumpWidget(
        wrapScreen(
          const ConfirmationScreen(),
          overrides: [
            selectionNotifierProvider.overrideWith(
              (ref) => _MockSelectionNotifier({'candidate-1', 'candidate-2'}),
            ),
            electionCandidatesProvider.overrideWith((ref) => candidates),
            votingNotifierProvider.overrideWith(
              (ref) => _MockVotingNotifier(const VotingState()),
            ),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                ElectionState(
                  status: ElectionLoadStatus.loaded,
                  election: _createActiveElection(),
                ),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WarningBanner), findsOneWidget);
    });

    testWidgets('displays selected candidates list', (tester) async {
      final candidates = createTestCandidates(3);

      await tester.pumpWidget(
        wrapScreen(
          const ConfirmationScreen(),
          overrides: [
            selectionNotifierProvider.overrideWith(
              (ref) => _MockSelectionNotifier({'candidate-1', 'candidate-2'}),
            ),
            electionCandidatesProvider.overrideWith((ref) => candidates),
            votingNotifierProvider.overrideWith(
              (ref) => _MockVotingNotifier(const VotingState()),
            ),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                ElectionState(
                  status: ElectionLoadStatus.loaded,
                  election: _createActiveElection(),
                ),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SelectedCandidatesList), findsOneWidget);
    });

    testWidgets('shows "Confirm Your Vote" in app bar', (tester) async {
      final candidates = createTestCandidates(3);

      await tester.pumpWidget(
        wrapScreen(
          const ConfirmationScreen(),
          overrides: [
            selectionNotifierProvider.overrideWith(
              (ref) => _MockSelectionNotifier({'candidate-1'}),
            ),
            electionCandidatesProvider.overrideWith((ref) => candidates),
            votingNotifierProvider.overrideWith(
              (ref) => _MockVotingNotifier(const VotingState()),
            ),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                ElectionState(
                  status: ElectionLoadStatus.loaded,
                  election: _createActiveElection(),
                ),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Confirm Your Vote'), findsOneWidget);
    });

    testWidgets('shows "Your Selected Candidates" label', (tester) async {
      final candidates = createTestCandidates(3);

      await tester.pumpWidget(
        wrapScreen(
          const ConfirmationScreen(),
          overrides: [
            selectionNotifierProvider.overrideWith(
              (ref) => _MockSelectionNotifier({'candidate-1'}),
            ),
            electionCandidatesProvider.overrideWith((ref) => candidates),
            votingNotifierProvider.overrideWith(
              (ref) => _MockVotingNotifier(const VotingState()),
            ),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                ElectionState(
                  status: ElectionLoadStatus.loaded,
                  election: _createActiveElection(),
                ),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your Selected Candidates'), findsOneWidget);
    });

    testWidgets('shows selected count', (tester) async {
      final candidates = createTestCandidates(5);

      await tester.pumpWidget(
        wrapScreen(
          const ConfirmationScreen(),
          overrides: [
            selectionNotifierProvider.overrideWith(
              (ref) => _MockSelectionNotifier({'candidate-1', 'candidate-2', 'candidate-3'}),
            ),
            electionCandidatesProvider.overrideWith((ref) => candidates),
            votingNotifierProvider.overrideWith(
              (ref) => _MockVotingNotifier(const VotingState()),
            ),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                ElectionState(
                  status: ElectionLoadStatus.loaded,
                  election: _createActiveElection(),
                ),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3 selected'), findsOneWidget);
    });

    testWidgets('shows confirm vote button', (tester) async {
      final candidates = createTestCandidates(3);

      await tester.pumpWidget(
        wrapScreen(
          const ConfirmationScreen(),
          overrides: [
            selectionNotifierProvider.overrideWith(
              (ref) => _MockSelectionNotifier({'candidate-1'}),
            ),
            electionCandidatesProvider.overrideWith((ref) => candidates),
            votingNotifierProvider.overrideWith(
              (ref) => _MockVotingNotifier(const VotingState()),
            ),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                ElectionState(
                  status: ElectionLoadStatus.loaded,
                  election: _createActiveElection(),
                ),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Confirm Vote'), findsOneWidget);
    });

    testWidgets('shows "Submitting..." when vote is being submitted', (tester) async {
      final candidates = createTestCandidates(3);

      await tester.pumpWidget(
        wrapScreen(
          const ConfirmationScreen(),
          overrides: [
            selectionNotifierProvider.overrideWith(
              (ref) => _MockSelectionNotifier({'candidate-1'}),
            ),
            electionCandidatesProvider.overrideWith((ref) => candidates),
            votingNotifierProvider.overrideWith(
              (ref) => _MockVotingNotifier(
                const VotingState(status: VotingStatus.submitting),
              ),
            ),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                ElectionState(
                  status: ElectionLoadStatus.loaded,
                  election: _createActiveElection(),
                ),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Submitting...'), findsOneWidget);
    });

    testWidgets('shows go back button', (tester) async {
      final candidates = createTestCandidates(3);

      await tester.pumpWidget(
        wrapScreen(
          const ConfirmationScreen(),
          overrides: [
            selectionNotifierProvider.overrideWith(
              (ref) => _MockSelectionNotifier({'candidate-1'}),
            ),
            electionCandidatesProvider.overrideWith((ref) => candidates),
            votingNotifierProvider.overrideWith(
              (ref) => _MockVotingNotifier(const VotingState()),
            ),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                ElectionState(
                  status: ElectionLoadStatus.loaded,
                  election: _createActiveElection(),
                ),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Go Back'), findsOneWidget);
    });

    testWidgets('go back button is disabled while submitting', (tester) async {
      final candidates = createTestCandidates(3);

      await tester.pumpWidget(
        wrapScreen(
          const ConfirmationScreen(),
          overrides: [
            selectionNotifierProvider.overrideWith(
              (ref) => _MockSelectionNotifier({'candidate-1'}),
            ),
            electionCandidatesProvider.overrideWith((ref) => candidates),
            votingNotifierProvider.overrideWith(
              (ref) => _MockVotingNotifier(
                const VotingState(status: VotingStatus.submitting),
              ),
            ),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                ElectionState(
                  status: ElectionLoadStatus.loaded,
                  election: _createActiveElection(),
                ),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final textButton = tester.widget<TextButton>(
        find.ancestor(
          of: find.text('Go Back'),
          matching: find.byType(TextButton),
        ),
      );
      expect(textButton.onPressed, isNull);
    });

    testWidgets('has LuckyAppBar', (tester) async {
      final candidates = createTestCandidates(3);

      await tester.pumpWidget(
        wrapScreen(
          const ConfirmationScreen(),
          overrides: [
            selectionNotifierProvider.overrideWith(
              (ref) => _MockSelectionNotifier({'candidate-1'}),
            ),
            electionCandidatesProvider.overrideWith((ref) => candidates),
            votingNotifierProvider.overrideWith(
              (ref) => _MockVotingNotifier(const VotingState()),
            ),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                ElectionState(
                  status: ElectionLoadStatus.loaded,
                  election: _createActiveElection(),
                ),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LuckyAppBar), findsOneWidget);
    });

    testWidgets('uses LuckyButton for confirm vote', (tester) async {
      final candidates = createTestCandidates(3);

      await tester.pumpWidget(
        wrapScreen(
          const ConfirmationScreen(),
          overrides: [
            selectionNotifierProvider.overrideWith(
              (ref) => _MockSelectionNotifier({'candidate-1'}),
            ),
            electionCandidatesProvider.overrideWith((ref) => candidates),
            votingNotifierProvider.overrideWith(
              (ref) => _MockVotingNotifier(const VotingState()),
            ),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                ElectionState(
                  status: ElectionLoadStatus.loaded,
                  election: _createActiveElection(),
                ),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LuckyButton), findsOneWidget);
    });

    testWidgets('button is disabled when submitting', (tester) async {
      final candidates = createTestCandidates(3);

      await tester.pumpWidget(
        wrapScreen(
          const ConfirmationScreen(),
          overrides: [
            selectionNotifierProvider.overrideWith(
              (ref) => _MockSelectionNotifier({'candidate-1'}),
            ),
            electionCandidatesProvider.overrideWith((ref) => candidates),
            votingNotifierProvider.overrideWith(
              (ref) => _MockVotingNotifier(
                const VotingState(status: VotingStatus.submitting),
              ),
            ),
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                ElectionState(
                  status: ElectionLoadStatus.loaded,
                  election: _createActiveElection(),
                ),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Check for reduced opacity
      final opacity = tester.widget<Opacity>(find.byType(Opacity).first);
      expect(opacity.opacity, 0.6);
    });
  });
}

// Mock selection notifier
class _MockSelectionNotifier extends StateNotifier<Set<String>>
    implements SelectionNotifier {
  _MockSelectionNotifier(super.state);

  @override
  int get selectionCount => state.length;

  @override
  int get maxVotes => 10;

  @override
  int get remainingSelections => maxVotes - state.length;

  @override
  bool get canSubmit => state.length == maxVotes;

  @override
  SelectionResult toggleSelection(String candidateId) => SelectionResult.selected;

  @override
  bool isSelected(String candidateId) => state.contains(candidateId);

  @override
  List<String> get selectedIds => state.toList();

  @override
  void clearSelections() {
    state = {};
  }
}

// Mock voting notifier
class _MockVotingNotifier extends StateNotifier<VotingState>
    implements VotingNotifier {
  _MockVotingNotifier(super.state);

  @override
  Future<bool> validateSelection(List<String> candidateIds) async => true;

  @override
  Future<void> submitVote(List<String> candidateIds, String sessionId) async {}

  @override
  void reset() {}

  @override
  void resetToInitial() {}
}

// Mock auth notifier
class _MockAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  _MockAuthNotifier(super.state);

  @override
  String? get phoneNumber => null;

  @override
  Future<void> sendOtp(String phoneNumber) async {}

  @override
  Future<void> verifyOtp(String code) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> checkAuthStatus() async {}

  @override
  Future<void> handleFirebaseSignOut() async {}

  @override
  Future<void> debugImpersonate(String phone, String magicToken) async {}

  @override
  void reset() {}

  @override
  void setImpersonating() {}

  @override
  void markPendingImpersonation() {}

  @override
  Future<void> tryRestoreSession(String userId) async {}

  @override
  Future<void> refreshToken() async {}
}

// Mock election notifier
class _MockElectionNotifier extends StateNotifier<ElectionState>
    implements ElectionNotifier {
  _MockElectionNotifier(super.state);

  @override
  Future<void> loadOngoingElection() async {}

  @override
  Future<void> loadElectionById(String id) async {}

  @override
  void reset() {}

  @override
  void markAsVoted() {}
}
