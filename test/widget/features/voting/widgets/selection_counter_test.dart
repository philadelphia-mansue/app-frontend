import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:philadelphia_mansue/features/voting/presentation/widgets/selection_counter.dart';
import 'package:philadelphia_mansue/features/voting/presentation/providers/selection_notifier.dart';
import 'package:philadelphia_mansue/features/elections/presentation/providers/election_providers.dart';

import '../../../../helpers/test_wrapper.dart';

void main() {
  group('SelectionCounter', () {
    testWidgets('displays review votes with 0 selections', (tester) async {
      await tester.pumpWidget(
        wrapWidgetWithProviders(
          const SelectionCounter(),
          overrides: [
            selectionCountProvider.overrideWith((ref) => 0),
            requiredVotesCountProvider.overrideWith((ref) => 10),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Review Votes'), findsOneWidget);
      expect(find.text('Select 10 more candidate(s) to proceed'), findsOneWidget);
    });

    testWidgets('displays current selection count', (tester) async {
      await tester.pumpWidget(
        wrapWidgetWithProviders(
          const SelectionCounter(),
          overrides: [
            selectionCountProvider.overrideWith((ref) => 5),
            requiredVotesCountProvider.overrideWith((ref) => 10),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Review Votes'), findsOneWidget);
      expect(find.text('Select 5 more candidate(s) to proceed'), findsOneWidget);
    });

    testWidgets('hides helper text when selection is complete', (tester) async {
      await tester.pumpWidget(
        wrapWidgetWithProviders(
          const SelectionCounter(),
          overrides: [
            selectionCountProvider.overrideWith((ref) => 10),
            requiredVotesCountProvider.overrideWith((ref) => 10),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Review Votes'), findsOneWidget);
      // No helper text when complete
      expect(find.text('Select 0 more candidate(s) to proceed'), findsNothing);
    });

    testWidgets('displays select more text when selection is incomplete', (tester) async {
      await tester.pumpWidget(
        wrapWidgetWithProviders(
          const SelectionCounter(),
          overrides: [
            selectionCountProvider.overrideWith((ref) => 3),
            requiredVotesCountProvider.overrideWith((ref) => 10),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select 7 more candidate(s) to proceed'), findsOneWidget);
    });

    testWidgets('works with custom required votes count', (tester) async {
      await tester.pumpWidget(
        wrapWidgetWithProviders(
          const SelectionCounter(),
          overrides: [
            selectionCountProvider.overrideWith((ref) => 3),
            requiredVotesCountProvider.overrideWith((ref) => 5),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Review Votes'), findsOneWidget);
      expect(find.text('Select 2 more candidate(s) to proceed'), findsOneWidget);
    });

    testWidgets('calls onReviewTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrapWidgetWithProviders(
          SelectionCounter(
            onReviewTap: () => tapped = true,
          ),
          overrides: [
            selectionCountProvider.overrideWith((ref) => 10),
            requiredVotesCountProvider.overrideWith((ref) => 10),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Review Votes'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('renders without onReviewTap callback', (tester) async {
      await tester.pumpWidget(
        wrapWidgetWithProviders(
          const SelectionCounter(),
          overrides: [
            selectionCountProvider.overrideWith((ref) => 5),
            requiredVotesCountProvider.overrideWith((ref) => 10),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Should render without error
      expect(find.text('Review Votes'), findsOneWidget);
    });

    testWidgets('has SafeArea wrapping content', (tester) async {
      await tester.pumpWidget(
        wrapWidgetWithProviders(
          const SelectionCounter(),
          overrides: [
            selectionCountProvider.overrideWith((ref) => 0),
            requiredVotesCountProvider.overrideWith((ref) => 10),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
}
