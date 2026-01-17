import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luckyui/luckyui.dart';
import 'package:philadelphia_mansue/l10n/app_localizations.dart';
import '../../../../core/utils/error_localizer.dart';
import '../../../../routing/routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../elections/presentation/providers/election_providers.dart';
import '../../../voting/presentation/providers/selection_notifier.dart';
import '../widgets/candidates_grid.dart';

/// Check if multi-election mode is active (more than one election available)
final _isMultiElectionModeProvider = Provider<bool>((ref) {
  final state = ref.watch(availableElectionsNotifierProvider);
  return state.elections.length > 1;
});

class CandidatesScreen extends ConsumerStatefulWidget {
  const CandidatesScreen({super.key});

  @override
  ConsumerState<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends ConsumerState<CandidatesScreen> {
  ProviderSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // After page refresh, election state is initial - trigger load when auth is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryLoadElection();
      // Also listen for auth changes to trigger load when auth completes
      _authSubscription = ref.listenManual(authNotifierProvider, (_, next) {
        if (next.status == AuthStatus.authenticated) {
          _tryLoadElection();
        }
      });
    });
  }

  @override
  void dispose() {
    _authSubscription?.close();
    super.dispose();
  }

  void _tryLoadElection() {
    final authState = ref.read(authNotifierProvider);
    final electionState = ref.read(electionNotifierProvider);

    // Only load if authenticated and election not yet loaded
    if (authState.status == AuthStatus.authenticated &&
        electionState.status == ElectionLoadStatus.initial) {
      // Get election_id from URL (preserves context on page reload)
      final urlElectionId = ref.read(urlElectionIdProvider);
      if (urlElectionId != null && urlElectionId.isNotEmpty) {
        ref.read(electionNotifierProvider.notifier).loadElectionById(urlElectionId);
      }
      // No fallback to loadOngoingElection - URL must have election_id
    }
  }

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

  void _onBackToElectionPicker() {
    // Reset election state
    ref.read(electionNotifierProvider.notifier).reset();
    ref.read(selectionNotifierProvider.notifier).clearSelections();
    // Return to election picker
    context.go(Routes.startVoting);
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

    // Handle navigation on noElection status change (not on every rebuild)
    ref.listen<ElectionState>(electionNotifierProvider, (previous, next) {
      if (next.status == ElectionLoadStatus.noElection) {
        context.go(Routes.voteEnded);
      }
    });

    // Also check current state immediately (ref.listen doesn't fire for existing state)
    if (electionState.status == ElectionLoadStatus.noElection) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(Routes.voteEnded);
      });
    }
    final selectedIds = ref.watch(selectionNotifierProvider);
    final requiredVotes = ref.watch(requiredVotesCountProvider);
    final canSubmit = selectedIds.length == requiredVotes;
    final isMultiElectionMode = ref.watch(_isMultiElectionModeProvider);

    // hasVoted redirect is handled by router
    final electionName = electionState.election?.name ?? l10n.selectCandidates;
    final electionDescription = electionState.election?.description;

    return Scaffold(
      appBar: LuckyAppBar(
        title: electionName,
        automaticallyImplyLeading: false,
        leading: isMultiElectionMode
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: l10n.goBack,
                onPressed: _onBackToElectionPicker,
              )
            : null,
        actions: kDebugMode
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'DEBUG: Logout',
                  onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          if (electionDescription != null && electionDescription.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                electionDescription,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          _buildProgressIndicator(selectedIds.length, requiredVotes, l10n),
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

  Widget _buildProgressIndicator(int count, int max, AppLocalizations l10n) {
    final progress = max > 0 ? count / max : 0.0;
    final percentage = (progress * 100).round();
    final remaining = max - count;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.candidatesSelectedProgress(count, max),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
          ),
          if (remaining > 0) ...[
            const SizedBox(height: 12),
            Text(
              l10n.selectMoreToContinue(remaining),
              style: TextStyle(
                fontSize: 14,
                color: Colors.indigo.shade700,
              ),
            ),
          ],
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
              Text(ErrorLocalizer.localize(state.errorMessage, l10n)),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                width: 120,
                child: LuckyButton(
                  text: l10n.retry,
                  height: 44,
                  onTap: () {
                    final storedElectionId = ref.read(urlElectionIdProvider);
                    if (storedElectionId != null && storedElectionId.isNotEmpty) {
                      ref.read(electionNotifierProvider.notifier).loadElectionById(storedElectionId);
                    }
                    // No fallback - election_id must be in URL
                  },
                ),
              ),
            ],
          ),
        );

      case ElectionLoadStatus.noElection:
        // Navigation handled by ref.listen in build()
        return const Center(child: CircularProgressIndicator());

      case ElectionLoadStatus.loaded:
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SizedBox.expand(
              child: CandidatesGrid(
                candidates: state.election?.candidates ?? [],
                selectedIds: selectedIds,
                onCandidateTap: _onCandidateTap,
              ),
            ),
          ),
        );
    }
  }
}
