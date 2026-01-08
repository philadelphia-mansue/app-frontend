import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luckyui/luckyui.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: context.luckyColors.n100,
            borderRadius: radiusXl,
            border: Border.all(
              color: errorText != null
                  ? const Color(0xFFEC003F)
                  : context.luckyColors.n200,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            maxLength: 6,
            autofocus: true,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: textXl.toDouble(),
              color: context.luckyColors.onSurface,
              fontWeight: boldFontWeight,
              letterSpacing: 8,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: '------',
              hintStyle: TextStyle(
                color: context.luckyColors.n500,
                letterSpacing: 8,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: spaceMd,
                vertical: spaceMd,
              ),
              counterText: '',
            ),
            onChanged: (value) {
              if (value.length == 6) {
                onComplete?.call();
              }
            },
            onSubmitted: (_) => onComplete?.call(),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: spaceXs),
          LuckySmallBody(
            text: errorText!,
            color: const Color(0xFFEC003F),
          ),
        ],
      ],
    );
  }
}
