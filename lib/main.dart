import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/env/env.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/utils/appcheck.dart'
    if (dart.library.html) 'core/utils/web_appcheck.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use path URL strategy (no # in URLs)
  usePathUrlStrategy();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Fix for web: inject reCAPTCHA site key into session storage before App Check
  // This fixes a race condition where Firebase SDK doesn't inject it fast enough
  // See: https://github.com/firebase/flutterfire/issues/11828
  if (kIsWeb) {
    writeFirebaseAppCheckInfoToSessionStorage(Env.recaptchaSiteKey);
  }

  // Initialize App Check
  // Use ReCaptchaV3Provider (NOT Enterprise) - same as waveful_app
  try {
    await FirebaseAppCheck.instance.activate(
      providerWeb: ReCaptchaV3Provider(Env.recaptchaSiteKey),
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode
          ? const AppleDebugProvider()
          : const AppleAppAttestProvider(),
    );
    debugPrint('App Check activated (debug: $kDebugMode)');
  } catch (e) {
    debugPrint('App Check error: $e');
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://35a18f7217d0618533065662f97468e1@o4510687619514368.ingest.de.sentry.io/4510687625347152';
      // Adds request headers and IP for users, for more info visit:
      // https://docs.sentry.io/platforms/dart/guides/flutter/data-management/data-collected/
      options.sendDefaultPii = true;
      options.enableLogs = true;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
      // Configure Session Replay
      options.replay.sessionSampleRate = 0.1;
      options.replay.onErrorSampleRate = 1.0;
    },
    appRunner: () => runApp(SentryWidget(child: 
    const ProviderScope(
      child: App(),
    ),
  )),
  );
  // TODO: Remove this line after sending the first sample event to sentry.
  await Sentry.captureException(StateError('This is a sample exception.'));
}
