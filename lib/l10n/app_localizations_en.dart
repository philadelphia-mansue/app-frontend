// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Philadelphia Mansue';

  @override
  String get anonymousLabel => 'Anonymous';

  @override
  String get welcome => 'Welcome';

  @override
  String get enterPhoneToVote => 'Enter your phone number to vote anonymously';

  @override
  String get enterVerificationCode => 'Enter the verification code';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneNumberHint => '+1234567890';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter your phone number';

  @override
  String get pleaseEnterValidPhoneNumber => 'Please enter a valid phone number';

  @override
  String get sendCode => 'Send Code';

  @override
  String get codeSent => 'Code Sent!';

  @override
  String enterCodeSentTo(String phoneNumber) {
    return 'Enter the 6-digit code sent to $phoneNumber';
  }

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get verificationCodeHint => '000000';

  @override
  String get pleaseEnterCode => 'Please enter the 6-digit code';

  @override
  String get didntReceiveCode => 'Didn\'t receive code? Resend';

  @override
  String get verify => 'Verify';

  @override
  String get changePhoneNumber => 'Change phone number';

  @override
  String get skipDevOnly => 'Skip (Dev Only)';

  @override
  String get phoneAlreadyVoted => 'This phone number has already voted.';

  @override
  String get selectCandidates => 'Select Candidates';

  @override
  String get yourVoteIsAnonymous => 'Your vote is anonymous';

  @override
  String get continueButton => 'Continue';

  @override
  String get errorLoadingCandidates => 'Error loading candidates';

  @override
  String get retry => 'Retry';

  @override
  String get confirmYourVote => 'Confirm Your Vote';

  @override
  String get yourSelectedCandidates => 'Your Selected Candidates';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get submitting => 'Submitting...';

  @override
  String get confirmVote => 'Confirm Vote';

  @override
  String get goBack => 'Go Back';

  @override
  String get voteSubmitted => 'Vote Submitted!';

  @override
  String get thankYouForParticipating =>
      'Thank you for participating in this election. Your vote has been recorded successfully.';

  @override
  String get voteAnonymousNotice =>
      'Your vote is anonymous and cannot be traced back to you.';

  @override
  String get close => 'Close';

  @override
  String get thankYou => 'Thank You!';

  @override
  String get successfullyVoted =>
      'You have successfully voted. This session is now complete.';

  @override
  String get ok => 'OK';

  @override
  String get errorSubmittingVote => 'Error submitting vote';

  @override
  String get warning => 'Warning';

  @override
  String get voteIsFinalWarning =>
      'This action cannot be undone. Your vote will be final and you cannot change your selection.';

  @override
  String selectionCounter(int count, int max) {
    return '$count / $max selected';
  }

  @override
  String get ready => 'Ready!';

  @override
  String maxCandidatesSelected(int max) {
    return 'Maximum $max candidates selected!';
  }

  @override
  String maxCandidatesLimit(int max) {
    return 'You can only select $max candidates';
  }

  @override
  String selectionValidationError(int max, int count) {
    return 'Please select exactly $max candidates. You have selected $count.';
  }

  @override
  String get duplicateCandidatesError => 'Duplicate candidates detected';

  @override
  String mustSelectExactCandidates(int count) {
    return 'Must select exactly $count candidates';
  }

  @override
  String get serverError => 'Server error occurred';

  @override
  String get cacheError => 'Cache error occurred';

  @override
  String get networkError => 'Network error occurred';

  @override
  String get validationError => 'Validation error occurred';

  @override
  String get authError => 'Authentication error occurred';

  @override
  String get verificationIdNotFound => 'Verification ID not found';

  @override
  String get phoneNotRegisteredAsVoter =>
      'Phone number not registered as voter';

  @override
  String get invalidFirebaseToken => 'Invalid Firebase token';

  @override
  String get sessionExpired => 'Session expired';

  @override
  String get backendAuthFailed => 'Backend authentication failed';

  @override
  String get validationFailed => 'Validation failed';

  @override
  String get noAuthenticatedUser => 'No authenticated user';

  @override
  String get failedToGetIdToken => 'Failed to get ID token';

  @override
  String get electionNotActive => 'Election is not active';

  @override
  String get invalidCandidateCount => 'Invalid number of candidates selected';

  @override
  String get duplicateCandidatesSelected => 'Duplicate candidates selected';

  @override
  String get noActiveElectionFound => 'No active election found';

  @override
  String get authenticationRequired => 'Authentication required';

  @override
  String get serverErrorTryLater => 'Server error. Please try again later.';

  @override
  String get connectionTimedOut => 'Connection timed out';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get noCandidatesSelected => 'No candidates selected';

  @override
  String get electionIdRequired => 'Election ID is required';

  @override
  String get duplicateCandidatesDetected => 'Duplicate candidates detected';

  @override
  String get reviewVotes => 'Review Votes';

  @override
  String selectMoreCandidatesToProceed(int remaining) {
    return 'Select $remaining more candidate(s) to proceed';
  }

  @override
  String candidatesSelectedProgress(int count, int max) {
    return '$count of $max candidates selected';
  }

  @override
  String selectMoreToContinue(int count) {
    return 'Select $count more to continue';
  }
}
