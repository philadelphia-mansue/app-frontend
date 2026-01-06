import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/env/env.dart';
import 'core/utils/appcheck.dart'
    if (dart.library.html) 'core/utils/web_appcheck.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
