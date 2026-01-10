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
      final isAuthLoading = authState.status == AuthStatus.initial;
      final isInAuthFlow = authState.status == AuthStatus.loading ||
          authState.status == AuthStatus.otpSent;
      final isElectionLoaded = electionState.status == ElectionLoadStatus.loaded ||
          electionState.status == ElectionLoadStatus.noElection ||
          electionState.status == ElectionLoadStatus.error;
      final hasVoted = ref.read(hasVotedCombinedProvider);
      final currentPath = state.matchedLocation;

      debugPrint('[Router] redirect: path=$currentPath, authStatus=${authState.status}, electionStatus=${electionState.status}, hasVoted=$hasVoted');

      // Load election when authenticated and not yet loaded
      if (isAuthenticated && electionState.status == ElectionLoadStatus.initial) {
        Future.microtask(() {
          ref.read(electionNotifierProvider.notifier).loadOngoingElection();
        });
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
        // Allow login page
        if (currentPath == Routes.phoneInput) return null;
        // Redirect everything else to login
        return Routes.phoneInput;
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
    ],
  );
});
