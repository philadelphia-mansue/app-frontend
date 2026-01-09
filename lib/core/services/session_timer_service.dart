import 'dart:async';
import 'package:flutter/foundation.dart';
import 'token_storage_service.dart';

/// Service that manages session timeout with periodic expiry checks.
/// Calls the provided callback when the session expires.
abstract class SessionTimerService {
  /// Start the session timer. Calls [onExpired] when session expires.
  void startSessionTimer(VoidCallback onExpired);

  /// Stop the session timer.
  void stopTimer();

  /// Whether the timer is currently active.
  bool get isTimerActive;
}

class SessionTimerServiceImpl implements SessionTimerService {
  final TokenStorageService _tokenStorage;

  Timer? _periodicCheckTimer;

  /// Check interval for session expiry (every 30 seconds)
  static const _checkInterval = Duration(seconds: 30);

  SessionTimerServiceImpl({required TokenStorageService tokenStorage})
      : _tokenStorage = tokenStorage;

  @override
  bool get isTimerActive => _periodicCheckTimer?.isActive ?? false;

  @override
  void startSessionTimer(VoidCallback onExpired) {
    // Stop any existing timer first
    stopTimer();

    debugPrint('[SessionTimer] Starting session timer with ${_checkInterval.inSeconds}s check interval');

    // Start periodic check
    _periodicCheckTimer = Timer.periodic(_checkInterval, (_) async {
      final isExpired = await _tokenStorage.isSessionExpired();
      if (isExpired) {
        debugPrint('[SessionTimer] Session expired - triggering logout');
        onExpired();
        stopTimer();
      }
    });
  }

  @override
  void stopTimer() {
    if (_periodicCheckTimer != null) {
      debugPrint('[SessionTimer] Stopping session timer');
      _periodicCheckTimer?.cancel();
      _periodicCheckTimer = null;
    }
  }
}
