import 'package:equatable/equatable.dart';

class Voter extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? qrCode;

  const Voter({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.qrCode,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [id, firstName, lastName, phone, qrCode];
}
