import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// A [MaterialLocalizations] delegate that handles every locale by falling
/// back to English for any locale not natively covered by Flutter's SDK
/// (e.g. Sanskrit 'sa').  This prevents "NoMaterialLocalizationsFound" crashes
/// when the app supports a locale that Flutter's built-in delegates do not.
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    final effectiveLocale =
        GlobalMaterialLocalizations.delegate.isSupported(locale)
            ? locale
            : const Locale('en');
    return GlobalMaterialLocalizations.delegate.load(effectiveLocale);
  }

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

/// A [CupertinoLocalizations] delegate that falls back to English for any
/// locale not natively supported by Flutter's [GlobalCupertinoLocalizations].
class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    final effectiveLocale =
        GlobalCupertinoLocalizations.delegate.isSupported(locale)
            ? locale
            : const Locale('en');
    return GlobalCupertinoLocalizations.delegate.load(effectiveLocale);
  }

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}
