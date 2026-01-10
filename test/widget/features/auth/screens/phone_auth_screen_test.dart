import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luckyui/luckyui.dart';
import 'package:philadelphia_mansue/features/auth/presentation/screens/phone_auth_screen.dart';
import 'package:philadelphia_mansue/features/auth/presentation/providers/auth_providers.dart';
import 'package:philadelphia_mansue/features/auth/presentation/providers/auth_state.dart';
import 'package:philadelphia_mansue/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:philadelphia_mansue/features/auth/presentation/widgets/otp_input_field.dart';

import '../../../../helpers/test_wrapper.dart';

void main() {
  group('PhoneAuthScreen', () {
    testWidgets('displays welcome message', (tester) async {
      await tester.pumpWidget(
        wrapScreen(
          const PhoneAuthScreen(),
          overrides: [
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome'), findsOneWidget);
    });

    testWidgets('displays phone input initially', (tester) async {
      await tester.pumpWidget(
        wrapScreen(
          const PhoneAuthScreen(),
          overrides: [
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PhoneInputField), findsOneWidget);
      expect(find.byType(OtpInputField), findsNothing);
    });

    testWidgets('displays "Send Code" button initially', (tester) async {
      await tester.pumpWidget(
        wrapScreen(
          const PhoneAuthScreen(),
          overrides: [
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Send Code'), findsOneWidget);
    });

    testWidgets('displays instruction text for phone input', (tester) async {
      await tester.pumpWidget(
        wrapScreen(
          const PhoneAuthScreen(),
          overrides: [
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enter your phone number to vote anonymously'), findsOneWidget);
    });

    testWidgets('shows error when phone number is empty', (tester) async {
      await tester.pumpWidget(
        wrapScreen(
          const PhoneAuthScreen(),
          overrides: [
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Tap send code without entering phone number
      await tester.tap(find.text('Send Code'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your phone number'), findsOneWidget);
    });

    testWidgets('shows error when phone number is too short', (tester) async {
      await tester.pumpWidget(
        wrapScreen(
          const PhoneAuthScreen(),
          overrides: [
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Enter too short phone number
      await tester.enterText(find.byType(TextField), '12345');
      await tester.tap(find.text('Send Code'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid phone number'), findsOneWidget);
    });

    testWidgets('has LuckyAppBar with app name', (tester) async {
      await tester.pumpWidget(
        wrapScreen(
          const PhoneAuthScreen(),
          overrides: [
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LuckyAppBar), findsOneWidget);
      expect(find.text('Philadelphia Mansue'), findsOneWidget);
    });

    testWidgets('uses LuckyButton for send code', (tester) async {
      await tester.pumpWidget(
        wrapScreen(
          const PhoneAuthScreen(),
          overrides: [
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LuckyButton), findsOneWidget);
    });

    testWidgets('uses LuckyHeading for welcome text', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        wrapScreen(
          const PhoneAuthScreen(),
          overrides: [
            authNotifierProvider.overrideWith(
              (ref) => _MockAuthNotifier(const AuthState()),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // LuckyUI components (LuckyHeading) may throw overflow exceptions in test
      // environments due to layout constraints. We intentionally consume these
      // to prevent non-critical rendering issues from failing the test.
      // If an exception occurs, verify it's the expected overflow type.
      final exception = tester.takeException();
      if (exception != null) {
        expect(
          exception.toString(),
          contains('overflow'),
          reason: 'Unexpected exception type: $exception',
        );
      }

      expect(find.byType(LuckyHeading), findsWidgets);
    });
  });
}

// Mock auth notifier for testing
class _MockAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  _MockAuthNotifier(super.state);

  @override
  String? get phoneNumber => null;

  @override
  Future<void> sendOtp(String phoneNumber) async {}

  @override
  Future<void> verifyOtp(String code) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> checkAuthStatus() async {}

  @override
  void handleFirebaseSignOut() {}

  @override
  Future<void> debugImpersonate(String phone, String magicToken) async {}

  @override
  void reset() {}

  @override
  void setImpersonating() {}

  @override
  void markPendingImpersonation() {}

  @override
  Future<void> tryRestoreSession(String userId) async {}
}
