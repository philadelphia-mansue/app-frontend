import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luckyui/luckyui.dart';
import '../core/constants/app_constants.dart';
import '../features/elections/presentation/providers/election_providers.dart';
import 'routes.dart';

/// Screen shown when election link is missing or invalid.
class NotFoundScreen extends ConsumerWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storedElectionId = ref.watch(urlElectionIdProvider);
    final hasStoredElectionId =
        storedElectionId != null && storedElectionId.isNotEmpty;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LuckyHeading(text: AppConstants.appName),
              const SizedBox(height: 32),
              const Icon(
                Icons.link_off_rounded,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              Text(
                'Invalid Link',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Please use the link from your invitation to access the voting app.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // If we have a stored election ID, offer to go back to login
              if (hasStoredElectionId) ...[
                FilledButton.icon(
                  onPressed: () => context.go(Routes.phoneInput),
                  icon: const Icon(Icons.login),
                  label: const Text('Go to Login'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
