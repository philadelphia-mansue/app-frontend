import 'voter.dart';

/// Result of successful authentication containing voter info
class AuthResult {
  final Voter voter;

  const AuthResult({
    required this.voter,
  });
}
