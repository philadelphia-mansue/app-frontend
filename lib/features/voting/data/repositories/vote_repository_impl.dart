import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/vote.dart';
import '../../domain/repositories/vote_repository.dart';
import '../datasources/vote_remote_datasource.dart';
import '../models/vote_model.dart';

class VoteRepositoryImpl implements VoteRepository {
  final VoteRemoteDataSource remoteDataSource;

  VoteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Vote>> submitVote(Vote vote) async {
    try {
      final voteModel = VoteModel.fromEntity(vote);
      final result = await remoteDataSource.submitVote(voteModel);
      return Right(result);
    } on AlreadyVotedException catch (e) {
      return Left(AlreadyVotedFailure(e.message));
    } on ElectionNotActiveException catch (e) {
      return Left(ElectionNotActiveFailure(e.message));
    } on InvalidCandidateCountException catch (e) {
      return Left(InvalidCandidateCountFailure(e.message));
    } on DuplicateCandidatesException catch (e) {
      return Left(DuplicateCandidatesFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
