import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luckyui/luckyui.dart';
import '../core/constants/app_constants.dart';
import '../features/elections/presentation/providers/election_providers.dart';

/// Splash screen shown while checking authentication and loading election data.
/// Also displays error state with retry option if election loading fails.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final electionState = ref.watch(electionNotifierProvider);
    final storedElectionId = ref.watch(urlElectionIdProvider);
    final isError = electionState.status == ElectionLoadStatus.error;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LuckyHeading(text: AppConstants.appName),
              const SizedBox(height: 24),
              if (isError) ...[
                // Error state UI
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                Text(
                  'Failed to Load Election',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  electionState.errorMessage ??
                      'An error occurred while loading the election data.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    // Retry loading election
                    if (storedElectionId != null &&
                        storedElectionId.isNotEmpty) {
                      ref
                          .read(electionNotifierProvider.notifier)
                          .loadElectionById(storedElectionId);
                    } else {
                      ref
                          .read(electionNotifierProvider.notifier)
                          .loadOngoingElection();
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
                const SizedBox(height: 16),
                Text(
                  'If the problem persists, please check your internet connection\nor contact the election administrator.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                // Loading state UI
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
