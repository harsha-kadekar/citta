import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/session_model.dart';
import 'package:citta/models/timer_mode.dart';

SessionModel _makeSession({TimerMode timerMode = TimerMode.countdown}) {
  return SessionModel(
    id: 'abc',
    date: DateTime.utc(2026, 1, 1),
    duration: 600,
    timerMode: timerMode,
  );
}

void main() {
  group('SessionModel.timerMode', () {
    test('toJson serializes timerMode as its storage string', () {
      final json = _makeSession(timerMode: TimerMode.stopwatch).toJson();
      expect(json['timerMode'], equals('stopwatch'));
    });

    test('fromJson parses a stored "countdown" string to TimerMode.countdown',
        () {
      final session = SessionModel.fromJson({
        'id': 'abc',
        'date': DateTime.utc(2026, 1, 1).toIso8601String(),
        'duration': 600,
        'timerMode': 'countdown',
      });
      expect(session.timerMode, equals(TimerMode.countdown));
    });

    test('fromJson parses a stored "stopwatch" string to TimerMode.stopwatch',
        () {
      final session = SessionModel.fromJson({
        'id': 'abc',
        'date': DateTime.utc(2026, 1, 1).toIso8601String(),
        'duration': 600,
        'timerMode': 'stopwatch',
      });
      expect(session.timerMode, equals(TimerMode.stopwatch));
    });

    test('round-trips through toJson/fromJson for every TimerMode value', () {
      for (final mode in TimerMode.values) {
        final session = _makeSession(timerMode: mode);
        final restored = SessionModel.fromJson(session.toJson());
        expect(restored.timerMode, equals(mode));
      }
    });

    test('copyWith replaces timerMode', () {
      final session = _makeSession(timerMode: TimerMode.countdown);
      final updated = session.copyWith(timerMode: TimerMode.stopwatch);
      expect(updated.timerMode, equals(TimerMode.stopwatch));
      expect(session.timerMode, equals(TimerMode.countdown));
    });
  });
}
