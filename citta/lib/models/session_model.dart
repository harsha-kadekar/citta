class SessionModel {
  final String id;
  final DateTime date;
  final int duration; // seconds
  final String timerMode;
  final String? notes;
  final List<String> tags;
  final bool completedFully;

  SessionModel({
    required this.id,
    required this.date,
    required this.duration,
    required this.timerMode,
    this.notes,
    List<String>? tags,
    this.completedFully = true,
  }) : tags = tags ?? [];

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      duration: json['duration'] as int,
      timerMode: json['timerMode'] as String,
      notes: json['notes'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      completedFully: json['completedFully'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toUtc().toIso8601String(),
      'duration': duration,
      'timerMode': timerMode,
      'notes': notes,
      'tags': tags,
      'completedFully': completedFully,
    };
  }

  SessionModel copyWith({
    String? id,
    DateTime? date,
    int? duration,
    String? timerMode,
    String? notes,
    List<String>? tags,
    bool? completedFully,
  }) {
    return SessionModel(
      id: id ?? this.id,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      timerMode: timerMode ?? this.timerMode,
      notes: notes ?? this.notes,
      tags: tags ?? List.from(this.tags),
      completedFully: completedFully ?? this.completedFully,
    );
  }
}
