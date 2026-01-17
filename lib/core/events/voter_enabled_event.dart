import 'package:equatable/equatable.dart';

/// Event received via WebSocket when a voter is enabled at an election station.
/// This is broadcast when an official scans the voter's QR code.
class VoterEnabledEvent extends Equatable {
  final String voterId;
  final String electionId;
  final String electionName;
  final DateTime enabledAt;

  const VoterEnabledEvent({
    required this.voterId,
    required this.electionId,
    required this.electionName,
    required this.enabledAt,
  });

  factory VoterEnabledEvent.fromJson(Map<String, dynamic> json) {
    return VoterEnabledEvent(
      voterId: json['voter_id'] as String,
      electionId: json['election_id'] as String,
      electionName: json['election_name'] as String,
      enabledAt: DateTime.parse(json['enabled_at'] as String),
    );
  }

  @override
  List<Object?> get props => [voterId, electionId, electionName, enabledAt];
}
