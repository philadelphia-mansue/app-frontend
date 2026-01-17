import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/api_constants.dart';
import '../events/voter_enabled_event.dart';
import 'token_storage_service.dart';

/// Abstract interface for Reverb WebSocket service
abstract class ReverbService {
  /// Connect to the Reverb WebSocket server
  Future<void> connect(String authToken);

  /// Subscribe to a private voter channel
  Future<void> subscribeToVoter(String voterId, String authToken);

  /// Stream of voter.enabled events
  Stream<VoterEnabledEvent> get voterEnabledStream;

  /// Whether the service is currently connected
  bool get isConnected;

  /// Disconnect from the WebSocket server
  void disconnect();

  /// Dispose resources
  void dispose();
}

/// Implementation of ReverbService for Laravel Reverb/Pusher protocol
class ReverbServiceImpl implements ReverbService {
  final Dio _dio;
  final TokenStorageService _tokenStorage;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  String? _socketId;
  bool _isConnected = false;
  bool _isDisposed = false;
  String? _currentVoterId;

  // Reconnection state
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  Timer? _reconnectTimer;

  final _voterEnabledController = StreamController<VoterEnabledEvent>.broadcast();
  Completer<void>? _connectionCompleter;

  ReverbServiceImpl({
    required Dio dio,
    required TokenStorageService tokenStorage,
  })  : _dio = dio,
        _tokenStorage = tokenStorage;

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<VoterEnabledEvent> get voterEnabledStream => _voterEnabledController.stream;

  @override
  Future<void> connect(String authToken) async {
    if (_isConnected) {
      debugPrint('[ReverbService] Already connected');
      return;
    }

    // Clear stale state from previous connection
    _socketId = null;
    _subscription?.cancel();
    _channel?.sink.close();

    // Create new completer for this connection attempt
    _connectionCompleter = Completer<void>();

    try {
      final uri = Uri.parse(ApiConstants.reverbWebSocketUrl);
      debugPrint('[ReverbService] Connecting to $uri');

      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
      );

      // Wait for connection_established event
      await _connectionCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('WebSocket connection timeout');
        },
      );

      _reconnectAttempts = 0;
      debugPrint('[ReverbService] Connected successfully, socketId: $_socketId');
    } catch (e) {
      debugPrint('[ReverbService] Connection failed: $e');
      _handleReconnect();
      rethrow;
    }
  }

  @override
  Future<void> subscribeToVoter(String voterId, String authToken) async {
    if (_socketId == null) {
      throw StateError('Not connected - call connect() first');
    }

    _currentVoterId = voterId;
    final channelName = 'private-voter.$voterId';

    debugPrint('[ReverbService] Subscribing to channel: $channelName');

    try {
      // Get auth signature from backend
      final authSignature = await _authenticateChannel(channelName, authToken);

      // Send pusher:subscribe event
      final subscribeMessage = jsonEncode({
        'event': 'pusher:subscribe',
        'data': {
          'channel': channelName,
          'auth': authSignature,
        },
      });

      _channel!.sink.add(subscribeMessage);
      debugPrint('[ReverbService] Subscription request sent');
    } catch (e) {
      debugPrint('[ReverbService] Subscription failed: $e');
      rethrow;
    }
  }

  Future<String> _authenticateChannel(String channelName, String authToken) async {
    final endpoint = '${ApiConstants.baseUrl}${ApiConstants.broadcastingAuthEndpoint}';

    debugPrint('[ReverbService] Authenticating channel at $endpoint');

    final response = await _dio.post(
      endpoint,
      data: {
        'socket_id': _socketId,
        'channel_name': channelName,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map && data.containsKey('auth')) {
        return data['auth'] as String;
      }
      throw Exception('Invalid auth response format');
    }

    throw Exception('Channel auth failed: ${response.statusCode}');
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final event = data['event'] as String?;

      debugPrint('[ReverbService] Received event: $event');

      switch (event) {
        case 'pusher:connection_established':
          _handleConnectionEstablished(data);
          break;
        case 'pusher_internal:subscription_succeeded':
        case 'pusher:subscription_succeeded':
          debugPrint('[ReverbService] Subscription succeeded');
          break;
        case 'pusher:error':
          _handlePusherError(data);
          break;
        case 'voter.enabled':
          _handleVoterEnabled(data);
          break;
        default:
          // Check if it's a channel event (has channel in data)
          if (data.containsKey('channel') && event != null) {
            _handleChannelEvent(event, data);
          }
      }
    } catch (e) {
      debugPrint('[ReverbService] Error parsing message: $e');
    }
  }

  void _handleConnectionEstablished(Map<String, dynamic> data) {
    final connectionData = data['data'];
    if (connectionData is String) {
      final parsed = jsonDecode(connectionData) as Map<String, dynamic>;
      _socketId = parsed['socket_id'] as String?;
    } else if (connectionData is Map) {
      _socketId = connectionData['socket_id'] as String?;
    }

    _isConnected = true;

    if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
      _connectionCompleter!.complete();
    }

    debugPrint('[ReverbService] Connection established, socketId: $_socketId');
  }

  void _handlePusherError(Map<String, dynamic> data) {
    final errorData = data['data'];
    String? message;
    int? code;

    if (errorData is String) {
      final parsed = jsonDecode(errorData) as Map<String, dynamic>;
      message = parsed['message'] as String?;
      code = parsed['code'] as int?;
    } else if (errorData is Map) {
      message = errorData['message'] as String?;
      code = errorData['code'] as int?;
    }

    debugPrint('[ReverbService] Pusher error: $code - $message');
  }

  void _handleVoterEnabled(Map<String, dynamic> data) {
    try {
      debugPrint('[ReverbService] Raw voter.enabled data: $data');
      debugPrint('[ReverbService] Raw voter.enabled data type: ${data.runtimeType}');

      dynamic eventData = data['data'];
      debugPrint('[ReverbService] Event data: $eventData');
      debugPrint('[ReverbService] Event data type: ${eventData.runtimeType}');

      // Data might be a JSON string or already parsed
      if (eventData is String) {
        debugPrint('[ReverbService] Decoding string data...');
        eventData = jsonDecode(eventData);
        debugPrint('[ReverbService] Decoded data: $eventData');
        debugPrint('[ReverbService] Decoded data type: ${eventData.runtimeType}');
      }

      // On web, JSON objects might not be Map<String, dynamic> directly
      // Convert to proper Map if needed
      if (eventData is Map) {
        final Map<String, dynamic> typedData = Map<String, dynamic>.from(eventData);
        debugPrint('[ReverbService] Typed data: $typedData');
        final event = VoterEnabledEvent.fromJson(typedData);
        debugPrint('[ReverbService] Voter enabled: ${event.voterId}');
        _voterEnabledController.add(event);
      } else {
        debugPrint('[ReverbService] Event data is not a Map: ${eventData.runtimeType}');
      }
    } catch (e, stackTrace) {
      debugPrint('[ReverbService] Error parsing voter.enabled event: $e');
      debugPrint('[ReverbService] Stack trace: $stackTrace');
    }
  }

  void _handleChannelEvent(String event, Map<String, dynamic> data) {
    // Handle events on subscribed channels
    if (event == 'voter.enabled') {
      _handleVoterEnabled(data);
    }
  }

  void _handleError(Object error) {
    debugPrint('[ReverbService] WebSocket error: $error');
    _isConnected = false;
    _handleReconnect();
  }

  void _handleDone() {
    debugPrint('[ReverbService] WebSocket closed');
    _isConnected = false;
    _handleReconnect();
  }

  void _handleReconnect() {
    if (_isDisposed) {
      debugPrint('[ReverbService] Service disposed, skipping reconnect');
      return;
    }

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('[ReverbService] Max reconnect attempts reached');
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts * 2); // Exponential backoff

    debugPrint('[ReverbService] Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () async {
      // Check again after timer delay in case service was disposed while waiting
      if (_isDisposed) {
        debugPrint('[ReverbService] Service disposed during reconnect delay');
        return;
      }

      try {
        // Fetch fresh token from storage instead of using stale _currentAuthToken
        final freshToken = await _tokenStorage.getToken();
        if (freshToken == null) {
          debugPrint('[ReverbService] No token available for reconnect');
          return;
        }

        debugPrint('[ReverbService] Using fresh token for reconnect');
        await connect(freshToken);
        if (_currentVoterId != null) {
          await subscribeToVoter(_currentVoterId!, freshToken);
        }
      } catch (e) {
        debugPrint('[ReverbService] Reconnect failed: $e');
      }
    });
  }

  @override
  void disconnect() {
    debugPrint('[ReverbService] Disconnecting');
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _socketId = null;
    _isConnected = false;
    _currentVoterId = null;
    _reconnectAttempts = 0;
  }

  @override
  void dispose() {
    _isDisposed = true;
    disconnect();
    _voterEnabledController.close();
  }
}
