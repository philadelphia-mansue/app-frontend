import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luckyui/luckyui.dart';
import 'package:philadelphia_mansue/core/utils/error_localizer.dart';
import 'package:philadelphia_mansue/l10n/app_localizations.dart';
import 'package:philadelphia_mansue/routing/routes.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../elections/domain/entities/election.dart';
import '../../../elections/presentation/providers/election_providers.dart';

class StartVotingScreen extends ConsumerStatefulWidget {
  const StartVotingScreen({super.key});

  @override
  ConsumerState<StartVotingScreen> createState() => _StartVotingScreenState();
}

class _StartVotingScreenState extends ConsumerState<StartVotingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadElections();
    });
  }

  Future<void> _loadElections() async {
    // Don't load elections if auth is still being restored
    final authStatus = ref.read(authNotifierProvider).status;
    if (authStatus != AuthStatus.authenticated) {
      debugPrint('[StartVotingScreen] Skipping election load - auth status: $authStatus');
      return;
    }
    await ref.read(availableElectionsNotifierProvider.notifier).loadAll();
  }

  void _onElectionTap(Election election) async {
    final l10n = AppLocalizations.of(context)!;

    // Already voted - no action
    if (election.hasVoted) return;

    // Not yet open - show toast
    if (election.status == ElectionStatus.upcoming) {
      LuckyToastMessenger.showToast(
        l10n.noOngoingElection,
        type: LuckyToastTypeEnum.warning,
      );
      return;
    }

    // Ended - show toast
    if (election.status == ElectionStatus.ended) {
      LuckyToastMessenger.showToast(
        l10n.votingNotActive,
        type: LuckyToastTypeEnum.warning,
      );
      return;
    }

    // Active - proceed to vote
    await ref.read(electionNotifierProvider.notifier).loadElectionById(election.id);

    if (!mounted) return;

    final electionState = ref.read(electionNotifierProvider);
    if (electionState.status == ElectionLoadStatus.loaded) {
      context.go('${Routes.candidates}?election_id=${election.id}');
    } else if (electionState.status == ElectionLoadStatus.error) {
      LuckyToastMessenger.showToast(
        ErrorLocalizer.localize(electionState.errorMessage, l10n),
        type: LuckyToastTypeEnum.warning,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final voter = ref.watch(currentVoterProvider);
    final voterName = voter?.fullName ?? '';
    final state = ref.watch(availableElectionsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.prevalidation),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.status == AvailableElectionsStatus.loading
                ? null
                : _loadElections,
            tooltip: l10n.retry,
          ),
          if (kDebugMode)
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
        child: _buildBody(state, voterName, l10n),
      ),
    );
  }

  Widget _buildBody(AvailableElectionsState state, String voterName, AppLocalizations l10n) {
    switch (state.status) {
      case AvailableElectionsStatus.initial:
      case AvailableElectionsStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case AvailableElectionsStatus.noElections:
        return _buildNoElectionsState(l10n);

      case AvailableElectionsStatus.error:
        return _buildErrorState(state.errorMessage, l10n);

      case AvailableElectionsStatus.loaded:
        return _buildElectionPicker(state, voterName, l10n);
    }
  }

  Widget _buildNoElectionsState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 32),
            LuckyHeading(
              text: l10n.noActiveElections,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LuckyBody(
              text: l10n.noOngoingElection,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 32),
            LuckyHeading(
              text: l10n.networkError,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LuckyBody(
              text: errorMessage ?? l10n.serverErrorTryLater,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LuckyButton(
              text: l10n.retry,
              onTap: _loadElections,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElectionPicker(AvailableElectionsState state, String voterName, AppLocalizations l10n) {
    final pendingElections = state.pendingElections;
    final completedElections = state.completedElections;
    final upcomingElections = state.upcomingElections;
    final endedElections = state.endedElections;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Welcome header
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.how_to_vote,
            size: 48,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        LuckyHeading(
          text: l10n.welcome,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        LuckyBody(
          text: l10n.selectAnElection,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Pending elections section (can vote)
        if (pendingElections.isNotEmpty) ...[
          _buildSectionHeader(l10n.availableElections, Icons.how_to_vote, Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          ...pendingElections.map((e) => _buildElectionCard(e, l10n)),
          const SizedBox(height: 16),
        ],

        // Upcoming elections section
        if (upcomingElections.isNotEmpty) ...[
          _buildSectionHeader(l10n.notYetOpen, Icons.schedule, Colors.orange),
          const SizedBox(height: 8),
          ...upcomingElections.map((e) => _buildElectionCard(e, l10n)),
          const SizedBox(height: 16),
        ],

        // Completed elections section (already voted)
        if (completedElections.isNotEmpty) ...[
          _buildSectionHeader(l10n.completedElections, Icons.check_circle, Colors.green),
          const SizedBox(height: 8),
          ...completedElections.map((e) => _buildElectionCard(e, l10n)),
          const SizedBox(height: 16),
        ],

        // Ended elections section (not voted, ended)
        if (endedElections.isNotEmpty) ...[
          _buildSectionHeader(l10n.ended, Icons.block, Colors.grey),
          const SizedBox(height: 8),
          ...endedElections.map((e) => _buildElectionCard(e, l10n)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildElectionCard(Election election, AppLocalizations l10n) {
    final canVote = election.isActive && !election.hasVoted;
    final isUpcoming = election.status == ElectionStatus.upcoming;
    final isEnded = election.status == ElectionStatus.ended;
    final hasVoted = election.hasVoted;

    // Determine icon
    IconData icon;
    Color iconColor;
    if (hasVoted) {
      icon = Icons.check_circle;
      iconColor = Colors.green;
    } else if (isUpcoming) {
      icon = Icons.schedule;
      iconColor = Colors.orange;
    } else if (isEnded) {
      icon = Icons.block;
      iconColor = Colors.grey;
    } else {
      icon = Icons.how_to_vote;
      iconColor = Theme.of(context).primaryColor;
    }

    // Determine trailing widget
    Widget trailing;
    if (hasVoted) {
      trailing = Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          l10n.voted,
          style: TextStyle(
            color: Colors.green.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      );
    } else if (isUpcoming) {
      trailing = Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          l10n.notYetOpen,
          style: TextStyle(
            color: Colors.orange.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      );
    } else if (isEnded) {
      trailing = Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          l10n.ended,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      );
    } else {
      trailing = Icon(Icons.chevron_right, color: Theme.of(context).primaryColor);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: canVote ? 2 : 0,
      color: canVote ? null : Colors.grey.shade50,
      child: InkWell(
        onTap: () => _onElectionTap(election),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      election.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: canVote ? null : Colors.grey,
                      ),
                    ),
                    if (election.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        election.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
