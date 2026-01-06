// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Reads Firebase App Check info from session storage
Map<String, dynamic> readFirebaseAppCheckInfoFromSessionStorage() {
  final recaptchaType =
      web.window.sessionStorage.getItem('FlutterFire-[DEFAULT]-recaptchaType');
  final recaptchaSiteKey =
      web.window.sessionStorage.getItem('FlutterFire-[DEFAULT]-recaptchaSiteKey');
  return {
    'recaptchaType': recaptchaType,
    'recaptchaSiteKey': recaptchaSiteKey,
  };
}

/// Writes Firebase App Check reCAPTCHA info to session storage.
/// This fixes a race condition where Firebase SDK doesn't inject the site key
/// fast enough, causing invalid-app-credential errors.
/// See: https://github.com/firebase/flutterfire/issues/11828
void writeFirebaseAppCheckInfoToSessionStorage(String siteKey) {
  try {
    // Always overwrite to ensure fresh values on page refresh
    // Stale tokens cause "invalid-app-credential" errors
    // Use 'recaptcha-v3' (NOT 'enterprise') - same as waveful_app
    web.window.sessionStorage.setItem(
      'FlutterFire-[DEFAULT]-recaptchaType',
      'recaptcha-v3',
    );
    web.window.sessionStorage.setItem(
      'FlutterFire-[DEFAULT]-recaptchaSiteKey',
      siteKey,
    );
    if (kDebugMode) {
      print('Firebase App Check info written to session storage');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error writing Firebase App Check info to session storage: $e');
    }
  }
}
