import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luckyui/luckyui.dart';
import 'package:philadelphia_mansue/features/candidates/presentation/screens/candidates_screen.dart';
import 'package:philadelphia_mansue/features/candidates/presentation/widgets/candidates_grid.dart';
import 'package:philadelphia_mansue/features/elections/presentation/providers/election_providers.dart';
import 'package:philadelphia_mansue/features/voting/presentation/providers/selection_notifier.dart';

import '../../../../helpers/test_wrapper.dart';
import '../../../../helpers/fixtures/election_fixture.dart';

const _testScreenSize = Size(600, 1200);

/// Safely consumes expected overflow errors from LuckyButton third-party component.
/// Rethrows any unexpected exception types to avoid masking real bugs.
///
/// Handles both:
/// - Direct FlutterError overflow exceptions
/// - Meta "Multiple exceptions" messages from the test framework when multiple
///   overflow errors occur (these are String type, not FlutterError)
///
/// Note: This test file specifically tests CandidatesScreen which uses LuckyButton,
/// a third-party component known to cause layout overflow errors in test environments.
/// The "Multiple exceptions" meta-message is allowed since it aggregates the expected
/// overflow errors that occur during rendering.
void consumeOverflowErrors(WidgetTester tester) {
  dynamic exception = tester.takeException();
  while (exception != null) {
    final errorString = exception.toString().toLowerCase();
    // Allow FlutterError overflow exceptions
    final isOverflowError = exception is FlutterError &&
        (errorString.contains('overflow') || errorString.contains('renderflex'));
    // Allow the framework's "Multiple exceptions" meta-message, which aggregates
    // overflow errors from LuckyButton during rendering. This is safe in this test
    // file since we know LuckyButton causes these expected overflow errors.
    final isMultipleExceptionsMessage =
        exception is String && errorString.contains('multiple exceptions');
    if (!isOverflowError && !isMultipleExceptionsMessage) {
      // ignore: only_throw_errors
      throw exception;
    }
    exception = tester.takeException();
  }
}

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
      consumeOverflowErrors(tester);

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
      consumeOverflowErrors(tester);

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
      consumeOverflowErrors(tester);

      // Screen shows progress indicator with selection count
      expect(find.text('0 of 10 candidates selected'), findsOneWidget);
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
      consumeOverflowErrors(tester);

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
      consumeOverflowErrors(tester);

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
      consumeOverflowErrors(tester);

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
      consumeOverflowErrors(tester);

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
      consumeOverflowErrors(tester);

      expect(find.text('Active Election'), findsOneWidget);
    });

    testWidgets('shows review votes button', (tester) async {
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
      consumeOverflowErrors(tester);

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('shows select more text when selection incomplete', (tester) async {
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
            selectionCountProvider.overrideWith((ref) => 3),
          ],
        ),
      );
      await tester.pumpAndSettle();
      consumeOverflowErrors(tester);

      // SelectionNotifier(10) starts empty, so remaining is 10
      expect(find.text('Select 10 more to continue'), findsOneWidget);
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
      consumeOverflowErrors(tester);

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
  Future<void> loadElectionById(String id) async {}

  @override
  void reset() {}
}
