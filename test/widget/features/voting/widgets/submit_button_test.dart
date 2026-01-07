import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luckyui/luckyui.dart';
import 'package:philadelphia_mansue/features/voting/presentation/widgets/submit_button.dart';
import 'package:philadelphia_mansue/features/voting/presentation/providers/selection_notifier.dart';
import 'package:philadelphia_mansue/features/voting/presentation/providers/voting_providers.dart';

import '../../../../helpers/test_wrapper.dart';

void main() {
  group('SubmitButton', () {
    testWidgets('displays "Confirm Vote" text when ready', (tester) async {
      await tester.pumpWidget(
        wrapWidgetWithProviders(
          SubmitButton(onSubmit: () {}),
          overrides: [
            canSubmitVoteProvider.overrideWith((ref) => true),
            votingNotifierProvider.overrideWith(
              (ref) => _MockVotingNotifier(const VotingState()),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Confirm Vote'), findsOneWidget);
    });

    testWidgets('displays "Submitting..." text when submitting', (tester) async {
      await tester.pumpWidget(
        wrapWidgetWithProviders(
          SubmitButton(onSubmit: () {}),
          overrides: [
            canSubmitVoteProvider.overrideWith((ref) => true),
            votingNotifierProvider.overrideWith(
              (ref) => _MockVotingNotifier(
                const VotingState(status: VotingStatus.submitting),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Submitting...'), findsOneWidget);
    });

    testWidgets('is disabled when canSubmit is false', (tester) async {
      await tester.pumpWidget(
        wrapWidgetWithProviders(
          SubmitButton(onSubmit: () {}),
          overrides: [
            canSubmitVoteProvider.overrideWith((ref) => false),
            votingNotifierProvider.overrideWith(
              (ref) => _MockVotingNotifier(const VotingState()),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Check for reduced opacity (disabled state)
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.6);
    });

    testWidgets('is enabled when canSubmit is true', (tester) async {
      await tester.pumpWidget(
        wrapWidgetWithProviders(
          SubmitButton(onSubmit: () {}),
          overrides: [
            canSubmitVoteProvider.overrideWith((ref) => true),
            votingNotifierProvider.overrideWith(
              (ref) => _MockVotingNotifier(const VotingState()),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Check for full opacity (enabled state)
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 1.0);
    });

    testWidgets('is disabled while submitting', (tester) async {
      await tester.pumpWidget(
        wrapWidgetWithProviders(
          SubmitButton(onSubmit: () {}),
          overrides: [
            canSubmitVoteProvider.overrideWith((ref) => true),
            votingNotifierProvider.overrideWith(
              (ref) => _MockVotingNotifier(
                const VotingState(status: VotingStatus.submitting),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Check for reduced opacity during submission
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.6);
    });

    testWidgets('calls onSubmit when tapped and enabled', (tester) async {
      bool submitted = false;

      await tester.pumpWidget(
        wrapWidgetWithProviders(
          SubmitButton(onSubmit: () => submitted = true),
          overrides: [
            canSubmitVoteProvider.overrideWith((ref) => true),
            votingNotifierProvider.overrideWith(
              (ref) => _MockVotingNotifier(const VotingState()),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(LuckyButton));
      await tester.pump();

      expect(submitted, isTrue);
    });

    testWidgets('does not call onSubmit when disabled', (tester) async {
      bool submitted = false;

      await tester.pumpWidget(
        wrapWidgetWithProviders(
          SubmitButton(onSubmit: () => submitted = true),
          overrides: [
            canSubmitVoteProvider.overrideWith((ref) => false),
            votingNotifierProvider.overrideWith(
              (ref) => _MockVotingNotifier(const VotingState()),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // The AbsorbPointer should prevent taps
      await tester.tap(find.byType(LuckyButton));
      await tester.pump();

      expect(submitted, isFalse);
    });

    testWidgets('contains LuckyButton widget', (tester) async {
      await tester.pumpWidget(
        wrapWidgetWithProviders(
          SubmitButton(onSubmit: () {}),
          overrides: [
            canSubmitVoteProvider.overrideWith((ref) => true),
            votingNotifierProvider.overrideWith(
              (ref) => _MockVotingNotifier(const VotingState()),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LuckyButton), findsOneWidget);
    });
  });
}

// Mock voting notifier for testing
class _MockVotingNotifier extends StateNotifier<VotingState>
    implements VotingNotifier {
  _MockVotingNotifier(super.state);

  @override
  Future<bool> validateSelection(List<String> candidateIds) async => true;

  @override
  Future<void> submitVote(List<String> candidateIds, String sessionId) async {}

  @override
  void reset() {}
}
