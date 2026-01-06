import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String phoneNumber;

  const User({
    required this.id,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [id, phoneNumber];
}
