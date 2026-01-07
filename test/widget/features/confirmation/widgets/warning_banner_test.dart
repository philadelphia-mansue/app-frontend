import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:philadelphia_mansue/features/confirmation/presentation/widgets/warning_banner.dart';

import '../../../../helpers/test_wrapper.dart';

void main() {
  group('WarningBanner', () {
    testWidgets('renders warning icon', (tester) async {
      await tester.pumpWidget(
        wrapWidget(const WarningBanner()),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('displays "Warning" title', (tester) async {
      await tester.pumpWidget(
        wrapWidget(const WarningBanner()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Warning'), findsOneWidget);
    });

    testWidgets('displays vote is final warning message', (tester) async {
      await tester.pumpWidget(
        wrapWidget(const WarningBanner()),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('This action cannot be undone. Your vote will be final and you cannot change your selection.'),
        findsOneWidget,
      );
    });

    testWidgets('has amber background color', (tester) async {
      await tester.pumpWidget(
        wrapWidget(const WarningBanner()),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WarningBanner),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.amber.shade100);
    });

    testWidgets('has rounded border', (tester) async {
      await tester.pumpWidget(
        wrapWidget(const WarningBanner()),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WarningBanner),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('has amber border', (tester) async {
      await tester.pumpWidget(
        wrapWidget(const WarningBanner()),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WarningBanner),
          matching: find.byType(Container).first,
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.border?.top.color, Colors.amber.shade300);
    });

    testWidgets('icon has correct size', (tester) async {
      await tester.pumpWidget(
        wrapWidget(const WarningBanner()),
      );
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.warning_amber_rounded));
      expect(icon.size, 32);
    });

    testWidgets('warning text has bold style', (tester) async {
      await tester.pumpWidget(
        wrapWidget(const WarningBanner()),
      );
      await tester.pumpAndSettle();

      final warningText = tester.widget<Text>(find.text('Warning'));
      expect(warningText.style?.fontWeight, FontWeight.bold);
    });
  });
}
