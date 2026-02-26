import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_as.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_kok.dart';
import 'app_localizations_mai.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sa.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_tcy.dart';
import 'app_localizations_te.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_zh.dart';

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
    Locale('ar'),
    Locale('as'),
    Locale('bn'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('gu'),
    Locale('he'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('kn'),
    Locale('kok'),
    Locale('mai'),
    Locale('ml'),
    Locale('mr'),
    Locale('or'),
    Locale('pa'),
    Locale('pt'),
    Locale('ru'),
    Locale('sa'),
    Locale('ta'),
    Locale('tcy'),
    Locale('te'),
    Locale('ur'),
    Locale('zh')
  ];

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionBegin.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get actionBegin;

  /// No description provided for @navDhyana.
  ///
  /// In en, this message translates to:
  /// **'Dhyana'**
  String get navDhyana;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @splashGreeting.
  ///
  /// In en, this message translates to:
  /// **'Namaskara'**
  String get splashGreeting;

  /// No description provided for @splashGreetingWithName.
  ///
  /// In en, this message translates to:
  /// **'Namaskara, {name}'**
  String splashGreetingWithName(String name);

  /// No description provided for @splashTapToBegin.
  ///
  /// In en, this message translates to:
  /// **'tap to begin'**
  String get splashTapToBegin;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Citta'**
  String get welcomeTitle;

  /// No description provided for @welcomeNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get welcomeNameHint;

  /// No description provided for @homeBegin.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get homeBegin;

  /// No description provided for @homeCountdown.
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get homeCountdown;

  /// No description provided for @homeStopwatch.
  ///
  /// In en, this message translates to:
  /// **'Stopwatch'**
  String get homeStopwatch;

  /// No description provided for @homeMin.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get homeMin;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historySelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String historySelected(int count);

  /// No description provided for @historyDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Sessions'**
  String get historyDeleteTitle;

  /// No description provided for @historyDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} sessions? This cannot be undone.'**
  String historyDeleteConfirm(int count);

  /// No description provided for @historyFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get historyFilterAll;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get historyEmpty;

  /// No description provided for @historyEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Complete your first dhyana session\nto see it here'**
  String get historyEmptyHint;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsTitle;

  /// No description provided for @statsToggleCalendar.
  ///
  /// In en, this message translates to:
  /// **'Toggle calendar view'**
  String get statsToggleCalendar;

  /// No description provided for @statsCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get statsCurrentStreak;

  /// No description provided for @statsLongestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get statsLongestStreak;

  /// No description provided for @statsTotalSessions.
  ///
  /// In en, this message translates to:
  /// **'Total Sessions'**
  String get statsTotalSessions;

  /// No description provided for @statsAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get statsAverage;

  /// No description provided for @statsDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{day} other{days}}'**
  String statsDays(num count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @settingsName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settingsName;

  /// No description provided for @settingsNameNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get settingsNameNotSet;

  /// No description provided for @settingsEditName.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get settingsEditName;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get settingsTimer;

  /// No description provided for @settingsDefaultMode.
  ///
  /// In en, this message translates to:
  /// **'Default Mode'**
  String get settingsDefaultMode;

  /// No description provided for @settingsDefaultDuration.
  ///
  /// In en, this message translates to:
  /// **'Default Duration'**
  String get settingsDefaultDuration;

  /// No description provided for @settingsDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String settingsDurationMinutes(int count);

  /// No description provided for @settingsCountdown.
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get settingsCountdown;

  /// No description provided for @settingsCountdownDesc.
  ///
  /// In en, this message translates to:
  /// **'Set a duration, timer counts down'**
  String get settingsCountdownDesc;

  /// No description provided for @settingsStopwatch.
  ///
  /// In en, this message translates to:
  /// **'Stopwatch'**
  String get settingsStopwatch;

  /// No description provided for @settingsStopwatchDesc.
  ///
  /// In en, this message translates to:
  /// **'Open-ended, stop manually'**
  String get settingsStopwatchDesc;

  /// No description provided for @settingsBellSounds.
  ///
  /// In en, this message translates to:
  /// **'Bell Sounds'**
  String get settingsBellSounds;

  /// No description provided for @settingsStartBell.
  ///
  /// In en, this message translates to:
  /// **'Start Bell'**
  String get settingsStartBell;

  /// No description provided for @settingsEndBell.
  ///
  /// In en, this message translates to:
  /// **'End Bell'**
  String get settingsEndBell;

  /// No description provided for @settingsIntervalBell.
  ///
  /// In en, this message translates to:
  /// **'Interval Bell'**
  String get settingsIntervalBell;

  /// No description provided for @settingsBellNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get settingsBellNone;

  /// No description provided for @settingsPickFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Pick from device...'**
  String get settingsPickFromDevice;

  /// No description provided for @settingsEnableInterval.
  ///
  /// In en, this message translates to:
  /// **'Enable Interval Bell'**
  String get settingsEnableInterval;

  /// No description provided for @settingsIntervalEvery.
  ///
  /// In en, this message translates to:
  /// **'Every {count} min'**
  String settingsIntervalEvery(int count);

  /// No description provided for @settingsOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsOff;

  /// No description provided for @settingsIntervalDuration.
  ///
  /// In en, this message translates to:
  /// **'Interval Duration'**
  String get settingsIntervalDuration;

  /// No description provided for @settingsIntervalSound.
  ///
  /// In en, this message translates to:
  /// **'Interval Sound'**
  String get settingsIntervalSound;

  /// No description provided for @settingsBgMusic.
  ///
  /// In en, this message translates to:
  /// **'Background Music'**
  String get settingsBgMusic;

  /// No description provided for @settingsMusicFile.
  ///
  /// In en, this message translates to:
  /// **'Music File'**
  String get settingsMusicFile;

  /// No description provided for @settingsMusicSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get settingsMusicSelected;

  /// No description provided for @settingsMusicNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get settingsMusicNone;

  /// No description provided for @settingsRemoveMusic.
  ///
  /// In en, this message translates to:
  /// **'Remove Background Music'**
  String get settingsRemoveMusic;

  /// No description provided for @settingsTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get settingsTags;

  /// No description provided for @settingsAddTag.
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get settingsAddTag;

  /// No description provided for @settingsAddTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Tag'**
  String get settingsAddTagTitle;

  /// No description provided for @settingsAddTagHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., focused'**
  String get settingsAddTagHint;

  /// No description provided for @settingsQuotes.
  ///
  /// In en, this message translates to:
  /// **'Quotes'**
  String get settingsQuotes;

  /// No description provided for @settingsAddCustomQuote.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Quote'**
  String get settingsAddCustomQuote;

  /// No description provided for @settingsUserQuotes.
  ///
  /// In en, this message translates to:
  /// **'{count} user quotes'**
  String settingsUserQuotes(int count);

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get settingsExport;

  /// No description provided for @settingsExportDesc.
  ///
  /// In en, this message translates to:
  /// **'Share your sessions & config as JSON'**
  String get settingsExportDesc;

  /// No description provided for @settingsImport.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get settingsImport;

  /// No description provided for @settingsImportDesc.
  ///
  /// In en, this message translates to:
  /// **'Load from a Citta JSON export file'**
  String get settingsImportDesc;

  /// No description provided for @settingsImportReplaceMsg.
  ///
  /// In en, this message translates to:
  /// **'Replace all existing data, or merge with current data?'**
  String get settingsImportReplaceMsg;

  /// No description provided for @settingsMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get settingsMerge;

  /// No description provided for @settingsReplaceAll.
  ///
  /// In en, this message translates to:
  /// **'Replace All'**
  String get settingsReplaceAll;

  /// No description provided for @settingsImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully'**
  String get settingsImportSuccess;

  /// No description provided for @settingsImportError.
  ///
  /// In en, this message translates to:
  /// **'Invalid import file'**
  String get settingsImportError;

  /// No description provided for @settingsExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String settingsExportFailed(String error);

  /// No description provided for @notesTitle.
  ///
  /// In en, this message translates to:
  /// **'Session Notes'**
  String get notesTitle;

  /// No description provided for @notesPrompt.
  ///
  /// In en, this message translates to:
  /// **'How was your practice?'**
  String get notesPrompt;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Write about your experience... (plain text or markdown)'**
  String get notesHint;

  /// No description provided for @notesWordCount.
  ///
  /// In en, this message translates to:
  /// **'{count} / 500 words'**
  String notesWordCount(int count);

  /// No description provided for @notesTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get notesTags;

  /// No description provided for @sessionComplete.
  ///
  /// In en, this message translates to:
  /// **'Session Complete'**
  String get sessionComplete;

  /// No description provided for @sessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get sessionTitle;

  /// No description provided for @sessionCountdown.
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get sessionCountdown;

  /// No description provided for @sessionStopwatch.
  ///
  /// In en, this message translates to:
  /// **'Stopwatch'**
  String get sessionStopwatch;

  /// No description provided for @sessionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get sessionCompleted;

  /// No description provided for @sessionNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get sessionNotes;

  /// No description provided for @sessionNoNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes for this session'**
  String get sessionNoNotes;

  /// No description provided for @addQuoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Quote'**
  String get addQuoteTitle;

  /// No description provided for @addQuoteOriginalText.
  ///
  /// In en, this message translates to:
  /// **'Original Text *'**
  String get addQuoteOriginalText;

  /// No description provided for @addQuoteOriginalHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the quote in original script...'**
  String get addQuoteOriginalHint;

  /// No description provided for @addQuoteLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get addQuoteLanguage;

  /// No description provided for @addQuoteTranslation.
  ///
  /// In en, this message translates to:
  /// **'English Translation *'**
  String get addQuoteTranslation;

  /// No description provided for @addQuoteTranslationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the English translation...'**
  String get addQuoteTranslationHint;

  /// No description provided for @addQuoteSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get addQuoteSource;

  /// No description provided for @addQuoteSourceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Bhagavad Gita'**
  String get addQuoteSourceHint;

  /// No description provided for @addQuoteReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get addQuoteReference;

  /// No description provided for @addQuoteReferenceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Chapter 2, Verse 47'**
  String get addQuoteReferenceHint;

  /// No description provided for @addQuoteSave.
  ///
  /// In en, this message translates to:
  /// **'Save Quote'**
  String get addQuoteSave;

  /// No description provided for @addQuoteAdded.
  ///
  /// In en, this message translates to:
  /// **'Quote added'**
  String get addQuoteAdded;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get langHindi;

  /// No description provided for @langKannada.
  ///
  /// In en, this message translates to:
  /// **'Kannada'**
  String get langKannada;

  /// No description provided for @langSanskrit.
  ///
  /// In en, this message translates to:
  /// **'Sanskrit'**
  String get langSanskrit;

  /// No description provided for @langTelugu.
  ///
  /// In en, this message translates to:
  /// **'Telugu'**
  String get langTelugu;

  /// No description provided for @langTamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get langTamil;

  /// No description provided for @langMalayalam.
  ///
  /// In en, this message translates to:
  /// **'Malayalam'**
  String get langMalayalam;

  /// No description provided for @langFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get langFrench;

  /// No description provided for @langGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get langGerman;

  /// No description provided for @langJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get langJapanese;

  /// No description provided for @langHebrew.
  ///
  /// In en, this message translates to:
  /// **'Hebrew'**
  String get langHebrew;

  /// No description provided for @langChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get langChinese;

  /// No description provided for @langMarathi.
  ///
  /// In en, this message translates to:
  /// **'Marathi'**
  String get langMarathi;

  /// No description provided for @langGujarati.
  ///
  /// In en, this message translates to:
  /// **'Gujarati'**
  String get langGujarati;

  /// No description provided for @langOdia.
  ///
  /// In en, this message translates to:
  /// **'Odia'**
  String get langOdia;

  /// No description provided for @langBengali.
  ///
  /// In en, this message translates to:
  /// **'Bengali'**
  String get langBengali;

  /// No description provided for @langTulu.
  ///
  /// In en, this message translates to:
  /// **'Tulu'**
  String get langTulu;

  /// No description provided for @langKonkani.
  ///
  /// In en, this message translates to:
  /// **'Konkani'**
  String get langKonkani;

  /// No description provided for @langUrdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get langUrdu;

  /// No description provided for @langItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get langItalian;

  /// No description provided for @langSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get langSpanish;

  /// No description provided for @langArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get langArabic;

  /// No description provided for @langRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get langRussian;

  /// No description provided for @langPortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get langPortuguese;

  /// No description provided for @langMaithili.
  ///
  /// In en, this message translates to:
  /// **'Maithili'**
  String get langMaithili;

  /// No description provided for @langAssamese.
  ///
  /// In en, this message translates to:
  /// **'Assamese'**
  String get langAssamese;

  /// No description provided for @langPunjabi.
  ///
  /// In en, this message translates to:
  /// **'Punjabi'**
  String get langPunjabi;

  /// No description provided for @langOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get langOther;

  /// No description provided for @preSessionSetup.
  ///
  /// In en, this message translates to:
  /// **'Session Setup'**
  String get preSessionSetup;

  /// No description provided for @timerPaused.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get timerPaused;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'as',
        'bn',
        'de',
        'en',
        'es',
        'fr',
        'gu',
        'he',
        'hi',
        'it',
        'ja',
        'kn',
        'kok',
        'mai',
        'ml',
        'mr',
        'or',
        'pa',
        'pt',
        'ru',
        'sa',
        'ta',
        'tcy',
        'te',
        'ur',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'as':
      return AppLocalizationsAs();
    case 'bn':
      return AppLocalizationsBn();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'gu':
      return AppLocalizationsGu();
    case 'he':
      return AppLocalizationsHe();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'kn':
      return AppLocalizationsKn();
    case 'kok':
      return AppLocalizationsKok();
    case 'mai':
      return AppLocalizationsMai();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'or':
      return AppLocalizationsOr();
    case 'pa':
      return AppLocalizationsPa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'sa':
      return AppLocalizationsSa();
    case 'ta':
      return AppLocalizationsTa();
    case 'tcy':
      return AppLocalizationsTcy();
    case 'te':
      return AppLocalizationsTe();
    case 'ur':
      return AppLocalizationsUr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
