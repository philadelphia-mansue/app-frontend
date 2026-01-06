import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/election.dart';
import '../repositories/election_repository.dart';

class GetOngoingElection implements UseCase<Election?, NoParams> {
  final ElectionRepository repository;

  GetOngoingElection(this.repository);

  @override
  Future<Either<Failure, Election?>> call(NoParams params) async {
    return await repository.getOngoingElection();
  }
}
