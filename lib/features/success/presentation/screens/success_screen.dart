import 'package:flutter/material.dart';
import 'package:luckyui/luckyui.dart';
import 'package:philadelphia_mansue/l10n/app_localizations.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 32),

                // Success Message
                LuckyHeading(
                  text: l10n.voteSubmitted,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                LuckyBody(
                  text: l10n.thankYouForParticipating,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Anonymous notice
                Text(
                  l10n.voteAnonymousNotice,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
