// Private sentinel type used by ConfigModel.copyWith to distinguish "caller
// passed null explicitly" (clear the field) from "caller omitted the argument"
// (keep the existing value).  A named private class makes the sentinel
// unforgeable from outside this library — unlike `const Object()`, external
// code cannot construct a `_Unset` and accidentally trigger the sentinel path.
import 'timer_mode.dart';
import 'app_theme_mode.dart';
import 'app_language.dart';
import 'audio_source.dart';

class _Unset {
  const _Unset();
}

const _unset = _Unset();

class ConfigModel {
  static const TimerMode defaultTimerMode = TimerMode.countdown;
  static const int defaultCountdownDuration = 900;
  static const AudioSource defaultBellStart =
      AudioSource.bundled('bright_tibetan_bell');
  static const AudioSource defaultBellEnd = AudioSource.bundled('bell_meditation');
  static const AudioSource defaultBellInterval = AudioSource.bundled('singing_bell');
  static const int defaultIntervalDuration = 300;
  static const bool defaultIntervalEnabled = false;
  static const bool defaultCalendarViewEnabled = false;
  static const AppThemeMode defaultThemeMode = AppThemeMode.dark;
  static const AppLanguage defaultLanguage = AppLanguage.system;
  static const List<String> defaultTags = ['calm', 'restless', 'deep', 'distracted'];
  static const List<String> defaultQuoteSources = [
    'subhashita',
    'yoga_sutra',
    'bhagavad_gita',
    'upanishad',
    'ramayana',
    'mahabharata',
  ];

  final TimerMode timerMode;
  final int countdownDuration; // seconds
  final AudioSource bellStart;
  final AudioSource bellEnd;
  final AudioSource bellInterval;
  final int intervalDuration; // seconds
  final bool intervalEnabled;
  final AudioSource? backgroundMusic;
  final bool calendarViewEnabled;
  final List<String> tags;
  final List<String> quoteSources;
  final String? userName;
  final AppThemeMode themeMode;
  final AppLanguage language;

  // Public constructor: always wraps caller-supplied lists as unmodifiable so
  // external mutations cannot corrupt stored state.
  ConfigModel({
    this.timerMode = defaultTimerMode,
    this.countdownDuration = defaultCountdownDuration,
    this.bellStart = defaultBellStart,
    this.bellEnd = defaultBellEnd,
    this.bellInterval = defaultBellInterval,
    this.intervalDuration = defaultIntervalDuration,
    this.intervalEnabled = defaultIntervalEnabled,
    this.backgroundMusic,
    this.calendarViewEnabled = defaultCalendarViewEnabled,
    this.userName,
    this.themeMode = defaultThemeMode,
    this.language = defaultLanguage,
    List<String>? tags,
    List<String>? quoteSources,
  // When the caller omits tags/quoteSources, reuse the const references
  // directly so that context.select() equality checks on these lists remain
  // stable across repeated loadConfig() calls.  Only wrap in List.unmodifiable
  // when the caller supplies an explicit (mutable) list.
  })  : tags = tags != null ? List.unmodifiable(tags) : defaultTags,
        quoteSources =
            quoteSources != null ? List.unmodifiable(quoteSources) : defaultQuoteSources;

  // Private constructor used by copyWith: accepts pre-validated list references
  // directly without re-wrapping, so the caller can preserve the same reference
  // and context.select() equality checks work correctly.
  // CONTRACT: callers must pass already-unmodifiable lists for tags and
  // quoteSources — this constructor does NOT wrap them.
  ConfigModel._internal({
    required this.timerMode,
    required this.countdownDuration,
    required this.bellStart,
    required this.bellEnd,
    required this.bellInterval,
    required this.intervalDuration,
    required this.intervalEnabled,
    required this.backgroundMusic,
    required this.calendarViewEnabled,
    required this.userName,
    required this.themeMode,
    required this.language,
    required this.tags,
    required this.quoteSources,
  }) {
    // Verify immutability without mutating: setting list[i]=list[i] writes the
    // same value back (no observable state change) but throws UnsupportedError
    // on unmodifiable lists, which is what we require.
    assert(() {
      try {
        if (tags.isNotEmpty) tags[0] = tags[0];
        return false; // no exception → list is mutable
      } on UnsupportedError {
        return true;
      }
    }() || tags.isEmpty, '_internal: tags must already be an unmodifiable list');
    assert(() {
      try {
        if (quoteSources.isNotEmpty) quoteSources[0] = quoteSources[0];
        return false;
      } on UnsupportedError {
        return true;
      }
    }() || quoteSources.isEmpty,
        '_internal: quoteSources must already be an unmodifiable list');
  }

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    final bellStartJson = json['bellStart'] as String?;
    final bellEndJson = json['bellEnd'] as String?;
    final bellIntervalJson = json['bellInterval'] as String?;
    final backgroundMusicJson = json['backgroundMusic'] as String?;
    return ConfigModel(
      timerMode: TimerModeStorage.fromStorageString(json['timerMode'] as String?,
          fallback: defaultTimerMode),
      countdownDuration: json['countdownDuration'] as int? ?? defaultCountdownDuration,
      bellStart: bellStartJson != null
          ? AudioSource.fromStorageString(bellStartJson)
          : defaultBellStart,
      bellEnd: bellEndJson != null
          ? AudioSource.fromStorageString(bellEndJson)
          : defaultBellEnd,
      bellInterval: bellIntervalJson != null
          ? AudioSource.fromStorageString(bellIntervalJson)
          : defaultBellInterval,
      intervalDuration: json['intervalDuration'] as int? ?? defaultIntervalDuration,
      intervalEnabled: json['intervalEnabled'] as bool? ?? defaultIntervalEnabled,
      backgroundMusic: backgroundMusicJson != null
          ? AudioSource.fromStorageString(backgroundMusicJson,
              allowBundled: false, allowRawPath: true)
          : null,
      calendarViewEnabled: json['calendarViewEnabled'] as bool? ?? defaultCalendarViewEnabled,
      userName: json['userName'] as String?,
      themeMode: AppThemeModeStorage.fromStorageString(json['themeMode'] as String?,
          fallback: defaultThemeMode),
      language: AppLanguageStorage.fromStorageString(json['language'] as String?,
          fallback: defaultLanguage),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      quoteSources: (json['quoteSources'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timerMode': timerMode.toStorageString(),
      'countdownDuration': countdownDuration,
      'bellStart': bellStart.toStorageString(),
      'bellEnd': bellEnd.toStorageString(),
      'bellInterval': bellInterval.toStorageString(),
      'intervalDuration': intervalDuration,
      'intervalEnabled': intervalEnabled,
      'backgroundMusic': backgroundMusic?.toStorageString(),
      'calendarViewEnabled': calendarViewEnabled,
      'userName': userName,
      'themeMode': themeMode.toStorageString(),
      'language': language.toStorageString(),
      'tags': tags,
      'quoteSources': quoteSources,
    };
  }

  ConfigModel copyWith({
    TimerMode? timerMode,
    int? countdownDuration,
    AudioSource? bellStart,
    AudioSource? bellEnd,
    AudioSource? bellInterval,
    int? intervalDuration,
    bool? intervalEnabled,
    // Use Object? + _unset sentinel so callers can pass null to clear these
    // nullable fields.  AudioSource? would make null indistinguishable from
    // "omitted".
    Object? backgroundMusic = _unset,
    bool? calendarViewEnabled,
    Object? userName = _unset,
    AppThemeMode? themeMode,
    AppLanguage? language,
    List<String>? tags,
    List<String>? quoteSources,
  }) {
    assert(
      identical(backgroundMusic, _unset) ||
          backgroundMusic == null ||
          backgroundMusic is AudioSource,
      'backgroundMusic must be AudioSource or null',
    );
    assert(
      identical(userName, _unset) || userName == null || userName is String,
      'userName must be String or null',
    );
    return ConfigModel._internal(
      timerMode: timerMode ?? this.timerMode,
      countdownDuration: countdownDuration ?? this.countdownDuration,
      bellStart: bellStart ?? this.bellStart,
      bellEnd: bellEnd ?? this.bellEnd,
      bellInterval: bellInterval ?? this.bellInterval,
      intervalDuration: intervalDuration ?? this.intervalDuration,
      intervalEnabled: intervalEnabled ?? this.intervalEnabled,
      backgroundMusic: identical(backgroundMusic, _unset)
          ? this.backgroundMusic
          : backgroundMusic as AudioSource?,
      calendarViewEnabled: calendarViewEnabled ?? this.calendarViewEnabled,
      userName: identical(userName, _unset)
          ? this.userName
          : userName as String?,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      // Preserve the existing reference when unchanged so that context.select()
      // equality checks skip unnecessary rebuilds.  Wrap in unmodifiable only
      // when the caller explicitly provides a new list.
      tags: tags != null ? List.unmodifiable(tags) : this.tags,
      quoteSources: quoteSources != null ? List.unmodifiable(quoteSources) : this.quoteSources,
    );
  }

  /// Returns a copy with device-local audio paths replaced by bundled defaults.
  /// Call this whenever loading config from an external source (import, sync,
  /// QR restore) that may contain file paths from a different device.
  ConfigModel sanitizeForDevice() => copyWith(
        bellStart: bellStart.isCustom ? defaultBellStart : bellStart,
        bellEnd: bellEnd.isCustom ? defaultBellEnd : bellEnd,
        bellInterval: bellInterval.isCustom ? defaultBellInterval : bellInterval,
        backgroundMusic: null,
      );
}
