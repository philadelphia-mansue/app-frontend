import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ro.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
    Locale('ro'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Philadelphia Mansue'**
  String get appName;

  /// Label shown for anonymous users
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymousLabel;

  /// Welcome greeting
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Instruction for phone number entry
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to vote anonymously'**
  String get enterPhoneToVote;

  /// Instruction for verification code entry
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code'**
  String get enterVerificationCode;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Phone number field hint
  ///
  /// In en, this message translates to:
  /// **'+1234567890'**
  String get phoneNumberHint;

  /// Validation message for empty phone
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhoneNumber;

  /// Validation message for invalid phone
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterValidPhoneNumber;

  /// Button text to send verification code
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// Confirmation that code was sent
  ///
  /// In en, this message translates to:
  /// **'Code Sent!'**
  String get codeSent;

  /// Instruction showing where code was sent
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {phoneNumber}'**
  String enterCodeSentTo(String phoneNumber);

  /// Verification code field label
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// Verification code field hint
  ///
  /// In en, this message translates to:
  /// **'000000'**
  String get verificationCodeHint;

  /// Validation message for empty code
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit code'**
  String get pleaseEnterCode;

  /// Link text to resend code
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive code? Resend'**
  String get didntReceiveCode;

  /// Button text to verify code
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// Link text to change phone number
  ///
  /// In en, this message translates to:
  /// **'Change phone number'**
  String get changePhoneNumber;

  /// Development-only skip button
  ///
  /// In en, this message translates to:
  /// **'Skip (Dev Only)'**
  String get skipDevOnly;

  /// Error message when phone already voted
  ///
  /// In en, this message translates to:
  /// **'This phone number has already voted.'**
  String get phoneAlreadyVoted;

  /// Title for candidate selection screen
  ///
  /// In en, this message translates to:
  /// **'Select Candidates'**
  String get selectCandidates;

  /// Anonymity notice
  ///
  /// In en, this message translates to:
  /// **'Your vote is anonymous'**
  String get yourVoteIsAnonymous;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Error message when candidates fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading candidates'**
  String get errorLoadingCandidates;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Title for confirmation screen
  ///
  /// In en, this message translates to:
  /// **'Confirm Your Vote'**
  String get confirmYourVote;

  /// Section header for selected candidates
  ///
  /// In en, this message translates to:
  /// **'Your Selected Candidates'**
  String get yourSelectedCandidates;

  /// Counter showing number of selections
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// Loading text during submission
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// Button text to confirm vote
  ///
  /// In en, this message translates to:
  /// **'Confirm Vote'**
  String get confirmVote;

  /// Button text to go back
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// Success message title
  ///
  /// In en, this message translates to:
  /// **'Vote Submitted!'**
  String get voteSubmitted;

  /// Success message body
  ///
  /// In en, this message translates to:
  /// **'Thank you for participating in this election. Your vote has been recorded successfully.'**
  String get thankYouForParticipating;

  /// Anonymity confirmation notice
  ///
  /// In en, this message translates to:
  /// **'Your vote is anonymous and cannot be traced back to you.'**
  String get voteAnonymousNotice;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Thank you title
  ///
  /// In en, this message translates to:
  /// **'Thank You!'**
  String get thankYou;

  /// Final success message
  ///
  /// In en, this message translates to:
  /// **'You have successfully voted. This session is now complete.'**
  String get successfullyVoted;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Error message for vote submission failure
  ///
  /// In en, this message translates to:
  /// **'Error submitting vote'**
  String get errorSubmittingVote;

  /// Warning title
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Warning message about vote being final
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Your vote will be final and you cannot change your selection.'**
  String get voteIsFinalWarning;

  /// Counter showing current selection out of maximum
  ///
  /// In en, this message translates to:
  /// **'{count} / {max} selected'**
  String selectionCounter(int count, int max);

  /// Ready state indicator
  ///
  /// In en, this message translates to:
  /// **'Ready!'**
  String get ready;

  /// Message when maximum candidates are selected
  ///
  /// In en, this message translates to:
  /// **'Maximum {max} candidates selected!'**
  String maxCandidatesSelected(int max);

  /// Message explaining the selection limit
  ///
  /// In en, this message translates to:
  /// **'You can only select {max} candidates'**
  String maxCandidatesLimit(int max);

  /// Validation error for incorrect selection count
  ///
  /// In en, this message translates to:
  /// **'Please select exactly {max} candidates. You have selected {count}.'**
  String selectionValidationError(int max, int count);

  /// Error message for duplicate candidate selection
  ///
  /// In en, this message translates to:
  /// **'Duplicate candidates detected'**
  String get duplicateCandidatesError;

  /// Error message for exact selection requirement
  ///
  /// In en, this message translates to:
  /// **'Must select exactly {count} candidates'**
  String mustSelectExactCandidates(int count);

  /// Generic server error message
  ///
  /// In en, this message translates to:
  /// **'Server error occurred'**
  String get serverError;

  /// Cache error message
  ///
  /// In en, this message translates to:
  /// **'Cache error occurred'**
  String get cacheError;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error occurred'**
  String get networkError;

  /// Validation error message
  ///
  /// In en, this message translates to:
  /// **'Validation error occurred'**
  String get validationError;

  /// Authentication error message
  ///
  /// In en, this message translates to:
  /// **'Authentication error occurred'**
  String get authError;

  /// Error message when verification ID is missing
  ///
  /// In en, this message translates to:
  /// **'Verification ID not found'**
  String get verificationIdNotFound;

  /// Error when phone number is not in voter registry
  ///
  /// In en, this message translates to:
  /// **'Phone number not registered as voter'**
  String get phoneNotRegisteredAsVoter;

  /// Error when Firebase token is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid Firebase token'**
  String get invalidFirebaseToken;

  /// Error when user session has expired
  ///
  /// In en, this message translates to:
  /// **'Session expired'**
  String get sessionExpired;

  /// Error when backend authentication fails
  ///
  /// In en, this message translates to:
  /// **'Backend authentication failed'**
  String get backendAuthFailed;

  /// Error when validation fails
  ///
  /// In en, this message translates to:
  /// **'Validation failed'**
  String get validationFailed;

  /// Error when no user is authenticated
  ///
  /// In en, this message translates to:
  /// **'No authenticated user'**
  String get noAuthenticatedUser;

  /// Error when unable to retrieve ID token
  ///
  /// In en, this message translates to:
  /// **'Failed to get ID token'**
  String get failedToGetIdToken;

  /// Error when election is not currently active
  ///
  /// In en, this message translates to:
  /// **'Election is not active'**
  String get electionNotActive;

  /// Error when wrong number of candidates are selected
  ///
  /// In en, this message translates to:
  /// **'Invalid number of candidates selected'**
  String get invalidCandidateCount;

  /// Error when same candidate is selected multiple times
  ///
  /// In en, this message translates to:
  /// **'Duplicate candidates selected'**
  String get duplicateCandidatesSelected;

  /// Error when no active election exists
  ///
  /// In en, this message translates to:
  /// **'No active election found'**
  String get noActiveElectionFound;

  /// Error when authentication is required but missing
  ///
  /// In en, this message translates to:
  /// **'Authentication required'**
  String get authenticationRequired;

  /// Generic server error with retry suggestion
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get serverErrorTryLater;

  /// Error when connection times out
  ///
  /// In en, this message translates to:
  /// **'Connection timed out'**
  String get connectionTimedOut;

  /// Error when there is no internet connectivity
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// Error when no candidates have been selected
  ///
  /// In en, this message translates to:
  /// **'No candidates selected'**
  String get noCandidatesSelected;

  /// Error when election ID is missing
  ///
  /// In en, this message translates to:
  /// **'Election ID is required'**
  String get electionIdRequired;

  /// Error when duplicate candidates are found
  ///
  /// In en, this message translates to:
  /// **'Duplicate candidates detected'**
  String get duplicateCandidatesDetected;

  /// Header for review votes button
  ///
  /// In en, this message translates to:
  /// **'Review Votes'**
  String get reviewVotes;

  /// Helper text showing how many more candidates need to be selected
  ///
  /// In en, this message translates to:
  /// **'Select {remaining} more candidate(s) to proceed'**
  String selectMoreCandidatesToProceed(int remaining);

  /// Progress header showing candidates selected
  ///
  /// In en, this message translates to:
  /// **'{count} of {max} candidates selected'**
  String candidatesSelectedProgress(int count, int max);

  /// Instruction showing how many more candidates to select
  ///
  /// In en, this message translates to:
  /// **'Select {count} more to continue'**
  String selectMoreToContinue(int count);

  /// Error when phone number format is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number format'**
  String get invalidPhoneFormat;

  /// Error when too many verification attempts
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get tooManyAttempts;

  /// Error when SMS quota is exceeded
  ///
  /// In en, this message translates to:
  /// **'SMS quota exceeded. Please try again later.'**
  String get smsQuotaExceeded;

  /// Error when sign in fails
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in'**
  String get failedToSignIn;

  /// Error when verification session expires
  ///
  /// In en, this message translates to:
  /// **'Verification session expired. Please request a new code.'**
  String get verificationExpired;

  /// Error when unable to retrieve voter profile
  ///
  /// In en, this message translates to:
  /// **'Failed to get voter profile'**
  String get failedToGetVoterProfile;

  /// Error when access is denied
  ///
  /// In en, this message translates to:
  /// **'Access denied'**
  String get accessDenied;

  /// Error when server returns unexpected response
  ///
  /// In en, this message translates to:
  /// **'Unexpected response from server'**
  String get unexpectedResponse;

  /// Generic unknown error message
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred'**
  String get unknownError;

  /// Error when a request fails
  ///
  /// In en, this message translates to:
  /// **'Request failed'**
  String get requestFailed;

  /// Error when OTP code is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code'**
  String get invalidOtp;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it', 'ro'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
    case 'ro':
      return AppLocalizationsRo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
