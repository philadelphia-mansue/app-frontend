import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service to cache which elections the user has voted in locally.
/// This is used for faster UX (instant redirect to success screen)
/// without waiting for the API response.
///
/// Note: This is NOT a security measure. The server is the source of truth
/// for vote status. This only stores that a vote was cast, not the details
/// of the vote (for anonymity).
abstract class VoteCacheService {
  /// Mark an election as voted in local cache
  Future<void> markAsVoted(String electionId);

  /// Check if user has voted in an election (from local cache)
  Future<bool> hasVotedInElection(String electionId);

  /// Clear all vote cache (used on logout if needed)
  Future<void> clearCache();
}

class VoteCacheServiceImpl implements VoteCacheService {
  static const _keyPrefix = 'voted_election_';

  final FlutterSecureStorage _storage;

  VoteCacheServiceImpl({required FlutterSecureStorage storage})
      : _storage = storage;

  @override
  Future<void> markAsVoted(String electionId) async {
    await _storage.write(key: '$_keyPrefix$electionId', value: 'true');
  }

  @override
  Future<bool> hasVotedInElection(String electionId) async {
    final value = await _storage.read(key: '$_keyPrefix$electionId');
    return value == 'true';
  }

  @override
  Future<void> clearCache() async {
    // Read all keys and delete ones with our prefix
    final all = await _storage.readAll();
    for (final key in all.keys) {
      if (key.startsWith(_keyPrefix)) {
        await _storage.delete(key: key);
      }
    }
  }
}
