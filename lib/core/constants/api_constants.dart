import '../env/env.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl => Env.apiBaseUrl;

  // Auth endpoints
  static const String votersLogin = '/api/voters/login';
  static const String votersImpersonate = '/api/voters/inpersonate'; // Note: backend typo
  static const String votersMe = '/api/voters/me';
  static const String checkPhone = '/api/voters/check-phone';
  static const String ping = '/api/ping';

  // Elections endpoints
  static const String electionsEndpoint = '/api/elections';
  static const String electionsActive = '/api/elections/active';

  // Voting endpoints
  static const String voteEndpoint = '/api/votes';
  static const String voteStatusEndpoint = '/api/votes/status';

  // Legacy endpoints (kept for compatibility)
  static const String candidatesEndpoint = '/api/candidates';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // WebSocket / Laravel Reverb
  static const String reverbHost = 'api.justapage.link';
  static const int reverbPort = 443;
  static const String reverbAppKey = 'if9kan27vmteqnevnb2o';
  static const String broadcastingAuthEndpoint = '/api/broadcasting/auth';

  /// WebSocket URL for Laravel Reverb connection
  static String get reverbWebSocketUrl =>
      'wss://$reverbHost:$reverbPort/app/$reverbAppKey';
}
