import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:philadelphia_mansue/features/auth/presentation/widgets/phone_input_field.dart';

import '../../../../helpers/test_wrapper.dart';

void main() {
  group('PhoneInputField', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders with Italian flag and +39 prefix', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          PhoneInputField(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Check for Italian flag emoji
      expect(find.text('🇮🇹'), findsOneWidget);
      // Check for +39 prefix
      expect(find.text('+39'), findsOneWidget);
    });

    testWidgets('displays phone number label', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          PhoneInputField(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Phone Number'), findsOneWidget);
    });

    testWidgets('displays hint text', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          PhoneInputField(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3XX XXX XXXX'), findsOneWidget);
    });

    testWidgets('accepts only digits', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          PhoneInputField(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Enter mixed characters
      await tester.enterText(find.byType(TextField), 'abc123def456');
      await tester.pump();

      // Should only contain digits
      expect(controller.text, '123456');
    });

    testWidgets('limits input to 10 characters', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          PhoneInputField(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Enter more than 10 digits
      await tester.enterText(find.byType(TextField), '12345678901234');
      await tester.pump();

      // Should be truncated to 10 digits
      expect(controller.text.length, 10);
      expect(controller.text, '1234567890');
    });

    testWidgets('displays error text when provided', (tester) async {
      const errorMessage = 'Invalid phone number';

      await tester.pumpWidget(
        wrapWidget(
          PhoneInputField(
            controller: controller,
            errorText: errorMessage,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('calls onSubmit when submitted', (tester) async {
      bool submitted = false;

      await tester.pumpWidget(
        wrapWidget(
          PhoneInputField(
            controller: controller,
            onSubmit: () => submitted = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter text and submit
      await tester.enterText(find.byType(TextField), '3331234567');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submitted, isTrue);
    });

    testWidgets('does not crash when onSubmit is null', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          PhoneInputField(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Submit without callback should not crash
      await tester.enterText(find.byType(TextField), '3331234567');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // No exception means test passed
    });

    testWidgets('has phone keyboard type', (tester) async {
      await tester.pumpWidget(
        wrapWidget(
          PhoneInputField(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, TextInputType.phone);
    });
  });
}
