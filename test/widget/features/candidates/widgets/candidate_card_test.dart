import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:philadelphia_mansue/features/candidates/presentation/widgets/candidate_card.dart';

import '../../../../helpers/test_wrapper.dart';
import '../../../../helpers/fixtures/candidate_fixture.dart';

void main() {
  group('CandidateCard', () {
    testWidgets('displays candidate full name', (tester) async {
      final candidate = createTestCandidate(
        firstName: 'John',
        lastName: 'Doe',
      );

      await tester.pumpWidget(
        wrapWidget(
          SizedBox(
            height: 200,
            width: 150,
            child: CandidateCard(
              candidate: candidate,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('JOHN DOE'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      final candidate = createTestCandidate();

      await tester.pumpWidget(
        wrapWidget(
          SizedBox(
            height: 200,
            width: 150,
            child: CandidateCard(
              candidate: candidate,
              isSelected: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CandidateCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows checkmark in filled circle when selected', (tester) async {
      final candidate = createTestCandidate();

      await tester.pumpWidget(
        wrapWidget(
          SizedBox(
            height: 200,
            width: 150,
            child: CandidateCard(
              candidate: candidate,
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show checkmark icon
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Should have filled indigo circle
      final containers = find.byType(Container);
      bool foundFilledCircle = false;
      for (final element in containers.evaluate()) {
        final container = element.widget as Container;
        final decoration = container.decoration;
        if (decoration is BoxDecoration &&
            decoration.shape == BoxShape.circle &&
            decoration.color == Colors.indigo) {
          foundFilledCircle = true;
          break;
        }
      }
      expect(foundFilledCircle, isTrue);
    });

    testWidgets('shows empty circle indicator when not selected', (tester) async {
      final candidate = createTestCandidate();

      await tester.pumpWidget(
        wrapWidget(
          SizedBox(
            height: 200,
            width: 150,
            child: CandidateCard(
              candidate: candidate,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // No checkmark when not selected
      expect(find.byIcon(Icons.check), findsNothing);

      // Circle indicator should exist but not be filled blue
      final positioned = find.byType(Positioned);
      expect(positioned, findsOneWidget);
    });

    testWidgets('has blue border when selected', (tester) async {
      final candidate = createTestCandidate();

      await tester.pumpWidget(
        wrapWidget(
          SizedBox(
            height: 200,
            width: 150,
            child: CandidateCard(
              candidate: candidate,
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CandidateCard),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.top.color, Colors.indigo);
    });

    testWidgets('has grey border when not selected', (tester) async {
      final candidate = createTestCandidate();

      await tester.pumpWidget(
        wrapWidget(
          SizedBox(
            height: 200,
            width: 150,
            child: CandidateCard(
              candidate: candidate,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(CandidateCard),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border?.top.color, Colors.grey.shade300);
    });

    testWidgets('shows person icon on image error', (tester) async {
      final candidate = createTestCandidate(
        photoUrl: '', // Empty URL will cause an error
      );

      await tester.pumpWidget(
        wrapWidget(
          SizedBox(
            height: 200,
            width: 150,
            child: CandidateCard(
              candidate: candidate,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Empty URL should trigger error builder showing person icon
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('name text has bold weight', (tester) async {
      final candidate = createTestCandidate(
        firstName: 'Test',
        lastName: 'Candidate',
      );

      await tester.pumpWidget(
        wrapWidget(
          SizedBox(
            height: 200,
            width: 150,
            child: CandidateCard(
              candidate: candidate,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('TEST CANDIDATE'));
      expect(text.style?.fontWeight, FontWeight.w700);
    });

    testWidgets('name text is center aligned', (tester) async {
      final candidate = createTestCandidate(
        firstName: 'Test',
        lastName: 'Candidate',
      );

      await tester.pumpWidget(
        wrapWidget(
          SizedBox(
            height: 200,
            width: 150,
            child: CandidateCard(
              candidate: candidate,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('TEST CANDIDATE'));
      expect(text.textAlign, TextAlign.center);
    });
  });
}
