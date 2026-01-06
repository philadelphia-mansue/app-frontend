import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luckyui/luckyui.dart';
import 'package:philadelphia_mansue/l10n/app_localizations.dart';
import '../../../../routing/routes.dart';
import '../../../elections/presentation/providers/election_providers.dart';
import '../../../voting/presentation/providers/selection_notifier.dart';
import '../../../voting/presentation/widgets/selection_counter.dart';
import '../widgets/candidates_grid.dart';

class CandidatesScreen extends ConsumerStatefulWidget {
  const CandidatesScreen({super.key});

  @override
  ConsumerState<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends ConsumerState<CandidatesScreen> {
  // Election is loaded by router when authenticated

  void _onSubmit() {
    final l10n = AppLocalizations.of(context)!;
    final selectionCount = ref.read(selectionNotifierProvider).length;
    final requiredVotes = ref.read(requiredVotesCountProvider);
    if (selectionCount == requiredVotes) {
      context.push(Routes.confirmation);
    } else {
      LuckyToastMessenger.showToast(
        l10n.mustSelectExactCandidates(requiredVotes),
        type: LuckyToastTypeEnum.warning,
      );
    }
  }

  void _onCandidateTap(String id) {
    final l10n = AppLocalizations.of(context)!;
    final requiredVotes = ref.read(requiredVotesCountProvider);
    final result = ref.read(selectionNotifierProvider.notifier).toggleSelection(id);

    switch (result) {
      case SelectionResult.alreadyAtMax:
        LuckyToastMessenger.showToast(
          l10n.maxCandidatesLimit(requiredVotes),
          type: LuckyToastTypeEnum.warning,
        );
        break;
      case SelectionResult.maxReached:
      case SelectionResult.selected:
      case SelectionResult.deselected:
        // No toast needed
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final electionState = ref.watch(electionNotifierProvider);
    final selectedIds = ref.watch(selectionNotifierProvider);
    final requiredVotes = ref.watch(requiredVotesCountProvider);
    final canSubmit = selectedIds.length == requiredVotes;

    // hasVoted redirect is handled by router
    final electionName = electionState.election?.name ?? l10n.selectCandidates;

    return Scaffold(
      appBar: LuckyAppBar(
        title: electionName,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SelectionCounter(),
          Expanded(
            child: _buildContent(electionState, selectedIds, l10n),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: GestureDetector(
                        onTap: canSubmit ? null : _onSubmit,
                        child: LuckyButton(
                          text: l10n.continueButton,
                          height: 52,
                          disabled: !canSubmit,
                          onTap: _onSubmit,
                          textSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ElectionState state, Set<String> selectedIds, AppLocalizations l10n) {
    switch (state.status) {
      case ElectionLoadStatus.loading:
      case ElectionLoadStatus.initial:
        return const Center(child: CircularProgressIndicator());

      case ElectionLoadStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.errorMessage ?? l10n.errorLoadingCandidates),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                width: 120,
                child: LuckyButton(
                  text: l10n.retry,
                  height: 44,
                  onTap: () {
                    ref.read(electionNotifierProvider.notifier).loadOngoingElection();
                  },
                ),
              ),
            ],
          ),
        );

      case ElectionLoadStatus.noElection:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.how_to_vote_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                l10n.noActiveElectionFound,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        );

      case ElectionLoadStatus.loaded:
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: CandidatesGrid(
              candidates: state.candidates,
              selectedIds: selectedIds,
              onCandidateTap: _onCandidateTap,
            ),
          ),
        );
    }
  }
}
