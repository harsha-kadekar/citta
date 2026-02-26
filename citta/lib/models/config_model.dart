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
  })  : tags = tags ?? List.of(defaultTags),
        quoteSources = quoteSources ?? List.of(defaultQuoteSources);

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
    String? backgroundMusic,
    bool? calendarViewEnabled,
    String? userName,
    String? themeMode,
    String? language,
    List<String>? tags,
    List<String>? quoteSources,
  }) {
    return ConfigModel(
      timerMode: timerMode ?? this.timerMode,
      countdownDuration: countdownDuration ?? this.countdownDuration,
      bellStart: bellStart ?? this.bellStart,
      bellEnd: bellEnd ?? this.bellEnd,
      bellInterval: bellInterval ?? this.bellInterval,
      intervalDuration: intervalDuration ?? this.intervalDuration,
      intervalEnabled: intervalEnabled ?? this.intervalEnabled,
      backgroundMusic: backgroundMusic ?? this.backgroundMusic,
      calendarViewEnabled: calendarViewEnabled ?? this.calendarViewEnabled,
      userName: userName ?? this.userName,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      tags: tags ?? List.from(this.tags),
      quoteSources: quoteSources ?? List.from(this.quoteSources),
    );
  }
}
