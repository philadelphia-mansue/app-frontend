import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/candidate_model.dart';

abstract class CandidateRemoteDataSource {
  Future<List<CandidateModel>> getCandidates();
}

class CandidateRemoteDataSourceImpl implements CandidateRemoteDataSource {
  final ApiClient apiClient;

  CandidateRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CandidateModel>> getCandidates() async {
    try {
      final response = await apiClient.get(ApiConstants.candidatesEndpoint);
      final data = response.data as List;
      return data.map((json) => CandidateModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
