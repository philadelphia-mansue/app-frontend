import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/candidate.dart';
import '../../domain/repositories/candidate_repository.dart';
import '../datasources/candidate_mock_datasource.dart';

class CandidateRepositoryImpl implements CandidateRepository {
  final CandidateMockDataSource mockDataSource;

  CandidateRepositoryImpl({required this.mockDataSource});

  @override
  Future<Either<Failure, List<Candidate>>> getCandidates() async {
    try {
      // Using mock data source for now
      // Replace with remoteDataSource when API is ready
      final candidates = await mockDataSource.getCandidates();
      return Right(candidates);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
