import 'package:philadelphia_mansue/features/auth/domain/entities/auth_result.dart';
import 'package:philadelphia_mansue/features/auth/domain/entities/voter.dart';

/// Creates a test AuthResult with customizable properties
AuthResult createTestAuthResult({
  String id = 'voter-123',
  String firstName = 'John',
  String lastName = 'Doe',
  String phone = '+1234567890',
  String? qrCode,
}) {
  return AuthResult(
    voter: Voter(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      qrCode: qrCode,
    ),
  );
}

/// Creates a test Voter with customizable properties
Voter createTestVoter({
  String id = 'voter-123',
  String firstName = 'John',
  String lastName = 'Doe',
  String phone = '+1234567890',
  String? qrCode,
}) {
  return Voter(
    id: id,
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    qrCode: qrCode,
  );
}

/// Creates a list of test voters
List<Voter> createTestVoters(int count) {
  return List.generate(
    count,
    (i) => createTestVoter(
      id: 'voter-${i + 1}',
      firstName: 'Voter',
      lastName: '${i + 1}',
      phone: '+1234567${i.toString().padLeft(3, '0')}',
    ),
  );
}
