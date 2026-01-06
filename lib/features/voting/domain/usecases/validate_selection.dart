import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';

class ValidateSelection implements UseCase<bool, ValidateSelectionParams> {
  ValidateSelection();

  @override
  Future<Either<Failure, bool>> call(ValidateSelectionParams params) async {
    if (params.candidateIds.length != AppConstants.maxVotes) {
      return Left(
        ValidationFailure(
          'Please select exactly ${AppConstants.maxVotes} candidates. '
          'You have selected ${params.candidateIds.length}.',
        ),
      );
    }

    // Check for duplicates
    final uniqueIds = params.candidateIds.toSet();
    if (uniqueIds.length != params.candidateIds.length) {
      return const Left(ValidationFailure('Duplicate candidates detected'));
    }

    return const Right(true);
  }
}

class ValidateSelectionParams {
  final List<String> candidateIds;

  const ValidateSelectionParams({required this.candidateIds});
}
