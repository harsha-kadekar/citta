import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Issue #103: the Android applicationId is permanent once the app is on a
// store (and has already shipped in the GitHub release APK since v0.3.0;
// v0.1.0–v0.2.1 used the placeholder `com.example.citta`). These tests pin it,
// and keep every place that encodes it in sync, so an accidental rename fails
// CI instead of silently shipping a "new" app.
// See docs/android-application-id.md at the repo root for the decision record.
const _appId = 'com.hkadekar.citta';

const _gradlePath = 'android/app/build.gradle.kts';

/// Returns the string value of the first uncommented `key = "..."`
/// assignment in a Gradle Kotlin DSL [source], or null if none exists.
String? gradleStringValue(String source, String key) => RegExp(
      '^\\s*$key\\s*=\\s*"([^"]+)"',
      multiLine: true,
    ).firstMatch(source)?.group(1);

void main() {
  group('gradleStringValue', () {
    test('ignores a commented-out assignment above the real one', () {
      const source = '''
    // applicationId = "$_appId"
    applicationId = "com.example.other"
''';
      expect(gradleStringValue(source, 'applicationId'), 'com.example.other');
    });

    test('does not match a key that only appears as a suffix', () {
      expect(gradleStringValue('testNamespace = "x.y"', 'namespace'), isNull);
    });
  });

  group('Android application ID', () {
    late String gradle;

    setUpAll(() {
      gradle = File(_gradlePath).readAsStringSync();
    });

    test('applicationId is the finalized $_appId', () {
      expect(gradleStringValue(gradle, 'applicationId'), _appId);
    });

    test('namespace matches the applicationId', () {
      expect(gradleStringValue(gradle, 'namespace'), _appId);
    });

    test('MainActivity.kt package and directory match the namespace', () {
      final activity = File(
        'android/app/src/main/kotlin/${_appId.replaceAll('.', '/')}/MainActivity.kt',
      );
      expect(activity.existsSync(), isTrue,
          reason: 'MainActivity.kt must live under the namespace path');
      expect(
        RegExp(r'^package\s+(\S+)', multiLine: true)
            .firstMatch(activity.readAsStringSync())
            ?.group(1),
        _appId,
      );
    });
  });
}
