import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:philadelphia_mansue/l10n/app_localizations.dart';

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback? onComplete;

  const OtpInputField({
    super.key,
    required this.controller,
    this.errorText,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        letterSpacing: 16,
        fontWeight: FontWeight.bold,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: InputDecoration(
        labelText: l10n.verificationCode,
        hintText: l10n.verificationCodeHint,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: (value) {
        if (value.length == 6) {
          onComplete?.call();
        }
      },
    );
  }
}
