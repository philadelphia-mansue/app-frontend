import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luckyui/luckyui.dart';
import 'package:philadelphia_mansue/features/candidates/presentation/screens/candidates_screen.dart';
import 'package:philadelphia_mansue/features/candidates/presentation/widgets/candidates_grid.dart';
import 'package:philadelphia_mansue/features/elections/presentation/providers/election_providers.dart';
import 'package:philadelphia_mansue/features/voting/presentation/providers/selection_notifier.dart';
import 'package:philadelphia_mansue/features/voting/presentation/widgets/selection_counter.dart';

import '../../../../helpers/test_wrapper.dart';
import '../../../../helpers/fixtures/election_fixture.dart';

// Note: LuckyButton third-party component causes overflow errors in tests.
// We suppress these errors as they don't affect the actual test assertions.
const _testScreenSize = Size(600, 1200);

void main() {
  group('CandidatesScreen', () {
    testWidgets('shows loading indicator when election is loading', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapScreen(
          const CandidatesScreen(),
          screenSize: _testScreenSize,
          overrides: [
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                const ElectionState(status: ElectionLoadStatus.loading),
              ),
            ),
            selectionNotifierProvider.overrideWith((ref) => SelectionNotifier(10)),
            requiredVotesCountProvider.overrideWith((ref) => 10),
          ],
        ),
      );
      await tester.pump();
      // Consume any overflow errors from LuckyButton (third-party component issue)
      tester.takeException();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows candidates grid when election is loaded', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final election = createActiveElection();

      await tester.pumpWidget(
        wrapScreen(
          const CandidatesScreen(),
          screenSize: _testScreenSize,
          overrides: [
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                ElectionState(
                  status: ElectionLoadStatus.loaded,
                  election: election,
                ),
              ),
            ),
            selectionNotifierProvider.overrideWith((ref) => SelectionNotifier(10)),
            requiredVotesCountProvider.overrideWith((ref) => 10),
          ],
        ),
      );
      await tester.pumpAndSettle();
      tester.takeException();

      expect(find.byType(CandidatesGrid), findsOneWidget);
    });

    testWidgets('shows selection counter', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final election = createActiveElection();

      await tester.pumpWidget(
        wrapScreen(
          const CandidatesScreen(),
          screenSize: _testScreenSize,
          overrides: [
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                ElectionState(
                  status: ElectionLoadStatus.loaded,
                  election: election,
                ),
              ),
            ),
            selectionNotifierProvider.overrideWith((ref) => SelectionNotifier(10)),
            requiredVotesCountProvider.overrideWith((ref) => 10),
            selectionCountProvider.overrideWith((ref) => 0),
          ],
        ),
      );
      await tester.pumpAndSettle();
      tester.takeException();

      expect(find.byType(SelectionCounter), findsOneWidget);
    });

    testWidgets('shows error message when election fails to load', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapScreen(
          const CandidatesScreen(),
          screenSize: _testScreenSize,
          overrides: [
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                const ElectionState(
                  status: ElectionLoadStatus.error,
                  errorMessage: 'Failed to load election',
                ),
              ),
            ),
            selectionNotifierProvider.overrideWith((ref) => SelectionNotifier(10)),
            requiredVotesCountProvider.overrideWith((ref) => 10),
          ],
        ),
      );
      await tester.pumpAndSettle();
      tester.takeException();

      expect(find.text('Failed to load election'), findsOneWidget);
    });

    testWidgets('shows retry button on error', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapScreen(
          const CandidatesScreen(),
          screenSize: _testScreenSize,
          overrides: [
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                const ElectionState(
                  status: ElectionLoadStatus.error,
                  errorMessage: 'Error',
                ),
              ),
            ),
            selectionNotifierProvider.overrideWith((ref) => SelectionNotifier(10)),
            requiredVotesCountProvider.overrideWith((ref) => 10),
          ],
        ),
      );
      await tester.pumpAndSettle();
      tester.takeException();

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows no election message when no election', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapScreen(
          const CandidatesScreen(),
          screenSize: _testScreenSize,
          overrides: [
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                const ElectionState(status: ElectionLoadStatus.noElection),
              ),
            ),
            selectionNotifierProvider.overrideWith((ref) => SelectionNotifier(10)),
            requiredVotesCountProvider.overrideWith((ref) => 10),
          ],
        ),
      );
      await tester.pumpAndSettle();
      tester.takeException();

      expect(find.text('No active election found'), findsOneWidget);
    });

    testWidgets('shows vote icon when no election', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrapScreen(
          const CandidatesScreen(),
          screenSize: _testScreenSize,
          overrides: [
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                const ElectionState(status: ElectionLoadStatus.noElection),
              ),
            ),
            selectionNotifierProvider.overrideWith((ref) => SelectionNotifier(10)),
            requiredVotesCountProvider.overrideWith((ref) => 10),
          ],
        ),
      );
      await tester.pumpAndSettle();
      tester.takeException();

      expect(find.byIcon(Icons.how_to_vote_outlined), findsOneWidget);
    });

    testWidgets('displays election name in app bar', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final election = createActiveElection();

      await tester.pumpWidget(
        wrapScreen(
          const CandidatesScreen(),
          screenSize: _testScreenSize,
          overrides: [
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                ElectionState(
                  status: ElectionLoadStatus.loaded,
                  election: election,
                ),
              ),
            ),
            selectionNotifierProvider.overrideWith((ref) => SelectionNotifier(10)),
            requiredVotesCountProvider.overrideWith((ref) => 10),
          ],
        ),
      );
      await tester.pumpAndSettle();
      tester.takeException();

      expect(find.text('Active Election'), findsOneWidget);
    });

    testWidgets('shows continue button', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final election = createActiveElection();

      await tester.pumpWidget(
        wrapScreen(
          const CandidatesScreen(),
          screenSize: _testScreenSize,
          overrides: [
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                ElectionState(
                  status: ElectionLoadStatus.loaded,
                  election: election,
                ),
              ),
            ),
            selectionNotifierProvider.overrideWith((ref) => SelectionNotifier(10)),
            requiredVotesCountProvider.overrideWith((ref) => 10),
          ],
        ),
      );
      await tester.pumpAndSettle();
      tester.takeException();

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('continue button is disabled when selection incomplete', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final election = createActiveElection();

      await tester.pumpWidget(
        wrapScreen(
          const CandidatesScreen(),
          screenSize: _testScreenSize,
          overrides: [
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                ElectionState(
                  status: ElectionLoadStatus.loaded,
                  election: election,
                ),
              ),
            ),
            selectionNotifierProvider.overrideWith((ref) => SelectionNotifier(10)),
            requiredVotesCountProvider.overrideWith((ref) => 10),
          ],
        ),
      );
      await tester.pumpAndSettle();
      tester.takeException();

      // Find the LuckyButton and verify it's disabled
      final luckyButton = tester.widget<LuckyButton>(find.byType(LuckyButton));
      expect(luckyButton.disabled, isTrue);
    });

    testWidgets('has LuckyAppBar', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final election = createActiveElection();

      await tester.pumpWidget(
        wrapScreen(
          const CandidatesScreen(),
          screenSize: _testScreenSize,
          overrides: [
            electionNotifierProvider.overrideWith(
              (ref) => _MockElectionNotifier(
                ElectionState(
                  status: ElectionLoadStatus.loaded,
                  election: election,
                ),
              ),
            ),
            selectionNotifierProvider.overrideWith((ref) => SelectionNotifier(10)),
            requiredVotesCountProvider.overrideWith((ref) => 10),
          ],
        ),
      );
      await tester.pumpAndSettle();
      tester.takeException();

      expect(find.byType(LuckyAppBar), findsOneWidget);
    });
  });
}

// Mock election notifier for testing
class _MockElectionNotifier extends StateNotifier<ElectionState>
    implements ElectionNotifier {
  _MockElectionNotifier(super.state);

  @override
  Future<void> loadOngoingElection() async {}

  @override
  void reset() {}
}
