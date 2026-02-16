import 'package:flutter_test/flutter_test.dart';
import 'package:citta/services/timer_service.dart';

void main() {
  late TimerService timerService;

  setUp(() {
    timerService = TimerService();
  });

  tearDown(() {
    timerService.dispose();
  });

  group('TimerService - Configuration', () {
    test('default configuration', () {
      expect(timerService.mode, TimerMode.countdown);
      expect(timerService.state, TimerState.idle);
      expect(timerService.elapsedSeconds, 0);
    });

    test('configure sets mode and duration', () {
      timerService.configure(
        mode: TimerMode.stopwatch,
        targetDuration: 600,
      );
      expect(timerService.mode, TimerMode.stopwatch);
      expect(timerService.targetDuration, 600);
    });

    test('cannot configure while running', () {
      timerService.start();
      timerService.configure(mode: TimerMode.stopwatch);
      // Should still be countdown since configure is ignored when running
      expect(timerService.mode, TimerMode.countdown);
    });
  });

  group('TimerService - Display', () {
    test('displayTime format for countdown', () {
      timerService.configure(targetDuration: 1200);
      expect(timerService.displayTime, '20:00');
    });

    test('displayTime format for stopwatch', () {
      timerService.configure(mode: TimerMode.stopwatch);
      expect(timerService.displayTime, '00:00');
    });

    test('progress is 0 at start', () {
      timerService.configure(targetDuration: 600);
      expect(timerService.progress, 0.0);
    });
  });

  group('TimerService - State Transitions', () {
    test('start changes state to running', () {
      timerService.start();
      expect(timerService.state, TimerState.running);
    });

    test('pause changes state to paused', () {
      timerService.start();
      timerService.pause();
      expect(timerService.state, TimerState.paused);
    });

    test('resume changes state back to running', () {
      timerService.start();
      timerService.pause();
      timerService.resume();
      expect(timerService.state, TimerState.running);
    });

    test('stop changes state to completed', () {
      timerService.start();
      timerService.stop();
      expect(timerService.state, TimerState.completed);
    });

    test('reset returns to idle', () {
      timerService.start();
      timerService.stop();
      timerService.reset();
      expect(timerService.state, TimerState.idle);
      expect(timerService.elapsedSeconds, 0);
    });

    test('cannot pause when idle', () {
      timerService.pause();
      expect(timerService.state, TimerState.idle);
    });

    test('cannot resume when not paused', () {
      timerService.start();
      timerService.resume(); // already running
      expect(timerService.state, TimerState.running);
    });
  });

  group('TimerService - Callbacks', () {
    test('onStart is called', () {
      bool startCalled = false;
      timerService.onStart = () => startCalled = true;
      timerService.start();
      expect(startCalled, true);
    });

    test('onComplete is called when countdown finishes', () async {
      bool completeCalled = false;
      timerService.configure(targetDuration: 1);
      timerService.onComplete = () => completeCalled = true;
      timerService.start();

      // Wait for timer to complete
      await Future.delayed(const Duration(seconds: 2));
      expect(completeCalled, true);
      expect(timerService.state, TimerState.completed);
    });

    test('onIntervalBell is called at intervals', () async {
      int intervalCount = 0;
      timerService.configure(
        targetDuration: 10,
        intervalDuration: 1,
        intervalEnabled: true,
      );
      timerService.onIntervalBell = () => intervalCount++;
      timerService.start();

      await Future.delayed(const Duration(seconds: 3, milliseconds: 500));
      timerService.stop();
      expect(intervalCount, greaterThanOrEqualTo(2));
    });
  });
}
