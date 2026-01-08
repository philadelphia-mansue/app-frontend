import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l10n/app_localizations.dart';
import 'package:luckyui/luckyui.dart';
import 'routing/app_router.dart';
import 'core/constants/app_constants.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Indigo color scheme for government app
    const indigoPrimary = Colors.indigo;
    final indigoLight = Colors.indigo.shade300;
    final indigoMuted = Colors.indigo.shade600;

    // Apply Inter font and indigo colors to the LuckyTheme
    final lightTheme = LuckyTheme.lightTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(LuckyTheme.lightTheme.textTheme),
      extensions: [
        LuckyColors.light.copyWith(
          primaryColor: indigoPrimary,
          primaryColor300: indigoLight,
          primaryColor500: indigoMuted,
        ),
      ],
    );
    final darkTheme = LuckyTheme.darkTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(LuckyTheme.darkTheme.textTheme),
      extensions: [
        LuckyColors.dark.copyWith(
          primaryColor: indigoPrimary,
          primaryColor300: indigoLight,
          primaryColor500: indigoMuted,
        ),
      ],
    );

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ro'),
        Locale('en'),
        Locale('it'),
      ],
      locale: const Locale('ro'),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return Stack(
          children: [
            child!,
            MediaQuery(
              data: mediaQuery.copyWith(
                padding: mediaQuery.padding.copyWith(
                  bottom: mediaQuery.padding.bottom + 80,
                ),
              ),
              child: const LuckyToastMessenger(),
            ),
            const LuckyToastMessenger(type: 'notification'),
          ],
        );
      },
    );
  }
}
