import 'package:flutter/widgets.dart' show BuildContext, Localizations;
import 'package:intl/intl.dart';
import '../l10n/intl_locale.dart';

/// Display variants for [formatDuration].
enum DurationDisplayStyle {
  /// Minutes only, e.g. `5m`. Used where space is tight (stats tiles).
  compact,

  /// Minutes and seconds, e.g. `5m 30s`, falling back to `45s` under a
  /// minute. Does not roll over into hours.
  short,

  /// Same as [short], but rolls over into hours as `1h 5m` once the
  /// duration reaches an hour.
  full,
}

/// Formats a duration given in [totalSeconds] according to [style].
String formatDuration(
  int totalSeconds, {
  DurationDisplayStyle style = DurationDisplayStyle.short,
}) {
  if (style == DurationDisplayStyle.compact) {
    return '${totalSeconds ~/ 60}m';
  }

  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;

  if (style == DurationDisplayStyle.full) {
    final hours = totalSeconds ~/ 3600;
    if (hours > 0) {
      return '${hours}h ${(totalSeconds % 3600) ~/ 60}m';
    }
  }

  if (minutes == 0) return '${seconds}s';
  return seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes}m';
}

/// Resolves the current locale from [context], falling back to `en` for
/// locales the intl package has no data for.
String currentLocaleStr(BuildContext context) =>
    safeIntlLocale(Localizations.localeOf(context).toString());

/// Formats [date] as a locale-appropriate abbreviated date, e.g. `Mar 5,
/// 2024` for `en` or `5. März 2024` for `de`.
String formatSessionDate(DateTime date, String localeStr) =>
    DateFormat.yMMMd(localeStr).format(date);

/// Formats [date]'s time of day using the locale's conventional 12h/24h
/// clock, e.g. `9:05 AM` for `en` or `09:05` for `de`.
String formatSessionTime(DateTime date, String localeStr) =>
    DateFormat.jm(localeStr).format(date);

/// Formats [date] as `MMMM y`, e.g. `March 2024`.
String formatMonthYear(DateTime date, String localeStr) =>
    DateFormat('MMMM y', localeStr).format(date);

/// Formats [date]'s weekday abbreviation, e.g. `Mon`.
String formatWeekdayShort(DateTime date, String localeStr) =>
    DateFormat('E', localeStr).format(date);
