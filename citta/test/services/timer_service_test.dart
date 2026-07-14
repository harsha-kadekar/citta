import 'package:flutter_test/flutter_test.dart';
import 'package:citta/services/timer_service.dart';

// ---------------------------------------------------------------------------
// Fake TimerTicker
// ---------------------------------------------------------------------------

/// Synchronous [TimerTickerBase] test double. Call [tick] to advance time by
/// one interval per call — no `Zone`/event-loop involvement, so timer
/// progression is fully deterministic in tests.
class FakeTimerTicker implements TimerTickerBase {
  void Function()? _onTick;
  Duration? _interval;
  bool _running = false;

  bool get isRunning => _running;
  Duration? get interval => _interval;

  @override
  void start(Duration interval, void Function() onTick) {
    _interval = interval;
    _onTick = onTick;
    _running = true;
  }

  @override
  void cancel() {
    _running = false;
  }

  /// Synchronously fires the tick callback [times] times, as if [times]
  /// intervals had elapsed.
  void tick([int times = 1]) {
    for (var i = 0; i < times && _running; i++) {
      _onTick?.call();
    }
  }
}

void main() {
  late TimerService timerService;
  late FakeTimerTicker fakeTicker;

  setUp(() {
    fakeTicker = FakeTimerTicker();
    timerService = TimerService(ticker: fakeTicker);
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
    test('start changes state to running and begins ticking', () {
      timerService.start();
      expect(timerService.state, TimerState.running);
      expect(fakeTicker.isRunning, true);
      expect(fakeTicker.interval, const Duration(seconds: 1));
    });

    test('pause changes state to paused and cancels the ticker', () {
      timerService.start();
      timerService.pause();
      expect(timerService.state, TimerState.paused);
      expect(fakeTicker.isRunning, false);
    });

    test('resume changes state back to running and restarts the ticker', () {
      timerService.start();
      timerService.pause();
      timerService.resume();
      expect(timerService.state, TimerState.running);
      expect(fakeTicker.isRunning, true);
    });

    test('stop changes state to completed and cancels the ticker', () {
      timerService.start();
      timerService.stop();
      expect(timerService.state, TimerState.completed);
      expect(fakeTicker.isRunning, false);
    });

    test('reset returns to idle and cancels the ticker', () {
      timerService.start();
      timerService.stop();
      timerService.reset();
      expect(timerService.state, TimerState.idle);
      expect(timerService.elapsedSeconds, 0);
      expect(fakeTicker.isRunning, false);
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

    test('dispose cancels the ticker', () {
      timerService.start();
      timerService.dispose();
      expect(fakeTicker.isRunning, false);
    });
  });

  group('TimerService - Callbacks', () {
    test('onStart is called', () {
      bool startCalled = false;
      timerService.onStart = () => startCalled = true;
      timerService.start();
      expect(startCalled, true);
    });

    test('onComplete is called when countdown finishes', () {
      bool completeCalled = false;
      timerService.configure(targetDuration: 1);
      timerService.onComplete = () => completeCalled = true;
      timerService.start();

      fakeTicker.tick(2);
      expect(completeCalled, true);
      expect(timerService.state, TimerState.completed);
    });

    test('onIntervalBell is called at intervals', () {
      int intervalCount = 0;
      timerService.configure(
        targetDuration: 10,
        intervalDuration: 1,
        intervalEnabled: true,
      );
      timerService.onIntervalBell = () => intervalCount++;
      timerService.start();

      fakeTicker.tick(3);
      timerService.stop();
      expect(intervalCount, greaterThanOrEqualTo(2));
    });
  });
}
