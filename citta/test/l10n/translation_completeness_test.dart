import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Issue #90: the 59 keys that `flutter gen-l10n`'s untranslated-messages-file
// report currently lists as missing from every non-English locale. Keys were
// added across issues #51-#59 and #64-#66 with translations left for a later
// batch pass; this test locks that pass in and prevents the backlog from
// silently regrowing for these specific keys.
const _keysUnderTest = <String>{
  'firstTimeSetupSubtitle',
  'firstTimeSetupThemeSectionTitle',
  'firstTimeSetupEncryptionAlreadyEnabledNotice',
  'firstTimeSetupContinueButton',
  'settingsColorPalette',
  'settingsExportChooseTitle',
  'settingsExportChooseMsg',
  'settingsExportChoosePlain',
  'settingsExportChooseEncrypted',
  'settingsImportEncryptedTitle',
  'settingsImportEncryptedSubtitle',
  'settingsImportEncryptedInputLabel',
  'settingsImportEncryptedSubmitButton',
  'settingsImportEncryptedErrorEmpty',
  'settingsImportEncryptedErrorWrong',
  'encryptionToggleTitle',
  'encryptionToggleSubtitle',
  'encryptionPasswordLabel',
  'encryptionConfirmPasswordLabel',
  'encryptionEnableButton',
  'encryptionErrorEmpty',
  'encryptionErrorTooShort',
  'encryptionErrorMismatch',
  'encryptionErrorGeneric',
  'recoveryKeyScreenTitle',
  'recoveryKeyWarning',
  'recoveryKeyCopyButton',
  'recoveryKeyShareButton',
  'recoveryKeyAckLabel',
  'recoveryKeyContinueButton',
  'recoveryKeyErrorGeneric',
  'unlockTitle',
  'unlockSubtitle',
  'unlockInputLabel',
  'unlockSubmitButton',
  'unlockErrorEmpty',
  'unlockErrorGeneric',
  'unlockErrorCorrupted',
  'settingsEncryptionTitle',
  'settingsEncryptionSubtitleEnabled',
  'settingsEncryptionSubtitleDisabled',
  'enableEncryptionScreenTitle',
  'settingsEncryptionDisableConfirmTitle',
  'settingsEncryptionDisableConfirmMessage',
  'settingsEncryptionDisableConfirmButton',
  'settingsEncryptionDisableError',
  'settingsChangePasswordTitle',
  'settingsChangePasswordSubtitle',
  'changePasswordScreenTitle',
  'changePasswordCurrentLabel',
  'changePasswordNewLabel',
  'changePasswordConfirmLabel',
  'changePasswordSubmitButton',
  'changePasswordErrorEmpty',
  'changePasswordErrorTooShort',
  'changePasswordErrorMismatch',
  'changePasswordErrorWrongCurrent',
  'changePasswordErrorGeneric',
  'changePasswordSuccess',
};

// (locale, key) pairs where the genuine translation is legitimately identical
// to the English string - e.g. "Password" is an unchanged loanword in Italian -
// so equality here is not evidence of an untranslated fallback.
const _knownLoanwords = <(String, String)>{
  ('it', 'encryptionPasswordLabel'),
};

void main() {
  final l10nDir = Directory('lib/l10n');
  final enJson = jsonDecode(File('${l10nDir.path}/app_en.arb').readAsStringSync())
      as Map<String, dynamic>;
  final enKeys = enJson.keys.where((k) => !k.startsWith('@')).toSet();

  final localeFiles = l10nDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.arb') && !f.path.endsWith('app_en.arb'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  group('Locale ARB files have no untranslated keys (issue #90)', () {
    test('setup sanity: there are 26 non-English locale files', () {
      expect(localeFiles.length, equals(26));
    });

    test('setup sanity: the tracked key set is exactly the 59 keys under test', () {
      expect(_keysUnderTest.length, equals(59));
      for (final key in _keysUnderTest) {
        expect(enKeys, contains(key),
            reason: '$key should exist in app_en.arb');
      }
    });

    for (final file in localeFiles) {
      final locale = file.uri.pathSegments.last
          .replaceFirst('app_', '')
          .replaceFirst('.arb', '');

      test('$locale has a genuine translation for every tracked key', () {
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

        final missing = <String>[];
        final copiedFromEnglish = <String>[];
        for (final key in _keysUnderTest) {
          if (!json.containsKey(key)) {
            missing.add(key);
            continue;
          }
          if (json[key] == enJson[key] &&
              !_knownLoanwords.contains((locale, key))) {
            copiedFromEnglish.add(key);
          }
        }

        expect(missing, isEmpty,
            reason: 'Locale "$locale" is missing translations for: $missing');
        expect(copiedFromEnglish, isEmpty,
            reason:
                'Locale "$locale" copies the English fallback (untranslated) for: $copiedFromEnglish');
      });
    }
  });

  group('German register consistency (issue #90 review)', () {
    // app_de.arb has always addressed the user formally (Sie/Ihr) - e.g.
    // welcomeNameHint: "Geben Sie Ihren Namen ein". A batch of translations
    // must not introduce the informal du/dein register alongside it.
    final informalMarker = RegExp(r'\b(du|dein\w*|dir|dich|lass)\b', caseSensitive: false);

    test('new keys use the formal Sie/Ihr register, not informal du/dein', () {
      final json = jsonDecode(File('lib/l10n/app_de.arb').readAsStringSync())
          as Map<String, dynamic>;

      final informal = <String>[];
      for (final key in _keysUnderTest) {
        final value = json[key] as String;
        if (informalMarker.hasMatch(value)) {
          informal.add('$key: "$value"');
        }
      }

      expect(informal, isEmpty,
          reason: 'German strings using informal register (expected formal '
              'Sie/Ihr throughout): $informal');
    });
  });
}
