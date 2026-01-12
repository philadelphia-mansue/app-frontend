import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luckyui/luckyui.dart';
import 'package:philadelphia_mansue/l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class VoteEndedScreen extends ConsumerWidget {
  const VoteEndedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
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

                  // Logout button
                  SizedBox(
                    width: 200,
                    child: LuckyButton(
                      text: l10n.logout,
                      height: 52,
                      onTap: () {
                        ref.read(authNotifierProvider.notifier).signOut();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
