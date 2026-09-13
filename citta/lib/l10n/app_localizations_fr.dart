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
  String get firstTimeSetupSubtitle =>
      'Configurons quelques éléments avant de commencer.';

  @override
  String get firstTimeSetupThemeSectionTitle => 'Choisissez votre thème';

  @override
  String get firstTimeSetupEncryptionAlreadyEnabledNotice =>
      'Le chiffrement est déjà activé pour vos réflexions.';

  @override
  String get firstTimeSetupContinueButton => 'Commencer';

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
  String get settingsColorPalette => 'Palette de couleurs';

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
  String get settingsExportChooseTitle => 'Exporter les données';

  @override
  String get settingsExportChooseMsg => 'Exporter en JSON simple ou chiffré ?';

  @override
  String get settingsExportChoosePlain => 'JSON simple';

  @override
  String get settingsExportChooseEncrypted => 'Chiffré';

  @override
  String get settingsImportEncryptedTitle => 'Export chiffré';

  @override
  String get settingsImportEncryptedSubtitle =>
      'Saisissez le mot de passe ou la clé de récupération utilisée pour chiffrer cet export.';

  @override
  String get settingsImportEncryptedInputLabel =>
      'Mot de passe ou clé de récupération';

  @override
  String get settingsImportEncryptedSubmitButton => 'Déverrouiller';

  @override
  String get settingsImportEncryptedErrorEmpty =>
      'Saisissez le mot de passe ou la clé de récupération';

  @override
  String get settingsImportEncryptedErrorWrong =>
      'Mot de passe ou clé de récupération incorrect. Veuillez réessayer.';

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
  String sessionDateAt(String date, String time) {
    return '$date à $time';
  }

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

  @override
  String get encryptionToggleTitle => 'Chiffrer mes réflexions';

  @override
  String get encryptionToggleSubtitle =>
      'Protégez vos séances sur cet appareil avec un mot de passe';

  @override
  String get encryptionPasswordLabel => 'Mot de passe';

  @override
  String get encryptionConfirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get encryptionEnableButton => 'Activer le chiffrement';

  @override
  String get encryptionErrorEmpty => 'Saisissez un mot de passe';

  @override
  String encryptionErrorTooShort(int minLength) {
    return 'Le mot de passe doit comporter au moins $minLength caractères';
  }

  @override
  String get encryptionErrorMismatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get encryptionErrorGeneric =>
      'Impossible d\'activer le chiffrement. Veuillez réessayer.';

  @override
  String get recoveryKeyScreenTitle => 'Enregistrez votre clé de récupération';

  @override
  String get recoveryKeyWarning =>
      'C\'est le seul moyen de récupérer vos données si vous oubliez votre mot de passe. Si vous perdez les deux, vos données seront irrécupérables de façon permanente.';

  @override
  String get recoveryKeyCopyButton => 'Copier';

  @override
  String get recoveryKeyShareButton => 'Partager';

  @override
  String get recoveryKeyAckLabel =>
      'J\'ai enregistré ma clé de récupération dans un endroit sûr';

  @override
  String get recoveryKeyContinueButton => 'Continuer';

  @override
  String get recoveryKeyErrorGeneric =>
      'Impossible de générer une clé de récupération. Veuillez réessayer.';

  @override
  String get unlockTitle => 'Déverrouiller Citta';

  @override
  String get unlockSubtitle =>
      'Saisissez votre mot de passe ou votre clé de récupération pour accéder à vos réflexions.';

  @override
  String get unlockInputLabel => 'Mot de passe ou clé de récupération';

  @override
  String get unlockSubmitButton => 'Déverrouiller';

  @override
  String get unlockErrorEmpty =>
      'Saisissez votre mot de passe ou votre clé de récupération';

  @override
  String get unlockErrorGeneric =>
      'Mot de passe ou clé de récupération incorrect. Veuillez réessayer.';

  @override
  String get unlockErrorCorrupted =>
      'Vos données chiffrées n\'ont pas pu être lues. Elles sont peut-être endommagées.';

  @override
  String get settingsEncryptionTitle => 'Chiffrement';

  @override
  String get settingsEncryptionSubtitleEnabled =>
      'Vos séances sont chiffrées sur cet appareil';

  @override
  String get settingsEncryptionSubtitleDisabled =>
      'Protégez vos séances avec un mot de passe';

  @override
  String get enableEncryptionScreenTitle => 'Activer le chiffrement';

  @override
  String get settingsEncryptionDisableConfirmTitle =>
      'Désactiver le chiffrement ?';

  @override
  String get settingsEncryptionDisableConfirmMessage =>
      'Vos séances seront à nouveau stockées en texte brut sur cet appareil.';

  @override
  String get settingsEncryptionDisableConfirmButton => 'Désactiver';

  @override
  String get settingsEncryptionDisableError =>
      'Impossible de désactiver le chiffrement. Veuillez réessayer.';

  @override
  String get settingsChangePasswordTitle => 'Changer le mot de passe';

  @override
  String get settingsChangePasswordSubtitle =>
      'Mettez à jour le mot de passe qui protège vos séances';

  @override
  String get changePasswordScreenTitle => 'Changer le mot de passe';

  @override
  String get changePasswordCurrentLabel => 'Mot de passe actuel';

  @override
  String get changePasswordNewLabel => 'Nouveau mot de passe';

  @override
  String get changePasswordConfirmLabel => 'Confirmer le nouveau mot de passe';

  @override
  String get changePasswordSubmitButton => 'Changer le mot de passe';

  @override
  String get changePasswordErrorEmpty =>
      'Saisissez votre mot de passe actuel et le nouveau';

  @override
  String changePasswordErrorTooShort(int minLength) {
    return 'Le nouveau mot de passe doit comporter au moins $minLength caractères';
  }

  @override
  String get changePasswordErrorMismatch =>
      'Les nouveaux mots de passe ne correspondent pas';

  @override
  String get changePasswordErrorWrongCurrent =>
      'Le mot de passe actuel est incorrect';

  @override
  String get changePasswordErrorGeneric =>
      'Impossible de changer le mot de passe. Veuillez réessayer.';

  @override
  String get changePasswordSuccess => 'Mot de passe changé avec succès';
}
