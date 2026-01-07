import 'package:philadelphia_mansue/features/auth/domain/entities/voter.dart';

/// Creates a test Voter with customizable properties
Voter createTestVoter({
  String id = 'voter-123',
  String firstName = 'John',
  String lastName = 'Doe',
  String phone = '+1234567890',
}) {
  return Voter(
    id: id,
    firstName: firstName,
    lastName: lastName,
    phone: phone,
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
      phone: '+123456789$i',
    ),
  );
}
