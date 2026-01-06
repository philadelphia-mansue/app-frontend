import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/voter.dart';
import '../repositories/auth_repository.dart';

class VerifyOtp implements UseCase<Voter, VerifyOtpParams> {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  @override
  Future<Either<Failure, Voter>> call(VerifyOtpParams params) async {
    return await repository.verifyOtp(params.verificationId, params.otp);
  }
}

class VerifyOtpParams {
  final String verificationId;
  final String otp;

  const VerifyOtpParams({
    required this.verificationId,
    required this.otp,
  });
}
