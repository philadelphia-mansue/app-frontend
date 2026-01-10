import 'package:philadelphia_mansue/l10n/app_localizations.dart';

/// Helper class to map error messages to localized versions.
///
/// Since error messages originate from data sources and domain layer
/// which don't have access to BuildContext, this helper maps known
/// error messages to their localized equivalents in the presentation layer.
class ErrorLocalizer {
  /// Maps an error message to its localized version.
  /// If no mapping is found, returns the original message.
  static String localize(String? errorMessage, AppLocalizations l10n) {
    if (errorMessage == null) return l10n.unknownError;

    final lowerMessage = errorMessage.toLowerCase();

    // Already voted errors
    if (lowerMessage.contains('already voted') ||
        lowerMessage.contains('has already voted')) {
      return l10n.phoneAlreadyVoted;
    }

    // Phone/verification errors
    if (lowerMessage.contains('verification id not found')) {
      return l10n.verificationIdNotFound;
    }
    if (lowerMessage.contains('invalid phone') ||
        lowerMessage.contains('phone number format')) {
      return l10n.invalidPhoneFormat;
    }
    if (lowerMessage.contains('too many attempts')) {
      return l10n.tooManyAttempts;
    }
    if (lowerMessage.contains('sms quota')) {
      return l10n.smsQuotaExceeded;
    }
    if (lowerMessage.contains('verification') &&
        lowerMessage.contains('expired')) {
      return l10n.verificationExpired;
    }
    if (lowerMessage.contains('invalid') &&
        (lowerMessage.contains('otp') || lowerMessage.contains('code'))) {
      return l10n.invalidOtp;
    }

    // Authentication errors
    if (lowerMessage.contains('not registered as voter')) {
      return l10n.phoneNotRegisteredAsVoter;
    }
    if (lowerMessage.contains('invalid firebase token')) {
      return l10n.invalidFirebaseToken;
    }
    if (lowerMessage.contains('session expired')) {
      return l10n.sessionExpired;
    }
    if (lowerMessage.contains('backend auth') &&
        lowerMessage.contains('failed')) {
      return l10n.backendAuthFailed;
    }
    if (lowerMessage.contains('no authenticated user')) {
      return l10n.noAuthenticatedUser;
    }
    if (lowerMessage.contains('failed to get id token')) {
      return l10n.failedToGetIdToken;
    }
    if (lowerMessage.contains('failed to sign in')) {
      return l10n.failedToSignIn;
    }
    if (lowerMessage.contains('authentication required')) {
      return l10n.authenticationRequired;
    }
    if (lowerMessage.contains('authentication error')) {
      return l10n.authError;
    }
    if (lowerMessage.contains('access denied')) {
      return l10n.accessDenied;
    }

    // Election errors
    if (lowerMessage.contains('no active election')) {
      return l10n.noActiveElectionFound;
    }
    if (lowerMessage.contains('election') &&
        lowerMessage.contains('not active')) {
      return l10n.electionNotActive;
    }
    if (lowerMessage.contains('election id') &&
        lowerMessage.contains('required')) {
      return l10n.electionIdRequired;
    }

    // Candidate/voting errors
    if (lowerMessage.contains('no candidates selected')) {
      return l10n.noCandidatesSelected;
    }
    if (lowerMessage.contains('duplicate candidates')) {
      return l10n.duplicateCandidatesDetected;
    }
    if (lowerMessage.contains('invalid') &&
        lowerMessage.contains('candidate')) {
      return l10n.invalidCandidateCount;
    }

    // Network/server errors
    if (lowerMessage.contains('connection timed out') ||
        lowerMessage.contains('timeout')) {
      return l10n.connectionTimedOut;
    }
    if (lowerMessage.contains('no internet') ||
        lowerMessage.contains('network error')) {
      return l10n.noInternetConnection;
    }
    if (lowerMessage.contains('server error')) {
      return l10n.serverErrorTryLater;
    }
    if (lowerMessage.contains('validation failed') ||
        lowerMessage.contains('validation error')) {
      return l10n.validationFailed;
    }

    // Generic errors
    if (lowerMessage.contains('request failed')) {
      return l10n.requestFailed;
    }
    if (lowerMessage.contains('unexpected response')) {
      return l10n.unexpectedResponse;
    }

    // If no match found, return original message
    // This allows server messages to pass through while known errors are localized
    return errorMessage;
  }
}
