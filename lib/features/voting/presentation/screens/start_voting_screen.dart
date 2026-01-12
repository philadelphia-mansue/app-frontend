import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luckyui/luckyui.dart';
import 'package:philadelphia_mansue/l10n/app_localizations.dart';
import 'package:philadelphia_mansue/routing/routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../elections/presentation/providers/election_providers.dart';

class StartVotingScreen extends ConsumerStatefulWidget {
  const StartVotingScreen({super.key});

  @override
  ConsumerState<StartVotingScreen> createState() => _StartVotingScreenState();
}

class _StartVotingScreenState extends ConsumerState<StartVotingScreen> {
  bool _isLoading = false;

  Future<void> _onStartVoting() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() => _isLoading = true);

    try {
      // Load ongoing election from API
      await ref.read(electionNotifierProvider.notifier).loadOngoingElection();

      if (!mounted) return;

      final electionState = ref.read(electionNotifierProvider);

      if (electionState.status == ElectionLoadStatus.error) {
        // Check if user is not prevalidated
        if (electionState.errorMessage == 'NOT_PREVALIDATED') {
          LuckyToastMessenger.showToast(
            l10n.notPrevalidated,
            type: LuckyToastTypeEnum.warning,
          );
          setState(() => _isLoading = false);
          return;
        }
        LuckyToastMessenger.showToast(
          electionState.errorMessage ?? l10n.electionNotFound,
          type: LuckyToastTypeEnum.error,
        );
        setState(() => _isLoading = false);
        return;
      }

      if (electionState.status == ElectionLoadStatus.noElection) {
        LuckyToastMessenger.showToast(
          l10n.noOngoingElection,
          type: LuckyToastTypeEnum.warning,
        );
        setState(() => _isLoading = false);
        return;
      }

      if (electionState.status == ElectionLoadStatus.loaded) {
        final election = electionState.election;

        if (election == null) {
          LuckyToastMessenger.showToast(
            l10n.electionNotFound,
            type: LuckyToastTypeEnum.error,
          );
          setState(() => _isLoading = false);
          return;
        }

        // Check if voting is active
        if (!election.isActive) {
          LuckyToastMessenger.showToast(
            l10n.votingNotActive,
            type: LuckyToastTypeEnum.warning,
          );
          // Reset election state since voting is not active
          ref.read(electionNotifierProvider.notifier).reset();
          setState(() => _isLoading = false);
          return;
        }

        // Check if user has already voted
        if (election.hasVoted) {
          LuckyToastMessenger.showToast(
            l10n.alreadyVotedMessage,
            type: LuckyToastTypeEnum.warning,
          );
          // Navigate to success screen
          context.go(Routes.success);
          return;
        }

        // Voting is active and user hasn't voted - navigate to candidates
        context.go(Routes.candidates);
      }
    } catch (e) {
      if (!mounted) return;
      LuckyToastMessenger.showToast(
        l10n.networkError,
        type: LuckyToastTypeEnum.error,
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final voter = ref.watch(currentVoterProvider);
    final voterName = voter?.fullName ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.prevalidation),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
            tooltip: l10n.logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Voting icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.how_to_vote,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Welcome message
                LuckyHeading(
                  text: l10n.welcomeUser(voterName),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Instructions
                LuckyBody(
                  text: l10n.startVotingInstructions,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Vote Now button
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : LuckyButton(
                          text: l10n.voteNow,
                          onTap: _onStartVoting,
                          height: 64,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
