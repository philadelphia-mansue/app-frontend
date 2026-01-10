import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/election.dart';
import '../repositories/election_repository.dart';

class GetElectionById implements UseCase<Election, GetElectionByIdParams> {
  final ElectionRepository repository;

  GetElectionById(this.repository);

  @override
  Future<Either<Failure, Election>> call(GetElectionByIdParams params) async {
    return await repository.getElectionById(params.id);
  }
}

class GetElectionByIdParams {
  final String id;

  const GetElectionByIdParams({required this.id});
}
