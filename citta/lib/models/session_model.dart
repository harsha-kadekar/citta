import 'package:flutter/foundation.dart' show listEquals;
import 'timer_mode.dart';

class SessionModel {
  final String id;
  final DateTime date;
  final int duration; // seconds
  final TimerMode timerMode;
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
  }) : tags = List.unmodifiable(tags ?? const []);

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      duration: json['duration'] as int,
      timerMode: TimerModeStorage.fromStorageString(json['timerMode'] as String?),
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
      'timerMode': timerMode.toStorageString(),
      'notes': notes,
      'tags': tags,
      'completedFully': completedFully,
    };
  }

  SessionModel copyWith({
    String? id,
    DateTime? date,
    int? duration,
    TimerMode? timerMode,
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
      tags: tags ?? this.tags,
      completedFully: completedFully ?? this.completedFully,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          date == other.date &&
          duration == other.duration &&
          timerMode == other.timerMode &&
          notes == other.notes &&
          listEquals(tags, other.tags) &&
          completedFully == other.completedFully;

  @override
  int get hashCode => Object.hash(
        id,
        date,
        duration,
        timerMode,
        notes,
        Object.hashAll(tags),
        completedFully,
      );
}
