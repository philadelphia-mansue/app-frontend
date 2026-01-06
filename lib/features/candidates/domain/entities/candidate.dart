import 'package:equatable/equatable.dart';

class Candidate extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String photoUrl;

  const Candidate({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.photoUrl,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [id, firstName, lastName, photoUrl];
}
