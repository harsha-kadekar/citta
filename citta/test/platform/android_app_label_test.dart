import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Issue #104: the Android launcher / store label must read "Citta", not the
// lowercase project name Flutter scaffolded ("citta"). The label is sourced
// from a single `app_name` string resource that keeps the brand name in one
// place; it is a brand name, so it is marked non-translatable and no
// qualified `values-*` resource may rename it.
const _appName = 'Citta';
const _labelResource = '@string/app_name';

const _srcDir = 'android/app/src';
const _mainManifest = '$_srcDir/main/AndroidManifest.xml';
const _resDir = '$_srcDir/main/res';

/// Returns the `android:label` attribute of the `<application>` element in
/// a manifest [source], or null if absent.
String? applicationLabel(String source) {
  final app = RegExp(r'<application\b[^>]*>', dotAll: true).firstMatch(source);
  if (app == null) return null;
  return RegExp(r'android:label\s*=\s*"([^"]*)"')
      .firstMatch(app.group(0)!)
      ?.group(1);
}

/// Returns every value of `<string name="[name]">` in a resources [source],
/// regardless of attribute order.
List<String> stringResources(String source, String name) => RegExp(
      '<string\\b[^>]*\\bname="$name"[^>]*>([^<]*)</string>',
    ).allMatches(source).map((m) => m.group(1)!).toList();

/// Returns every `app_name` value defined in any XML file directly under
/// the resource directory [dir].
List<String> appNamesIn(Directory dir) => dir
    .listSync()
    .whereType<File>()
    .where((f) => f.path.endsWith('.xml'))
    .expand((f) => stringResources(f.readAsStringSync(), 'app_name'))
    .toList();

String _baseName(FileSystemEntity e) =>
    e.uri.pathSegments.lastWhere((s) => s.isNotEmpty);

void main() {
  group('applicationLabel', () {
    test('reads the label from the <application> element only', () {
      const source = '''
<manifest>
    <application
        android:name="x"
        android:label="Foo">
        <activity android:label="Bar"/>
    </application>
</manifest>''';
      expect(applicationLabel(source), 'Foo');
    });

    test('returns null when <application> has no label', () {
      const source = '<manifest><application android:name="x">'
          '<activity android:label="Bar"/></application></manifest>';
      expect(applicationLabel(source), isNull);
    });
  });

  group('stringResources', () {
    test('matches regardless of attribute order', () {
      const source = '<resources>'
          '<string translatable="false" name="app_name">Citta</string>'
          '</resources>';
      expect(stringResources(source, 'app_name'), ['Citta']);
    });

    test('does not match a name that only ends with the key', () {
      const source = '<string name="old_app_name">x</string>';
      expect(stringResources(source, 'app_name'), isEmpty);
    });
  });

  group('Android launcher label', () {
    test('main manifest uses the $_labelResource resource', () {
      expect(
        applicationLabel(File(_mainManifest).readAsStringSync()),
        _labelResource,
      );
    });

    test('res/values defines app_name exactly once, as "$_appName"', () {
      expect(appNamesIn(Directory('$_resDir/values')), [_appName]);
    });

    test('no build-type manifest overrides the application label', () {
      for (final buildType in ['debug', 'profile']) {
        final manifest = File('$_srcDir/$buildType/AndroidManifest.xml');
        if (!manifest.existsSync()) continue;
        expect(applicationLabel(manifest.readAsStringSync()), isNull,
            reason: '$buildType manifest must not override android:label');
      }
    });

    test('no qualified values-* resource renames the app', () {
      final qualified = Directory(_resDir)
          .listSync()
          .whereType<Directory>()
          .where((d) => _baseName(d).startsWith('values-'));
      for (final dir in qualified) {
        for (final value in appNamesIn(dir)) {
          expect(value, _appName, reason: '${dir.path} renames the app');
        }
      }
    });
  });
}
