import '../features/voting/data/models/vote_model.dart';

class MockVoteService {
  // Simulated storage of voted phone numbers
  static final Set<String> _votedPhones = {};

  // Check if a phone number has already voted
  static Future<bool> hasPhoneVoted(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _votedPhones.contains(phoneNumber);
  }

  // Submit a vote
  static Future<VoteModel> submitVote(VoteModel vote, String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 1));

    // Check if already voted
    if (_votedPhones.contains(phoneNumber)) {
      throw Exception('This phone number has already voted');
    }

    // Mark as voted
    _votedPhones.add(phoneNumber);

    return vote;
  }

  // Reset for testing
  static void reset() {
    _votedPhones.clear();
  }
}
