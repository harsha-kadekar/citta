import '../models/session_model.dart';
import '../models/timer_mode.dart';
import '../services/storage_service.dart';

/// Recovers a session left in progress by a previous run that was
/// interrupted (killed, crashed) before it could be saved normally.
class SessionRecoveryService {
  const SessionRecoveryService();

  /// If a saved in-progress marker exists, appends the recovered session to
  /// [existingSessions] and persists the merged list under storage's write
  /// lock, then clears the marker. Returns [existingSessions] unchanged
  /// (same reference) if there is nothing to recover.
  ///
  /// Never throws: a failure anywhere after the recovered session is built
  /// (parsing the marker, persisting it, or clearing it) is swallowed here,
  /// with a best-effort attempt to still clear the marker, and the
  /// already-built (but possibly unpersisted) session list is returned
  /// regardless — so a save failure loses at most the persistence of that
  /// one recovery, not the recovered session itself for the rest of this
  /// run.
  Future<List<SessionModel>> recover(
    StorageService storageService,
    List<SessionModel> existingSessions,
  ) async {
    final data = await storageService.loadInProgressSession();
    if (data == null) return existingSessions;

    var sessions = existingSessions;
    try {
      final id = data['id'] as String;
      final elapsed = data['elapsedSeconds'] as int? ?? 0;
      if (!existingSessions.any((s) => s.id == id) && elapsed > 0) {
        final session = SessionModel(
          id: id,
          date: DateTime.parse(data['startDate'] as String),
          duration: elapsed,
          timerMode: TimerModeStorage.fromStorageString(data['timerMode'] as String?),
          completedFully: false,
        );
        sessions = List.unmodifiable([...existingSessions, session]);
        await storageService.runExclusive(
          () => storageService.saveSessions(sessions),
        );
      }
      await storageService.clearInProgressSession();
    } catch (_) {
      await storageService.clearInProgressSession().catchError((_) {});
    }

    return sessions;
  }
}
