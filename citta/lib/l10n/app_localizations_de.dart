// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionSkip => 'Überspringen';

  @override
  String get actionContinue => 'Weiter';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionAdd => 'Hinzufügen';

  @override
  String get actionBegin => 'Beginnen';

  @override
  String get navDhyana => 'Dhyana';

  @override
  String get navHistory => 'Verlauf';

  @override
  String get navStats => 'Statistiken';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get splashGreeting => 'Namaskara';

  @override
  String splashGreetingWithName(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get splashTapToBegin => 'tippen um zu beginnen';

  @override
  String get welcomeTitle => 'Willkommen bei Citta';

  @override
  String get welcomeNameHint => 'Geben Sie Ihren Namen ein';

  @override
  String get homeBegin => 'Beginnen';

  @override
  String get homeCountdown => 'Countdown';

  @override
  String get homeStopwatch => 'Stoppuhr';

  @override
  String get homeMin => 'Min';

  @override
  String get historyTitle => 'Verlauf';

  @override
  String historySelected(int count) {
    return '$count ausgewählt';
  }

  @override
  String get historyDeleteTitle => 'Sitzungen löschen';

  @override
  String historyDeleteConfirm(int count) {
    return '$count Sitzung(en) löschen? Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String get historyFilterAll => 'Alle';

  @override
  String get historyEmpty => 'Noch keine Sitzungen';

  @override
  String get historyEmptyHint =>
      'Schließen Sie Ihre erste Dhyana-Sitzung ab\num sie hier zu sehen';

  @override
  String get statsTitle => 'Statistiken';

  @override
  String get statsToggleCalendar => 'Kalenderansicht umschalten';

  @override
  String get statsCurrentStreak => 'Aktuelle Serie';

  @override
  String get statsLongestStreak => 'Längste Serie';

  @override
  String get statsTotalSessions => 'Sitzungen gesamt';

  @override
  String get statsAverage => 'Durchschnitt';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tage',
      one: 'Tag',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get settingsName => 'Name';

  @override
  String get settingsNameNotSet => 'Nicht festgelegt';

  @override
  String get settingsEditName => 'Name bearbeiten';

  @override
  String get settingsAppearance => 'Erscheinungsbild';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSystem => 'Systemsprache';

  @override
  String get settingsTimer => 'Timer';

  @override
  String get settingsDefaultMode => 'Standardmodus';

  @override
  String get settingsDefaultDuration => 'Standarddauer';

  @override
  String settingsDurationMinutes(int count) {
    return '$count Minuten';
  }

  @override
  String get settingsCountdown => 'Countdown';

  @override
  String get settingsCountdownDesc => 'Dauer festlegen, Timer zählt herunter';

  @override
  String get settingsStopwatch => 'Stoppuhr';

  @override
  String get settingsStopwatchDesc => 'Offen, manuell stoppen';

  @override
  String get settingsBellSounds => 'Klingelgeräusche';

  @override
  String get settingsStartBell => 'Startglocke';

  @override
  String get settingsEndBell => 'Endglocke';

  @override
  String get settingsIntervalBell => 'Intervallglocke';

  @override
  String get settingsBellNone => 'Keine';

  @override
  String get settingsPickFromDevice => 'Vom Gerät auswählen...';

  @override
  String get settingsEnableInterval => 'Intervallglocke aktivieren';

  @override
  String settingsIntervalEvery(int count) {
    return 'Alle $count Min';
  }

  @override
  String get settingsOff => 'Aus';

  @override
  String get settingsIntervalDuration => 'Intervalldauer';

  @override
  String get settingsIntervalSound => 'Intervallton';

  @override
  String get settingsBgMusic => 'Hintergrundmusik';

  @override
  String get settingsMusicFile => 'Musikdatei';

  @override
  String get settingsMusicSelected => 'Ausgewählt';

  @override
  String get settingsMusicNone => 'Keine';

  @override
  String get settingsRemoveMusic => 'Hintergrundmusik entfernen';

  @override
  String get settingsTags => 'Tags';

  @override
  String get settingsAddTag => '+ Hinzufügen';

  @override
  String get settingsAddTagTitle => 'Tag hinzufügen';

  @override
  String get settingsAddTagHint => 'z.B., konzentriert';

  @override
  String get settingsQuotes => 'Zitate';

  @override
  String get settingsAddCustomQuote => 'Eigenes Zitat hinzufügen';

  @override
  String settingsUserQuotes(int count) {
    return '$count Benutzerzitat(e)';
  }

  @override
  String get settingsData => 'Daten';

  @override
  String get settingsExport => 'Daten exportieren';

  @override
  String get settingsExportDesc => 'Sitzungen & Konfiguration als JSON teilen';

  @override
  String get settingsImport => 'Daten importieren';

  @override
  String get settingsImportDesc => 'Aus einer Citta JSON-Exportdatei laden';

  @override
  String get settingsImportReplaceMsg =>
      'Alle vorhandenen Daten ersetzen oder mit aktuellen Daten zusammenführen?';

  @override
  String get settingsMerge => 'Zusammenführen';

  @override
  String get settingsReplaceAll => 'Alles ersetzen';

  @override
  String get settingsImportSuccess => 'Daten erfolgreich importiert';

  @override
  String get settingsImportError => 'Ungültige Importdatei';

  @override
  String settingsExportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get notesTitle => 'Sitzungsnotizen';

  @override
  String get notesPrompt => 'Wie war Ihre Übung?';

  @override
  String get notesHint =>
      'Schreiben Sie über Ihre Erfahrung... (Text oder Markdown)';

  @override
  String notesWordCount(int count) {
    return '$count / 500 Wörter';
  }

  @override
  String get notesTags => 'Tags';

  @override
  String get sessionComplete => 'Sitzung abgeschlossen';

  @override
  String get sessionTitle => 'Sitzung';

  @override
  String get sessionCountdown => 'Countdown';

  @override
  String get sessionStopwatch => 'Stoppuhr';

  @override
  String get sessionCompleted => 'Abgeschlossen';

  @override
  String get sessionNotes => 'Notizen';

  @override
  String get sessionNoNotes => 'Keine Notizen für diese Sitzung';

  @override
  String get addQuoteTitle => 'Zitat hinzufügen';

  @override
  String get addQuoteOriginalText => 'Originaltext *';

  @override
  String get addQuoteOriginalHint =>
      'Geben Sie das Zitat im Originalskript ein...';

  @override
  String get addQuoteLanguage => 'Sprache';

  @override
  String get addQuoteTranslation => 'Englische Übersetzung *';

  @override
  String get addQuoteTranslationHint =>
      'Geben Sie die englische Übersetzung ein...';

  @override
  String get addQuoteSource => 'Quelle';

  @override
  String get addQuoteSourceHint => 'z.B., Bhagavad Gita';

  @override
  String get addQuoteReference => 'Referenz';

  @override
  String get addQuoteReferenceHint => 'z.B., Kapitel 2, Vers 47';

  @override
  String get addQuoteSave => 'Zitat speichern';

  @override
  String get addQuoteAdded => 'Zitat hinzugefügt';

  @override
  String get langEnglish => 'Englisch';

  @override
  String get langHindi => 'Hindi';

  @override
  String get langKannada => 'Kannada';

  @override
  String get langSanskrit => 'Sanskrit';

  @override
  String get langTelugu => 'Telugu';

  @override
  String get langTamil => 'Tamil';

  @override
  String get langMalayalam => 'Malayalam';

  @override
  String get langFrench => 'Französisch';

  @override
  String get langGerman => 'Deutsch';

  @override
  String get langJapanese => 'Japanisch';

  @override
  String get langHebrew => 'Hebräisch';

  @override
  String get langChinese => 'Chinesisch';

  @override
  String get langMarathi => 'Marathi';

  @override
  String get langGujarati => 'Gujarati';

  @override
  String get langOdia => 'Odia';

  @override
  String get langBengali => 'Bengalisch';

  @override
  String get langTulu => 'Tulu';

  @override
  String get langKonkani => 'Konkani';

  @override
  String get langUrdu => 'Urdu';

  @override
  String get langItalian => 'Italienisch';

  @override
  String get langSpanish => 'Spanisch';

  @override
  String get langArabic => 'Arabisch';

  @override
  String get langRussian => 'Russisch';

  @override
  String get langPortuguese => 'Portugiesisch';

  @override
  String get langMaithili => 'Maithili';

  @override
  String get langAssamese => 'Assamesisch';

  @override
  String get langPunjabi => 'Punjabi';

  @override
  String get langOther => 'Sonstige';

  @override
  String get preSessionSetup => 'Sitzungseinrichtung';

  @override
  String get timerPaused => 'PAUSIERT';
}
