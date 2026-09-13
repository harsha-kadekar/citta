// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get actionCancel => 'Annulla';

  @override
  String get actionSave => 'Salva';

  @override
  String get actionSkip => 'Salta';

  @override
  String get actionContinue => 'Continua';

  @override
  String get actionDelete => 'Elimina';

  @override
  String get actionAdd => 'Aggiungi';

  @override
  String get actionBegin => 'Inizia';

  @override
  String get navDhyana => 'Dhyana';

  @override
  String get navHistory => 'Cronologia';

  @override
  String get navStats => 'Statistiche';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get splashGreeting => 'Namaskara';

  @override
  String splashGreetingWithName(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get splashTapToBegin => 'Tocca per iniziare';

  @override
  String get welcomeTitle => 'Benvenuto su Citta';

  @override
  String get welcomeNameHint => 'Inserisci il tuo nome';

  @override
  String get firstTimeSetupSubtitle =>
      'Configuriamo alcune cose prima di iniziare.';

  @override
  String get firstTimeSetupThemeSectionTitle => 'Scegli il tuo tema';

  @override
  String get firstTimeSetupEncryptionAlreadyEnabledNotice =>
      'La crittografia è già attiva per le tue riflessioni.';

  @override
  String get firstTimeSetupContinueButton => 'Inizia';

  @override
  String get homeBegin => 'Inizia';

  @override
  String get homeCountdown => 'Conto alla rovescia';

  @override
  String get homeStopwatch => 'Cronometro';

  @override
  String get homeMin => 'min';

  @override
  String get historyTitle => 'Cronologia';

  @override
  String historySelected(int count) {
    return '$count selected';
  }

  @override
  String get historyDeleteTitle => 'Elimina sessioni';

  @override
  String historyDeleteConfirm(int count) {
    return 'Delete $count sessions? This cannot be undone.';
  }

  @override
  String get historyFilterAll => 'Tutto';

  @override
  String get historyEmpty => 'Nessuna sessione ancora';

  @override
  String get historyEmptyHint =>
      'Completa la tua prima sessione di dhyana\nper vederla qui';

  @override
  String get statsTitle => 'Statistiche';

  @override
  String get statsToggleCalendar => 'Mostra calendario';

  @override
  String get statsCurrentStreak => 'Serie attuale';

  @override
  String get statsLongestStreak => 'Serie più lunga';

  @override
  String get statsTotalSessions => 'Sessioni totali';

  @override
  String get statsAverage => 'Media';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'giorni',
      one: 'giorno',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsProfile => 'Profilo';

  @override
  String get settingsName => 'Nome';

  @override
  String get settingsNameNotSet => 'Non impostato';

  @override
  String get settingsEditName => 'Modifica nome';

  @override
  String get settingsAppearance => 'Aspetto';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeDark => 'Scuro';

  @override
  String get settingsThemeLight => 'Chiaro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsColorPalette => 'Tavolozza colori';

  @override
  String get settingsLanguageSystem => 'Predefinito di sistema';

  @override
  String get settingsTimer => 'Timer';

  @override
  String get settingsDefaultMode => 'Default Mode';

  @override
  String get settingsDefaultDuration => 'Default Duration';

  @override
  String settingsDurationMinutes(int count) {
    return '$count minutes';
  }

  @override
  String get settingsCountdown => 'Conto alla rovescia';

  @override
  String get settingsCountdownDesc => 'Set a duration, timer counts down';

  @override
  String get settingsStopwatch => 'Cronometro';

  @override
  String get settingsStopwatchDesc => 'Open-ended, stop manually';

  @override
  String get settingsBellSounds => 'Suoni campana';

  @override
  String get settingsStartBell => 'Start Bell';

  @override
  String get settingsEndBell => 'End Bell';

  @override
  String get settingsIntervalBell => 'Interval Bell';

  @override
  String get settingsBellNone => 'None';

  @override
  String get settingsPickFromDevice => 'Pick from device...';

  @override
  String get settingsEnableInterval => 'Enable Interval Bell';

  @override
  String settingsIntervalEvery(int count) {
    return 'Every $count min';
  }

  @override
  String get settingsOff => 'Spento';

  @override
  String get settingsIntervalDuration => 'Interval Duration';

  @override
  String get settingsIntervalSound => 'Interval Sound';

  @override
  String get settingsBgMusic => 'Background Music';

  @override
  String get settingsMusicFile => 'Music File';

  @override
  String get settingsMusicSelected => 'Selected';

  @override
  String get settingsMusicNone => 'None';

  @override
  String get settingsRemoveMusic => 'Remove Background Music';

  @override
  String get settingsTags => 'Tags';

  @override
  String get settingsAddTag => '+ Add';

  @override
  String get settingsAddTagTitle => 'Add Tag';

  @override
  String get settingsAddTagHint => 'e.g., focused';

  @override
  String get settingsQuotes => 'Quotes';

  @override
  String get settingsAddCustomQuote => 'Add Custom Quote';

  @override
  String settingsUserQuotes(int count) {
    return '$count user quotes';
  }

  @override
  String get settingsData => 'Dati';

  @override
  String get settingsExport => 'Esporta dati';

  @override
  String get settingsExportDesc => 'Share your sessions & config as JSON';

  @override
  String get settingsImport => 'Importa dati';

  @override
  String get settingsImportDesc => 'Load from a Citta JSON export file';

  @override
  String get settingsImportReplaceMsg =>
      'Replace all existing data, or merge with current data?';

  @override
  String get settingsMerge => 'Unisci';

  @override
  String get settingsReplaceAll => 'Sostituisci tutto';

  @override
  String get settingsImportSuccess => 'Dati importati con successo';

  @override
  String get settingsImportError => 'File non valido';

  @override
  String settingsExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get settingsExportChooseTitle => 'Esporta dati';

  @override
  String get settingsExportChooseMsg =>
      'Esportare come JSON semplice o crittografato?';

  @override
  String get settingsExportChoosePlain => 'JSON semplice';

  @override
  String get settingsExportChooseEncrypted => 'Crittografato';

  @override
  String get settingsImportEncryptedTitle => 'Esportazione crittografata';

  @override
  String get settingsImportEncryptedSubtitle =>
      'Inserisci la password o la chiave di recupero usata per crittografare questa esportazione.';

  @override
  String get settingsImportEncryptedInputLabel =>
      'Password o chiave di recupero';

  @override
  String get settingsImportEncryptedSubmitButton => 'Sblocca';

  @override
  String get settingsImportEncryptedErrorEmpty =>
      'Inserisci la password o la chiave di recupero';

  @override
  String get settingsImportEncryptedErrorWrong =>
      'Password o chiave di recupero errata. Riprova.';

  @override
  String get notesTitle => 'Note sessione';

  @override
  String get notesPrompt => 'Com\'è andata la tua pratica?';

  @override
  String get notesHint => 'Scrivi della tua esperienza...';

  @override
  String notesWordCount(int count) {
    return '$count / 500 words';
  }

  @override
  String get notesTags => 'Tags';

  @override
  String get sessionComplete => 'Sessione completata';

  @override
  String get sessionTitle => 'Sessione';

  @override
  String sessionDateAt(String date, String time) {
    return '$date alle $time';
  }

  @override
  String get sessionCountdown => 'Countdown';

  @override
  String get sessionStopwatch => 'Stopwatch';

  @override
  String get sessionCompleted => 'Completato';

  @override
  String get sessionNotes => 'Note';

  @override
  String get sessionNoNotes => 'Nessuna nota per questa sessione';

  @override
  String get addQuoteTitle => 'Aggiungi citazione';

  @override
  String get addQuoteOriginalText => 'Original Text *';

  @override
  String get addQuoteOriginalHint => 'Enter the quote in original script...';

  @override
  String get addQuoteLanguage => 'Lingua';

  @override
  String get addQuoteTranslation => 'English Translation *';

  @override
  String get addQuoteTranslationHint => 'Enter the English translation...';

  @override
  String get addQuoteSource => 'Source';

  @override
  String get addQuoteSourceHint => 'e.g., Bhagavad Gita';

  @override
  String get addQuoteReference => 'Reference';

  @override
  String get addQuoteReferenceHint => 'e.g., Chapter 2, Verse 47';

  @override
  String get addQuoteSave => 'Save Quote';

  @override
  String get addQuoteAdded => 'Quote added';

  @override
  String get langEnglish => 'Inglese';

  @override
  String get langHindi => 'Hindi';

  @override
  String get langKannada => 'Kannada';

  @override
  String get langSanskrit => 'Sanscrito';

  @override
  String get langTelugu => 'Telugu';

  @override
  String get langTamil => 'Tamil';

  @override
  String get langMalayalam => 'Malayalam';

  @override
  String get langFrench => 'Francese';

  @override
  String get langGerman => 'Tedesco';

  @override
  String get langJapanese => 'Giapponese';

  @override
  String get langHebrew => 'Ebraico';

  @override
  String get langChinese => 'Cinese';

  @override
  String get langMarathi => 'Marathi';

  @override
  String get langGujarati => 'Gujarati';

  @override
  String get langOdia => 'Odia';

  @override
  String get langBengali => 'Bengalese';

  @override
  String get langTulu => 'Tulu';

  @override
  String get langKonkani => 'Konkani';

  @override
  String get langUrdu => 'Urdu';

  @override
  String get langItalian => 'Italiano';

  @override
  String get langSpanish => 'Spagnolo';

  @override
  String get langArabic => 'Arabo';

  @override
  String get langRussian => 'Russo';

  @override
  String get langPortuguese => 'Portoghese';

  @override
  String get langMaithili => 'Maithili';

  @override
  String get langAssamese => 'Assamese';

  @override
  String get langPunjabi => 'Punjabi';

  @override
  String get langOther => 'Altro';

  @override
  String get preSessionSetup => 'Configura sessione';

  @override
  String get timerPaused => 'IN PAUSA';

  @override
  String get encryptionToggleTitle => 'Crittografa le mie riflessioni';

  @override
  String get encryptionToggleSubtitle =>
      'Proteggi le tue sessioni su questo dispositivo con una password';

  @override
  String get encryptionPasswordLabel => 'Password';

  @override
  String get encryptionConfirmPasswordLabel => 'Conferma password';

  @override
  String get encryptionEnableButton => 'Attiva crittografia';

  @override
  String get encryptionErrorEmpty => 'Inserisci una password';

  @override
  String encryptionErrorTooShort(int minLength) {
    return 'La password deve contenere almeno $minLength caratteri';
  }

  @override
  String get encryptionErrorMismatch => 'Le password non corrispondono';

  @override
  String get encryptionErrorGeneric =>
      'Impossibile attivare la crittografia. Riprova.';

  @override
  String get recoveryKeyScreenTitle => 'Salva la tua chiave di recupero';

  @override
  String get recoveryKeyWarning =>
      'Questo è l\'unico modo per recuperare i tuoi dati se dimentichi la password. Se perdi entrambi, i tuoi dati saranno permanentemente irrecuperabili.';

  @override
  String get recoveryKeyCopyButton => 'Copia';

  @override
  String get recoveryKeyShareButton => 'Condividi';

  @override
  String get recoveryKeyAckLabel =>
      'Ho salvato la mia chiave di recupero in un luogo sicuro';

  @override
  String get recoveryKeyContinueButton => 'Continua';

  @override
  String get recoveryKeyErrorGeneric =>
      'Impossibile generare una chiave di recupero. Riprova.';

  @override
  String get unlockTitle => 'Sblocca Citta';

  @override
  String get unlockSubtitle =>
      'Inserisci la tua password o chiave di recupero per accedere alle tue riflessioni.';

  @override
  String get unlockInputLabel => 'Password o chiave di recupero';

  @override
  String get unlockSubmitButton => 'Sblocca';

  @override
  String get unlockErrorEmpty =>
      'Inserisci la tua password o chiave di recupero';

  @override
  String get unlockErrorGeneric =>
      'Password o chiave di recupero errata. Riprova.';

  @override
  String get unlockErrorCorrupted =>
      'Non è stato possibile leggere i tuoi dati crittografati. Potrebbero essere danneggiati.';

  @override
  String get settingsEncryptionTitle => 'Crittografia';

  @override
  String get settingsEncryptionSubtitleEnabled =>
      'Le tue sessioni sono crittografate su questo dispositivo';

  @override
  String get settingsEncryptionSubtitleDisabled =>
      'Proteggi le tue sessioni con una password';

  @override
  String get enableEncryptionScreenTitle => 'Attiva crittografia';

  @override
  String get settingsEncryptionDisableConfirmTitle =>
      'Disattivare la crittografia?';

  @override
  String get settingsEncryptionDisableConfirmMessage =>
      'Le tue sessioni verranno nuovamente memorizzate come testo semplice su questo dispositivo.';

  @override
  String get settingsEncryptionDisableConfirmButton => 'Disattiva';

  @override
  String get settingsEncryptionDisableError =>
      'Impossibile disattivare la crittografia. Riprova.';

  @override
  String get settingsChangePasswordTitle => 'Cambia password';

  @override
  String get settingsChangePasswordSubtitle =>
      'Aggiorna la password che protegge le tue sessioni';

  @override
  String get changePasswordScreenTitle => 'Cambia password';

  @override
  String get changePasswordCurrentLabel => 'Password attuale';

  @override
  String get changePasswordNewLabel => 'Nuova password';

  @override
  String get changePasswordConfirmLabel => 'Conferma nuova password';

  @override
  String get changePasswordSubmitButton => 'Cambia password';

  @override
  String get changePasswordErrorEmpty =>
      'Inserisci la password attuale e quella nuova';

  @override
  String changePasswordErrorTooShort(int minLength) {
    return 'La nuova password deve contenere almeno $minLength caratteri';
  }

  @override
  String get changePasswordErrorMismatch =>
      'Le nuove password non corrispondono';

  @override
  String get changePasswordErrorWrongCurrent =>
      'La password attuale non è corretta';

  @override
  String get changePasswordErrorGeneric =>
      'Impossibile cambiare la password. Riprova.';

  @override
  String get changePasswordSuccess => 'Password cambiata con successo';
}
