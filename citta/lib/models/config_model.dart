// Sentinel used by ConfigModel.copyWith to distinguish "caller passed null
// explicitly" (clear the field) from "caller omitted the argument" (keep the
// existing value).  Using a top-level const avoids allocating on every call.
const _unset = Object();

class ConfigModel {
  static const String defaultTimerMode = 'countdown';
  static const int defaultCountdownDuration = 900;
  static const String defaultBellStart = 'bundled:bright_tibetan_bell';
  static const String defaultBellEnd = 'bundled:bell_meditation';
  static const String defaultBellInterval = 'bundled:singing_bell';
  static const int defaultIntervalDuration = 300;
  static const bool defaultIntervalEnabled = false;
  static const bool defaultCalendarViewEnabled = false;
  static const String defaultThemeMode = 'dark';
  static const String defaultLanguage = 'system';
  static const List<String> defaultTags = ['calm', 'restless', 'deep', 'distracted'];
  static const List<String> defaultQuoteSources = [
    'subhashita',
    'yoga_sutra',
    'bhagavad_gita',
    'upanishad',
    'ramayana',
    'mahabharata',
  ];

  String timerMode; // "countdown" or "stopwatch"
  int countdownDuration; // seconds
  String bellStart;
  String bellEnd;
  String bellInterval;
  int intervalDuration; // seconds
  bool intervalEnabled;
  String? backgroundMusic;
  bool calendarViewEnabled;
  List<String> tags;
  List<String> quoteSources;
  String? userName;
  String themeMode; // 'dark', 'light', or 'system'
  String language; // 'system', 'en', 'kn', 'sa', 'hi', 'te', 'ta', 'ml', 'fr', 'de', 'ja', 'he', 'zh'

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
  })  : tags = List.unmodifiable(tags ?? defaultTags),
        quoteSources = List.unmodifiable(quoteSources ?? defaultQuoteSources);

  // Private constructor used by copyWith: accepts pre-validated list references
  // directly without re-wrapping, so the caller can preserve the same reference
  // and context.select() equality checks work correctly.
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
  });

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(
      timerMode: json['timerMode'] as String? ?? defaultTimerMode,
      countdownDuration: json['countdownDuration'] as int? ?? defaultCountdownDuration,
      bellStart: json['bellStart'] as String? ?? defaultBellStart,
      bellEnd: json['bellEnd'] as String? ?? defaultBellEnd,
      bellInterval: json['bellInterval'] as String? ?? defaultBellInterval,
      intervalDuration: json['intervalDuration'] as int? ?? defaultIntervalDuration,
      intervalEnabled: json['intervalEnabled'] as bool? ?? defaultIntervalEnabled,
      backgroundMusic: json['backgroundMusic'] as String?,
      calendarViewEnabled: json['calendarViewEnabled'] as bool? ?? defaultCalendarViewEnabled,
      userName: json['userName'] as String?,
      themeMode: json['themeMode'] as String? ?? defaultThemeMode,
      language: json['language'] as String? ?? defaultLanguage,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      quoteSources: (json['quoteSources'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timerMode': timerMode,
      'countdownDuration': countdownDuration,
      'bellStart': bellStart,
      'bellEnd': bellEnd,
      'bellInterval': bellInterval,
      'intervalDuration': intervalDuration,
      'intervalEnabled': intervalEnabled,
      'backgroundMusic': backgroundMusic,
      'calendarViewEnabled': calendarViewEnabled,
      'userName': userName,
      'themeMode': themeMode,
      'language': language,
      'tags': tags,
      'quoteSources': quoteSources,
    };
  }

  ConfigModel copyWith({
    String? timerMode,
    int? countdownDuration,
    String? bellStart,
    String? bellEnd,
    String? bellInterval,
    int? intervalDuration,
    bool? intervalEnabled,
    // Use Object? + _unset sentinel so callers can pass null to clear these
    // nullable fields.  String? would make null indistinguishable from "omitted".
    Object? backgroundMusic = _unset,
    bool? calendarViewEnabled,
    Object? userName = _unset,
    String? themeMode,
    String? language,
    List<String>? tags,
    List<String>? quoteSources,
  }) {
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
          : backgroundMusic as String?,
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
}
