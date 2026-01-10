import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luckyui/luckyui.dart';
import 'package:philadelphia_mansue/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/error_localizer.dart';
import '../../../elections/presentation/providers/election_providers.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_state.dart';
import '../widgets/phone_input_field.dart';
import '../widgets/otp_input_field.dart';

/// Combined phone authentication screen with single-page flow
///
/// This screen handles both phone number input and OTP verification
/// on the same page, toggling between states using [_showCodeSent].
class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  // Debug impersonate controllers (only used in kDebugMode)
  final _debugPhoneController = TextEditingController();
  final _debugTokenController = TextEditingController(
    text: kDebugMode
        ? '5a9130f80f3c5c6aca98feb8a8f4f97d3b67e1c71aff0a575d5f88662e936754d878bb2820af823c3211a8a2a8d21b83766c57aa2707d5dbb7fd588915630d08'
        : '',
  );

  bool _showCodeSent = false;
  bool _isLoading = false;
  String? _errorText;
  String? _debugErrorText;

  @override
  void initState() {
    super.initState();
    // Load election data to display event info on login page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final electionState = ref.read(electionNotifierProvider);
      if (electionState.status == ElectionLoadStatus.initial) {
        ref.read(electionNotifierProvider.notifier).loadOngoingElection();
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _debugPhoneController.dispose();
    _debugTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final election = ref.watch(currentElectionProvider);

    return Scaffold(
      appBar: LuckyAppBar(
        title: AppConstants.appName,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),

              // Header
              LuckyHeading(
                text: l10n.welcome,
              ),
              const SizedBox(height: 8),
              LuckyBody(
                text: _showCodeSent
                    ? l10n.enterVerificationCode
                    : l10n.enterPhoneToVote,
              ),

              // Election Info
              if (election != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        election.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (election.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          election.description,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Phone number input section
              if (!_showCodeSent) ...[
                PhoneInputField(
                  controller: _phoneController,
                  errorText: _errorText,
                  onSubmit: _onSendCode,
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : LuckyButton(
                        text: l10n.sendCode,
                        onTap: _onSendCode,
                      ),
              ],

              // OTP verification section
              if (_showCodeSent) ...[
                // Success message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 24,
                            color: Color(0xFF4CAF50),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.codeSent,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4CAF50),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.enterCodeSentTo('+39${_phoneController.text}'),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // OTP Input
                OtpInputField(
                  controller: _otpController,
                  errorText: _errorText,
                  onComplete: _onVerifyCode,
                ),

                const SizedBox(height: 16),

                // Resend button
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : _onSendCode,
                    child: Text(l10n.didntReceiveCode),
                  ),
                ),

                const SizedBox(height: 24),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : LuckyButton(
                        text: l10n.verify,
                        onTap: _onVerifyCode,
                      ),

                const SizedBox(height: 16),

                // Change number button
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Just update local UI state - no need to reset auth provider
                      // This avoids router refresh race conditions
                      setState(() {
                        _showCodeSent = false;
                        _otpController.clear();
                        _errorText = null;
                        _isLoading = false;
                      });
                    },
                    child: Text(l10n.changePhoneNumber),
                  ),
                ),
              ],

              // Debug impersonate section (only in debug mode)
              if (kDebugMode) ...[
                const SizedBox(height: 48),
                const Divider(),
                const SizedBox(height: 16),
                const LuckyBody(text: 'DEBUG: Impersonate Login'),
                const SizedBox(height: 16),
                TextField(
                  controller: _debugPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone (without +39)',
                    hintText: '3331234567',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _debugTokenController,
                  decoration: const InputDecoration(
                    labelText: 'Magic Token',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_debugErrorText != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _debugErrorText!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 16),
                LuckyButton(
                  text: 'DEBUG: Impersonate',
                  onTap: _isLoading ? () {} : () => _onDebugImpersonate(),
                ),
              ],

            ],
          ),
        ),
      ),
    );
  }

  /// Sends verification code to the phone number
  Future<void> _onSendCode() async {
    final l10n = AppLocalizations.of(context)!;
    final rawPhone = _phoneController.text.trim();
    // Prepend Italy country code
    final phone = '+39$rawPhone';
    debugPrint('[PhoneAuthScreen] _onSendCode called with: $phone');

    if (rawPhone.isEmpty) {
      setState(() => _errorText = l10n.pleaseEnterPhoneNumber);
      return;
    }

    if (rawPhone.length < 9) {
      setState(() => _errorText = l10n.pleaseEnterValidPhoneNumber);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      debugPrint('[PhoneAuthScreen] Calling authNotifierProvider.sendOtp...');
      await ref.read(authNotifierProvider.notifier).sendOtp(phone);

      final state = ref.read(authNotifierProvider);
      debugPrint('[PhoneAuthScreen] After sendOtp, state.status: ${state.status}');
      debugPrint('[PhoneAuthScreen] state.errorMessage: ${state.errorMessage}');

      if (!mounted) return;

      if (state.status == AuthStatus.otpSent) {
        debugPrint('[PhoneAuthScreen] OTP sent successfully, showing OTP input');
        setState(() {
          _showCodeSent = true;
          _isLoading = false;
        });
      } else if (state.status == AuthStatus.error) {
        debugPrint('[PhoneAuthScreen] Error state detected, errorMessage: ${state.errorMessage}');
        setState(() {
          _isLoading = false;
          _errorText = ErrorLocalizer.localize(state.errorMessage, l10n);
        });
      } else {
        debugPrint('[PhoneAuthScreen] Unknown state: ${state.status}');
        setState(() => _isLoading = false);
      }
    } catch (e, stackTrace) {
      debugPrint('[PhoneAuthScreen] EXCEPTION caught: $e');
      debugPrint('[PhoneAuthScreen] Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = l10n.authError;
      });
    }
  }

  /// Verifies the OTP code
  Future<void> _onVerifyCode() async {
    final l10n = AppLocalizations.of(context)!;
    final code = _otpController.text.trim();

    if (code.length != 6) {
      setState(() => _errorText = l10n.pleaseEnterCode);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await ref.read(authNotifierProvider.notifier).verifyOtp(code);

      final state = ref.read(authNotifierProvider);

      if (!mounted) return;

      if (state.status == AuthStatus.error) {
        setState(() {
          _isLoading = false;
          _errorText = ErrorLocalizer.localize(state.errorMessage, l10n);
        });
      }
      // Navigation happens via ref.listen above
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = ErrorLocalizer.localize(e.toString(), l10n);
      });
    }
  }

  /// Debug-only impersonate login (bypasses OTP flow)
  Future<void> _onDebugImpersonate() async {
    final phone = _debugPhoneController.text.trim();
    final token = _debugTokenController.text.trim();

    if (phone.isEmpty || token.isEmpty) {
      setState(() => _debugErrorText = 'Phone and token required');
      return;
    }

    setState(() {
      _isLoading = true;
      _debugErrorText = null;
    });

    try {
      await ref.read(authNotifierProvider.notifier).debugImpersonate(phone, token);

      final state = ref.read(authNotifierProvider);

      if (!mounted) return;

      if (state.status == AuthStatus.authenticated) {
        _debugPhoneController.clear();
        setState(() => _isLoading = false);
        // Navigation happens automatically via router
      } else if (state.status == AuthStatus.error) {
        setState(() {
          _isLoading = false;
          _debugErrorText = state.errorMessage;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _debugErrorText = e.toString();
      });
    }
  }
}
