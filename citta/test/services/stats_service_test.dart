import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/session_model.dart';
import 'package:citta/services/stats_service.dart';

void main() {
  late StatsService statsService;

  setUp(() {
    statsService = StatsService();
  });

  group('StatsService', () {
    test('empty sessions returns zeros', () {
      final stats = statsService.calculateStats([]);
      expect(stats.totalSessions, 0);
      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 0);
      expect(stats.averageDurationSeconds, 0);
    });

    test('single session stats', () {
      final sessions = [
        SessionModel(
          id: '1',
          date: DateTime.now(),
          duration: 600,
          timerMode: 'countdown',
        ),
      ];
      final stats = statsService.calculateStats(sessions);
      expect(stats.totalSessions, 1);
      expect(stats.currentStreak, 1);
      expect(stats.longestStreak, 1);
      expect(stats.averageDurationSeconds, 600);
    });

    test('consecutive days streak', () {
      final today = DateTime.now();
      final sessions = [
        SessionModel(
          id: '1',
          date: today,
          duration: 600,
          timerMode: 'countdown',
        ),
        SessionModel(
          id: '2',
          date: today.subtract(const Duration(days: 1)),
          duration: 600,
          timerMode: 'countdown',
        ),
        SessionModel(
          id: '3',
          date: today.subtract(const Duration(days: 2)),
          duration: 600,
          timerMode: 'countdown',
        ),
      ];
      final stats = statsService.calculateStats(sessions);
      expect(stats.currentStreak, 3);
      expect(stats.longestStreak, 3);
    });

    test('broken streak', () {
      final today = DateTime.now();
      final sessions = [
        SessionModel(
          id: '1',
          date: today,
          duration: 600,
          timerMode: 'countdown',
        ),
        // Gap of 1 day
        SessionModel(
          id: '2',
          date: today.subtract(const Duration(days: 3)),
          duration: 600,
          timerMode: 'countdown',
        ),
        SessionModel(
          id: '3',
          date: today.subtract(const Duration(days: 4)),
          duration: 600,
          timerMode: 'countdown',
        ),
      ];
      final stats = statsService.calculateStats(sessions);
      expect(stats.currentStreak, 1);
      expect(stats.longestStreak, 2);
    });

    test('average duration calculation', () {
      final sessions = [
        SessionModel(
          id: '1',
          date: DateTime.now(),
          duration: 600,
          timerMode: 'countdown',
        ),
        SessionModel(
          id: '2',
          date: DateTime.now().subtract(const Duration(days: 1)),
          duration: 1200,
          timerMode: 'countdown',
        ),
      ];
      final stats = statsService.calculateStats(sessions);
      expect(stats.averageDurationSeconds, 900);
      expect(stats.totalDurationSeconds, 1800);
    });

    test('multiple sessions on same day count as one day for streak', () {
      // Pin to noon so subtracting 2 hours never crosses midnight.
      final now = DateTime.now();
      final todayNoon = DateTime(now.year, now.month, now.day, 12);
      final sessions = [
        SessionModel(
          id: '1',
          date: todayNoon,
          duration: 300,
          timerMode: 'countdown',
        ),
        SessionModel(
          id: '2',
          date: todayNoon.subtract(const Duration(hours: 2)),
          duration: 300,
          timerMode: 'countdown',
        ),
      ];
      final stats = statsService.calculateStats(sessions);
      expect(stats.totalSessions, 2);
      expect(stats.currentStreak, 1);
    });
  });

  group('groupByDate', () {
    test('groups sessions correctly', () {
      final today = DateTime.now();
      final sessions = [
        SessionModel(
          id: '1',
          date: today,
          duration: 600,
          timerMode: 'countdown',
        ),
        SessionModel(
          id: '2',
          date: today.subtract(const Duration(hours: 2)),
          duration: 300,
          timerMode: 'countdown',
        ),
        SessionModel(
          id: '3',
          date: today.subtract(const Duration(days: 1)),
          duration: 600,
          timerMode: 'countdown',
        ),
      ];

      final grouped = statsService.groupByDate(sessions);
      expect(grouped.length, 2); // Two unique days
    });
  });
}
