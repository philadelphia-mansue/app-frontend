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
import '../features/prevalidation/presentation/screens/prevalidation_screen.dart';
import '../features/success/presentation/screens/success_screen.dart';
import '../features/voting/presentation/providers/local_vote_providers.dart';
import '../features/voting/presentation/screens/start_voting_screen.dart';
import '../features/voting/presentation/screens/vote_ended_screen.dart';
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
      if (previous?.status == AuthStatus.authenticated &&
          next.status == AuthStatus.unauthenticated) {
        ref.read(electionNotifierProvider.notifier).reset();
        ref.read(availableElectionsNotifierProvider.notifier).reset();
        ref.read(urlElectionIdProvider.notifier).state = null;
      }

      // When user becomes authenticated, load available elections
      // This determines if user needs prevalidation or can go directly to voting
      if (previous?.status != AuthStatus.authenticated &&
          next.status == AuthStatus.authenticated) {
        ref.read(availableElectionsNotifierProvider.notifier).loadAll();
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
    // Listen to available elections changes (for prevalidation skip logic)
    ref.listen(availableElectionsNotifierProvider, (_, _) {
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

      // Get stored election ID (from backend auth response)
      final storedElectionId = ref.read(urlElectionIdProvider);
      final loadedElectionId = electionState.election?.id;
      final effectiveElectionId = (storedElectionId != null && storedElectionId.isNotEmpty)
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
        debugPrint('[Router] Impersonate request');
        // Mark pending impersonation (doesn't modify state, prevents Firebase signout)
        ref.read(authNotifierProvider.notifier).markPendingImpersonation();
        // Trigger impersonate (async) and redirect to splash while loading
        Future.microtask(() {
          ref.read(authNotifierProvider.notifier).debugImpersonate(phone, magicToken);
        });
        return Routes.splash;
      }

      // Still loading auth (initial state) - go to splash and wait
      // But allow all app pages to stay - preserves URL on page refresh
      if (isAuthLoading) {
        if (currentPath == Routes.prevalidation ||
            currentPath == Routes.startVoting ||
            currentPath == Routes.candidates ||
            currentPath == Routes.confirmation ||
            currentPath == Routes.success ||
            currentPath == Routes.voteEnded ||
            currentPath == Routes.splash) {
          return null;
        }
        return Routes.splash;
      }

      // In the middle of auth flow (sending OTP, verifying) - stay on login
      if (isInAuthFlow) {
        return currentPath == Routes.phoneInput ? null : Routes.phoneInput;
      }

      // Not authenticated - redirect to login
      if (!isAuthenticated) {
        if (currentPath == Routes.phoneInput) {
          return null;
        }
        return Routes.phoneInput;
      }

      // ===== AUTHENTICATED USER LOGIC =====

      // Flow: (check prevalidation) → start-voting OR prevalidation → candidates → confirmation → success

      // Read available elections state to determine if user is prevalidated
      final availableElectionsState = ref.read(availableElectionsNotifierProvider);
      final isCheckingPrevalidation =
          availableElectionsState.status == AvailableElectionsStatus.initial ||
          availableElectionsState.status == AvailableElectionsStatus.loading;
      // User is prevalidated only if API returned actual elections.
      // Empty list (noElections) does NOT mean prevalidated - user must show QR to officials first.
      final hasPrevalidatedElections =
          availableElectionsState.status == AvailableElectionsStatus.loaded &&
              availableElectionsState.elections.isNotEmpty;

      debugPrint('[Router] availableElections: status=${availableElectionsState.status}, count=${availableElectionsState.elections.length}, hasPrevalidated=$hasPrevalidatedElections');

      // If no election (vote ended) - redirect to vote-ended page
      // This takes precedence for authenticated users when election has ended
      if (electionState.status == ElectionLoadStatus.noElection) {
        if (currentPath == Routes.voteEnded) {
          return null;
        }
        // Redirect from voting flow and pre-election flow pages
        // Users can navigate back to elections from voteEnded if needed
        if (currentPath == Routes.candidates ||
            currentPath == Routes.confirmation ||
            currentPath == Routes.startVoting ||
            currentPath == Routes.prevalidation ||
            currentPath == Routes.splash) {
          return Routes.voteEnded;
        }
      }

      // If election is loaded and user has voted - go to success
      if (isElectionLoaded && hasVoted) {
        if (currentPath == Routes.success) {
          return null;
        }
        return _buildRedirectWithElectionId(Routes.success, effectiveElectionId);
      }

      // If election is loaded and user hasn't voted - allow voting flow
      if (electionState.status == ElectionLoadStatus.loaded && !hasVoted) {
        if (currentPath == Routes.candidates ||
            currentPath == Routes.confirmation) {
          return null;
        }
        // If on other pages, redirect to candidates
        if (currentPath != Routes.prevalidation && currentPath != Routes.startVoting) {
          return _buildRedirectWithElectionId(Routes.candidates, effectiveElectionId);
        }
      }

      // Allow prevalidation and start-voting screens (pre-election flow)
      if (currentPath == Routes.prevalidation ||
          currentPath == Routes.startVoting) {
        return null;
      }

      // Still checking if user has prevalidated elections - stay on splash
      if (isCheckingPrevalidation) {
        if (currentPath == Routes.splash) {
          return null;
        }
        return Routes.splash;
      }

      // Default: authenticated user without election loaded
      // - If prevalidated for elections → go to start-voting (skip prevalidation)
      // - If not prevalidated → go to prevalidation screen
      if (currentPath == Routes.splash || currentPath == Routes.phoneInput) {
        if (hasPrevalidatedElections) {
          return Routes.startVoting;
        }
        return Routes.prevalidation;
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
        path: Routes.prevalidation,
        builder: (context, state) => const PrevalidationScreen(),
      ),
      GoRoute(
        path: Routes.startVoting,
        builder: (context, state) => const StartVotingScreen(),
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
      GoRoute(
        path: Routes.voteEnded,
        builder: (context, state) => const VoteEndedScreen(),
      ),
      // Impersonate route - handled by redirect, shows splash while processing
      GoRoute(
        path: Routes.impersonate,
        builder: (context, state) => const SplashScreen(),
      ),
      // Not found route
      GoRoute(
        path: Routes.notFound,
        builder: (context, state) => const NotFoundScreen(),
      ),
    ],
  );
});
