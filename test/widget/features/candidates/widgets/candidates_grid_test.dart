import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:philadelphia_mansue/features/candidates/presentation/widgets/candidates_grid.dart';
import 'package:philadelphia_mansue/features/candidates/presentation/widgets/candidate_card.dart';

import '../../../../helpers/test_wrapper.dart';
import '../../../../helpers/fixtures/candidate_fixture.dart';

void main() {
  group('CandidatesGrid', () {
    // GridView.builder uses lazy rendering based on viewport size.
    // For tests counting rendered items, we must set the physical view size
    // to ensure all items are built. MediaQuery.size only affects widget
    // layout decisions (like column count), not the render viewport bounds.
    testWidgets('renders correct number of candidate cards', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final candidates = createTestCandidates(5);

      await tester.pumpWidget(
        wrapWidget(
          CandidatesGrid(
            candidates: candidates,
            selectedIds: {},
            onCandidateTap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CandidateCard), findsNWidgets(5));
    });

    testWidgets('displays candidate names', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final candidates = createTestCandidates(3);

      await tester.pumpWidget(
        wrapWidget(
          CandidatesGrid(
            candidates: candidates,
            selectedIds: {},
            onCandidateTap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CANDIDATE 1'), findsOneWidget);
      expect(find.text('CANDIDATE 2'), findsOneWidget);
      expect(find.text('CANDIDATE 3'), findsOneWidget);
    });

    testWidgets('marks selected candidates', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final candidates = createTestCandidates(3);

      await tester.pumpWidget(
        wrapWidget(
          CandidatesGrid(
            candidates: candidates,
            selectedIds: {'candidate-1', 'candidate-3'},
            onCandidateTap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should have 2 checkmarks for selected candidates
      expect(find.byIcon(Icons.check), findsNWidgets(2));
    });

    testWidgets('calls onCandidateTap with correct id when card is tapped', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final candidates = createTestCandidates(3);
      String? tappedId;

      await tester.pumpWidget(
        wrapWidget(
          CandidatesGrid(
            candidates: candidates,
            selectedIds: {},
            onCandidateTap: (id) => tappedId = id,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the first candidate card
      await tester.tap(find.text('CANDIDATE 1'));
      await tester.pump();

      expect(tappedId, 'candidate-1');
    });

    testWidgets('uses 2 columns on mobile screen size', (tester) async {
      final candidates = createTestCandidates(4);

      await tester.pumpWidget(
        wrapWidgetWithProviders(
          CandidatesGrid(
            candidates: candidates,
            selectedIds: {},
            onCandidateTap: (_) {},
          ),
          screenSize: const Size(400, 800), // Mobile size
        ),
      );
      await tester.pumpAndSettle();

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 2);
    });

    testWidgets('uses 4 columns on desktop screen size', (tester) async {
      final candidates = createTestCandidates(4);

      await tester.pumpWidget(
        wrapWidgetWithProviders(
          CandidatesGrid(
            candidates: candidates,
            selectedIds: {},
            onCandidateTap: (_) {},
          ),
          screenSize: const Size(1200, 800), // Desktop size
        ),
      );
      await tester.pumpAndSettle();

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 4);
    });

    testWidgets('renders empty grid when no candidates', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          CandidatesGrid(
            candidates: const [],
            selectedIds: {},
            onCandidateTap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CandidateCard), findsNothing);
    });

    testWidgets('grid has correct padding', (tester) async {
      final candidates = createTestCandidates(2);

      await tester.pumpWidget(
        wrapWidget(
          CandidatesGrid(
            candidates: candidates,
            selectedIds: {},
            onCandidateTap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gridView = tester.widget<GridView>(find.byType(GridView));
      expect(gridView.padding, const EdgeInsets.all(16));
    });

    testWidgets('grid has correct aspect ratio', (tester) async {
      final candidates = createTestCandidates(2);

      await tester.pumpWidget(
        wrapWidget(
          CandidatesGrid(
            candidates: candidates,
            selectedIds: {},
            onCandidateTap: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.childAspectRatio, 0.75);
    });
  });
}
