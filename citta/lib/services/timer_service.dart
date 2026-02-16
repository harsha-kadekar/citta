import 'dart:async';
import 'package:flutter/foundation.dart';

enum TimerMode { countdown, stopwatch }

enum TimerState { idle, running, paused, completed }

class TimerService extends ChangeNotifier {
  TimerMode _mode = TimerMode.countdown;
  TimerState _state = TimerState.idle;
  int _targetDuration = 1200; // seconds (for countdown)
  int _elapsedSeconds = 0;
  int _intervalDuration = 300; // seconds
  bool _intervalEnabled = false;
  Timer? _timer;
  int _lastIntervalFired = 0;

  // Callbacks
  VoidCallback? onComplete;
  VoidCallback? onIntervalBell;
  VoidCallback? onStart;

  TimerMode get mode => _mode;
  TimerState get state => _state;
  int get targetDuration => _targetDuration;
  int get elapsedSeconds => _elapsedSeconds;
  bool get intervalEnabled => _intervalEnabled;
  int get intervalDuration => _intervalDuration;

  int get remainingSeconds {
    if (_mode == TimerMode.countdown) {
      return (_targetDuration - _elapsedSeconds).clamp(0, _targetDuration);
    }
    return _elapsedSeconds;
  }

  int get displaySeconds => _mode == TimerMode.countdown
      ? remainingSeconds
      : _elapsedSeconds;

  String get displayTime {
    final total = displaySeconds;
    final hours = total ~/ 3600;
    final minutes = (total % 3600) ~/ 60;
    final seconds = total % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (_mode == TimerMode.countdown && _targetDuration > 0) {
      return _elapsedSeconds / _targetDuration;
    }
    return 0;
  }

  void configure({
    TimerMode? mode,
    int? targetDuration,
    int? intervalDuration,
    bool? intervalEnabled,
  }) {
    if (_state != TimerState.idle) return;
    if (mode != null) _mode = mode;
    if (targetDuration != null) _targetDuration = targetDuration;
    if (intervalDuration != null) _intervalDuration = intervalDuration;
    if (intervalEnabled != null) _intervalEnabled = intervalEnabled;
    notifyListeners();
  }

  void start() {
    if (_state != TimerState.idle) return;
    _elapsedSeconds = 0;
    _lastIntervalFired = 0;
    _state = TimerState.running;
    onStart?.call();
    _startTicking();
    notifyListeners();
  }

  void pause() {
    if (_state != TimerState.running) return;
    _timer?.cancel();
    _state = TimerState.paused;
    notifyListeners();
  }

  void resume() {
    if (_state != TimerState.paused) return;
    _state = TimerState.running;
    _startTicking();
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _state = TimerState.completed;
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _elapsedSeconds = 0;
    _lastIntervalFired = 0;
    _state = TimerState.idle;
    notifyListeners();
  }

  void _startTicking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;

      // Check interval bell
      if (_intervalEnabled && _intervalDuration > 0) {
        final intervalCount = _elapsedSeconds ~/ _intervalDuration;
        if (intervalCount > _lastIntervalFired) {
          _lastIntervalFired = intervalCount;
          // Don't fire interval bell at the exact end time for countdown
          if (_mode != TimerMode.countdown ||
              _elapsedSeconds < _targetDuration) {
            onIntervalBell?.call();
          }
        }
      }

      // Check countdown completion
      if (_mode == TimerMode.countdown &&
          _elapsedSeconds >= _targetDuration) {
        _timer?.cancel();
        _state = TimerState.completed;
        onComplete?.call();
      }

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
