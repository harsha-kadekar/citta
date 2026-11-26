import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Issue #105: the release signing key is the app's identity on F-Droid and
// Google Play — an update signed with any other key is rejected. These tests
// keep the documented fingerprint, the verification script and the repo's
// keystore hygiene in sync. See docs/android-signing-key.md at the repo root.
//
// SHA-256 of the signing certificate in the v0.3.0 GitHub release APK.
const _certSha256 =
    'cee3a0e0f1f4b435be8541364111270dc283f8b4742d8ca138e407336dcb6716';
const _keyAlias = 'citta';
const _storePass = 'testpass';

// `flutter test` runs with citta/ as the working directory; docs/ and
// scripts/ live at the repo root.
const _docPath = '../docs/android-signing-key.md';
const _scriptPath = '../scripts/verify-release-key.sh';

bool _onPath(String tool) =>
    Process.runSync('sh', ['-c', 'command -v $tool']).exitCode == 0;

/// Skip reason when keytool is unavailable locally; null (run, and fail
/// loudly) in CI so losing this coverage can't go unnoticed.
Object? _keytoolSkip() {
  if (_onPath('keytool')) return false;
  if (Platform.environment.containsKey('CI')) return false;
  return 'keytool not on PATH';
}

/// Adds a fresh RSA key entry named [alias] to the PKCS12 keystore at [path],
/// creating the keystore if needed.
void _addKey(String path, String alias) {
  final result = Process.runSync('keytool', [
    '-genkeypair',
    '-keystore',
    path,
    '-storetype',
    'PKCS12',
    '-storepass',
    _storePass,
    '-alias',
    alias,
    '-keyalg',
    'RSA',
    '-keysize',
    '2048',
    '-validity',
    '1',
    '-dname',
    'CN=$alias',
  ]);
  expect(result.exitCode, 0, reason: '${result.stderr}');
}

/// Returns the colon-free lowercase cert SHA-256 of [alias] in [keystore].
String _fingerprintOf(String keystore, String alias) {
  final out = Process.runSync('keytool', [
    '-list',
    '-v',
    '-keystore',
    keystore,
    '-storepass',
    _storePass,
    '-alias',
    alias,
  ]).stdout as String;
  final match = RegExp(r'SHA256:\s*([0-9A-F:]+)').firstMatch(out)!;
  return match.group(1)!.replaceAll(':', '').toLowerCase();
}

/// Runs the script with the parent environment (so PATH still finds the JDK
/// and git) but with the script's own inputs pinned: the developer's
/// CITTA_EXPECTED_CERT_SHA256 / KEY_ALIAS / KEYSTORE_PASSWORD never leak into
/// the results.
ProcessResult _runScript(List<String> args, {Map<String, String>? env}) =>
    Process.runSync(
      'bash',
      [_scriptPath, ...args],
      environment: {
        'KEYSTORE_PASSWORD': _storePass,
        'CITTA_EXPECTED_CERT_SHA256': '',
        'KEY_ALIAS': '',
        ...?env,
      },
      includeParentEnvironment: true,
    );

/// Writes an executable fake `apksigner` into [dir] that prints [signers]
/// as its certificate digests, mimicking `apksigner verify --print-certs`.
void _fakeApksigner(Directory dir, List<String> signers) {
  final lines = [
    for (var i = 0; i < signers.length; i++)
      'Signer #${i + 1} certificate SHA-256 digest: ${signers[i]}',
  ];
  final file = File('${dir.path}/apksigner')
    ..writeAsStringSync("#!/bin/sh\ncat <<'EOF'\n${lines.join('\n')}\nEOF\n");
  Process.runSync('chmod', ['+x', file.path]);
}

void main() {
  group('Release signing key documentation', () {
    late String doc;

    setUpAll(() => doc = File(_docPath).readAsStringSync());

    test('records the release certificate SHA-256 fingerprint', () {
      expect(doc, contains(_certSha256));
    });

    test('records the key alias used by key.properties.example', () {
      final example = File('android/key.properties.example').readAsStringSync();
      expect(example, contains('keyAlias=$_keyAlias'));
      expect(doc, contains('`$_keyAlias`'));
    });

    test('documents backup and restore procedures', () {
      expect(doc, contains('## Backups'));
      expect(doc, contains('## Restore'));
    });
  });

  group('Keystore hygiene', () {
    // Paths are relative to the repo root; git applies every .gitignore.
    const mustBeIgnored = [
      'citta/android/key.properties',
      'citta/android/app/upload.jks',
      'citta-release.jks',
      'citta-release.keystore',
      'citta-release.p12',
      'docs/citta-release.pfx',
      'citta/citta-release.p12',
    ];

    for (final path in mustBeIgnored) {
      test('git ignores $path', () {
        final result = Process.runSync('git', ['check-ignore', '-q', path],
            workingDirectory: '..');
        expect(result.exitCode, 0, reason: '$path is not gitignored');
      });
    }
  });

  group('release CI', () {
    test('verifies the release APK signer before publishing', () {
      final ci = File('../.github/workflows/ci.yml').readAsStringSync();
      final verify = ci.indexOf('scripts/verify-release-key.sh');
      final publish = ci.indexOf('action-gh-release');
      expect(verify, isNonNegative);
      expect(verify, lessThan(publish));
    });
  });

  group('verify-release-key.sh', () {
    test('pins the same fingerprint as the docs', () {
      final script = File(_scriptPath).readAsStringSync();
      expect(script, contains(_certSha256));
    });

    test('fails with usage when no file is given', () {
      final result = _runScript([]);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, contains('Usage'));
    });

    test('fails when the file does not exist', () {
      final result = _runScript(['/nonexistent/citta-release.jks']);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, contains('not found'));
    });

    group('with a file on disk', () {
      late Directory tmp;

      setUp(() => tmp = Directory.systemTemp.createTempSync('citta_signing_'));
      tearDown(() => tmp.deleteSync(recursive: true));

      test('rejects an unsupported file type with a clear error', () {
        final path = '${tmp.path}/notes.txt';
        File(path).writeAsStringSync('hello');
        final result = _runScript([path]);
        expect(result.exitCode, 2);
        expect(result.stderr, contains('unsupported file type'));
      });

      group('APK', () {
        late Directory bin;

        setUp(() => bin = Directory('${tmp.path}/bin')..createSync());

        ProcessResult runApk(String name) {
          final apk = '${tmp.path}/$name';
          File(apk).writeAsStringSync('not really an apk');
          return _runScript(
            [apk],
            env: {'PATH': '${bin.path}:${Platform.environment['PATH']}'},
          );
        }

        test('accepts a single signer matching the release key', () {
          _fakeApksigner(bin, [_certSha256]);
          final result = runApk('app-release.apk');
          expect(result.exitCode, 0,
              reason: '${result.stdout}${result.stderr}');
          expect(result.stdout, contains('OK'));
        });

        test('treats the .apk extension case-insensitively', () {
          _fakeApksigner(bin, [_certSha256]);
          final result = runApk('APP-RELEASE.APK');
          expect(result.exitCode, 0,
              reason: '${result.stdout}${result.stderr}');
        });

        test('rejects a single signer that is not the release key', () {
          _fakeApksigner(bin, ['ab' * 32]);
          final result = runApk('app-release.apk');
          expect(result.exitCode, 1);
          expect(result.stdout, contains('MISMATCH'));
        });

        test('refuses an APK with more than one signer', () {
          _fakeApksigner(bin, [_certSha256, 'ab' * 32]);
          final result = runApk('app-release.apk');
          expect(result.exitCode, 2);
          expect(result.stderr, contains('expected exactly one signer'));
        });
      });

      group('keystore', () {
        late String keystore;

        setUp(() => keystore = '${tmp.path}/test.p12');

        test('rejects a keystore whose certificate is not the release key', () {
          _addKey(keystore, _keyAlias);
          final result = _runScript([keystore]);
          expect(result.exitCode, 1);
          expect(result.stdout, contains('MISMATCH'));
        });

        test('accepts a keystore whose certificate matches the expected key',
            () {
          _addKey(keystore, _keyAlias);
          final result = _runScript(
            [keystore],
            env: {
              'CITTA_EXPECTED_CERT_SHA256': _fingerprintOf(keystore, _keyAlias),
            },
          );
          expect(result.exitCode, 0,
              reason: '${result.stdout}${result.stderr}');
          expect(result.stdout, contains('OK'));
        });

        test('checks the citta alias, not whichever entry is listed first', () {
          // A matching key under another alias must not make the check pass:
          // Gradle signs with keyAlias=citta.
          _addKey(keystore, 'aaa-other');
          _addKey(keystore, _keyAlias);
          _addKey(keystore, 'zzz-other');
          for (final decoy in ['aaa-other', 'zzz-other']) {
            final result = _runScript(
              [keystore],
              env: {
                'CITTA_EXPECTED_CERT_SHA256': _fingerprintOf(keystore, decoy),
              },
            );
            expect(result.exitCode, 1,
                reason: 'decoy $decoy: ${result.stdout}${result.stderr}');
          }
        });

        test('fails when the keystore has no citta alias', () {
          _addKey(keystore, 'other');
          final result = _runScript(
            [keystore],
            env: {
              'CITTA_EXPECTED_CERT_SHA256': _fingerprintOf(keystore, 'other')
            },
          );
          expect(result.exitCode, 2);
        });

        test('honours KEY_ALIAS for a non-default alias', () {
          _addKey(keystore, 'upload');
          final result = _runScript(
            [keystore],
            env: {
              'KEY_ALIAS': 'upload',
              'CITTA_EXPECTED_CERT_SHA256': _fingerprintOf(keystore, 'upload'),
            },
          );
          expect(result.exitCode, 0,
              reason: '${result.stdout}${result.stderr}');
        });

        test('checks the signer of a jar-signed app bundle (.aab)', () {
          _addKey(keystore, _keyAlias);
          final aab = '${tmp.path}/app-release.aab';
          File('${tmp.path}/BundleConfig.pb').writeAsStringSync('x');
          expect(
            Process.runSync(
                'jar', ['cf', aab, '-C', tmp.path, 'BundleConfig.pb']).exitCode,
            0,
          );
          final signed = Process.runSync('jarsigner', [
            '-keystore',
            keystore,
            '-storepass',
            _storePass,
            aab,
            _keyAlias,
          ]);
          expect(signed.exitCode, 0,
              reason: '${signed.stdout}${signed.stderr}');

          final mismatch = _runScript([aab]);
          expect(mismatch.exitCode, 1);
          expect(mismatch.stdout, contains('MISMATCH'));

          final match = _runScript(
            [aab],
            env: {
              'CITTA_EXPECTED_CERT_SHA256': _fingerprintOf(keystore, _keyAlias),
            },
          );
          expect(match.exitCode, 0, reason: '${match.stdout}${match.stderr}');
        });

        test(
            'asks for KEYSTORE_PASSWORD instead of prompting non-interactively',
            () {
          _addKey(keystore, _keyAlias);
          // stdin of a child process is not a TTY, so keytool can't prompt.
          final result = _runScript([keystore], env: {'KEYSTORE_PASSWORD': ''});
          expect(result.exitCode, 2);
          expect(result.stderr, contains('KEYSTORE_PASSWORD'));
        });
      }, skip: _keytoolSkip());
    });
  });
}
