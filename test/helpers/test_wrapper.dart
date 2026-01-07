import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:philadelphia_mansue/l10n/app_localizations.dart';

/// A wrapper widget that provides the necessary context for widget tests.
/// Includes Material theme, localization, and Riverpod ProviderScope.
class TestWrapper extends StatelessWidget {
  final Widget child;
  final List<Override>? overrides;
  final Locale locale;
  final Size screenSize;

  const TestWrapper({
    super.key,
    required this.child,
    this.overrides,
    this.locale = const Locale('en'),
    this.screenSize = const Size(500, 900),
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides ?? [],
      child: MediaQuery(
        data: MediaQueryData(size: screenSize),
        child: MaterialApp(
          home: child,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ro'),
            Locale('it'),
          ],
          locale: locale,
        ),
      ),
    );
  }
}

/// Creates a minimal wrapper for simple widget tests without providers.
Widget wrapWidget(Widget widget, {Locale locale = const Locale('en')}) {
  return TestWrapper(
    locale: locale,
    child: Scaffold(body: widget),
  );
}

/// Creates a wrapper with provider overrides for ConsumerWidget tests.
Widget wrapWidgetWithProviders(
  Widget widget, {
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
  Size screenSize = const Size(500, 900),
}) {
  return TestWrapper(
    overrides: overrides,
    locale: locale,
    screenSize: screenSize,
    child: Scaffold(body: widget),
  );
}

/// Creates a full screen wrapper for screen tests.
Widget wrapScreen(
  Widget screen, {
  List<Override> overrides = const [],
  Locale locale = const Locale('en'),
  Size screenSize = const Size(500, 900),
}) {
  return ProviderScope(
    overrides: overrides,
    child: MediaQuery(
      data: MediaQueryData(size: screenSize),
      child: MaterialApp(
        home: screen,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ro'),
          Locale('it'),
        ],
        locale: locale,
      ),
    ),
  );
}
