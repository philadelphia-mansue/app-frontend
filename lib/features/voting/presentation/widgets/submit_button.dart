import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luckyui/luckyui.dart';
import 'package:philadelphia_mansue/l10n/app_localizations.dart';
import '../providers/selection_notifier.dart';
import '../providers/voting_providers.dart';

class SubmitButton extends ConsumerWidget {
  final VoidCallback onSubmit;

  const SubmitButton({
    super.key,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final canSubmit = ref.watch(canSubmitVoteProvider);
    final votingState = ref.watch(votingNotifierProvider);
    final isSubmitting = votingState.status == VotingStatus.submitting;
    final isDisabled = !canSubmit || isSubmitting;

    return AbsorbPointer(
      absorbing: isDisabled,
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0,
        child: LuckyButton(
          text: isSubmitting ? l10n.submitting : l10n.confirmVote,
          onTap: onSubmit,
        ),
      ),
    );
  }
}
