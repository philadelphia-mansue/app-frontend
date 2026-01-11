import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luckyui/luckyui.dart';
import 'package:philadelphia_mansue/l10n/app_localizations.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/error_localizer.dart';
import '../../../../routing/routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../elections/presentation/providers/election_providers.dart';
import '../../../voting/presentation/providers/selection_notifier.dart';
import '../../../voting/presentation/providers/voting_providers.dart';
import '../widgets/selected_candidates_list.dart';
import '../widgets/warning_banner.dart';

class ConfirmationScreen extends ConsumerWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedIds = ref.watch(selectionNotifierProvider);
    final allCandidates = ref.watch(electionCandidatesProvider);
    final votingState = ref.watch(votingNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    // Filter selected candidates
    final selectedCandidates = allCandidates
        .where((c) => selectedIds.contains(c.id))
        .toList();

    // Listen for voting success
    ref.listen<VotingState>(votingNotifierProvider, (previous, next) async {
      if (next.status == VotingStatus.success) {
        // Save to local cache for faster UX on next app launch
        final electionId = ref.read(currentElectionIdProvider);
        if (electionId != null) {
          await ref.read(voteCacheServiceProvider).markAsVoted(electionId);
        }
        if (context.mounted) {
          // Include election_id in URL so it persists across page refresh
          final successPath = electionId != null
              ? '${Routes.success}?election_id=$electionId'
              : Routes.success;
          context.go(successPath);
        }
      } else if (next.status == VotingStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorLocalizer.localize(next.errorMessage, l10n)),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: LuckyAppBar(
        title: l10n.confirmYourVote,
      ),
      body: Column(
        children: [
          const WarningBanner(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  l10n.yourSelectedCandidates,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  l10n.selectedCount(selectedCandidates.length),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: SelectedCandidatesList(
                  candidates: selectedCandidates,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(
                builder: (context) {
                  final isSubmitting = votingState.status == VotingStatus.submitting;
                  return AbsorbPointer(
                    absorbing: isSubmitting,
                    child: Opacity(
                      opacity: isSubmitting ? 0.6 : 1.0,
                      child: LuckyButton(
                        text: isSubmitting ? l10n.submitting : l10n.confirmVote,
                        onTap: () async {
                          final materialL10n = MaterialLocalizations.of(context);
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.confirmYourVote),
                              content: Text(l10n.voteIsFinalWarning),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(materialL10n.cancelButtonLabel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(l10n.confirmVote),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            final voterId = authState.voter?.id ?? 'anonymous';
                            ref.read(votingNotifierProvider.notifier).submitVote(
                                  selectedIds.toList(),
                                  voterId,
                                );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: votingState.status == VotingStatus.submitting
                    ? null
                    : () => context.pop(),
                child: Text(l10n.goBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
