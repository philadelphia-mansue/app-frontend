import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luckyui/luckyui.dart';
import 'package:philadelphia_mansue/features/success/presentation/screens/success_screen.dart';

import '../../../../helpers/test_wrapper.dart';

void main() {
  group('SuccessScreen', () {
    testWidgets('renders success icon', (tester) async {
      await tester.pumpWidget(
        wrapScreen(const SuccessScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('displays "Vote Submitted!" message', (tester) async {
      await tester.pumpWidget(
        wrapScreen(const SuccessScreen()),
      );
      await tester.pumpAndSettle();

      // LuckyHeading contains the text
      expect(find.byType(LuckyHeading), findsOneWidget);
      expect(find.text('Vote Submitted!'), findsOneWidget);
    });

    testWidgets('displays thank you message', (tester) async {
      await tester.pumpWidget(
        wrapScreen(const SuccessScreen()),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Thank you for participating in this election. Your vote has been recorded successfully.'),
        findsOneWidget,
      );
    });

    testWidgets('displays anonymous notice', (tester) async {
      await tester.pumpWidget(
        wrapScreen(const SuccessScreen()),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Your vote is anonymous and cannot be traced back to you.'),
        findsOneWidget,
      );
    });

    testWidgets('success icon has green color', (tester) async {
      await tester.pumpWidget(
        wrapScreen(const SuccessScreen()),
      );
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      expect(icon.color, Colors.green.shade600);
    });

    testWidgets('success icon has correct size', (tester) async {
      await tester.pumpWidget(
        wrapScreen(const SuccessScreen()),
      );
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      expect(icon.size, 80);
    });

    testWidgets('icon container is circular with green background', (tester) async {
      await tester.pumpWidget(
        wrapScreen(const SuccessScreen()),
      );
      await tester.pumpAndSettle();

      // Find the container containing the icon
      final containerFinder = find.ancestor(
        of: find.byIcon(Icons.check_circle),
        matching: find.byType(Container),
      );

      final containers = tester.widgetList<Container>(containerFinder).toList();
      final decoratedContainer = containers.firstWhere(
        (c) => c.decoration is BoxDecoration,
      );

      final decoration = decoratedContainer.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color, Colors.green.shade100);
    });

    testWidgets('content is centered', (tester) async {
      await tester.pumpWidget(
        wrapScreen(const SuccessScreen()),
      );
      await tester.pumpAndSettle();

      // The main Center widget should be present
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('is wrapped in SafeArea', (tester) async {
      await tester.pumpWidget(
        wrapScreen(const SuccessScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('uses Scaffold', (tester) async {
      await tester.pumpWidget(
        wrapScreen(const SuccessScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('anonymous notice has grey color', (tester) async {
      await tester.pumpWidget(
        wrapScreen(const SuccessScreen()),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(
        find.text('Your vote is anonymous and cannot be traced back to you.'),
      );
      expect(text.style?.color, Colors.grey.shade600);
    });
  });
}
