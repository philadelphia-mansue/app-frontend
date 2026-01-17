// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appName => 'Philadelphia Mansue';

  @override
  String get anonymousLabel => 'Anonim';

  @override
  String get welcome => 'Bine ați venit';

  @override
  String get enterPhoneToVote =>
      'Introduceți numărul de telefon pentru a vota anonim';

  @override
  String get enterVerificationCode => 'Introduceți codul de verificare';

  @override
  String get phoneNumber => 'Număr de telefon';

  @override
  String get phoneNumberHint => '+1234567890';

  @override
  String get pleaseEnterPhoneNumber =>
      'Vă rugăm să introduceți numărul de telefon';

  @override
  String get pleaseEnterValidPhoneNumber =>
      'Vă rugăm să introduceți un număr de telefon valid';

  @override
  String get sendCode => 'Trimite codul';

  @override
  String get codeSent => 'Cod trimis!';

  @override
  String enterCodeSentTo(String phoneNumber) {
    return 'Introduceți codul din 6 cifre trimis la $phoneNumber';
  }

  @override
  String get verificationCode => 'Cod de verificare';

  @override
  String get verificationCodeHint => '000000';

  @override
  String get pleaseEnterCode => 'Vă rugăm să introduceți codul din 6 cifre';

  @override
  String get didntReceiveCode => 'Nu ați primit codul? Retrimite';

  @override
  String get verify => 'Verifică';

  @override
  String get changePhoneNumber => 'Schimbă numărul de telefon';

  @override
  String get skipDevOnly => 'Sări peste (Doar dezvoltare)';

  @override
  String get phoneAlreadyVoted => 'Acest număr de telefon a votat deja.';

  @override
  String get selectCandidates => 'Selectați candidații';

  @override
  String get yourVoteIsAnonymous => 'Votul dumneavoastră este anonim';

  @override
  String get continueButton => 'Continuă';

  @override
  String get errorLoadingCandidates => 'Eroare la încărcarea candidaților';

  @override
  String get retry => 'Reîncearcă';

  @override
  String get confirmYourVote => 'Confirmați votul';

  @override
  String get yourSelectedCandidates => 'Candidații selectați';

  @override
  String selectedCount(int count) {
    return '$count selectați';
  }

  @override
  String get submitting => 'Se trimite...';

  @override
  String get confirmVote => 'Confirmă votul';

  @override
  String get goBack => 'Înapoi';

  @override
  String get voteSubmitted => 'Vot trimis!';

  @override
  String get thankYouForParticipating =>
      'Vă mulțumim pentru participarea la aceste alegeri. Votul dumneavoastră a fost înregistrat cu succes.';

  @override
  String get voteAnonymousNotice =>
      'Votul dumneavoastră este anonim și nu poate fi asociat cu identitatea dumneavoastră.';

  @override
  String get close => 'Închide';

  @override
  String get thankYou => 'Vă mulțumim!';

  @override
  String get successfullyVoted =>
      'Ați votat cu succes. Această sesiune s-a încheiat.';

  @override
  String get ok => 'OK';

  @override
  String get errorSubmittingVote => 'Eroare la trimiterea votului';

  @override
  String get warning => 'Atenție';

  @override
  String get voteIsFinalWarning =>
      'Această acțiune nu poate fi anulată. Votul dumneavoastră va fi definitiv și nu veți putea modifica selecția.';

  @override
  String selectionCounter(int count, int max) {
    return '$count / $max selectați';
  }

  @override
  String get ready => 'Gata!';

  @override
  String maxCandidatesSelected(int max) {
    return 'Maxim $max candidați selectați!';
  }

  @override
  String maxCandidatesLimit(int max) {
    return 'Puteți selecta doar $max candidați';
  }

  @override
  String selectionValidationError(int max, int count) {
    return 'Selectați exact $max candidați. Ați selectat $count.';
  }

  @override
  String get duplicateCandidatesError =>
      'Au fost detectați candidați duplicați';

  @override
  String mustSelectExactCandidates(int count) {
    return 'Trebuie să selectați exact $count candidați';
  }

  @override
  String get serverError => 'A apărut o eroare de server';

  @override
  String get cacheError => 'A apărut o eroare de cache';

  @override
  String get networkError => 'A apărut o eroare de rețea';

  @override
  String get validationError => 'A apărut o eroare de validare';

  @override
  String get authError => 'A apărut o eroare de autentificare';

  @override
  String get verificationIdNotFound => 'ID-ul de verificare nu a fost găsit';

  @override
  String get phoneNotRegisteredAsVoter =>
      'Numărul de telefon nu este înregistrat ca alegător';

  @override
  String get invalidFirebaseToken => 'Token Firebase invalid';

  @override
  String get sessionExpired => 'Sesiune expirată';

  @override
  String get backendAuthFailed => 'Autentificarea backend a eșuat';

  @override
  String get validationFailed => 'Validarea a eșuat';

  @override
  String get noAuthenticatedUser => 'Niciun utilizator autentificat';

  @override
  String get failedToGetIdToken => 'Nu s-a putut obține token-ul ID';

  @override
  String get electionNotActive => 'Alegerile nu sunt active';

  @override
  String get invalidCandidateCount => 'Număr invalid de candidați selectați';

  @override
  String get duplicateCandidatesSelected => 'Candidați duplicați selectați';

  @override
  String get noActiveElectionFound => 'Nu s-au găsit alegeri active';

  @override
  String get authenticationRequired => 'Autentificare necesară';

  @override
  String get serverErrorTryLater =>
      'Eroare de server. Vă rugăm să încercați mai târziu.';

  @override
  String get connectionTimedOut => 'Conexiunea a expirat';

  @override
  String get noInternetConnection => 'Fără conexiune la internet';

  @override
  String get noCandidatesSelected => 'Niciun candidat selectat';

  @override
  String get electionIdRequired => 'ID-ul alegerilor este necesar';

  @override
  String get duplicateCandidatesDetected =>
      'Au fost detectați candidați duplicați';

  @override
  String get reviewVotes => 'Revizuiți Voturile';

  @override
  String selectMoreCandidatesToProceed(int remaining) {
    return 'Selectați încă $remaining candidat(i) pentru a continua';
  }

  @override
  String candidatesSelectedProgress(int count, int max) {
    return '$count din $max candidați selectați';
  }

  @override
  String selectMoreToContinue(int count) {
    return 'Selectați încă $count pentru a continua';
  }

  @override
  String get invalidPhoneFormat => 'Format de număr de telefon invalid';

  @override
  String get tooManyAttempts =>
      'Prea multe încercări. Vă rugăm să încercați mai târziu.';

  @override
  String get smsQuotaExceeded =>
      'Cota de SMS depășită. Vă rugăm să încercați mai târziu.';

  @override
  String get failedToSignIn => 'Autentificarea a eșuat';

  @override
  String get verificationExpired =>
      'Sesiunea de verificare a expirat. Vă rugăm să solicitați un nou cod.';

  @override
  String get failedToGetVoterProfile =>
      'Nu s-a putut obține profilul alegătorului';

  @override
  String get accessDenied => 'Acces refuzat';

  @override
  String get unexpectedResponse => 'Răspuns neașteptat de la server';

  @override
  String get unknownError => 'A apărut o eroare necunoscută';

  @override
  String get requestFailed => 'Cererea a eșuat';

  @override
  String get invalidOtp => 'Cod de verificare invalid';

  @override
  String get appTitle => 'Conferința Europeană';

  @override
  String get logout => 'Deconectare';

  @override
  String welcomeUser(String name) {
    return 'Bine ați venit, $name';
  }

  @override
  String get prevalidation => 'Prevalidare';

  @override
  String get scanToVote => 'Scanează pentru a Vota';

  @override
  String get prevalidationInstructions =>
      'Arătați acest cod QR personalului pentru verificare';

  @override
  String get scanInstructions =>
      'Îndreptați camera spre codul QR al alegerilor';

  @override
  String get invalidQrCode =>
      'Cod QR invalid. Scanați un link electoral valid.';

  @override
  String get electionNotFound => 'Alegerile nu au fost găsite';

  @override
  String get alreadyVotedTitle => 'Ați votat deja';

  @override
  String get alreadyVotedMessage =>
      'Ați votat deja în aceste alegeri. Scanați un alt cod QR electoral.';

  @override
  String get voteAnotherElection => 'Votează la alte alegeri';

  @override
  String get voteNow => 'Votează Acum';

  @override
  String get startVotingInstructions =>
      'Când ești pregătit, apasă butonul de mai jos pentru a începe votarea';

  @override
  String get votingNotActive =>
      'Votarea nu este activă în acest moment. Încearcă din nou mai târziu.';

  @override
  String get noOngoingElection => 'Trebuie să așteptați ca votul să înceapă.';

  @override
  String get continueToVoting => 'Continuă';

  @override
  String get voteEndedTitle => 'Votul s-a încheiat';

  @override
  String get voteEndedMessage =>
      'Mulțumim pentru participare. Votul nu mai este activ.';

  @override
  String get notPrevalidated =>
      'Trebuie să fii prevalidat de staff înainte de a vota.';

  @override
  String get noActiveElections => 'Așteptați ziua alegerilor.';

  @override
  String get phoneNotRegistered => 'Numărul de telefon nu este înregistrat';

  @override
  String get availableElections => 'Alegeri Disponibile';

  @override
  String get completedElections => 'Alegeri Finalizate';

  @override
  String get voted => 'Votat';

  @override
  String get notYetOpen => 'Nu a început încă';

  @override
  String get ended => 'Încheiat';

  @override
  String moreElectionsAvailable(int count) {
    return 'Mai aveți $count alegere/i în care să votați';
  }

  @override
  String get voteNextElection => 'Votează la Următoarele Alegeri';

  @override
  String get doneForNow => 'Am terminat deocamdată';

  @override
  String get done => 'Gata';

  @override
  String get selectAnElection => 'Selectați o alegere pentru a vota';

  @override
  String get backToElections => 'Înapoi la Alegeri';

  @override
  String get failedToLoadElection => 'Nu s-a putut încărca alegerea';

  @override
  String get electionLoadError =>
      'A apărut o eroare la încărcarea datelor alegerilor.';

  @override
  String get persistentErrorHelp =>
      'Dacă problema persistă, verificați conexiunea la internet sau contactați administratorul alegerilor.';

  @override
  String get loading => 'Se încarcă...';

  @override
  String get failedToLoadElections => 'Nu s-au putut încărca alegerile';

  @override
  String get failedToCheckElections =>
      'Nu s-au putut verifica alegerile active';

  @override
  String get countryItaly => 'Italia';

  @override
  String get countryRomania => 'România';
}
