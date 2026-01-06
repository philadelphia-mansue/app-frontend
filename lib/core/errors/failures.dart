import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error occurred']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error occurred']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication error occurred']);
}

class AlreadyVotedFailure extends Failure {
  const AlreadyVotedFailure([super.message = 'This phone number has already voted']);
}

class ElectionNotActiveFailure extends Failure {
  const ElectionNotActiveFailure([super.message = 'Election is not active']);
}

class InvalidCandidateCountFailure extends Failure {
  const InvalidCandidateCountFailure([super.message = 'Invalid number of candidates selected']);
}

class DuplicateCandidatesFailure extends Failure {
  const DuplicateCandidatesFailure([super.message = 'Duplicate candidates selected']);
}
