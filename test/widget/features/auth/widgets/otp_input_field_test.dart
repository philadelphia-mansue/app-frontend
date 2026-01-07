import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:philadelphia_mansue/features/auth/presentation/widgets/otp_input_field.dart';

import '../../../../helpers/test_wrapper.dart';

void main() {
  group('OtpInputField', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders with verification code label', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          OtpInputField(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verification Code'), findsOneWidget);
    });

    testWidgets('displays hint text', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          OtpInputField(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('000000'), findsOneWidget);
    });

    testWidgets('accepts only digits', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          OtpInputField(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Enter mixed characters
      await tester.enterText(find.byType(TextField), 'abc123def');
      await tester.pump();

      // Should only contain digits
      expect(controller.text, '123');
    });

    testWidgets('limits input to 6 characters', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          OtpInputField(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Enter more than 6 digits
      await tester.enterText(find.byType(TextField), '123456789');
      await tester.pump();

      // Should be truncated to 6 digits
      expect(controller.text.length, 6);
      expect(controller.text, '123456');
    });

    testWidgets('displays error text when provided', (tester) async {
      const errorMessage = 'Invalid verification code';

      await tester.pumpWidget(
        wrapWidget(
          OtpInputField(
            controller: controller,
            errorText: errorMessage,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('calls onComplete when 6 digits are entered', (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        wrapWidget(
          OtpInputField(
            controller: controller,
            onComplete: () => completed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter exactly 6 digits
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();

      expect(completed, isTrue);
    });

    testWidgets('does not call onComplete for less than 6 digits', (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        wrapWidget(
          OtpInputField(
            controller: controller,
            onComplete: () => completed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter less than 6 digits
      await tester.enterText(find.byType(TextField), '12345');
      await tester.pump();

      expect(completed, isFalse);
    });

    testWidgets('does not crash when onComplete is null', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          OtpInputField(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Enter 6 digits without callback should not crash
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();

      // No exception means test passed
    });

    testWidgets('has number keyboard type', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          OtpInputField(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, TextInputType.number);
    });

    testWidgets('text is center aligned', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          OtpInputField(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.textAlign, TextAlign.center);
    });

    testWidgets('has bold styling with letter spacing', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          OtpInputField(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.style?.fontWeight, FontWeight.bold);
      expect(textField.style?.letterSpacing, 16);
    });
  });
}
