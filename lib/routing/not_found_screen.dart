import 'package:flutter/material.dart';
import 'package:luckyui/luckyui.dart';
import '../core/constants/app_constants.dart';
import '../l10n/app_localizations.dart';

/// Screen shown when no election_id is provided in the URL.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                Icons.link_off,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.electionIdRequired,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Please use a valid election link to access the voting system.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
