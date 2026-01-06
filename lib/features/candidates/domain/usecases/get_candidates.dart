import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/candidate.dart';
import '../repositories/candidate_repository.dart';

class GetCandidates implements UseCase<List<Candidate>, NoParams> {
  final CandidateRepository repository;

  GetCandidates(this.repository);

  @override
  Future<Either<Failure, List<Candidate>>> call(NoParams params) async {
    return await repository.getCandidates();
  }
}
