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

/// Provider that checks if user has voted.
/// The API is the ONLY SOURCE OF TRUTH.
///
/// Logic:
/// - If election is loaded: return API value (hasVoted from election)
/// - If election not loaded yet: return false (don't know yet, assume not voted)
///
/// This prevents stale local cache from incorrectly redirecting to success page
/// when the backend has deleted a vote.
final hasVotedCombinedProvider = Provider<bool>((ref) {
  // Check if election data is loaded from API
  final electionState = ref.watch(electionNotifierProvider);
  final isElectionLoaded = electionState.status == ElectionLoadStatus.loaded;

  // Only trust API - local cache is just for optimization, not routing decisions
  if (isElectionLoaded) {
    return ref.watch(hasVotedProvider);
  }

  // Election not loaded yet - return false (we don't know, so don't redirect to success)
  // The router will keep user on splash until election loads anyway
  return false;
});
