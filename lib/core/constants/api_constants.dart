import '../env/env.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl => Env.apiBaseUrl;

  // Auth endpoints
  static const String votersLogin = '/api/voters/login';
  static const String votersImpersonate = '/api/voters/inpersonate';
  static const String votersMe = '/api/voters/me';

  // Elections endpoints
  static const String electionsEndpoint = '/api/elections';

  // Voting endpoints
  static const String voteEndpoint = '/api/votes';
  static const String voteStatusEndpoint = '/api/votes/status';

  // Legacy endpoints (kept for compatibility)
  static const String candidatesEndpoint = '/api/candidates';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
