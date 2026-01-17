import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/election.dart';

abstract class ElectionRepository {
  Future<Either<Failure, Election?>> getOngoingElection();
  Future<Either<Failure, Election>> getElectionById(String id);

  /// Check if there is at least one active election.
  /// Returns Right(true) if active election exists, Right(false) if not.
  Future<Either<Failure, bool>> hasActiveElection();

  /// Get all elections the voter is prevalidated for.
  Future<Either<Failure, List<Election>>> getAllOngoingElections();
}
