import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luckyui/luckyui.dart';
import 'package:philadelphia_mansue/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
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

  bool _showCodeSent = false;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
          _errorText = state.errorMessage ?? l10n.authError;
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
          _errorText = state.errorMessage ?? l10n.authError;
        });
      }
      // Navigation happens via ref.listen above
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = l10n.authError;
      });
    }
  }
}
