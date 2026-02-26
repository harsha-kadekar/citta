// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionSkip => 'Omitir';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionAdd => 'Agregar';

  @override
  String get actionBegin => 'Comenzar';

  @override
  String get navDhyana => 'Dhyana';

  @override
  String get navHistory => 'Historial';

  @override
  String get navStats => 'Estadísticas';

  @override
  String get navSettings => 'Configuración';

  @override
  String get splashGreeting => 'Namaskara';

  @override
  String splashGreetingWithName(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get splashTapToBegin => 'Toca para comenzar';

  @override
  String get welcomeTitle => 'Bienvenido a Citta';

  @override
  String get welcomeNameHint => 'Ingresa tu nombre';

  @override
  String get homeBegin => 'Comenzar';

  @override
  String get homeCountdown => 'Cuenta regresiva';

  @override
  String get homeStopwatch => 'Cronómetro';

  @override
  String get homeMin => 'min';

  @override
  String get historyTitle => 'Historial';

  @override
  String historySelected(int count) {
    return '$count selected';
  }

  @override
  String get historyDeleteTitle => 'Eliminar sesiones';

  @override
  String historyDeleteConfirm(int count) {
    return 'Delete $count sessions? This cannot be undone.';
  }

  @override
  String get historyFilterAll => 'Todo';

  @override
  String get historyEmpty => 'Aún no hay sesiones';

  @override
  String get historyEmptyHint =>
      'Completa tu primera sesión de dhyana\npara verla aquí';

  @override
  String get statsTitle => 'Estadísticas';

  @override
  String get statsToggleCalendar => 'Alternar calendario';

  @override
  String get statsCurrentStreak => 'Racha actual';

  @override
  String get statsLongestStreak => 'Racha más larga';

  @override
  String get statsTotalSessions => 'Sesiones totales';

  @override
  String get statsAverage => 'Promedio';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'días',
      one: 'día',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsProfile => 'Perfil';

  @override
  String get settingsName => 'Nombre';

  @override
  String get settingsNameNotSet => 'No establecido';

  @override
  String get settingsEditName => 'Editar nombre';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Predeterminado del sistema';

  @override
  String get settingsTimer => 'Temporizador';

  @override
  String get settingsDefaultMode => 'Default Mode';

  @override
  String get settingsDefaultDuration => 'Default Duration';

  @override
  String settingsDurationMinutes(int count) {
    return '$count minutes';
  }

  @override
  String get settingsCountdown => 'Cuenta regresiva';

  @override
  String get settingsCountdownDesc => 'Set a duration, timer counts down';

  @override
  String get settingsStopwatch => 'Cronómetro';

  @override
  String get settingsStopwatchDesc => 'Open-ended, stop manually';

  @override
  String get settingsBellSounds => 'Sonidos de campana';

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
  String get settingsOff => 'Apagado';

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
  String get settingsData => 'Datos';

  @override
  String get settingsExport => 'Exportar datos';

  @override
  String get settingsExportDesc => 'Share your sessions & config as JSON';

  @override
  String get settingsImport => 'Importar datos';

  @override
  String get settingsImportDesc => 'Load from a Citta JSON export file';

  @override
  String get settingsImportReplaceMsg =>
      'Replace all existing data, or merge with current data?';

  @override
  String get settingsMerge => 'Fusionar';

  @override
  String get settingsReplaceAll => 'Reemplazar todo';

  @override
  String get settingsImportSuccess => 'Datos importados correctamente';

  @override
  String get settingsImportError => 'Archivo no válido';

  @override
  String settingsExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get notesTitle => 'Notas de sesión';

  @override
  String get notesPrompt => '¿Cómo fue tu práctica?';

  @override
  String get notesHint => 'Escribe sobre tu experiencia...';

  @override
  String notesWordCount(int count) {
    return '$count / 500 words';
  }

  @override
  String get notesTags => 'Tags';

  @override
  String get sessionComplete => 'Sesión completa';

  @override
  String get sessionTitle => 'Sesión';

  @override
  String get sessionCountdown => 'Countdown';

  @override
  String get sessionStopwatch => 'Stopwatch';

  @override
  String get sessionCompleted => 'Completado';

  @override
  String get sessionNotes => 'Notas';

  @override
  String get sessionNoNotes => 'Sin notas para esta sesión';

  @override
  String get addQuoteTitle => 'Agregar cita';

  @override
  String get addQuoteOriginalText => 'Original Text *';

  @override
  String get addQuoteOriginalHint => 'Enter the quote in original script...';

  @override
  String get addQuoteLanguage => 'Idioma';

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
  String get langEnglish => 'Inglés';

  @override
  String get langHindi => 'Hindi';

  @override
  String get langKannada => 'Canarés';

  @override
  String get langSanskrit => 'Sánscrito';

  @override
  String get langTelugu => 'Telugu';

  @override
  String get langTamil => 'Tamil';

  @override
  String get langMalayalam => 'Malayalam';

  @override
  String get langFrench => 'Francés';

  @override
  String get langGerman => 'Alemán';

  @override
  String get langJapanese => 'Japonés';

  @override
  String get langHebrew => 'Hebreo';

  @override
  String get langChinese => 'Chino';

  @override
  String get langMarathi => 'Marathi';

  @override
  String get langGujarati => 'Gujarati';

  @override
  String get langOdia => 'Odia';

  @override
  String get langBengali => 'Bengalí';

  @override
  String get langTulu => 'Tulu';

  @override
  String get langKonkani => 'Konkani';

  @override
  String get langUrdu => 'Urdu';

  @override
  String get langItalian => 'Italiano';

  @override
  String get langSpanish => 'Español';

  @override
  String get langArabic => 'Árabe';

  @override
  String get langRussian => 'Ruso';

  @override
  String get langPortuguese => 'Portugués';

  @override
  String get langMaithili => 'Maithili';

  @override
  String get langAssamese => 'Asamés';

  @override
  String get langPunjabi => 'Punjabi';

  @override
  String get langOther => 'Otro';

  @override
  String get preSessionSetup => 'Configurar sesión';

  @override
  String get timerPaused => 'EN PAUSA';
}
