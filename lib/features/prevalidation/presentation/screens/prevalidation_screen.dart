import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luckyui/luckyui.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:philadelphia_mansue/l10n/app_localizations.dart';
import 'package:philadelphia_mansue/routing/routes.dart';
import '../../../../core/di/providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../elections/presentation/providers/election_providers.dart';

class PrevalidationScreen extends ConsumerStatefulWidget {
  const PrevalidationScreen({super.key});

  @override
  ConsumerState<PrevalidationScreen> createState() => _PrevalidationScreenState();
}

class _PrevalidationScreenState extends ConsumerState<PrevalidationScreen> {
  bool _isConnecting = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    // Initialize WebSocket connection after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectWebSocket();
    });
  }

  Future<void> _connectWebSocket() async {
    if (_isConnecting) return;

    final voter = ref.read(currentVoterProvider);
    if (voter == null) {
      debugPrint('[PrevalidationScreen] No voter, skipping WebSocket connection');
      return;
    }

    if (!mounted) return;

    setState(() {
      _isConnecting = true;
    });

    try {
      final tokenStorage = ref.read(tokenStorageServiceProvider);
      final token = await tokenStorage.getToken();

      if (token == null) {
        debugPrint('[PrevalidationScreen] No auth token, skipping WebSocket connection');
        if (mounted) {
          setState(() {
            _isConnecting = false;
          });
        }
        return;
      }

      final reverb = ref.read(reverbServiceProvider);

      if (!reverb.isConnected) {
        debugPrint('[PrevalidationScreen] Connecting to Reverb WebSocket...');
        await reverb.connect(token);
        debugPrint('[PrevalidationScreen] Subscribing to voter channel...');
        await reverb.subscribeToVoter(voter.id, token);
      }

      if (mounted) {
        setState(() {
          _isConnecting = false;
          _isConnected = true;
        });
      }
    } catch (e) {
      debugPrint('[PrevalidationScreen] WebSocket connection error: $e');
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _isConnected = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Disconnect WebSocket when leaving the screen
    final reverb = ref.read(reverbServiceProvider);
    reverb.disconnect();
    debugPrint('[PrevalidationScreen] Disconnected WebSocket on dispose');
    super.dispose();
  }

  void _onVoterEnabled() {
    debugPrint('[PrevalidationScreen] Voter enabled, refreshing elections and navigating...');
    // Refresh available elections to get the newly enabled election
    ref.read(availableElectionsNotifierProvider.notifier).loadAll();
    // Navigate to start voting screen
    context.go(Routes.startVoting);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final voter = ref.watch(currentVoterProvider);
    final qrData = voter?.qrCode ?? voter?.id ?? '';
    final voterName = voter?.fullName ?? '';

    // Listen for voter.enabled events
    ref.listen(voterEnabledStreamProvider, (previous, next) {
      next.whenData((event) {
        debugPrint('[PrevalidationScreen] Received voter.enabled event: ${event.voterId}');
        _onVoterEnabled();
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.prevalidation),
        actions: kDebugMode
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    ref.read(authNotifierProvider.notifier).signOut();
                  },
                  tooltip: l10n.logout,
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive QR size: min 50, max 250, leave room for padding
            final qrSize = (constraints.maxWidth - 100).clamp(50.0, 250.0);
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                          size: qrSize,
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
                      const SizedBox(height: 24),

                      // Connection status indicator
                      _buildConnectionStatus(context, l10n),
                      const SizedBox(height: 24),

                      // Continue button (fallback if WebSocket fails)
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    if (_isConnecting) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.connecting,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    if (_isConnected) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.waitingForValidation,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      );
    }

    // Not connected - show nothing (fallback to manual button)
    return const SizedBox.shrink();
  }
}
