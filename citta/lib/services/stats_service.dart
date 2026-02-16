import '../models/session_model.dart';

class StatsResult {
  final int totalSessions;
  final int currentStreak;
  final int longestStreak;
  final int averageDurationSeconds;
  final int totalDurationSeconds;

  const StatsResult({
    required this.totalSessions,
    required this.currentStreak,
    required this.longestStreak,
    required this.averageDurationSeconds,
    required this.totalDurationSeconds,
  });
}

class StatsService {
  StatsResult calculateStats(List<SessionModel> sessions) {
    if (sessions.isEmpty) {
      return const StatsResult(
        totalSessions: 0,
        currentStreak: 0,
        longestStreak: 0,
        averageDurationSeconds: 0,
        totalDurationSeconds: 0,
      );
    }

    final totalSessions = sessions.length;
    final totalDuration =
        sessions.fold<int>(0, (sum, s) => sum + s.duration);
    final avgDuration = totalDuration ~/ totalSessions;

    // Calculate streaks based on unique days
    final uniqueDays = <DateTime>{};
    for (final session in sessions) {
      final date = session.date.toLocal();
      uniqueDays.add(DateTime(date.year, date.month, date.day));
    }

    final sortedDays = uniqueDays.toList()..sort();
    int currentStreak = 0;
    int longestStreak = 0;
    int streak = 1;

    // Check if today or yesterday is in the list (for current streak)
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    for (int i = 1; i < sortedDays.length; i++) {
      final diff = sortedDays[i].difference(sortedDays[i - 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        if (streak > longestStreak) longestStreak = streak;
        streak = 1;
      }
    }
    if (streak > longestStreak) longestStreak = streak;

    // Current streak: count backwards from today
    if (sortedDays.contains(todayDate) ||
        sortedDays.contains(yesterdayDate)) {
      currentStreak = 1;
      DateTime checkDate = sortedDays.contains(todayDate)
          ? todayDate
          : yesterdayDate;
      while (true) {
        final prevDate = checkDate.subtract(const Duration(days: 1));
        if (sortedDays.contains(prevDate)) {
          currentStreak++;
          checkDate = prevDate;
        } else {
          break;
        }
      }
    }

    return StatsResult(
      totalSessions: totalSessions,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      averageDurationSeconds: avgDuration,
      totalDurationSeconds: totalDuration,
    );
  }

  /// Get sessions grouped by date for calendar display.
  Map<DateTime, List<SessionModel>> groupByDate(
      List<SessionModel> sessions) {
    final map = <DateTime, List<SessionModel>>{};
    for (final session in sessions) {
      final date = session.date.toLocal();
      final key = DateTime(date.year, date.month, date.day);
      map.putIfAbsent(key, () => []).add(session);
    }
    return map;
  }
}
