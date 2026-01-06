import '../../domain/entities/voter.dart';

class VoterModel extends Voter {
  const VoterModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.phone,
  });

  factory VoterModel.fromJson(Map<String, dynamic> json) {
    return VoterModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
    };
  }

  factory VoterModel.fromEntity(Voter voter) {
    return VoterModel(
      id: voter.id,
      firstName: voter.firstName,
      lastName: voter.lastName,
      phone: voter.phone,
    );
  }
}
