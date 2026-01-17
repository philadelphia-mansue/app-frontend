import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luckyui/luckyui.dart';
import 'package:philadelphia_mansue/l10n/app_localizations.dart';
import 'package:philadelphia_mansue/routing/routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../elections/presentation/providers/election_providers.dart';
import '../../../voting/presentation/providers/selection_notifier.dart';

class SuccessScreen extends ConsumerWidget {
  const SuccessScreen({super.key});

  void _onVoteNext(BuildContext context, WidgetRef ref) {
    // Reset state for next election
    ref.read(electionNotifierProvider.notifier).reset();
    ref.read(selectionNotifierProvider.notifier).clearSelections();
    // Refresh available elections (to update hasVoted flags)
    ref.read(availableElectionsNotifierProvider.notifier).refresh();
    // Go back to election picker
    context.go(Routes.startVoting);
  }

  void _onDone(BuildContext context, WidgetRef ref) {
    ref.read(authNotifierProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final hasRemaining = ref.watch(hasRemainingElectionsProvider);
    final remainingCount = ref.watch(remainingElectionsCountProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                  // Success Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Success Message
                  LuckyHeading(
                    text: l10n.voteSubmitted,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  LuckyBody(
                    text: l10n.thankYouForParticipating,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Anonymous notice
                  Text(
                    l10n.voteAnonymousNotice,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),

                  // Remaining elections prompt
                  if (hasRemaining) ...[
                    const SizedBox(height: 48),
                    const Divider(),
                    const SizedBox(height: 24),

                    // More elections available message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.how_to_vote,
                            color: Theme.of(context).primaryColor,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              l10n.moreElectionsAvailable(remainingCount),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Vote Next Election button
                    SizedBox(
                      width: double.infinity,
                      child: LuckyButton(
                        text: l10n.voteNextElection,
                        onTap: () => _onVoteNext(context, ref),
                        height: 56,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Done for now button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => _onDone(context, ref),
                        child: Text(
                          l10n.doneForNow,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // No remaining elections - show Done button
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: LuckyButton(
                        text: l10n.done,
                        onTap: () => _onDone(context, ref),
                        height: 56,
                      ),
                    ),
                  ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
