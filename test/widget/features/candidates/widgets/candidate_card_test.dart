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

      expect(find.text('John Doe'), findsOneWidget);
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

    testWidgets('shows checkmark when selected', (tester) async {
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

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('does not show checkmark when not selected', (tester) async {
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

      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('has green border when selected', (tester) async {
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
      expect(decoration.border?.top.color, Colors.green);
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

      final text = tester.widget<Text>(find.text('Test Candidate'));
      expect(text.style?.fontWeight, FontWeight.bold);
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

      final text = tester.widget<Text>(find.text('Test Candidate'));
      expect(text.textAlign, TextAlign.center);
    });
  });
}
