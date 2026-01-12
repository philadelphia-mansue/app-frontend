import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class VerifyOtp implements UseCase<AuthResult, VerifyOtpParams> {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  @override
  Future<Either<Failure, AuthResult>> call(VerifyOtpParams params) async {
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
