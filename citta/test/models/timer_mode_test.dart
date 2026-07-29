import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/timer_mode.dart';

void main() {
  group('TimerMode.toStorageString', () {
    test('countdown serializes to "countdown"', () {
      expect(TimerMode.countdown.toStorageString(), equals('countdown'));
    });

    test('stopwatch serializes to "stopwatch"', () {
      expect(TimerMode.stopwatch.toStorageString(), equals('stopwatch'));
    });
  });

  group('TimerModeStorage.fromStorageString', () {
    test('"countdown" parses to TimerMode.countdown', () {
      expect(TimerModeStorage.fromStorageString('countdown'),
          equals(TimerMode.countdown));
    });

    test('"stopwatch" parses to TimerMode.stopwatch', () {
      expect(TimerModeStorage.fromStorageString('stopwatch'),
          equals(TimerMode.stopwatch));
    });

    test('null falls back to TimerMode.countdown by default', () {
      expect(
          TimerModeStorage.fromStorageString(null), equals(TimerMode.countdown));
    });

    test('unrecognized value falls back to TimerMode.countdown by default', () {
      expect(TimerModeStorage.fromStorageString('interval'),
          equals(TimerMode.countdown));
    });

    test('caller-supplied fallback is honored for null input', () {
      expect(
          TimerModeStorage.fromStorageString(null,
              fallback: TimerMode.stopwatch),
          equals(TimerMode.stopwatch));
    });

    test('caller-supplied fallback is honored for unrecognized input', () {
      expect(
          TimerModeStorage.fromStorageString('bogus',
              fallback: TimerMode.stopwatch),
          equals(TimerMode.stopwatch));
    });
  });

  group('TimerMode round-trip', () {
    test('every value survives toStorageString -> fromStorageString', () {
      for (final mode in TimerMode.values) {
        expect(TimerModeStorage.fromStorageString(mode.toStorageString()),
            equals(mode));
      }
    });
  });
}
