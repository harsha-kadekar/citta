import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Issue #107: F-Droid and Google Play reject an upload that reuses a
// versionCode, and F-Droid's auto-update matches git tags against the version
// in pubspec.yaml. These tests keep docs/RELEASING.md, the tag check script and
// the CI release job in sync.

// `flutter test` runs with citta/ as the working directory; docs/, scripts/
// and .github/ live at the repo root.
const _docPath = '../docs/RELEASING.md';
final _scriptPath = File('../scripts/check-release-version.sh').absolute.path;

// Only these variables reach git and the script: an inherited GIT_DIR or
// GIT_WORK_TREE (e.g. from a git hook running `flutter test`) would otherwise
// point every command at the real Citta repository.
final _gitEnv = {
  'PATH': Platform.environment['PATH'] ?? '/usr/bin:/bin',
  'HOME': Directory.systemTemp.path,
  'GIT_AUTHOR_NAME': 'Test',
  'GIT_AUTHOR_EMAIL': 'test@example.invalid',
  'GIT_COMMITTER_NAME': 'Test',
  'GIT_COMMITTER_EMAIL': 'test@example.invalid',
  // Keep the developer's global git config (signing, hooks) out of the repo.
  'GIT_CONFIG_GLOBAL': '/dev/null',
  'GIT_CONFIG_NOSYSTEM': '1',
};

/// A throwaway git repo laid out like Citta's (pubspec under citta/).
class _Repo {
  _Repo() : dir = Directory.systemTemp.createTempSync('citta_versioning_') {
    _git(['init', '-q']);
  }

  final Directory dir;

  void _git(List<String> args) {
    final result = Process.runSync('git', args,
        workingDirectory: dir.path,
        environment: _gitEnv,
        includeParentEnvironment: false);
    expect(result.exitCode, 0, reason: 'git $args: ${result.stderr}');
  }

  /// Commits a pubspec whose version line reads `version: [version]`,
  /// tagging it as [tag] if given.
  void release(String version, {String? tag}) {
    Directory('${dir.path}/citta').createSync(recursive: true);
    File('${dir.path}/citta/pubspec.yaml')
        .writeAsStringSync('name: citta\nversion: $version\n');
    _git(['add', '.']);
    _git(['commit', '-q', '-m', 'bump to $version']);
    if (tag != null) _git(['tag', '-a', tag, '-m', tag]);
  }

  /// Commits a file that isn't the pubspec, tagging it as [tag].
  void commitWithoutPubspec(String tag) {
    File('${dir.path}/README').writeAsStringSync(tag);
    _git(['add', '.']);
    _git(['commit', '-q', '-m', tag]);
    _git(['tag', '-a', tag, '-m', tag]);
  }

  /// Starts a new branch at [ref].
  void branchFrom(String ref) => _git(['checkout', '-q', '-b', 'side', ref]);

  ProcessResult check(List<String> args) => Process.runSync(
        'bash',
        [_scriptPath, ...args],
        workingDirectory: dir.path,
        environment: _gitEnv,
        includeParentEnvironment: false,
      );

  void delete() => dir.deleteSync(recursive: true);
}

void main() {
  group('docs/RELEASING.md', () {
    late String doc;

    setUpAll(() => doc = File(_docPath).readAsStringSync());

    test('contains a release checklist', () {
      expect(doc, contains('## Release checklist'));
      expect(doc, contains('- [ ]'));
    });

    test('states the build number rule', () {
      expect(doc, contains('versionCode'));
      expect(doc, contains('`+N`'));
    });

    test('states the tag rule', () {
      expect(doc, contains('`vX.Y.Z`'));
      expect(doc, contains('scripts/check-release-version.sh'));
    });

    test('tells the release PR to keep the release history current', () {
      expect(doc, contains('## Release history'));
      expect(doc, contains('- [ ] Add a row for `vX.Y.Z`'));
    });

    test('is linked from the README', () {
      final readme = File('../README.md').readAsStringSync();
      expect(readme, contains('](docs/RELEASING.md)'));
    });
  });

  test('pubspec.yaml version has the form X.Y.Z+N', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(
        pubspec,
        matches(RegExp(r'^version: "?\d+\.\d+\.\d+\+[1-9]\d*"?$',
            multiLine: true)));
  });

  group('check-release-version.sh', () {
    late _Repo repo;

    setUp(() => repo = _Repo());
    tearDown(() => repo.delete());

    test('fails with usage when no tag is given', () {
      final result = repo.check([]);
      expect(result.exitCode, 2);
      expect(result.stderr, contains('Usage'));
    });

    test('fails when the tag does not exist', () {
      repo.release('0.1.0+1');
      final result = repo.check(['v0.1.0']);
      expect(result.exitCode, isNot(0));
      expect(result.stderr, contains('v0.1.0'));
    });

    test('passes for the first release', () {
      repo.release('0.1.0+1', tag: 'v0.1.0');
      final result = repo.check(['v0.1.0']);
      expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');
      expect(result.stdout, contains('OK'));
    });

    test('passes when the build number increases', () {
      repo
        ..release('0.1.0+1', tag: 'v0.1.0')
        ..release('0.2.0+2', tag: 'v0.2.0');
      final result = repo.check(['v0.2.0']);
      expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');
    });

    test('reads the version at the tagged commit, not the working tree', () {
      repo
        ..release('0.2.0+2', tag: 'v0.2.0')
        ..release('0.3.0+3');
      final result = repo.check(['v0.2.0']);
      expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');
    });

    test('ignores later releases when re-checking an older tag', () {
      repo
        ..release('0.1.0+1', tag: 'v0.1.0')
        ..release('0.2.0+2', tag: 'v0.2.0');
      final result = repo.check(['v0.1.0']);
      expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');
    });

    test('ignores earlier v* tags that have no pubspec', () {
      repo
        ..commitWithoutPubspec('vendor-base')
        ..release('0.1.0+1', tag: 'v0.1.0');
      final result = repo.check(['v0.1.0']);
      expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');
    });

    test('fails with a message when the tagged commit has no pubspec', () {
      repo.commitWithoutPubspec('v0.1.0');
      final result = repo.check(['v0.1.0']);
      expect(result.exitCode, 1);
      expect(result.stdout, contains('no version'));
    });

    test('accepts a quoted version', () {
      repo.release('"0.1.0+1"', tag: 'v0.1.0');
      final result = repo.check(['v0.1.0']);
      expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');
    });

    test('fails when a build number is reused on another branch', () {
      repo
        ..release('0.1.0+1', tag: 'v0.1.0')
        ..release('0.2.0+2', tag: 'v0.2.0')
        ..branchFrom('v0.1.0')
        ..release('0.1.1+2', tag: 'v0.1.1');
      final result = repo.check(['v0.1.1']);
      expect(result.exitCode, 1);
      expect(result.stdout, contains('v0.2.0'));
    });

    test('fails when the tag does not match the version name', () {
      repo.release('0.2.1+2', tag: 'v0.2.0');
      final result = repo.check(['v0.2.0']);
      expect(result.exitCode, 1);
      expect(result.stdout, contains('0.2.1'));
    });

    test('fails when the version has no +N build number', () {
      repo.release('0.2.0', tag: 'v0.2.0');
      final result = repo.check(['v0.2.0']);
      expect(result.exitCode, 1);
      expect(result.stdout, contains('build number'));
    });

    test('fails when the build number is reused', () {
      repo
        ..release('0.1.0+2', tag: 'v0.1.0')
        ..release('0.2.0+2', tag: 'v0.2.0');
      final result = repo.check(['v0.2.0']);
      expect(result.exitCode, 1);
      expect(result.stdout, contains('v0.1.0'));
    });

    test('fails when the build number goes down', () {
      repo
        ..release('0.1.0+5', tag: 'v0.1.0')
        ..release('0.2.0+3', tag: 'v0.2.0');
      final result = repo.check(['v0.2.0']);
      expect(result.exitCode, 1);
    });
  });

  group('release CI', () {
    late String ci;

    setUpAll(() => ci = File('../.github/workflows/ci.yml').readAsStringSync());

    test('checks the tag against pubspec.yaml before building', () {
      final release = ci.indexOf('\n  release:');
      final check = ci.indexOf(r'scripts/check-release-version.sh', release);
      final build = ci.indexOf('flutter build apk --release', release);
      expect(release, isNonNegative);
      expect(check, isNonNegative);
      expect(check, lessThan(build));
    });

    test('fetches all tags so the build number can be compared', () {
      final release = ci.indexOf('\n  release:');
      expect(ci.indexOf('fetch-depth: 0', release), isNonNegative);
    });
  });
}
