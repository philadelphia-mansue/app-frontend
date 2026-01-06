import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/election_model.dart';

abstract class ElectionRemoteDataSource {
  Future<ElectionModel?> getOngoingElection();
  Future<ElectionModel> getElectionById(String id);
}

class ElectionRemoteDataSourceImpl implements ElectionRemoteDataSource {
  final ApiClient apiClient;

  ElectionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ElectionModel?> getOngoingElection() async {
    try {
      final response = await apiClient.get(
        ApiConstants.electionsEndpoint,
        queryParameters: {'status': 'ongoing'},
      );

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
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ElectionModel> getElectionById(String id) async {
    try {
      final response = await apiClient.get('${ApiConstants.electionsEndpoint}/$id');
      return ElectionModel.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
