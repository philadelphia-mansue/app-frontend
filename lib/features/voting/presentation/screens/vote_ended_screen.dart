import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luckyui/luckyui.dart';
import 'package:philadelphia_mansue/l10n/app_localizations.dart';
import 'package:philadelphia_mansue/routing/routes.dart';
import '../../../elections/presentation/providers/election_providers.dart';

class VoteEndedScreen extends ConsumerWidget {
  const VoteEndedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

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
                  // Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.how_to_vote_outlined,
                      size: 64,
                      color: Colors.orange.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  LuckyHeading(
                    text: l10n.voteEndedTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Message
                  LuckyBody(
                    text: l10n.voteEndedMessage,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                        // Back to Elections button (primary action)
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: SizedBox(
                            width: double.infinity,
                            child: LuckyButton(
                              text: l10n.backToElections,
                              height: 52,
                              onTap: () {
                                // Reset election state and go back to election picker
                                ref.read(electionNotifierProvider.notifier).reset();
                                ref.read(availableElectionsNotifierProvider.notifier).refresh();
                                context.go(Routes.startVoting);
                              },
                            ),
                          ),
                        ),
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
