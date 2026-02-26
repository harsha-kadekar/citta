// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionSkip => 'Pular';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionDelete => 'Excluir';

  @override
  String get actionAdd => 'Adicionar';

  @override
  String get actionBegin => 'Começar';

  @override
  String get navDhyana => 'Dhyana';

  @override
  String get navHistory => 'Histórico';

  @override
  String get navStats => 'Estatísticas';

  @override
  String get navSettings => 'Configurações';

  @override
  String get splashGreeting => 'Namaskara';

  @override
  String splashGreetingWithName(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get splashTapToBegin => 'Toque para começar';

  @override
  String get welcomeTitle => 'Bem-vindo ao Citta';

  @override
  String get welcomeNameHint => 'Digite seu nome';

  @override
  String get homeBegin => 'Começar';

  @override
  String get homeCountdown => 'Contagem regressiva';

  @override
  String get homeStopwatch => 'Cronômetro';

  @override
  String get homeMin => 'min';

  @override
  String get historyTitle => 'Histórico';

  @override
  String historySelected(int count) {
    return '$count selected';
  }

  @override
  String get historyDeleteTitle => 'Excluir sessões';

  @override
  String historyDeleteConfirm(int count) {
    return 'Delete $count sessions? This cannot be undone.';
  }

  @override
  String get historyFilterAll => 'Tudo';

  @override
  String get historyEmpty => 'Nenhuma sessão ainda';

  @override
  String get historyEmptyHint =>
      'Complete sua primeira sessão de dhyana\npara vê-la aqui';

  @override
  String get statsTitle => 'Estatísticas';

  @override
  String get statsToggleCalendar => 'Alternar calendário';

  @override
  String get statsCurrentStreak => 'Sequência atual';

  @override
  String get statsLongestStreak => 'Maior sequência';

  @override
  String get statsTotalSessions => 'Total de sessões';

  @override
  String get statsAverage => 'Média';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dias',
      one: 'dia',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsProfile => 'Perfil';

  @override
  String get settingsName => 'Nome';

  @override
  String get settingsNameNotSet => 'Não definido';

  @override
  String get settingsEditName => 'Editar nome';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Padrão do sistema';

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
  String get settingsCountdown => 'Contagem regressiva';

  @override
  String get settingsCountdownDesc => 'Set a duration, timer counts down';

  @override
  String get settingsStopwatch => 'Cronômetro';

  @override
  String get settingsStopwatchDesc => 'Open-ended, stop manually';

  @override
  String get settingsBellSounds => 'Sons de sino';

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
  String get settingsOff => 'Desligado';

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
  String get settingsData => 'Dados';

  @override
  String get settingsExport => 'Exportar dados';

  @override
  String get settingsExportDesc => 'Share your sessions & config as JSON';

  @override
  String get settingsImport => 'Importar dados';

  @override
  String get settingsImportDesc => 'Load from a Citta JSON export file';

  @override
  String get settingsImportReplaceMsg =>
      'Replace all existing data, or merge with current data?';

  @override
  String get settingsMerge => 'Mesclar';

  @override
  String get settingsReplaceAll => 'Substituir tudo';

  @override
  String get settingsImportSuccess => 'Dados importados com sucesso';

  @override
  String get settingsImportError => 'Arquivo inválido';

  @override
  String settingsExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get notesTitle => 'Notas da sessão';

  @override
  String get notesPrompt => 'Como foi sua prática?';

  @override
  String get notesHint => 'Escreva sobre sua experiência...';

  @override
  String notesWordCount(int count) {
    return '$count / 500 words';
  }

  @override
  String get notesTags => 'Tags';

  @override
  String get sessionComplete => 'Sessão concluída';

  @override
  String get sessionTitle => 'Sessão';

  @override
  String get sessionCountdown => 'Countdown';

  @override
  String get sessionStopwatch => 'Stopwatch';

  @override
  String get sessionCompleted => 'Concluído';

  @override
  String get sessionNotes => 'Notas';

  @override
  String get sessionNoNotes => 'Nenhuma nota para esta sessão';

  @override
  String get addQuoteTitle => 'Adicionar citação';

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
  String get langEnglish => 'Inglês';

  @override
  String get langHindi => 'Hindi';

  @override
  String get langKannada => 'Canarês';

  @override
  String get langSanskrit => 'Sânscrito';

  @override
  String get langTelugu => 'Telugu';

  @override
  String get langTamil => 'Tâmil';

  @override
  String get langMalayalam => 'Malaiala';

  @override
  String get langFrench => 'Francês';

  @override
  String get langGerman => 'Alemão';

  @override
  String get langJapanese => 'Japonês';

  @override
  String get langHebrew => 'Hebraico';

  @override
  String get langChinese => 'Chinês';

  @override
  String get langMarathi => 'Marata';

  @override
  String get langGujarati => 'Gujarati';

  @override
  String get langOdia => 'Odia';

  @override
  String get langBengali => 'Bengali';

  @override
  String get langTulu => 'Tulu';

  @override
  String get langKonkani => 'Concani';

  @override
  String get langUrdu => 'Urdu';

  @override
  String get langItalian => 'Italiano';

  @override
  String get langSpanish => 'Espanhol';

  @override
  String get langArabic => 'Árabe';

  @override
  String get langRussian => 'Russo';

  @override
  String get langPortuguese => 'Português';

  @override
  String get langMaithili => 'Maithili';

  @override
  String get langAssamese => 'Assamese';

  @override
  String get langPunjabi => 'Punjabi';

  @override
  String get langOther => 'Outro';

  @override
  String get preSessionSetup => 'Configurar sessão';

  @override
  String get timerPaused => 'EM PAUSA';
}
