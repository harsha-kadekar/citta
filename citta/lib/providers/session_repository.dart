import '../models/session_model.dart';
import '../services/stats_service.dart';
import '../services/storage_service.dart';

/// Owns the in-memory session list and everything derived from it
/// (sorted-by-date view, stats). Reads and writes go through
/// [StorageService.runExclusive] so a save here can never interleave with a
/// concurrent import's snapshot-then-write sequence.
class SessionRepository {
  final StorageService storageService;
  final StatsService statsService;

  List<SessionModel> _sessions = const [];
  List<SessionModel> _sortedSessions = const [];
  StatsResult _stats = const StatsResult(
    totalSessions: 0,
    currentStreak: 0,
    longestStreak: 0,
    averageDurationSeconds: 0,
    totalDurationSeconds: 0,
  );

  SessionRepository({required this.storageService, required this.statsService});

  List<SessionModel> get sessions => _sessions;
  List<SessionModel> get sortedSessions => _sortedSessions;
  StatsResult get stats => _stats;

  /// Sets the session list from data the caller already loaded (bootstrap,
  /// post-import resync) without performing any I/O itself. Wraps
  /// [sessions] in an unmodifiable view regardless of what the caller
  /// passed in, so the [sessions] getter's unmodifiable contract holds no
  /// matter how this was called.
  void seed(List<SessionModel> sessions) {
    _sessions = List.unmodifiable(sessions);
    _refreshDerivedData();
  }

  /// Alias for [seed] used at post-import resync call sites, where the name
  /// better documents intent than "seed" (which reads as bootstrap-only).
  void resync(List<SessionModel> sessions) => seed(sessions);

  void _refreshDerivedData() {
    final sorted = List<SessionModel>.from(_sessions)
      ..sort((a, b) => b.date.compareTo(a.date));
    _sortedSessions = List.unmodifiable(sorted);
    _stats = statsService.calculateStats(_sessions);
  }

  // add/delete read the current list from storage inside the same lock as
  // their write, rather than mutating the (possibly stale) in-memory
  // _sessions cache — otherwise a concurrent import replacing the sessions
  // file could be silently overwritten by a save computed from a snapshot
  // taken before the import committed.
  Future<void> add(SessionModel session) async {
    _sessions = List.unmodifiable(await storageService.runExclusive(() async {
      final current = await storageService.loadSessions();
      final updated = [...current, session];
      await storageService.saveSessions(updated);
      return updated;
    }));
    _refreshDerivedData();
  }

  Future<void> delete(List<String> sessionIds) async {
    _sessions = List.unmodifiable(await storageService.runExclusive(() async {
      final current = await storageService.loadSessions();
      final updated =
          current.where((s) => !sessionIds.contains(s.id)).toList();
      await storageService.saveSessions(updated);
      return updated;
    }));
    _refreshDerivedData();
  }

  List<SessionModel> filterByTag(String tag) {
    return _sessions.where((s) => s.tags.contains(tag)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<SessionModel> filterByTags(List<String> tags) {
    if (tags.isEmpty) return _sortedSessions;
    return _sortedSessions
        .where((s) => tags.any((tag) => s.tags.contains(tag)))
        .toList();
  }
}
