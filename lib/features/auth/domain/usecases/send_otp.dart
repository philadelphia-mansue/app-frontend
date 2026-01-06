import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SendOtp implements UseCase<String, SendOtpParams> {
  final AuthRepository repository;

  SendOtp(this.repository);

  @override
  Future<Either<Failure, String>> call(SendOtpParams params) async {
    return await repository.sendOtp(params.phoneNumber);
  }
}

class SendOtpParams {
  final String phoneNumber;

  const SendOtpParams({required this.phoneNumber});
}
