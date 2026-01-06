import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  // API Configuration
  @EnviedField(varName: 'API_BASE_URL')
  static final String apiBaseUrl = _Env.apiBaseUrl;

  // reCAPTCHA
  @EnviedField(varName: 'RECAPTCHA_SITE_KEY')
  static final String recaptchaSiteKey = _Env.recaptchaSiteKey;

  // Firebase - Web
  @EnviedField(varName: 'FIREBASE_WEB_API_KEY')
  static final String firebaseWebApiKey = _Env.firebaseWebApiKey;
  @EnviedField(varName: 'FIREBASE_WEB_APP_ID')
  static final String firebaseWebAppId = _Env.firebaseWebAppId;
  @EnviedField(varName: 'FIREBASE_WEB_MEASUREMENT_ID')
  static final String firebaseWebMeasurementId = _Env.firebaseWebMeasurementId;

  // Firebase - Android
  @EnviedField(varName: 'FIREBASE_ANDROID_API_KEY')
  static final String firebaseAndroidApiKey = _Env.firebaseAndroidApiKey;
  @EnviedField(varName: 'FIREBASE_ANDROID_APP_ID')
  static final String firebaseAndroidAppId = _Env.firebaseAndroidAppId;

  // Firebase - iOS
  @EnviedField(varName: 'FIREBASE_IOS_API_KEY')
  static final String firebaseIosApiKey = _Env.firebaseIosApiKey;
  @EnviedField(varName: 'FIREBASE_IOS_APP_ID')
  static final String firebaseIosAppId = _Env.firebaseIosAppId;
  @EnviedField(varName: 'FIREBASE_IOS_BUNDLE_ID')
  static final String firebaseIosBundleId = _Env.firebaseIosBundleId;

  // Firebase - macOS
  @EnviedField(varName: 'FIREBASE_MACOS_APP_ID')
  static final String firebaseMacosAppId = _Env.firebaseMacosAppId;
  @EnviedField(varName: 'FIREBASE_MACOS_BUNDLE_ID')
  static final String firebaseMacosBundleId = _Env.firebaseMacosBundleId;

  // Firebase - Windows
  @EnviedField(varName: 'FIREBASE_WINDOWS_APP_ID')
  static final String firebaseWindowsAppId = _Env.firebaseWindowsAppId;
  @EnviedField(varName: 'FIREBASE_WINDOWS_MEASUREMENT_ID')
  static final String firebaseWindowsMeasurementId =
      _Env.firebaseWindowsMeasurementId;

  // Firebase - Shared
  @EnviedField(varName: 'FIREBASE_PROJECT_ID')
  static final String firebaseProjectId = _Env.firebaseProjectId;
  @EnviedField(varName: 'FIREBASE_MESSAGING_SENDER_ID')
  static final String firebaseMessagingSenderId =
      _Env.firebaseMessagingSenderId;
  @EnviedField(varName: 'FIREBASE_STORAGE_BUCKET')
  static final String firebaseStorageBucket = _Env.firebaseStorageBucket;
  @EnviedField(varName: 'FIREBASE_AUTH_DOMAIN')
  static final String firebaseAuthDomain = _Env.firebaseAuthDomain;
}
