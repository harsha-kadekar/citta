import '../models/config_model.dart';
import '../models/session_model.dart';
import '../services/audio_service.dart';
import '../services/quote_service.dart';
import '../services/storage_service.dart';
import 'session_recovery_service.dart';

class BootstrapResult {
  final ConfigModel config;
  final List<SessionModel> sessions;

  const BootstrapResult({required this.config, required this.sessions});
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
    var sessions = List<SessionModel>.unmodifiable(await storageService.loadSessions());
    await quoteService.initialize();
    await audioService.init();
    audioService.warmUp(config.bellEnd); // fire-and-forget — completes well before first session

    try {
      sessions = await sessionRecoveryService.recover(storageService, sessions);
    } catch (_) {
      await storageService.clearInProgressSession().catchError((_) {});
    }

    return BootstrapResult(config: config, sessions: sessions);
  }
}
