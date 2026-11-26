import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Issue #106: Citta publishes a privacy policy (required by Google Play,
// expected by F-Droid users) at a stable public URL linked from the README.
// The policy's central claim is that the app makes no network requests, so
// the release (main) manifest must never request the INTERNET permission —
// adding it without revising PRIVACY.md would make the policy false.
const _mainManifest = 'android/app/src/main/AndroidManifest.xml';

/// The release manifest after Gradle merges in every plugin/library
/// manifest — the permissions the shipped APK actually requests. Only
/// present after `flutter build apk --release`; CI's release job builds it
/// and then re-runs this test, so a dependency that adds INTERNET via
/// manifest merging blocks the release even though [_mainManifest] is clean.
const _mergedReleaseManifest = 'build/app/intermediates/merged_manifests/'
    'release/processReleaseManifest/AndroidManifest.xml';
const _internet = 'android.permission.INTERNET';
const _policyReason = 'PRIVACY.md states Citta cannot connect to the '
    'internet; update the policy before adding network access';
const _privacyPolicy = '../PRIVACY.md';
const _readme = '../README.md';
const _publicUrl =
    'https://github.com/harsha-kadekar/citta/blob/master/PRIVACY.md';

/// Returns the `android:name` of every `<uses-permission>` element in a
/// manifest [source], ignoring XML comments and attribute order.
List<String> requestedPermissions(String source) {
  final uncommented = source.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
  return RegExp(r'<uses-permission\b[^>]*>', dotAll: true)
      .allMatches(uncommented)
      .map((m) => RegExp(r'android:name\s*=\s*"([^"]*)"')
          .firstMatch(m.group(0)!)
          ?.group(1))
      .whereType<String>()
      .toList();
}

void main() {
  group('requestedPermissions', () {
    test('reads names regardless of attribute order', () {
      const source = '<manifest>'
          '<uses-permission android:maxSdkVersion="28"\n'
          '    android:name="android.permission.INTERNET"/>'
          '</manifest>';
      expect(requestedPermissions(source), ['android.permission.INTERNET']);
    });

    test('ignores permissions inside XML comments', () {
      const source = '<manifest><!-- <uses-permission '
          'android:name="android.permission.INTERNET"/> --></manifest>';
      expect(requestedPermissions(source), isEmpty);
    });
  });

  group('privacy policy', () {
    test('release manifest does not request the INTERNET permission', () {
      expect(
        requestedPermissions(File(_mainManifest).readAsStringSync()),
        isNot(contains(_internet)),
        reason: _policyReason,
      );
    });

    test(
      'merged release manifest does not request the INTERNET permission',
      () {
        expect(
          requestedPermissions(
              File(_mergedReleaseManifest).readAsStringSync()),
          isNot(contains(_internet)),
          reason: '$_policyReason (a dependency may have added it via '
              'manifest merging)',
        );
      },
      skip: File(_mergedReleaseManifest).existsSync()
          ? false
          : 'no release build; run `flutter build apk --release` first',
    );

    test('PRIVACY.md exists at the repository root', () {
      final policy = File(_privacyPolicy);
      expect(policy.existsSync(), isTrue);
      expect(policy.readAsStringSync().trim(), isNotEmpty);
    });

    test('README links to the policy and its public URL', () {
      final readme = File(_readme).readAsStringSync();
      expect(readme, contains('](PRIVACY.md)'));
      expect(readme, contains(_publicUrl));
    });
  });
}
