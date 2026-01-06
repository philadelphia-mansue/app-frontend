import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/vote.dart';

abstract class VoteRepository {
  Future<Either<Failure, Vote>> submitVote(Vote vote);
}
