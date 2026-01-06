import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/election.dart';

abstract class ElectionRepository {
  Future<Either<Failure, Election?>> getOngoingElection();
  Future<Either<Failure, Election>> getElectionById(String id);
}
