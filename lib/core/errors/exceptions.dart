class ServerException implements Exception {
  final String message;

  const ServerException({this.message = 'Server error occurred'});

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Cache error occurred'});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'Network error occurred'});

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;

  const AuthException({this.message = 'Authentication error occurred'});

  @override
  String toString() => 'AuthException: $message';
}

class AlreadyVotedException implements Exception {
  final String message;

  const AlreadyVotedException({this.message = 'This phone number has already voted'});

  @override
  String toString() => 'AlreadyVotedException: $message';
}

class ElectionNotActiveException implements Exception {
  final String message;

  const ElectionNotActiveException({this.message = 'Election is not active'});

  @override
  String toString() => 'ElectionNotActiveException: $message';
}

class InvalidCandidateCountException implements Exception {
  final String message;

  const InvalidCandidateCountException({this.message = 'Invalid number of candidates selected'});

  @override
  String toString() => 'InvalidCandidateCountException: $message';
}

class DuplicateCandidatesException implements Exception {
  final String message;

  const DuplicateCandidatesException({this.message = 'Duplicate candidates selected'});

  @override
  String toString() => 'DuplicateCandidatesException: $message';
}
