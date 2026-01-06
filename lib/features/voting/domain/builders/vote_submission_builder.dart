import '../entities/vote.dart';

class VoteSubmissionBuilder {
  final List<String> _candidateIds = [];
  String? _sessionId;
  String? _electionId;
  int _maxVotes;
  DateTime? _timestamp;

  VoteSubmissionBuilder({int maxVotes = 10}) : _maxVotes = maxVotes;

  VoteSubmissionBuilder setMaxVotes(int maxVotes) {
    _maxVotes = maxVotes;
    return this;
  }

  VoteSubmissionBuilder setSessionId(String sessionId) {
    _sessionId = sessionId;
    return this;
  }

  VoteSubmissionBuilder setElectionId(String electionId) {
    _electionId = electionId;
    return this;
  }

  VoteSubmissionBuilder addCandidate(String candidateId) {
    if (_candidateIds.length < _maxVotes &&
        !_candidateIds.contains(candidateId)) {
      _candidateIds.add(candidateId);
    }
    return this;
  }

  VoteSubmissionBuilder addCandidates(List<String> candidateIds) {
    for (final id in candidateIds) {
      addCandidate(id);
    }
    return this;
  }

  VoteSubmissionBuilder removeCandidate(String candidateId) {
    _candidateIds.remove(candidateId);
    return this;
  }

  VoteSubmissionBuilder setTimestamp(DateTime timestamp) {
    _timestamp = timestamp;
    return this;
  }

  bool get isValid =>
      _candidateIds.length == _maxVotes &&
      _sessionId != null &&
      _electionId != null;

  int get candidateCount => _candidateIds.length;

  int get maxVotes => _maxVotes;

  List<String> get candidateIds => List.unmodifiable(_candidateIds);

  Vote build() {
    if (!isValid) {
      throw StateError(
        'Cannot build Vote: '
        'candidateCount=${_candidateIds.length}/$_maxVotes, '
        'sessionId=${_sessionId != null}, '
        'electionId=${_electionId != null}',
      );
    }

    return Vote(
      id: _generateVoteId(),
      electionId: _electionId!,
      selectedCandidateIds: List.unmodifiable(_candidateIds),
      timestamp: _timestamp ?? DateTime.now(),
    );
  }

  String _generateVoteId() {
    return 'vote_${DateTime.now().millisecondsSinceEpoch}_$_sessionId';
  }

  void reset() {
    _candidateIds.clear();
    _sessionId = null;
    _electionId = null;
    _timestamp = null;
  }
}
