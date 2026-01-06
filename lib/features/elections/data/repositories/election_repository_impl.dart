import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/election.dart';
import '../../domain/repositories/election_repository.dart';
import '../datasources/election_remote_datasource.dart';

class ElectionRepositoryImpl implements ElectionRepository {
  final ElectionRemoteDataSource remoteDataSource;

  ElectionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Election?>> getOngoingElection() async {
    try {
      final election = await remoteDataSource.getOngoingElection();
      return Right(election);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Election>> getElectionById(String id) async {
    try {
      final election = await remoteDataSource.getElectionById(id);
      return Right(election);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
