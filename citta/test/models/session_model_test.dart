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

  group('SessionModel value equality', () {
    SessionModel session({
      String id = 'abc',
      DateTime? date,
      int duration = 600,
      TimerMode timerMode = TimerMode.countdown,
      String? notes,
      List<String>? tags,
      bool completedFully = true,
    }) =>
        SessionModel(
          id: id,
          date: date ?? DateTime.utc(2026, 1, 1),
          duration: duration,
          timerMode: timerMode,
          notes: notes,
          tags: tags,
          completedFully: completedFully,
        );

    test('two sessions with identical fields (incl. tags content) are ==', () {
      final a = session(tags: ['calm', 'deep']);
      final b = session(tags: ['calm', 'deep']);
      expect(identical(a.tags, b.tags), isFalse);
      expect(a == b, isTrue);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('sessions differing only in id are not ==', () {
      expect(session(id: 'a') == session(id: 'b'), isFalse);
    });

    test('sessions differing only in duration are not ==', () {
      expect(session(duration: 100) == session(duration: 200), isFalse);
    });

    test('sessions differing only in tags content are not ==', () {
      expect(session(tags: ['calm']) == session(tags: ['calm', 'deep']), isFalse);
    });

    test('sessions differing only in completedFully are not ==', () {
      expect(session(completedFully: true) == session(completedFully: false), isFalse);
    });

    test('sessions differing only in date are not ==', () {
      expect(
        session(date: DateTime.utc(2026, 1, 1)) ==
            session(date: DateTime.utc(2026, 1, 2)),
        isFalse,
      );
    });

    test('sessions differing only in timerMode are not ==', () {
      expect(
        session(timerMode: TimerMode.countdown) ==
            session(timerMode: TimerMode.stopwatch),
        isFalse,
      );
    });

    test('sessions differing only in notes are not ==', () {
      expect(session(notes: 'a') == session(notes: 'b'), isFalse);
    });

    test('tags list is unmodifiable — external add throws', () {
      final s = session(tags: ['calm']);
      expect(() => s.tags.add('deep'), throwsUnsupportedError,
          reason: 'tags must be defensively copied so callers cannot bypass '
              'copyWith and silently change hashCode/equality after construction');
    });

    test('mutating the caller-supplied list after construction does not change the session',
        () {
      final callerTags = ['calm'];
      final s = SessionModel(
        id: 'abc',
        date: DateTime.utc(2026, 1, 1),
        duration: 600,
        timerMode: TimerMode.countdown,
        tags: callerTags,
      );
      final hashBefore = s.hashCode;
      callerTags.add('deep');
      expect(s.tags, equals(['calm']),
          reason: 'SessionModel must not hold a live reference to the '
              "caller's list — otherwise external mutation silently changes "
              "an already-constructed session's equality/hashCode");
      expect(s.hashCode, equals(hashBefore));
    });
  });
}
