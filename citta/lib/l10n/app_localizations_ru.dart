// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionSkip => 'Пропустить';

  @override
  String get actionContinue => 'Продолжить';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionAdd => 'Добавить';

  @override
  String get actionBegin => 'Начать';

  @override
  String get navDhyana => 'Дхьяна';

  @override
  String get navHistory => 'История';

  @override
  String get navStats => 'Статистика';

  @override
  String get navSettings => 'Настройки';

  @override
  String get splashGreeting => 'Намаскара';

  @override
  String splashGreetingWithName(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get splashTapToBegin => 'Нажмите, чтобы начать';

  @override
  String get welcomeTitle => 'Добро пожаловать в Citta';

  @override
  String get welcomeNameHint => 'Введите ваше имя';

  @override
  String get homeBegin => 'Начать';

  @override
  String get homeCountdown => 'Обратный отсчёт';

  @override
  String get homeStopwatch => 'Секундомер';

  @override
  String get homeMin => 'мин';

  @override
  String get historyTitle => 'История';

  @override
  String historySelected(int count) {
    return '$count selected';
  }

  @override
  String get historyDeleteTitle => 'Удалить сессии';

  @override
  String historyDeleteConfirm(int count) {
    return 'Delete $count sessions? This cannot be undone.';
  }

  @override
  String get historyFilterAll => 'Все';

  @override
  String get historyEmpty => 'Сессий пока нет';

  @override
  String get historyEmptyHint =>
      'Завершите первую сессию дхьяны\nчтобы увидеть её здесь';

  @override
  String get statsTitle => 'Статистика';

  @override
  String get statsToggleCalendar => 'Переключить календарь';

  @override
  String get statsCurrentStreak => 'Текущая серия';

  @override
  String get statsLongestStreak => 'Наибольшая серия';

  @override
  String get statsTotalSessions => 'Всего сессий';

  @override
  String get statsAverage => 'Среднее';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'дней',
      one: 'день',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsProfile => 'Профиль';

  @override
  String get settingsName => 'Имя';

  @override
  String get settingsNameNotSet => 'Не задано';

  @override
  String get settingsEditName => 'Изменить имя';

  @override
  String get settingsAppearance => 'Внешний вид';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageSystem => 'По умолчанию';

  @override
  String get settingsTimer => 'Таймер';

  @override
  String get settingsDefaultMode => 'Default Mode';

  @override
  String get settingsDefaultDuration => 'Default Duration';

  @override
  String settingsDurationMinutes(int count) {
    return '$count minutes';
  }

  @override
  String get settingsCountdown => 'Обратный отсчёт';

  @override
  String get settingsCountdownDesc => 'Set a duration, timer counts down';

  @override
  String get settingsStopwatch => 'Секундомер';

  @override
  String get settingsStopwatchDesc => 'Open-ended, stop manually';

  @override
  String get settingsBellSounds => 'Звуки колокола';

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
  String get settingsOff => 'Выкл';

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
  String get settingsData => 'Данные';

  @override
  String get settingsExport => 'Экспорт данных';

  @override
  String get settingsExportDesc => 'Share your sessions & config as JSON';

  @override
  String get settingsImport => 'Импорт данных';

  @override
  String get settingsImportDesc => 'Load from a Citta JSON export file';

  @override
  String get settingsImportReplaceMsg =>
      'Replace all existing data, or merge with current data?';

  @override
  String get settingsMerge => 'Объединить';

  @override
  String get settingsReplaceAll => 'Заменить всё';

  @override
  String get settingsImportSuccess => 'Данные успешно импортированы';

  @override
  String get settingsImportError => 'Недопустимый файл';

  @override
  String settingsExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get notesTitle => 'Заметки сессии';

  @override
  String get notesPrompt => 'Как прошла ваша практика?';

  @override
  String get notesHint => 'Напишите о своём опыте...';

  @override
  String notesWordCount(int count) {
    return '$count / 500 words';
  }

  @override
  String get notesTags => 'Tags';

  @override
  String get sessionComplete => 'Сессия завершена';

  @override
  String get sessionTitle => 'Сессия';

  @override
  String get sessionCountdown => 'Countdown';

  @override
  String get sessionStopwatch => 'Stopwatch';

  @override
  String get sessionCompleted => 'Завершено';

  @override
  String get sessionNotes => 'Заметки';

  @override
  String get sessionNoNotes => 'Нет заметок для этой сессии';

  @override
  String get addQuoteTitle => 'Добавить цитату';

  @override
  String get addQuoteOriginalText => 'Original Text *';

  @override
  String get addQuoteOriginalHint => 'Enter the quote in original script...';

  @override
  String get addQuoteLanguage => 'Язык';

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
  String get langEnglish => 'Английский';

  @override
  String get langHindi => 'Хинди';

  @override
  String get langKannada => 'Каннада';

  @override
  String get langSanskrit => 'Санскрит';

  @override
  String get langTelugu => 'Телугу';

  @override
  String get langTamil => 'Тамильский';

  @override
  String get langMalayalam => 'Малаялам';

  @override
  String get langFrench => 'Французский';

  @override
  String get langGerman => 'Немецкий';

  @override
  String get langJapanese => 'Японский';

  @override
  String get langHebrew => 'Иврит';

  @override
  String get langChinese => 'Китайский';

  @override
  String get langMarathi => 'Маратхи';

  @override
  String get langGujarati => 'Гуджарати';

  @override
  String get langOdia => 'Ория';

  @override
  String get langBengali => 'Бенгальский';

  @override
  String get langTulu => 'Тулу';

  @override
  String get langKonkani => 'Конкани';

  @override
  String get langUrdu => 'Урду';

  @override
  String get langItalian => 'Итальянский';

  @override
  String get langSpanish => 'Испанский';

  @override
  String get langArabic => 'Арабский';

  @override
  String get langRussian => 'Русский';

  @override
  String get langPortuguese => 'Португальский';

  @override
  String get langMaithili => 'Майтхили';

  @override
  String get langAssamese => 'Ассамский';

  @override
  String get langPunjabi => 'Пенджабский';

  @override
  String get langOther => 'Другой';

  @override
  String get preSessionSetup => 'Настройка сессии';

  @override
  String get timerPaused => 'НА ПАУЗЕ';
}
