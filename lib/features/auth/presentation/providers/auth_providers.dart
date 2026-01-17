import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/vote_cache_service.dart';
import '../../../../core/utils/selection_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/voter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import 'auth_state.dart';

// Data Source - with ApiClient and TokenStorage dependencies
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageServiceProvider),
  );
});

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(tokenStorageServiceProvider),
  );
});

// Use Cases
final sendOtpUseCaseProvider = Provider<SendOtp>((ref) {
  return SendOtp(ref.watch(authRepositoryProvider));
});

final verifyOtpUseCaseProvider = Provider<VerifyOtp>((ref) {
  return VerifyOtp(ref.watch(authRepositoryProvider));
});

/// Stream provider for current Firebase user ID.
/// Emits user ID when signed in, null when signed out.
/// Fires immediately with current state, then on every sign-in/sign-out.
///
/// NOTE: Do NOT invalidate this provider on sign out!
/// The authStateChanges() stream will naturally emit null after sign out,
/// which will update reactively without intermediate loading states.
final currentUserIdProvider = StreamProvider<String?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  debugPrint('[AuthProvider] Setting up currentUserIdProvider stream');
  return repository.authStateChanges();
});

/// Provides whether any Firebase user is currently signed in.
/// Returns true only when we have a confirmed user ID.
final isFirebaseSignedInProvider = Provider<bool>((ref) {
  final userIdAsync = ref.watch(currentUserIdProvider);
  return userIdAsync.maybeWhen(
    data: (userId) => userId != null,
    orElse: () => false,
  );
});

// Auth Notifier - handles OTP flow and app auth state
class AuthNotifier extends StateNotifier<AuthState> {
  final SendOtp _sendOtp;
  final VerifyOtp _verifyOtp;
  final AuthRepository _repository;
  final AuthRemoteDataSource _dataSource;
  final VoteCacheService _voteCache;
  String? _phoneNumber;
  bool _isRestoringSession = false;
  bool _isImpersonated = false;
  bool _pendingImpersonation = false;

  AuthNotifier({
    required SendOtp sendOtp,
    required VerifyOtp verifyOtp,
    required AuthRepository repository,
    required AuthRemoteDataSource dataSource,
    required VoteCacheService voteCache,
  })  : _sendOtp = sendOtp,
        _verifyOtp = verifyOtp,
        _repository = repository,
        _dataSource = dataSource,
        _voteCache = voteCache,
        super(AuthState.initial());

  String? get phoneNumber => _phoneNumber;

  /// Safely updates state, handling cases where notifier was disposed
  void _safeSetState(AuthState newState) {
    if (!mounted) {
      debugPrint('[AuthNotifier] Notifier disposed, cannot update state to: ${newState.status}');
      return;
    }
    state = newState;
  }

  /// Try to restore session with backend using current Firebase user.
  /// Called by the session restoration provider when Firebase user changes.
  Future<void> tryRestoreSession(String userId) async {
    // Already authenticated - no need to restore
    if (state.status == AuthStatus.authenticated) {
      debugPrint('[AuthNotifier] Already authenticated, skipping restore');
      return;
    }

    // Skip if we're in the middle of OTP flow
    if (state.status == AuthStatus.loading || state.status == AuthStatus.otpSent) {
      debugPrint('[AuthNotifier] Skipping restore - OTP flow in progress');
      return;
    }

    // Prevent concurrent restore attempts (race condition fix)
    if (_isRestoringSession) {
      debugPrint('[AuthNotifier] Session restore already in progress, skipping');
      return;
    }
    _isRestoringSession = true;

    debugPrint('[AuthNotifier] Attempting to restore session for user: $userId');

    try {
      // First, check if we already have a valid stored token
      final isAuthenticated = await _repository.isAuthenticated();
      if (isAuthenticated) {
        debugPrint('[AuthNotifier] Found existing token, validating...');
        final result = await _repository.getCurrentVoter();
        final restored = result.fold(
          (failure) {
            debugPrint('[AuthNotifier] Stored token invalid: ${failure.message}');
            // Don't sign out yet - will try Firebase token exchange below
            return false;
          },
          (voter) {
            debugPrint('[AuthNotifier] Restored with existing token');
            _safeSetState(AuthState.authenticated(voter));
            return true;
          },
        );
        if (restored) return;
        // Backend token was invalid - fall through to try Firebase token exchange
      }

      // Try to exchange Firebase token for new backend token
      // This handles both: (1) no stored token, and (2) stored token was invalid
      debugPrint('[AuthNotifier] Attempting Firebase token exchange...');
      final idToken = await _dataSource.getFirebaseIdToken();
      await _dataSource.exchangeTokenWithBackend(idToken);
      debugPrint('[AuthNotifier] Token exchanged successfully');

      // Get voter profile
      final result = await _repository.getCurrentVoter();
      result.fold(
        (failure) {
          debugPrint('[AuthNotifier] Failed to get voter: ${failure.message}');
          _safeSetState(AuthState.unauthenticated());
        },
        (voter) {
          debugPrint('[AuthNotifier] Session restored for voter');
          _safeSetState(AuthState.authenticated(voter));
        },
      );
    } catch (e) {
      debugPrint('[AuthNotifier] Session restore failed: $e');
      // Don't set error state - just leave as initial/unauthenticated
      if (state.status == AuthStatus.initial) {
        _safeSetState(AuthState.unauthenticated());
      }
    } finally {
      _isRestoringSession = false;
    }
  }

  /// Mark that impersonation is about to happen (called from router, doesn't modify state)
  void markPendingImpersonation() {
    _pendingImpersonation = true;
  }

  /// Handle Firebase user signed out or no user on startup
  Future<void> handleFirebaseSignOut() async {
    // Don't override if impersonation is pending or already done
    if (_pendingImpersonation) {
      debugPrint('[AuthNotifier] Skipping Firebase sign out - impersonation pending');
      return;
    }
    if (_isImpersonated) {
      debugPrint('[AuthNotifier] Skipping Firebase sign out - user is impersonated');
      return;
    }
    // Handle auth, initial, AND error states - error state should also reset on sign out
    if (state.status == AuthStatus.authenticated ||
        state.status == AuthStatus.initial ||
        state.status == AuthStatus.error) {
      // Check if there's a stored token (from impersonation) before setting unauthenticated
      final hasToken = await _repository.isAuthenticated();
      if (hasToken) {
        debugPrint('[AuthNotifier] No Firebase user but found stored token, restoring session');
        final result = await _repository.getCurrentVoter();
        result.fold(
          (failure) {
            debugPrint('[AuthNotifier] Token invalid: ${failure.message}');
            _safeSetState(AuthState.unauthenticated());
          },
          (voter) {
            debugPrint('[AuthNotifier] Session restored from stored token');
            _isImpersonated = true;
            _safeSetState(AuthState.authenticated(voter));
          },
        );
        return;
      }
      debugPrint('[AuthNotifier] No Firebase user, setting unauthenticated');
      _safeSetState(AuthState.unauthenticated());
    }
  }

  /// Check if user is already authenticated (has valid token)
  Future<void> checkAuthStatus() async {
    // Use the same mutex as tryRestoreSession to prevent conflicts
    if (_isRestoringSession) {
      debugPrint('[AuthNotifier] Session restore in progress, skipping checkAuthStatus');
      return;
    }
    _isRestoringSession = true;

    try {
      final isAuthenticated = await _repository.isAuthenticated();
      if (isAuthenticated) {
        // Try to get current voter profile
        final result = await _repository.getCurrentVoter();
        result.fold(
          (failure) => _safeSetState(AuthState.unauthenticated()),
          (voter) => _safeSetState(AuthState.authenticated(voter)),
        );
      } else {
        _safeSetState(AuthState.unauthenticated());
      }
    } finally {
      _isRestoringSession = false;
    }
  }

  Future<void> sendOtp(String phoneNumber) async {
    debugPrint('[AuthNotifier] sendOtp called');
    state = AuthState.loading();
    _phoneNumber = phoneNumber;

    // Send OTP directly - vote status is checked per-election after authentication
    debugPrint('[AuthNotifier] Sending OTP...');
    final result = await _sendOtp(SendOtpParams(phoneNumber: phoneNumber));

    result.fold(
      (failure) {
        debugPrint('[AuthNotifier] OTP send failed: ${failure.message}');
        _safeSetState(AuthState.error(failure.message));
      },
      (verificationId) {
        debugPrint('[AuthNotifier] OTP sent successfully, verificationId: $verificationId');
        _safeSetState(AuthState.otpSent(verificationId));
      },
    );
    debugPrint('[AuthNotifier] sendOtp completed, state: ${mounted ? state.status.toString() : "disposed"}');
  }

  Future<void> verifyOtp(String otp) async {
    if (state.verificationId == null) {
      _safeSetState(AuthState.error('Verification ID not found'));
      return;
    }

    final verificationId = state.verificationId!;
    _safeSetState(state.copyWith(status: AuthStatus.loading));

    final result = await _verifyOtp(
      VerifyOtpParams(
        verificationId: verificationId,
        otp: otp,
      ),
    );

    result.fold(
      (failure) => _safeSetState(AuthState.error(failure.message)),
      (authResult) => _safeSetState(AuthState.authenticated(authResult.voter)),
    );
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _phoneNumber = null;
    _isImpersonated = false;

    // Clear all cached data to prevent data leakage between users
    await _voteCache.clearCache();
    clearAllStoredSelectionData();
    debugPrint('[AuthNotifier] Cleared vote cache and selection storage on logout');

    // NOTE: Don't need to set state here - the authStateChanges stream
    // will naturally emit null after sign out, which triggers handleFirebaseSignOut
    _safeSetState(AuthState.unauthenticated());
  }

  /// Set impersonating state (called from router before debugImpersonate)
  void setImpersonating() {
    _safeSetState(AuthState.impersonating());
  }

  /// Debug-only impersonate login (bypasses OTP flow)
  Future<void> debugImpersonate(String phone, String magicToken) async {
    // Prevent duplicate impersonation attempts
    if (state.status == AuthStatus.loading || state.status == AuthStatus.authenticated) {
      debugPrint('[AuthNotifier] DEBUG: Impersonate already in progress or done, skipping');
      return;
    }
    debugPrint('[AuthNotifier] DEBUG: Attempting impersonate login');
    _safeSetState(AuthState.loading());

    try {
      final authResponse = await _dataSource.impersonateUser(
        phone: phone,
        magicToken: magicToken,
      );

      final voter = authResponse.voter;
      debugPrint('[AuthNotifier] DEBUG: Impersonate successful');
      _isImpersonated = true;
      _pendingImpersonation = false;
      _safeSetState(AuthState.authenticated(voter));
    } catch (e) {
      debugPrint('[AuthNotifier] DEBUG: Impersonate failed: $e');
      _pendingImpersonation = false;
      _safeSetState(AuthState.error(e.toString()));
    }
  }

  void reset() {
    _phoneNumber = null;
    _isRestoringSession = false;
    _isImpersonated = false;
    _pendingImpersonation = false;
    // Use unauthenticated instead of initial to avoid redirect to splash
    _safeSetState(AuthState.unauthenticated());
  }

  /// Refresh the backend token using the existing Firebase session.
  /// This replaces the old ping() approach - instead of checking if the token
  /// is valid and logging out if not, we simply get a fresh token.
  Future<void> refreshToken() async {
    if (state.status != AuthStatus.authenticated) {
      debugPrint('[AuthNotifier] Token refresh skipped - not authenticated');
      return;
    }

    debugPrint('[AuthNotifier] Refreshing backend token...');
    try {
      // Get fresh Firebase ID token
      final firebaseIdToken = await _dataSource.getFirebaseIdToken();

      // Exchange for new backend token (also stores the new token)
      final authResponse = await _dataSource.exchangeTokenWithBackend(firebaseIdToken);

      // Update state with fresh voter data (VoterModel extends Voter)
      _safeSetState(AuthState.authenticated(authResponse.voter));
      debugPrint('[AuthNotifier] Token refresh successful');
    } on AuthException catch (e) {
      debugPrint('[AuthNotifier] Token refresh failed: ${e.message} - signing out');
      signOut();
    } catch (e) {
      // Network errors - keep session, user is still "authenticated" locally
      debugPrint('[AuthNotifier] Token refresh network error: $e - keeping session');
    }
  }
}

// Auth Notifier Provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier(
    sendOtp: ref.read(sendOtpUseCaseProvider),
    verifyOtp: ref.read(verifyOtpUseCaseProvider),
    repository: ref.read(authRepositoryProvider),
    dataSource: ref.read(authRemoteDataSourceProvider),
    voteCache: ref.read(voteCacheServiceProvider),
  );

  // Set up unauthorized callback to attempt token refresh on 401 responses.
  // If refresh fails (Firebase session invalid), refreshToken will call signOut.
  Future.microtask(() {
    ref.read(onUnauthorizedCallbackProvider.notifier).state = () {
      notifier.refreshToken();
    };
  });

  // Listen to Firebase auth state changes and sync with AuthNotifier
  ref.listen<AsyncValue<String?>>(currentUserIdProvider, (previous, next) {
    next.when(
      data: (userId) {
        if (userId != null) {
          // Firebase user signed in - try to restore session
          notifier.tryRestoreSession(userId);
        } else {
          // Firebase user signed out
          notifier.handleFirebaseSignOut();
        }
      },
      loading: () {
        debugPrint('[AuthProvider] Auth state loading...');
      },
      error: (error, stack) {
        debugPrint('[AuthProvider] Auth state error: $error');
      },
    );
  }, fireImmediately: true);

  return notifier;
});

// Convenience selectors
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).status == AuthStatus.authenticated;
});

final currentVoterProvider = Provider<Voter?>((ref) {
  return ref.watch(authNotifierProvider).voter;
});
