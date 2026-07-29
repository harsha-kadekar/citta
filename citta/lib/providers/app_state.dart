import 'package:flutter/widgets.dart';
import '../models/config_model.dart';
import '../models/session_model.dart';
import '../models/timer_mode.dart';
import '../models/app_language.dart';
import '../services/storage_service.dart';
import '../services/quote_service.dart';
import '../services/audio_service.dart';
import '../services/stats_service.dart';

class AppState extends ChangeNotifier {
  final StorageService storageService;
  final QuoteService quoteService;
  final AudioService audioService;
  final StatsService statsService;

  ConfigModel _config = ConfigModel();
  List<SessionModel> _sessions = const [];
  List<SessionModel> _sortedSessions = const [];
  StatsResult _stats = const StatsResult(
    totalSessions: 0,
    currentStreak: 0,
    longestStreak: 0,
    averageDurationSeconds: 0,
    totalDurationSeconds: 0,
  );
  bool _isLoading = true;

  // Counts, not just flags, active imports: importData() calls can overlap
  // (StorageService's shared lock queues rather than rejects concurrent
  // imports), so a single boolean cleared by whichever import finishes
  // first would wrongly report "no import in flight" while another is
  // still queued or running.
  int _activeImportCount = 0;

  AppState({
    required this.storageService,
    required this.quoteService,
    required this.audioService,
    required this.statsService,
  });

  ConfigModel get config => _config;
  List<SessionModel> get sessions => _sessions;
  bool get isLoading => _isLoading;
  StatsResult get stats => _stats;

  void _refreshDerivedData() {
    final sorted = List<SessionModel>.from(_sessions)
      ..sort((a, b) => b.date.compareTo(a.date));
    _sortedSessions = List.unmodifiable(sorted);
    _stats = statsService.calculateStats(_sessions);
  }

  Locale? get locale => _config.language == AppLanguage.system
      ? null
      : Locale(_config.language.code);

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _config = await storageService.loadConfig();
    _sessions = List.unmodifiable(await storageService.loadSessions());
    await quoteService.initialize();
    await audioService.init();
    audioService.warmUp(_config.bellEnd); // fire-and-forget — completes well before first session

    try {
      await _recoverInterruptedSession();
    } catch (_) {
      await storageService.clearInProgressSession().catchError((_) {});
    }

    _refreshDerivedData();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _recoverInterruptedSession() async {
    final data = await storageService.loadInProgressSession();
    if (data == null) return;

    final id = data['id'] as String;
    final elapsed = data['elapsedSeconds'] as int? ?? 0;
    if (!_sessions.any((s) => s.id == id) && elapsed > 0) {
      final session = SessionModel(
        id: id,
        date: DateTime.parse(data['startDate'] as String),
        duration: elapsed,
        timerMode: TimerModeStorage.fromStorageString(data['timerMode'] as String?),
        completedFully: false,
      );
      _sessions = List.unmodifiable([..._sessions, session]);
      await storageService.runExclusive(
        () => storageService.saveSessions(_sessions),
      );
    }

    await storageService.clearInProgressSession();
  }

  // --- In-Progress Session ---

  Future<void> saveInProgressSession({
    required String id,
    required DateTime startDate,
    required int elapsedSeconds,
    required TimerMode timerMode,
    required int targetDuration,
  }) =>
      storageService.saveInProgressSession(
        id: id,
        startDate: startDate,
        elapsedSeconds: elapsedSeconds,
        timerMode: timerMode.toStorageString(),
        targetDuration: targetDuration,
      );

  Future<void> clearInProgressSession() =>
      storageService.clearInProgressSession();

  // --- Config ---

  /// Replaces the config outright with [config], as computed by the caller.
  /// Use this when the caller has already produced the full desired value
  /// (e.g. a settings screen that read the current config synchronously and
  /// applied one change to it). For "change one field of whatever the
  /// config currently is," prefer [mutateConfig] instead — it recomputes
  /// against storage's current value rather than this method's possibly
  /// stale [config] argument, so it can't be clobbered by (or clobber) a
  /// concurrent import.
  Future<void> updateConfig(ConfigModel config) async {
    _config = config;
    await storageService.runExclusive(() => storageService.saveConfig(config));
    notifyListeners();
  }

  /// Applies [transform] to the current config and persists the result.
  ///
  /// While no import is active ([_activeImportCount] is 0), [transform] is
  /// first tried speculatively against the cached [_config] so a genuine
  /// no-op (e.g. adding a tag that's already present) skips storage
  /// entirely and preserves [_config]'s identity — Selector-based widgets
  /// rely on that to avoid rebuilding. That speculative check is skipped
  /// entirely whenever at least one import is active — [_config] may be
  /// stale relative to an import that hasn't finished resyncing yet, so
  /// e.g. addTag("a") must not be short-circuited as a no-op just because
  /// the *stale* cache already had "a", when the import in flight is about
  /// to remove it (or vice versa for removeTag). Only when it would
  /// actually change something (or an import might be active) does this
  /// re-read the current value from storage *inside* the same lock as the
  /// write, so the transform is applied to whatever is actually on disk
  /// rather than to a stale in-memory snapshot.
  Future<void> mutateConfig(
    ConfigModel Function(ConfigModel current) transform,
  ) async {
    if (_activeImportCount == 0) {
      final speculative = transform(_config);
      if (identical(speculative, _config)) return;
    }

    _config = await storageService.runExclusive(() async {
      final current = await storageService.loadConfig();
      final next = transform(current);
      await storageService.saveConfig(next);
      return next;
    });
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) =>
      mutateConfig((current) => current.copyWith(language: language));

  // --- Sessions ---

  // addSession/deleteSessions read the current list from storage inside the
  // same lock as their write, rather than mutating the (possibly stale)
  // in-memory _sessions cache — otherwise a concurrent import replacing the
  // sessions file could be silently overwritten by a save computed from a
  // snapshot taken before the import committed.
  Future<void> addSession(SessionModel session) async {
    _sessions = List.unmodifiable(await storageService.runExclusive(() async {
      final current = await storageService.loadSessions();
      final updated = [...current, session];
      await storageService.saveSessions(updated);
      return updated;
    }));
    _refreshDerivedData();
    notifyListeners();
  }

  List<SessionModel> get sortedSessions => _sortedSessions;

  List<SessionModel> filterByTag(String tag) {
    return _sessions.where((s) => s.tags.contains(tag)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> deleteSessions(List<String> sessionIds) async {
    _sessions = List.unmodifiable(await storageService.runExclusive(() async {
      final current = await storageService.loadSessions();
      final updated =
          current.where((s) => !sessionIds.contains(s.id)).toList();
      await storageService.saveSessions(updated);
      return updated;
    }));
    _refreshDerivedData();
    notifyListeners();
  }

  List<SessionModel> filterByTags(List<String> tags) {
    if (tags.isEmpty) return _sortedSessions;
    return _sortedSessions
        .where((s) => tags.any((tag) => s.tags.contains(tag)))
        .toList();
  }

  // --- Tags ---

  Future<void> addTag(String tag) => mutateConfig((current) {
        if (current.tags.contains(tag)) return current;
        return current.copyWith(tags: [...current.tags, tag]);
      });

  Future<void> removeTag(String tag) => mutateConfig((current) {
        if (!current.tags.contains(tag)) return current;
        return current.copyWith(
          tags: current.tags.where((t) => t != tag).toList(),
        );
      });

  // --- Import ---

  Future<bool> importData(String content, {bool replaceAll = true}) async {
    // Spans the entire call, including the post-write resync below — not
    // just the storage-level write lock — so that mutateConfig's fast path
    // (see above) knows to distrust _config for as long as ANY import is
    // still active, including the gap between one import's storage
    // transaction finishing and its own resync completing while another
    // overlapping import is still queued or running.
    _activeImportCount++;
    try {
      bool success;
      try {
        success = await storageService.importValidated(content,
            replaceAll: replaceAll);
      } catch (_) {
        success = false;
      }
      // Always resync from disk, even on failure: a failed import may have
      // been partially (or, in rare cases, incompletely-rolled-back)
      // written, so in-memory state must reflect whatever actually landed
      // on disk rather than assuming nothing changed. This runs under the
      // same lock as the import itself so it queues correctly behind (and
      // therefore observes) any concurrent config/session/quote save that
      // was made while the import was in flight, instead of racing it.
      await storageService.runExclusive(() async {
        _config = await storageService.loadConfig();
        _sessions = List.unmodifiable(await storageService.loadSessions());
        await quoteService.reloadUserQuotes();
      });
      _refreshDerivedData();
      notifyListeners();
      return success;
    } finally {
      _activeImportCount--;
    }
  }
}
