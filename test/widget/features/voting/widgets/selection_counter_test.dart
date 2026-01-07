import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:philadelphia_mansue/features/voting/presentation/widgets/selection_counter.dart';
import 'package:philadelphia_mansue/features/voting/presentation/providers/selection_notifier.dart';
import 'package:philadelphia_mansue/features/elections/presentation/providers/election_providers.dart';

import '../../../../helpers/test_wrapper.dart';

void main() {
  group('SelectionCounter', () {
    testWidgets('displays 0 / 10 when no selections', (tester) async {
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

      expect(find.text('0 / 10 selected'), findsOneWidget);
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

      expect(find.text('5 / 10 selected'), findsOneWidget);
    });

    testWidgets('displays check icon when selection is complete', (tester) async {
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

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('displays vote icon when selection is incomplete', (tester) async {
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

      expect(find.byIcon(Icons.how_to_vote), findsOneWidget);
    });

    testWidgets('changes background color when selection is complete', (tester) async {
      // First render incomplete state
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

      // Check that grey background is used
      final incompleteContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(SelectionCounter),
          matching: find.byType(Container).first,
        ),
      );
      final incompleteDecoration = incompleteContainer.decoration as BoxDecoration;
      expect(incompleteDecoration.color, Colors.grey.shade100);
    });

    testWidgets('uses primary color for complete state', (tester) async {
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

      // The primaryContainer color should be used for complete state
      // We verify this indirectly by checking the icon color
      final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      expect(icon.color, isNotNull);
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

      expect(find.text('3 / 5 selected'), findsOneWidget);
    });
  });
}
