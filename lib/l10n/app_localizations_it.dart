// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Philadelphia Mansue';

  @override
  String get anonymousLabel => 'Anonimo';

  @override
  String get welcome => 'Benvenuto';

  @override
  String get enterPhoneToVote =>
      'Inserisca il Suo numero di telefono per votare in modo anonimo';

  @override
  String get enterVerificationCode => 'Inserisca il codice di verifica';

  @override
  String get phoneNumber => 'Numero di Telefono';

  @override
  String get phoneNumberHint => '+1234567890';

  @override
  String get pleaseEnterPhoneNumber =>
      'La preghiamo di inserire il Suo numero di telefono';

  @override
  String get pleaseEnterValidPhoneNumber =>
      'La preghiamo di inserire un numero di telefono valido';

  @override
  String get sendCode => 'Invia Codice';

  @override
  String get codeSent => 'Codice Inviato!';

  @override
  String enterCodeSentTo(String phoneNumber) {
    return 'Inserisca il codice a 6 cifre inviato a $phoneNumber';
  }

  @override
  String get verificationCode => 'Codice di Verifica';

  @override
  String get verificationCodeHint => '000000';

  @override
  String get pleaseEnterCode => 'La preghiamo di inserire il codice a 6 cifre';

  @override
  String get didntReceiveCode => 'Non ha ricevuto il codice? Reinvia';

  @override
  String get verify => 'Verifica';

  @override
  String get changePhoneNumber => 'Cambia numero di telefono';

  @override
  String get skipDevOnly => 'Salta (Solo Sviluppo)';

  @override
  String get phoneAlreadyVoted => 'Questo numero di telefono ha già votato.';

  @override
  String get selectCandidates => 'Seleziona Candidati';

  @override
  String get yourVoteIsAnonymous => 'Il Suo voto è anonimo';

  @override
  String get continueButton => 'Continua';

  @override
  String get errorLoadingCandidates => 'Errore nel caricamento dei candidati';

  @override
  String get retry => 'Riprova';

  @override
  String get confirmYourVote => 'Confermi il Suo Voto';

  @override
  String get yourSelectedCandidates => 'I Suoi Candidati Selezionati';

  @override
  String selectedCount(int count) {
    return '$count selezionati';
  }

  @override
  String get submitting => 'Invio in corso...';

  @override
  String get confirmVote => 'Conferma Voto';

  @override
  String get goBack => 'Indietro';

  @override
  String get voteSubmitted => 'Voto Inviato!';

  @override
  String get thankYouForParticipating =>
      'Grazie per aver partecipato a questa elezione. Il Suo voto è stato registrato con successo.';

  @override
  String get voteAnonymousNotice =>
      'Il Suo voto è anonimo e non può essere ricondotto a Lei.';

  @override
  String get close => 'Chiudi';

  @override
  String get thankYou => 'Grazie!';

  @override
  String get successfullyVoted =>
      'Ha votato con successo. Questa sessione è ora completata.';

  @override
  String get ok => 'OK';

  @override
  String get errorSubmittingVote => 'Errore nell\'invio del voto';

  @override
  String get warning => 'Attenzione';

  @override
  String get voteIsFinalWarning =>
      'Questa azione non può essere annullata. Il Suo voto sarà definitivo e non potrà modificare la Sua selezione.';

  @override
  String selectionCounter(int count, int max) {
    return '$count / $max selezionati';
  }

  @override
  String get ready => 'Pronto!';

  @override
  String maxCandidatesSelected(int max) {
    return 'Massimo $max candidati selezionati!';
  }

  @override
  String maxCandidatesLimit(int max) {
    return 'Può selezionare solo $max candidati';
  }

  @override
  String selectionValidationError(int max, int count) {
    return 'Seleziona esattamente $max candidati. Ne ha selezionati $count.';
  }

  @override
  String get duplicateCandidatesError => 'Rilevati candidati duplicati';

  @override
  String mustSelectExactCandidates(int count) {
    return 'Deve selezionare esattamente $count candidati';
  }

  @override
  String get serverError => 'Si è verificato un errore del server';

  @override
  String get cacheError => 'Si è verificato un errore della cache';

  @override
  String get networkError => 'Si è verificato un errore di rete';

  @override
  String get validationError => 'Si è verificato un errore di validazione';

  @override
  String get authError => 'Si è verificato un errore di autenticazione';

  @override
  String get verificationIdNotFound => 'ID di verifica non trovato';

  @override
  String get phoneNotRegisteredAsVoter =>
      'Numero di telefono non registrato come elettore';

  @override
  String get invalidFirebaseToken => 'Token Firebase non valido';

  @override
  String get sessionExpired => 'Sessione scaduta';

  @override
  String get backendAuthFailed => 'Autenticazione del backend fallita';

  @override
  String get validationFailed => 'Validazione fallita';

  @override
  String get noAuthenticatedUser => 'Nessun utente autenticato';

  @override
  String get failedToGetIdToken => 'Impossibile ottenere il token ID';

  @override
  String get electionNotActive => 'L\'elezione non è attiva';

  @override
  String get invalidCandidateCount =>
      'Numero di candidati selezionati non valido';

  @override
  String get duplicateCandidatesSelected => 'Candidati duplicati selezionati';

  @override
  String get noActiveElectionFound => 'Nessuna elezione attiva trovata';

  @override
  String get authenticationRequired => 'Autenticazione richiesta';

  @override
  String get serverErrorTryLater => 'Errore del server. Riprova più tardi.';

  @override
  String get connectionTimedOut => 'Connessione scaduta';

  @override
  String get noInternetConnection => 'Nessuna connessione internet';

  @override
  String get noCandidatesSelected => 'Nessun candidato selezionato';

  @override
  String get electionIdRequired => 'ID elezione richiesto';

  @override
  String get duplicateCandidatesDetected => 'Candidati duplicati rilevati';

  @override
  String get reviewVotes => 'Rivedi Voti';

  @override
  String selectMoreCandidatesToProceed(int remaining) {
    return 'Seleziona ancora $remaining candidato/i per procedere';
  }

  @override
  String candidatesSelectedProgress(int count, int max) {
    return '$count di $max candidati selezionati';
  }

  @override
  String selectMoreToContinue(int count) {
    return 'Seleziona altri $count per continuare';
  }
}
