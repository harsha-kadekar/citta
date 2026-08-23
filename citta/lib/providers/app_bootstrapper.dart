import '../models/config_model.dart';
import '../models/session_model.dart';
import '../services/audio_service.dart';
import '../services/quote_service.dart';
import '../services/storage_service.dart';
import 'session_recovery_service.dart';

class BootstrapResult {
  final ConfigModel config;
  final List<SessionModel> sessions;

  /// True when encryption is enabled but this run couldn't unlock the
  /// master key from the secure-storage cache (see
  /// [StorageService.tryUnlockWithCachedKey]) — e.g. a fresh reinstall, a
  /// new device, or a manually cleared cache. [sessions] is empty in this
  /// case: [AppBootstrapper.run] never attempts to read the encrypted
  /// `sessions.json` while locked. The caller (`AppState`/`AppRoot`) is
  /// expected to show an unlock screen and, on success, call
  /// [AppBootstrapper.loadUnlockedSessions] to load the sessions this run
  /// skipped.
  final bool needsUnlock;

  const BootstrapResult({
    required this.config,
    required this.sessions,
    this.needsUnlock = false,
  });
}

/// Runs the app's startup sequence: loads persisted config and sessions,
/// initializes the quote/audio services, and recovers any session left
/// in-progress by a previous, interrupted run.
class AppBootstrapper {
  final SessionRecoveryService sessionRecoveryService;

  const AppBootstrapper({
    this.sessionRecoveryService = const SessionRecoveryService(),
  });

  Future<BootstrapResult> run({
    required StorageService storageService,
    required QuoteService quoteService,
    required AudioService audioService,
  }) async {
    final config = await storageService.loadConfig();
    await storageService.tryUnlockWithCachedKey();
    final needsUnlock =
        await storageService.isEncryptionEnabled && !storageService.isUnlocked;

    var sessions = <SessionModel>[];
    if (!needsUnlock) {
      sessions = await loadUnlockedSessions(storageService);
    }

    await quoteService.initialize();
    await audioService.init();
    audioService.warmUp(config.bellEnd); // fire-and-forget — completes well before first session

    return BootstrapResult(
      config: config,
      sessions: sessions,
      needsUnlock: needsUnlock,
    );
  }

  /// Loads sessions and recovers any in-progress marker, for use once
  /// [storageService] is known to be readable — either because encryption
  /// isn't enabled, or because it has just been unlocked. Callers must not
  /// invoke this while [BootstrapResult.needsUnlock] is (or would be) true:
  /// [StorageService.loadSessions] throws [StorageLockedException] against
  /// locked, encrypted data.
  Future<List<SessionModel>> loadUnlockedSessions(
    StorageService storageService,
  ) async {
    var sessions =
        List<SessionModel>.unmodifiable(await storageService.loadSessions());
    try {
      sessions = await sessionRecoveryService.recover(storageService, sessions);
    } catch (_) {
      await storageService.clearInProgressSession().catchError((_) {});
    }
    return sessions;
  }
}
