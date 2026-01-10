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
/// Returns true if either source says the user has voted.
///
/// This provides faster UX: local cache is checked first (instant),
/// and API response updates it when available.
///
/// Security note: The server is the source of truth. This is only
/// for UX optimization, not security enforcement.
final hasVotedCombinedProvider = Provider<bool>((ref) {
  // Check local cache (async, may not be ready yet)
  final localVotedAsync = ref.watch(localHasVotedProvider);
  final localVoted = localVotedAsync.maybeWhen(
    data: (hasVoted) => hasVoted,
    orElse: () => false,
  );

  // Check API response
  final apiVoted = ref.watch(hasVotedProvider);

  // Return true if EITHER says voted
  return localVoted || apiVoted;
});
