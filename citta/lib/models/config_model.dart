class ConfigModel {
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

  ConfigModel({
    this.timerMode = 'countdown',
    this.countdownDuration = 1200,
    this.bellStart = 'bundled:tibetan_bowl',
    this.bellEnd = 'bundled:tibetan_bowl',
    this.bellInterval = 'bundled:soft_chime',
    this.intervalDuration = 300,
    this.intervalEnabled = false,
    this.backgroundMusic,
    this.calendarViewEnabled = false,
    List<String>? tags,
    List<String>? quoteSources,
  })  : tags = tags ?? ['calm', 'restless', 'deep', 'distracted'],
        quoteSources = quoteSources ??
            [
              'subhashita',
              'yoga_sutra',
              'bhagavad_gita',
              'upanishad',
              'ramayana',
              'mahabharata',
            ];

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(
      timerMode: json['timerMode'] as String? ?? 'countdown',
      countdownDuration: json['countdownDuration'] as int? ?? 1200,
      bellStart: json['bellStart'] as String? ?? 'bundled:tibetan_bowl',
      bellEnd: json['bellEnd'] as String? ?? 'bundled:tibetan_bowl',
      bellInterval: json['bellInterval'] as String? ?? 'bundled:soft_chime',
      intervalDuration: json['intervalDuration'] as int? ?? 300,
      intervalEnabled: json['intervalEnabled'] as bool? ?? false,
      backgroundMusic: json['backgroundMusic'] as String?,
      calendarViewEnabled: json['calendarViewEnabled'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          ['calm', 'restless', 'deep', 'distracted'],
      quoteSources: (json['quoteSources'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [
            'subhashita',
            'yoga_sutra',
            'bhagavad_gita',
            'upanishad',
            'ramayana',
            'mahabharata',
          ],
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
      tags: tags ?? List.from(this.tags),
      quoteSources: quoteSources ?? List.from(this.quoteSources),
    );
  }
}
