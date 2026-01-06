import 'voter_model.dart';

class AuthResponseModel {
  final String token;
  final String tokenType;
  final VoterModel voter;

  const AuthResponseModel({
    required this.token,
    required this.tokenType,
    required this.voter,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      voter: VoterModel.fromJson(json['voter'] as Map<String, dynamic>),
    );
  }
}
