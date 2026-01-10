import '../../domain/entities/candidate.dart';

class CandidateModel extends Candidate {
  const CandidateModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.photoUrl,
  });

  /// Creates a CandidateModel from API JSON response
  /// API format: { id, name, surname, full_name, photo }
  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      id: json['id'] as String,
      firstName: json['name'] as String,
      lastName: json['surname'] as String,
      photoUrl: json['photo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': firstName,
      'surname': lastName,
      'full_name': fullName,
      'photo': photoUrl,
    };
  }

  factory CandidateModel.fromEntity(Candidate candidate) {
    return CandidateModel(
      id: candidate.id,
      firstName: candidate.firstName,
      lastName: candidate.lastName,
      photoUrl: candidate.photoUrl,
    );
  }

  /// Creates a CandidateModel from Election API JSON response
  /// Election API format: { id, first_name, last_name, photo_url }
  factory CandidateModel.fromElectionJson(Map<String, dynamic> json) {
    final rawPhotoUrl = json['photo_url'] as String? ?? '';
    // Sanitize URL: fix double slashes in path (keep :// for protocol)
    final sanitizedPhotoUrl = rawPhotoUrl.replaceAll(RegExp(r'(?<!:)//+'), '/');

    return CandidateModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      photoUrl: sanitizedPhotoUrl,
    );
  }
}
