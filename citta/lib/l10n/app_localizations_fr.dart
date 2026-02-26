// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionSkip => 'Ignorer';

  @override
  String get actionContinue => 'Continuer';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get actionBegin => 'Commencer';

  @override
  String get navDhyana => 'Dhyana';

  @override
  String get navHistory => 'Historique';

  @override
  String get navStats => 'Statistiques';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get splashGreeting => 'Namaskara';

  @override
  String splashGreetingWithName(String name) {
    return 'Namaskara, $name';
  }

  @override
  String get splashTapToBegin => 'appuyer pour commencer';

  @override
  String get welcomeTitle => 'Bienvenue sur Citta';

  @override
  String get welcomeNameHint => 'Entrez votre nom';

  @override
  String get homeBegin => 'Commencer';

  @override
  String get homeCountdown => 'Compte à rebours';

  @override
  String get homeStopwatch => 'Chronomètre';

  @override
  String get homeMin => 'min';

  @override
  String get historyTitle => 'Historique';

  @override
  String historySelected(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String get historyDeleteTitle => 'Supprimer les séances';

  @override
  String historyDeleteConfirm(int count) {
    return 'Supprimer $count séance(s) ? Cela ne peut pas être annulé.';
  }

  @override
  String get historyFilterAll => 'Tout';

  @override
  String get historyEmpty => 'Aucune séance pour l\'instant';

  @override
  String get historyEmptyHint =>
      'Terminez votre première séance de dhyana\npour la voir ici';

  @override
  String get statsTitle => 'Statistiques';

  @override
  String get statsToggleCalendar => 'Basculer la vue calendrier';

  @override
  String get statsCurrentStreak => 'Série actuelle';

  @override
  String get statsLongestStreak => 'Série la plus longue';

  @override
  String get statsTotalSessions => 'Total des séances';

  @override
  String get statsAverage => 'Moyenne';

  @override
  String statsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'jours',
      one: 'jour',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get settingsName => 'Nom';

  @override
  String get settingsNameNotSet => 'Non défini';

  @override
  String get settingsEditName => 'Modifier le nom';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSystem => 'Langue du système';

  @override
  String get settingsTimer => 'Minuterie';

  @override
  String get settingsDefaultMode => 'Mode par défaut';

  @override
  String get settingsDefaultDuration => 'Durée par défaut';

  @override
  String settingsDurationMinutes(int count) {
    return '$count minutes';
  }

  @override
  String get settingsCountdown => 'Compte à rebours';

  @override
  String get settingsCountdownDesc =>
      'Définir une durée, la minuterie décompte';

  @override
  String get settingsStopwatch => 'Chronomètre';

  @override
  String get settingsStopwatchDesc => 'Durée libre, arrêt manuel';

  @override
  String get settingsBellSounds => 'Sons de cloche';

  @override
  String get settingsStartBell => 'Cloche de début';

  @override
  String get settingsEndBell => 'Cloche de fin';

  @override
  String get settingsIntervalBell => 'Cloche d\'intervalle';

  @override
  String get settingsBellNone => 'Aucun';

  @override
  String get settingsPickFromDevice => 'Choisir depuis l\'appareil...';

  @override
  String get settingsEnableInterval => 'Activer la cloche d\'intervalle';

  @override
  String settingsIntervalEvery(int count) {
    return 'Toutes les $count min';
  }

  @override
  String get settingsOff => 'Désactivé';

  @override
  String get settingsIntervalDuration => 'Durée d\'intervalle';

  @override
  String get settingsIntervalSound => 'Son d\'intervalle';

  @override
  String get settingsBgMusic => 'Musique de fond';

  @override
  String get settingsMusicFile => 'Fichier musical';

  @override
  String get settingsMusicSelected => 'Sélectionné';

  @override
  String get settingsMusicNone => 'Aucun';

  @override
  String get settingsRemoveMusic => 'Supprimer la musique de fond';

  @override
  String get settingsTags => 'Étiquettes';

  @override
  String get settingsAddTag => '+ Ajouter';

  @override
  String get settingsAddTagTitle => 'Ajouter une étiquette';

  @override
  String get settingsAddTagHint => 'ex., concentré';

  @override
  String get settingsQuotes => 'Citations';

  @override
  String get settingsAddCustomQuote => 'Ajouter une citation personnalisée';

  @override
  String settingsUserQuotes(int count) {
    return '$count citation(s) utilisateur';
  }

  @override
  String get settingsData => 'Données';

  @override
  String get settingsExport => 'Exporter les données';

  @override
  String get settingsExportDesc => 'Partager vos séances et config en JSON';

  @override
  String get settingsImport => 'Importer les données';

  @override
  String get settingsImportDesc =>
      'Charger depuis un fichier d\'export Citta JSON';

  @override
  String get settingsImportReplaceMsg =>
      'Remplacer toutes les données existantes, ou fusionner avec les données actuelles ?';

  @override
  String get settingsMerge => 'Fusionner';

  @override
  String get settingsReplaceAll => 'Tout remplacer';

  @override
  String get settingsImportSuccess => 'Données importées avec succès';

  @override
  String get settingsImportError => 'Fichier d\'import invalide';

  @override
  String settingsExportFailed(String error) {
    return 'Échec de l\'exportation : $error';
  }

  @override
  String get notesTitle => 'Notes de séance';

  @override
  String get notesPrompt => 'Comment s\'est passée votre pratique ?';

  @override
  String get notesHint =>
      'Écrivez sur votre expérience... (texte brut ou markdown)';

  @override
  String notesWordCount(int count) {
    return '$count / 500 mots';
  }

  @override
  String get notesTags => 'Étiquettes';

  @override
  String get sessionComplete => 'Séance terminée';

  @override
  String get sessionTitle => 'Séance';

  @override
  String get sessionCountdown => 'Compte à rebours';

  @override
  String get sessionStopwatch => 'Chronomètre';

  @override
  String get sessionCompleted => 'Terminé';

  @override
  String get sessionNotes => 'Notes';

  @override
  String get sessionNoNotes => 'Aucune note pour cette séance';

  @override
  String get addQuoteTitle => 'Ajouter une citation';

  @override
  String get addQuoteOriginalText => 'Texte original *';

  @override
  String get addQuoteOriginalHint =>
      'Entrez la citation dans le script original...';

  @override
  String get addQuoteLanguage => 'Langue';

  @override
  String get addQuoteTranslation => 'Traduction anglaise *';

  @override
  String get addQuoteTranslationHint => 'Entrez la traduction anglaise...';

  @override
  String get addQuoteSource => 'Source';

  @override
  String get addQuoteSourceHint => 'ex., Bhagavad Gita';

  @override
  String get addQuoteReference => 'Référence';

  @override
  String get addQuoteReferenceHint => 'ex., Chapitre 2, Verset 47';

  @override
  String get addQuoteSave => 'Enregistrer la citation';

  @override
  String get addQuoteAdded => 'Citation ajoutée';

  @override
  String get langEnglish => 'Anglais';

  @override
  String get langHindi => 'Hindi';

  @override
  String get langKannada => 'Kannada';

  @override
  String get langSanskrit => 'Sanskrit';

  @override
  String get langTelugu => 'Télougou';

  @override
  String get langTamil => 'Tamoul';

  @override
  String get langMalayalam => 'Malayalam';

  @override
  String get langFrench => 'Français';

  @override
  String get langGerman => 'Allemand';

  @override
  String get langJapanese => 'Japonais';

  @override
  String get langHebrew => 'Hébreu';

  @override
  String get langChinese => 'Chinois';

  @override
  String get langMarathi => 'Marathi';

  @override
  String get langGujarati => 'Gujarati';

  @override
  String get langOdia => 'Odia';

  @override
  String get langBengali => 'Bengali';

  @override
  String get langTulu => 'Tulu';

  @override
  String get langKonkani => 'Konkani';

  @override
  String get langUrdu => 'Ourdou';

  @override
  String get langItalian => 'Italien';

  @override
  String get langSpanish => 'Espagnol';

  @override
  String get langArabic => 'Arabe';

  @override
  String get langRussian => 'Russe';

  @override
  String get langPortuguese => 'Portugais';

  @override
  String get langMaithili => 'Maithili';

  @override
  String get langAssamese => 'Assamais';

  @override
  String get langPunjabi => 'Pendjabi';

  @override
  String get langOther => 'Autre';

  @override
  String get preSessionSetup => 'Configuration de la séance';

  @override
  String get timerPaused => 'EN PAUSE';
}
