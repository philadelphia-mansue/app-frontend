import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../elections/presentation/providers/election_providers.dart';

/// Checks local cache to see if user has voted in the current election.
/// This is a FutureProvider because reading from secure storage is async.
final localHasVotedProvider = FutureProvider<bool>((ref) async {
  final electionId = ref.watch(currentElectionIdProvider);
  if (electionId == null) return false;

  final voteCache = ref.watch(voteCacheServiceProvider);
  return await voteCache.hasVotedInElection(electionId);
});

/// Combined provider that checks BOTH local cache and API response.
/// The API is the SOURCE OF TRUTH - when loaded, it overrides local cache.
///
/// Logic:
/// - If election is loaded: trust API (even if local cache says voted)
/// - If election not loaded yet: use local cache for fast UX
///
/// This handles the case where backend deletes a vote:
/// - Local cache says "voted" but API says "not voted"
/// - We trust the API and clear the stale local cache
final hasVotedCombinedProvider = Provider<bool>((ref) {
  // Check if election data is loaded from API
  final electionState = ref.watch(electionNotifierProvider);
  final isElectionLoaded = electionState.status == ElectionLoadStatus.loaded;

  // Get API response (source of truth when available)
  final apiVoted = ref.watch(hasVotedProvider);

  // If election is loaded, API is the source of truth
  if (isElectionLoaded) {
    // Check local cache for mismatch detection
    final localVotedAsync = ref.watch(localHasVotedProvider);
    final localVoted = localVotedAsync.maybeWhen(
      data: (hasVoted) => hasVoted,
      orElse: () => false,
    );

    // If API says not voted but local says voted, we have stale cache
    // Clear it asynchronously (fire and forget)
    if (!apiVoted && localVoted) {
      debugPrint('[VoteCache] API says not voted but local cache says voted - clearing stale cache');
      final electionId = ref.read(currentElectionIdProvider);
      if (electionId != null) {
        ref.read(voteCacheServiceProvider).hasVotedInElection(electionId).then((_) {
          // Clear the specific election from cache
          ref.read(voteCacheServiceProvider).clearCache();
          // Invalidate the local provider to refresh
          ref.invalidate(localHasVotedProvider);
        });
      }
    }

    // Trust API when election is loaded
    return apiVoted;
  }

  // Election not loaded yet - use local cache for fast UX
  final localVotedAsync = ref.watch(localHasVotedProvider);
  return localVotedAsync.maybeWhen(
    data: (hasVoted) => hasVoted,
    orElse: () => false,
  );
});
