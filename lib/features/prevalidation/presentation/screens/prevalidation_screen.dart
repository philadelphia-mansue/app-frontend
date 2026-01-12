import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luckyui/luckyui.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:philadelphia_mansue/l10n/app_localizations.dart';
import 'package:philadelphia_mansue/routing/routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class PrevalidationScreen extends ConsumerWidget {
  const PrevalidationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final voter = ref.watch(currentVoterProvider);
    final qrData = voter?.qrCode ?? voter?.id ?? '';
    final voterName = voter?.fullName ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.prevalidation),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
            tooltip: l10n.logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // QR Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 250,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  ),
                ),
                const SizedBox(height: 32),

                // Voter Name
                LuckyHeading(
                  text: voterName,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Instructions
                LuckyBody(
                  text: l10n.prevalidationInstructions,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: LuckyButton(
                    text: l10n.continueToVoting,
                    onTap: () => context.go(Routes.startVoting),
                    height: 56,
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
