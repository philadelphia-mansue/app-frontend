import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/election_model.dart';

abstract class ElectionRemoteDataSource {
  Future<ElectionModel?> getOngoingElection();
  Future<ElectionModel> getElectionById(String id);

  /// Check if there is at least one active election.
  /// Returns true if active election exists, false otherwise.
  Future<bool> hasActiveElection();

  /// Get all elections the voter is prevalidated for.
  /// Returns full list instead of just the first one.
  Future<List<ElectionModel>> getAllOngoingElections();
}

class ElectionRemoteDataSourceImpl implements ElectionRemoteDataSource {
  final ApiClient apiClient;

  ElectionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ElectionModel?> getOngoingElection() async {
    try {
      // Get all elections the voter is enabled to vote in (no status filter)
      final response = await apiClient.get(ApiConstants.electionsEndpoint);

      final data = response.data;
      if (data == null) {
        return null;
      }

      // Handle both list and single object responses
      List<dynamic> electionsList;
      if (data is List) {
        electionsList = data;
      } else if (data is Map<String, dynamic> && data['data'] is List) {
        electionsList = data['data'] as List;
      } else if (data is Map<String, dynamic> && data['data'] is Map) {
        // Single election returned
        return ElectionModel.fromJson(data);
      } else {
        return null;
      }

      if (electionsList.isEmpty) {
        return null;
      }

      // Get the first ongoing election's ID and fetch full details
      final electionId = electionsList.first['id'] as String;
      return await getElectionById(electionId);
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ServerException(message: 'Session expired. Please log in again.');
      }
      throw ServerException(message: e.message ?? 'Failed to load election');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ElectionModel> getElectionById(String id) async {
    try {
      final response = await apiClient.get('${ApiConstants.electionsEndpoint}/$id');
      return ElectionModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ServerException(message: 'Session expired. Please log in again.');
      }
      if (e.response?.statusCode == 403) {
        throw ServerException(message: 'NOT_PREVALIDATED');
      }
      throw ServerException(message: e.message ?? 'Failed to load election');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> hasActiveElection() async {
    try {
      final response = await apiClient.get(ApiConstants.electionsActive);
      final hasActive = response.data['has_active_election'] as bool? ?? false;
      return hasActive;
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to check active elections');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ElectionModel>> getAllOngoingElections() async {
    try {
      // Get all elections the voter is enabled to vote in
      final response = await apiClient.get(ApiConstants.electionsEndpoint);

      final data = response.data;
      if (data == null) {
        return [];
      }

      // Handle both list and single object responses
      List<dynamic> electionsList;
      if (data is List) {
        electionsList = data;
      } else if (data is Map<String, dynamic> && data['data'] is List) {
        electionsList = data['data'] as List;
      } else if (data is Map<String, dynamic> && data['data'] is Map) {
        // Single election returned - fetch full details
        final electionId = data['data']['id'] as String;
        final election = await getElectionById(electionId);
        return [election];
      } else {
        return [];
      }

      if (electionsList.isEmpty) {
        return [];
      }

      // Fetch full details for all elections
      final elections = <ElectionModel>[];
      for (final item in electionsList) {
        final electionId = item['id'] as String;
        try {
          final election = await getElectionById(electionId);
          elections.add(election);
        } on ServerException catch (e) {
          // Only skip elections where voter is not prevalidated
          // Rethrow auth/network failures so they surface correctly
          if (e.message == 'NOT_PREVALIDATED') {
            continue;
          }
          rethrow;
        }
      }

      return elections;
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ServerException(message: 'Session expired. Please log in again.');
      }
      throw ServerException(message: e.message ?? 'Failed to load elections');
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
