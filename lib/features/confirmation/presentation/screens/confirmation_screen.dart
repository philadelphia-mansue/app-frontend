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
    final electionState = ref.watch(electionNotifierProvider);

    // Clear stale error state on screen entry (Fix 8)
    // Preserve alreadyVoted errors to prevent repeated submission attempts
    if (votingState.status == VotingStatus.error &&
        votingState.errorType != VotingErrorType.alreadyVoted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ref.read(votingNotifierProvider.notifier).resetToInitial();
        }
      });
    }

    // Filter selected candidates
    final selectedCandidates = allCandidates
        .where((c) => selectedIds.contains(c.id))
        .toList();

    // Listen for voting success
    ref.listen<VotingState>(votingNotifierProvider, (previous, next) async {
      if (next.status == VotingStatus.success) {
        // 1. Optimistic update - enables immediate navigation
        ref.read(electionNotifierProvider.notifier).markAsVoted();

        // 2. Save to local cache for faster UX on next app launch
        final electionId = ref.read(currentElectionIdProvider);
        if (electionId != null) {
          await ref.read(voteCacheServiceProvider).markAsVoted(electionId);
        }

        // 3. Navigate immediately (user sees success)
        if (context.mounted) {
          // Include election_id in URL so it persists across page refresh
          final successPath = electionId != null
              ? '${Routes.success}?election_id=$electionId'
              : Routes.success;
          context.go(successPath);
        }

        // 4. Re-fetch from backend in background (confirms state)
        // This ensures hasVoted is verified from the authoritative backend
        if (electionId != null) {
          ref.read(electionNotifierProvider.notifier).loadElectionById(electionId);
        }
      } else if (next.status == VotingStatus.error) {
        // Fix 4: Clear selections if already voted
        if (next.errorType == VotingErrorType.alreadyVoted) {
          ref.read(selectionNotifierProvider.notifier).clearSelections();
          // Force reload election to get updated hasVoted status
          final electionId = ref.read(currentElectionIdProvider);
          if (electionId != null) {
            ref.read(electionNotifierProvider.notifier).loadElectionById(electionId);
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorLocalizer.localize(next.errorMessage, l10n)),
            backgroundColor: Colors.red,
          ),
        );

        // Fix 6: Reset voting state so user can retry (unless already voted)
        if (next.errorType != VotingErrorType.alreadyVoted) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (context.mounted) {
              ref.read(votingNotifierProvider.notifier).resetToInitial();
            }
          });
        }
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
                          // Fix 2: Check election is still active
                          final election = electionState.election;
                          if (election == null || !election.isActive) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.votingNotActive),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // Fix 2: Check user is still authenticated
                          if (authState.voter == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.sessionExpired),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

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
                    : () {
                        // Fix 7: Reset voting state before navigating back
                        ref.read(votingNotifierProvider.notifier).resetToInitial();
                        context.pop();
                      },
                child: Text(l10n.goBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
