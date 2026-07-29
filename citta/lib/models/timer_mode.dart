enum TimerMode { countdown, stopwatch }

extension TimerModeStorage on TimerMode {
  String toStorageString() => switch (this) {
        TimerMode.countdown => 'countdown',
        TimerMode.stopwatch => 'stopwatch',
      };

  static TimerMode fromStorageString(
    String? value, {
    TimerMode fallback = TimerMode.countdown,
  }) {
    return switch (value) {
      'countdown' => TimerMode.countdown,
      'stopwatch' => TimerMode.stopwatch,
      _ => fallback,
    };
  }
}
