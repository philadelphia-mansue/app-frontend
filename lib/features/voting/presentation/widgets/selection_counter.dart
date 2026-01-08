import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:philadelphia_mansue/l10n/app_localizations.dart';
import '../../../elections/presentation/providers/election_providers.dart';
import '../providers/selection_notifier.dart';

class SelectionCounter extends ConsumerWidget {
  const SelectionCounter({
    super.key,
    this.onReviewTap,
  });

  /// Callback when the review button is tapped.
  /// If null, the button will appear disabled.
  final VoidCallback? onReviewTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectionCount = ref.watch(selectionCountProvider);
    final requiredVotes = ref.watch(requiredVotesCountProvider);
    final isComplete = selectionCount == requiredVotes;
    final remaining = requiredVotes - selectionCount;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Review Votes button in rounded container
            GestureDetector(
              onTap: onReviewTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  color: isComplete
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  l10n.reviewVotes,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: isComplete ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            // Helper text below (only when incomplete)
            if (!isComplete) ...[
              const SizedBox(height: 12),
              Text(
                l10n.selectMoreCandidatesToProceed(remaining),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
