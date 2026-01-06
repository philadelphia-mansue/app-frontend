import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:philadelphia_mansue/l10n/app_localizations.dart';
import '../../../elections/presentation/providers/election_providers.dart';
import '../providers/selection_notifier.dart';

class SelectionCounter extends ConsumerWidget {
  const SelectionCounter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectionCount = ref.watch(selectionCountProvider);
    final requiredVotes = ref.watch(requiredVotesCountProvider);
    final isComplete = selectionCount == requiredVotes;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isComplete
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.how_to_vote,
            color: isComplete
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            l10n.selectionCounter(selectionCount, requiredVotes),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isComplete
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
