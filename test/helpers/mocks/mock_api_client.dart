import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:philadelphia_mansue/core/network/api_client.dart';

/// Mock implementation of ApiClient for testing
class MockApiClient extends Mock implements ApiClient {
  /// Stub responses for specific paths
  final Map<String, Response<dynamic>> _getResponses = {};
  final Map<String, Response<dynamic>> _postResponses = {};

  /// Stub exceptions for specific paths
  final Map<String, Exception> _getExceptions = {};
  final Map<String, Exception> _postExceptions = {};

  /// Configure a successful GET response
  void stubGet(String path, dynamic data, {int statusCode = 200}) {
    _getResponses[path] = Response(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: statusCode,
    );
  }

  /// Configure a GET to throw an exception
  void stubGetError(String path, Exception exception) {
    _getExceptions[path] = exception;
  }

  /// Configure a successful POST response
  void stubPost(String path, dynamic data, {int statusCode = 200}) {
    _postResponses[path] = Response(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: statusCode,
    );
  }

  /// Configure a POST to throw an exception
  void stubPostError(String path, Exception exception) {
    _postExceptions[path] = exception;
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (_getExceptions.containsKey(path)) {
      throw _getExceptions[path]!;
    }
    if (_getResponses.containsKey(path)) {
      return _getResponses[path]! as Response<T>;
    }
    throw UnimplementedError('No stub for GET $path');
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (_postExceptions.containsKey(path)) {
      throw _postExceptions[path]!;
    }
    if (_postResponses.containsKey(path)) {
      return _postResponses[path]! as Response<T>;
    }
    throw UnimplementedError('No stub for POST $path');
  }

  /// Clear all stubs
  void reset() {
    _getResponses.clear();
    _postResponses.clear();
    _getExceptions.clear();
    _postExceptions.clear();
  }
}

/// Helper to create a mock DioException with a specific status code
DioException createDioException(
  int statusCode, {
  String? message,
  String path = '',
  dynamic data,
}) {
  final responseData = data ?? (message != null ? {'message': message} : null);
  return DioException(
    requestOptions: RequestOptions(path: path),
    response: Response(
      statusCode: statusCode,
      data: responseData,
      requestOptions: RequestOptions(path: path),
    ),
    type: DioExceptionType.badResponse,
  );
}

/// Helper to create a network timeout DioException
DioException createTimeoutException({String path = ''}) {
  return DioException(
    requestOptions: RequestOptions(path: path),
    type: DioExceptionType.connectionTimeout,
    message: 'Connection timed out',
  );
}

/// Helper to create a connection error DioException
DioException createConnectionException({String path = ''}) {
  return DioException(
    requestOptions: RequestOptions(path: path),
    type: DioExceptionType.connectionError,
    message: 'No internet connection',
  );
}

/// Manual mock for TokenStorageService (use FakeTokenStorageService to avoid
/// collision with mockito-generated MockTokenStorageService)
class FakeTokenStorageService {
  String? _token;
  bool saveTokenCalled = false;
  bool deleteTokenCalled = false;

  Future<void> saveToken(String token) async {
    _token = token;
    saveTokenCalled = true;
  }

  Future<String?> getToken() async => _token;

  Future<void> deleteToken() async {
    _token = null;
    deleteTokenCalled = true;
  }

  Future<bool> hasToken() async => _token != null;

  void reset() {
    _token = null;
    saveTokenCalled = false;
    deleteTokenCalled = false;
  }
}
