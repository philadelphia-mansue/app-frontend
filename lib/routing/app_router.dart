import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/utils/url_params.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/auth/presentation/providers/auth_state.dart';
import '../features/auth/presentation/screens/phone_auth_screen.dart';
import '../features/candidates/presentation/screens/candidates_screen.dart';
import '../features/confirmation/presentation/screens/confirmation_screen.dart';
import '../features/elections/presentation/providers/election_providers.dart';
import '../features/success/presentation/screens/success_screen.dart';
import '../features/voting/presentation/providers/local_vote_providers.dart';
import 'not_found_screen.dart';
import 'routes.dart';
import 'splash_screen.dart';

/// Notifier that triggers router refresh when auth or election state changes
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    // Listen to auth changes
    ref.listen(authNotifierProvider, (previous, next) {
      // Reset election state when user becomes unauthenticated
      // This ensures fresh election data is loaded for the next user
      // Note: We keep urlElectionIdProvider so next user can log into same election
      if (previous?.status == AuthStatus.authenticated &&
          next.status == AuthStatus.unauthenticated) {
        ref.read(electionNotifierProvider.notifier).reset();
        // Keep election ID - don't clear urlElectionIdProvider
      }

      // Reset election if user just authenticated and election is in error state
      // This allows the router to trigger a fresh election load after re-login
      if (next.status == AuthStatus.authenticated &&
          ref.read(electionNotifierProvider).status == ElectionLoadStatus.error) {
        ref.read(electionNotifierProvider.notifier).reset();
      }

      notifyListeners();
    });
    // Listen to election changes
    ref.listen(electionNotifierProvider, (_, _) {
      notifyListeners();
    });
    // Watch voteDeletedDetectorProvider to detect vote deletion across page refresh
    // This compares local cache vs API to detect if vote was deleted
    ref.watch(voteDeletedDetectorProvider);
  }
}

final _routerRefreshProvider = Provider((ref) => RouterRefreshNotifier(ref));

/// Build redirect path with election_id query parameter if available
String _buildRedirectWithElectionId(String basePath, String? electionId) {
  if (electionId != null && electionId.isNotEmpty) {
    return '$basePath?election_id=$electionId';
  }
  return basePath;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(_routerRefreshProvider);

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refreshNotifier,
    // Handle Firebase Auth callback URLs and unknown routes
    errorBuilder: (context, state) => const PhoneAuthScreen(),
    redirect: (context, state) {
      // Read current state (not watch - we're in redirect callback)
      final authState = ref.read(authNotifierProvider);
      final electionState = ref.read(electionNotifierProvider);

      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isAuthLoading = authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.impersonating;
      final isInAuthFlow = authState.status == AuthStatus.loading ||
          authState.status == AuthStatus.otpSent;
      // Note: error state is NOT considered "loaded" - user stays on splash with error UI
      final isElectionLoaded = electionState.status == ElectionLoadStatus.loaded ||
          electionState.status == ElectionLoadStatus.noElection;
      final hasVoted = ref.read(hasVotedCombinedProvider);
      final currentPath = state.matchedLocation;

      // Extract election_id from URL (only store if election not yet loaded)
      // With hash routing, query params in main URL aren't in GoRouter's state,
      // so we also check the browser URL directly on web
      final goRouterElectionId = state.uri.queryParameters['election_id'];
      final browserElectionId = getBrowserElectionId();
      final urlElectionId = (goRouterElectionId != null && goRouterElectionId.isNotEmpty)
          ? goRouterElectionId
          : browserElectionId;

      if (urlElectionId != null && urlElectionId.isNotEmpty) {
        if (electionState.status == ElectionLoadStatus.initial) {
          final currentStoredId = ref.read(urlElectionIdProvider);
          if (currentStoredId != urlElectionId) {
            debugPrint('[Router] Storing URL election_id: $urlElectionId');
            Future.microtask(() {
              ref.read(urlElectionIdProvider.notifier).state = urlElectionId;
            });
          }
        }
      }

      final storedElectionId = ref.read(urlElectionIdProvider);
      // Effective election ID for use in redirects - prefer URL, fallback to stored, fallback to loaded election
      final loadedElectionId = electionState.election?.id;
      final effectiveElectionId = (urlElectionId != null && urlElectionId.isNotEmpty)
          ? urlElectionId
          : (storedElectionId != null && storedElectionId.isNotEmpty)
              ? storedElectionId
              : loadedElectionId;
      debugPrint('[Router] redirect: path=$currentPath, authStatus=${authState.status}, electionStatus=${electionState.status}, hasVoted=$hasVoted, electionId=$effectiveElectionId');

      // Allow not-found page to be shown
      if (currentPath == Routes.notFound) {
        return null;
      }

      // Handle impersonation via query params (works on any route)
      // Check both GoRouter params (hash fragment) and browser URL params (main URL)
      final goRouterPhone = state.uri.queryParameters['phone'];
      final goRouterMagicToken = state.uri.queryParameters['magic_token'];
      final phone = (goRouterPhone != null && goRouterPhone.isNotEmpty)
          ? goRouterPhone
          : getBrowserPhone();
      final magicToken = (goRouterMagicToken != null && goRouterMagicToken.isNotEmpty)
          ? goRouterMagicToken
          : getBrowserMagicToken();

      if (phone != null && magicToken != null && !isInAuthFlow && !isAuthenticated) {
        debugPrint('[Router] Impersonate request: phone=$phone');
        // Mark pending impersonation (doesn't modify state, prevents Firebase signout)
        ref.read(authNotifierProvider.notifier).markPendingImpersonation();
        // Trigger impersonate (async) and redirect to splash while loading
        Future.microtask(() {
          ref.read(authNotifierProvider.notifier).debugImpersonate(phone, magicToken);
        });
        return Routes.splash;
      }

      // Load election when authenticated and not yet loaded
      // Note: error state requires manual retry from splash screen (no auto-retry)
      if (isAuthenticated &&
          electionState.status == ElectionLoadStatus.initial) {
        if (storedElectionId != null && storedElectionId.isNotEmpty) {
          debugPrint('[Router] Loading election by ID: $storedElectionId');
          Future.microtask(() {
            ref.read(electionNotifierProvider.notifier).loadElectionById(storedElectionId);
          });
        }
        // No fallback to loadOngoingElection - election_id must be provided in URL
      }

      // Still loading auth (initial state) - go to splash and wait
      if (isAuthLoading) {
        return currentPath == Routes.splash ? null : Routes.splash;
      }

      // In the middle of auth flow (sending OTP, verifying) - stay on login
      if (isInAuthFlow) {
        return currentPath == Routes.phoneInput ? null : Routes.phoneInput;
      }

      // Not authenticated
      if (!isAuthenticated) {
        // Check if we have an election_id (from URL or stored)
        final hasElectionId = effectiveElectionId != null && effectiveElectionId.isNotEmpty;

        // Allow login page if we have an election_id
        if (currentPath == Routes.phoneInput) {
          return hasElectionId ? null : Routes.notFound;
        }
        // Redirect to login with election_id preserved, otherwise to not-found
        return hasElectionId
            ? _buildRedirectWithElectionId(Routes.phoneInput, effectiveElectionId)
            : Routes.notFound;
      }

      // Authenticated but no election_id - cannot proceed without an election
      final hasElectionId = effectiveElectionId != null && effectiveElectionId.isNotEmpty;
      if (!hasElectionId) {
        debugPrint('[Router] Authenticated but no election_id - redirecting to not-found');
        return Routes.notFound;
      }

      // Authenticated but election not loaded yet - wait on splash
      // hasVoted is only accurate after election loads from API
      if (!isElectionLoaded) {
        return currentPath == Routes.splash
            ? null
            : _buildRedirectWithElectionId(Routes.splash, effectiveElectionId);
      }

      // Authenticated and election loaded - apply routing rules
      debugPrint('[Router] hasVoted check: electionLoaded=$isElectionLoaded, hasVoted=$hasVoted');

      // User has voted - only allow success screen
      if (hasVoted) {
        return currentPath == Routes.success
            ? null
            : _buildRedirectWithElectionId(Routes.success, effectiveElectionId);
      }

      // User hasn't voted - allow candidates, confirmation, but not login or splash
      if (currentPath == Routes.phoneInput || currentPath == Routes.splash) {
        return _buildRedirectWithElectionId(Routes.candidates, effectiveElectionId);
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.phoneInput,
        builder: (context, state) => const PhoneAuthScreen(),
      ),
      GoRoute(
        path: Routes.candidates,
        builder: (context, state) => const CandidatesScreen(),
      ),
      GoRoute(
        path: Routes.confirmation,
        builder: (context, state) => const ConfirmationScreen(),
      ),
      GoRoute(
        path: Routes.success,
        builder: (context, state) => const SuccessScreen(),
      ),
      // Impersonate route - handled by redirect, shows splash while processing
      GoRoute(
        path: Routes.impersonate,
        builder: (context, state) => const SplashScreen(),
      ),
      // Not found route - shown when no election_id provided
      GoRoute(
        path: Routes.notFound,
        builder: (context, state) => const NotFoundScreen(),
      ),
    ],
  );
});
