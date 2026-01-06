import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/candidate.dart';

abstract class CandidateRepository {
  Future<Either<Failure, List<Candidate>>> getCandidates();
}
