import 'dart:convert';
import 'dart:io';

import 'package:citta/services/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the F-Droid requirement that every bundled asset is documented with
/// a FOSS-compatible license (issue #102), and that the asset READMEs never
/// drift from the files actually present.

const _licensesDoc = 'ASSETS_LICENSES.md';

/// SPDX-style identifiers accepted as FOSS-compatible for bundled assets.
/// Deliberately excludes the Pixabay Content License and similar
/// "royalty-free" terms, which F-Droid does not accept.
const _allowedLicenses = {
  'CC0-1.0',
  'CC-BY-4.0',
  'CC-BY-SA-4.0',
  'MIT',
  'Apache-2.0',
  'OFL-1.1',
  'Public-Domain',
};

/// A row of the attribution table: `| `path` | ... | license |`.
class _Row {
  _Row(this.path, this.license, this.source);
  final String path;
  final String license;
  final String source;
}

List<_Row> _parseRows() {
  final rowPattern = RegExp(r'^\|\s*`(assets/[^`]+)`\s*\|(.*)\|\s*$');
  final rows = <_Row>[];
  for (final line in File(_licensesDoc).readAsLinesSync()) {
    final match = rowPattern.firstMatch(line.trim());
    if (match == null) continue;
    final cells = match.group(2)!.split('|').map((c) => c.trim()).toList();
    // Columns after the path: Description | Source | Author | License.
    rows.add(_Row(match.group(1)!, cells.last, cells[1]));
  }
  return rows;
}

/// Every asset file under [root], except READMEs and hidden OS/tooling files
/// such as `.DS_Store` or `.gitkeep`.
Set<String> _bundledAssetFiles([String root = 'assets']) => Directory(root)
    .listSync(recursive: true)
    .whereType<File>()
    .map((f) => f.path.replaceAll(r'\', '/'))
    .where((p) => !p.toLowerCase().endsWith('.md'))
    .where((p) => !p.split('/').last.startsWith('.'))
    .toSet();

void main() {
  test('asset scan ignores hidden files and READMEs', () {
    final dir = Directory.systemTemp.createTempSync('assets_scan');
    addTearDown(() => dir.deleteSync(recursive: true));
    File('${dir.path}/.DS_Store').createSync();
    File('${dir.path}/README.md').createSync();
    File('${dir.path}/bell.mp3').createSync();
    expect(_bundledAssetFiles(dir.path).map((p) => p.split('/').last),
        equals({'bell.mp3'}));
  });

  test('$_licensesDoc exists', () {
    expect(File(_licensesDoc).existsSync(), isTrue);
  });

  group('$_licensesDoc attribution table', () {
    late List<_Row> rows;
    setUpAll(() => rows = _parseRows());

    test('documents every bundled asset file', () {
      final documented = rows.map((r) => r.path).toSet();
      final missing = _bundledAssetFiles().difference(documented);
      expect(missing, isEmpty,
          reason: 'Bundled assets with no license entry: $missing');
    });

    test('lists only files that actually exist', () {
      final stale =
          rows.map((r) => r.path).where((p) => !File(p).existsSync()).toList();
      expect(stale, isEmpty, reason: 'Documented but not present: $stale');
    });

    test('documents each file once', () {
      final paths = rows.map((r) => r.path).toList();
      expect(paths.toSet().length, paths.length);
    });

    test('every license is FOSS-compatible', () {
      for (final row in rows) {
        final parts = row.license.split('+').map((p) => p.trim());
        for (final part in parts) {
          expect(_allowedLicenses, contains(part),
              reason: '${row.path} has non-allowlisted license "$part"');
        }
      }
    });

    test('every bundled sound records a source URL or original recording',
        () {
      for (final row in rows.where((r) => r.path.startsWith('assets/sounds/'))) {
        expect(
            row.source.contains('https://') ||
                row.source.startsWith('Original recording'),
            isTrue,
            reason: '${row.path} needs a source URL or "Original recording"');
      }
    });

    test('covers every sound the app can play', () {
      final documented = rows.map((r) => r.path).toSet();
      for (final path in AudioService.bundledSounds.values) {
        expect(documented, contains(path));
      }
    });
  });

  group('assets/data/quotes.json translations', () {
    // Distinctive wording from copyrighted English editions (Prabhupada 1972,
    // Satchidananda 1978, Gambhirananda/Advaita Ashrama). Bundled translations
    // are original MIT renderings, so none of these should appear.
    const copyrightedPhrases = [
      'conditioned soul',
      'supersoul',
      'mind-stuff',
      'such equanimity is called yoga',
      'such is the simile',
      'fraught with fear',
      'becomes firmly grounded',
      'retains its undisturbed calmness',
      'continuous flow of cognition',
      'when disturbed by negative thoughts',
      'beyond empirical dealings',
      'not a mass of cognition',
      'o son of kunti, it can be restrained',
    ];

    test('do not reuse wording from copyrighted translations', () {
      final json = File('assets/data/quotes.json').readAsStringSync();
      final translations = (jsonDecode(json)['quotes'] as List)
          .map((q) => (q as Map)['translation'] as String);
      for (final t in translations) {
        for (final phrase in copyrightedPhrases) {
          expect(t.toLowerCase(), isNot(contains(phrase)),
              reason: 'Translation reuses copyrighted wording: "$t"');
        }
      }
    });
  });

  group('assets/sounds/README.md', () {
    test('names exactly the MP3 files present', () {
      final readme = File('assets/sounds/README.md').readAsStringSync();
      final named = RegExp(r'[\w-]+\.mp3')
          .allMatches(readme)
          .map((m) => 'assets/sounds/${m.group(0)}')
          .toSet();
      final present = Directory('assets/sounds')
          .listSync()
          .whereType<File>()
          .map((f) => f.path.replaceAll(r'\', '/'))
          .where((p) => p.endsWith('.mp3'))
          .toSet();
      expect(named, equals(present));
    });

    test('does not recommend non-free sources', () {
      final readme =
          File('assets/sounds/README.md').readAsStringSync().toLowerCase();
      expect(readme, isNot(contains('pixabay')));
    });
  });
}
