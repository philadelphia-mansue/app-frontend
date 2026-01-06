import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:philadelphia_mansue/l10n/app_localizations.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback? onSubmit;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.errorText,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        labelText: l10n.phoneNumber,
        hintText: '3XX XXX XXXX',
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🇮🇹', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                '+39',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onSubmitted: (_) => onSubmit?.call(),
    );
  }
}
