import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/vote_model.dart';

abstract class VoteRemoteDataSource {
  Future<VoteModel> submitVote(VoteModel vote);
}

class VoteRemoteDataSourceImpl implements VoteRemoteDataSource {
  final ApiClient apiClient;

  VoteRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<VoteModel> submitVote(VoteModel vote) async {
    try {
      final response = await apiClient.post(
        ApiConstants.voteEndpoint,
        data: vote.toApiRequest(),
      );

      // 201 Created - Vote successful
      if (response.statusCode == 201) {
        return vote;
      }

      throw ServerException(message: 'Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      if (e is ServerException ||
          e is AlreadyVotedException ||
          e is ElectionNotActiveException ||
          e is InvalidCandidateCountException ||
          e is DuplicateCandidatesException ||
          e is AuthException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  Exception _mapDioException(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;
      final message = data is Map ? data['message'] as String? : null;

      switch (statusCode) {
        case 401:
          return const AuthException(message: 'Authentication required');
        case 403:
          // Handle specific 403 errors
          if (message != null) {
            if (message.toLowerCase().contains('already voted')) {
              return AlreadyVotedException(message: message);
            }
            if (message.toLowerCase().contains('not active') ||
                message.toLowerCase().contains('not currently active')) {
              return ElectionNotActiveException(message: message);
            }
          }
          return AuthException(message: message ?? 'Access denied');
        case 409:
          // Handle conflict (race condition duplicate vote)
          return AlreadyVotedException(
            message: message ?? 'Vote already recorded',
          );
        case 422:
          // Handle validation errors
          if (message != null) {
            if (message.toLowerCase().contains('exactly') &&
                message.toLowerCase().contains('candidate')) {
              return InvalidCandidateCountException(message: message);
            }
            if (message.toLowerCase().contains('duplicate') ||
                message.toLowerCase().contains('same candidate')) {
              return DuplicateCandidatesException(message: message);
            }
          }
          return ServerException(message: message ?? 'Validation error');
        case 500:
        case 502:
        case 503:
          return const ServerException(
              message: 'Server error. Please try again later.');
        default:
          return ServerException(message: message ?? 'Request failed');
      }
    }

    // Network errors
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkException(message: 'Connection timed out');
    }
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkException(message: 'No internet connection');
    }

    return ServerException(message: e.message ?? 'Unknown error');
  }
}
