import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/session_model.dart';
import 'package:citta/models/timer_mode.dart';
import 'package:citta/providers/session_repository.dart';
import 'package:citta/services/stats_service.dart';
import 'package:citta/services/storage_service.dart';

SessionModel _session(String id, {DateTime? date}) => SessionModel(
      id: id,
      date: date ?? DateTime.utc(2024, 6, 1),
      duration: 300,
      timerMode: TimerMode.countdown,
      tags: const [],
    );

void main() {
  group('SessionRepository', () {
    late Directory tmpDir;
    late StorageService storage;
    late SessionRepository repo;

    setUp(() {
      tmpDir = Directory.systemTemp.createTempSync('citta_session_repo_test_');
      storage = StorageService.withBasePath(tmpDir.path);
      repo = SessionRepository(storageService: storage, statsService: const StatsService());
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    test('seed() sets sessions and computes derived data without touching storage', () {
      repo.seed([_session('a'), _session('b')]);

      expect(repo.sessions.map((s) => s.id), ['a', 'b']);
      expect(repo.stats.totalSessions, 2);
      expect(File('${tmpDir.path}/sessions.json').existsSync(), isFalse,
          reason: 'seed() is used during bootstrap with already-loaded '
              'data, it must not perform its own I/O');
    });

    test('seed() makes sessions unmodifiable even when given a mutable list', () {
      repo.seed(<SessionModel>[_session('a')]);

      expect(() => repo.sessions.add(_session('b')), throwsUnsupportedError,
          reason: 'callers of seed() must not be able to bypass the '
              "sessions getter's unmodifiable contract by passing a plain "
              'mutable list');
    });

    test('sortedSessions orders sessions by date descending', () {
      repo.seed([
        _session('old', date: DateTime.utc(2024, 1, 1)),
        _session('new', date: DateTime.utc(2024, 6, 1)),
      ]);

      expect(repo.sortedSessions.map((s) => s.id), ['new', 'old']);
    });

    test('add() persists the new session to storage and updates derived data', () async {
      await storage.saveSessions([_session('a')]);
      repo.seed([_session('a')]);

      await repo.add(_session('b'));

      expect(repo.sessions.map((s) => s.id), containsAll(['a', 'b']));
      expect(repo.stats.totalSessions, 2);

      final persisted = await storage.loadSessions();
      expect(persisted.map((s) => s.id), containsAll(['a', 'b']),
          reason: 'add() must persist through storage, not just update '
              'the in-memory cache');
    });

    test('add() reads the current sessions from storage rather than the stale in-memory cache',
        () async {
      repo.seed([_session('a')]);
      // Simulate a concurrent writer (e.g. an import) landing on disk after
      // seed() but before add() runs.
      await storage.saveSessions([_session('a'), _session('external')]);

      await repo.add(_session('b'));

      final ids = repo.sessions.map((s) => s.id).toSet();
      expect(ids, {'a', 'external', 'b'},
          reason: 'add() must not overwrite a concurrent external write '
              'with a save computed from a stale snapshot');
    });

    test('delete() removes matching sessions and updates derived data', () async {
      repo.seed([_session('a'), _session('b')]);
      await storage.saveSessions([_session('a'), _session('b')]);

      await repo.delete(['a']);

      expect(repo.sessions.map((s) => s.id), ['b']);
      expect(repo.stats.totalSessions, 1);

      final persisted = await storage.loadSessions();
      expect(persisted.map((s) => s.id), ['b']);
    });

    test('filterByTag returns matching sessions sorted by date descending', () {
      final tagged = SessionModel(
        id: 'tagged',
        date: DateTime.utc(2024, 1, 1),
        duration: 300,
        timerMode: TimerMode.countdown,
        tags: const ['focus'],
      );
      final taggedNewer = SessionModel(
        id: 'tagged-newer',
        date: DateTime.utc(2024, 6, 1),
        duration: 300,
        timerMode: TimerMode.countdown,
        tags: const ['focus'],
      );
      final untagged = _session('untagged');
      repo.seed([tagged, taggedNewer, untagged]);

      final result = repo.filterByTag('focus');

      expect(result.map((s) => s.id), ['tagged-newer', 'tagged']);
    });

    test('filterByTags returns sortedSessions unchanged when tags is empty', () {
      repo.seed([_session('a'), _session('b')]);

      expect(identical(repo.filterByTags(const []), repo.sortedSessions), isTrue);
    });

    test('filterByTags returns sessions matching any of the given tags', () {
      final a = SessionModel(
        id: 'a',
        date: DateTime.utc(2024, 6, 1),
        duration: 300,
        timerMode: TimerMode.countdown,
        tags: const ['calm'],
      );
      final b = SessionModel(
        id: 'b',
        date: DateTime.utc(2024, 5, 1),
        duration: 300,
        timerMode: TimerMode.countdown,
        tags: const ['focus'],
      );
      final c = _session('c', date: DateTime.utc(2024, 4, 1));
      repo.seed([a, b, c]);

      final result = repo.filterByTags(['calm', 'focus']);

      expect(result.map((s) => s.id), ['a', 'b']);
    });
  });
}
