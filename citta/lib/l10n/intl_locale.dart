import 'package:intl/intl.dart';

/// Returns [locale] if the intl package has locale data for it, otherwise
/// returns `'en'`.  This prevents [DateFormat] from throwing
/// `Invalid argument(s): Invalid locale "sa"` for locales the app supports
/// but the intl package does not ship data for (e.g. Sanskrit 'sa').
String safeIntlLocale(String locale) {
  try {
    DateFormat('y', locale);
    return locale;
  } on ArgumentError {
    return 'en';
  }
}
