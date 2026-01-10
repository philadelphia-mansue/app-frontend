import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      // Reset election state and URL election ID when user becomes unauthenticated
      // This ensures fresh election data is loaded for the next user
      if (previous?.status == AuthStatus.authenticated &&
          next.status == AuthStatus.unauthenticated) {
        ref.read(electionNotifierProvider.notifier).reset();
        ref.read(urlElectionIdProvider.notifier).state = null;
      }
      notifyListeners();
    });
    // Listen to election changes
    ref.listen(electionNotifierProvider, (_, _) {
      notifyListeners();
    });
    // Listen to local vote cache changes (for faster redirect after voting)
    ref.listen(localHasVotedProvider, (_, _) {
      notifyListeners();
    });
  }
}

final _routerRefreshProvider = Provider((ref) => RouterRefreshNotifier(ref));

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
      final isElectionLoaded = electionState.status == ElectionLoadStatus.loaded ||
          electionState.status == ElectionLoadStatus.noElection ||
          electionState.status == ElectionLoadStatus.error;
      final hasVoted = ref.read(hasVotedCombinedProvider);
      final currentPath = state.matchedLocation;

      // Extract election_id from URL (only store if election not yet loaded)
      final urlElectionId = state.uri.queryParameters['election_id'];
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
      debugPrint('[Router] redirect: path=$currentPath, authStatus=${authState.status}, electionStatus=${electionState.status}, hasVoted=$hasVoted, electionId=$storedElectionId');

      // Allow not-found page to be shown
      if (currentPath == Routes.notFound) {
        return null;
      }

      // Handle impersonation via query params (works on any route)
      final phone = state.uri.queryParameters['phone'];
      final magicToken = state.uri.queryParameters['magic_token'];
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

      // Load election when authenticated and not yet loaded (or failed previously)
      if (isAuthenticated &&
          (electionState.status == ElectionLoadStatus.initial ||
           electionState.status == ElectionLoadStatus.error)) {
        if (storedElectionId != null && storedElectionId.isNotEmpty) {
          debugPrint('[Router] Loading election by ID: $storedElectionId');
          Future.microtask(() {
            ref.read(electionNotifierProvider.notifier).loadElectionById(storedElectionId);
          });
        } else {
          // No election_id provided - load ongoing election automatically
          debugPrint('[Router] No election_id provided, loading ongoing election');
          Future.microtask(() {
            ref.read(electionNotifierProvider.notifier).loadOngoingElection();
          });
        }
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
        final hasElectionId = (urlElectionId != null && urlElectionId.isNotEmpty) ||
            (storedElectionId != null && storedElectionId.isNotEmpty);

        // Allow login page if we have an election_id
        if (currentPath == Routes.phoneInput) {
          return hasElectionId ? null : Routes.notFound;
        }
        // Redirect to login if we have election_id, otherwise to not-found
        return hasElectionId ? Routes.phoneInput : Routes.notFound;
      }

      // Authenticated but election not loaded yet - stay on/go to splash
      if (!isElectionLoaded) {
        return currentPath == Routes.splash ? null : Routes.splash;
      }

      // Authenticated and election loaded - apply routing rules

      // User has voted - only allow success screen
      if (hasVoted) {
        return currentPath == Routes.success ? null : Routes.success;
      }

      // User hasn't voted - allow candidates, confirmation, but not login or splash
      if (currentPath == Routes.phoneInput || currentPath == Routes.splash) {
        return Routes.candidates;
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
