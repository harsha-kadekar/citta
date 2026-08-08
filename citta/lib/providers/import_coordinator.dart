import '../services/quote_service.dart';
import '../services/storage_service.dart';
import 'config_controller.dart';
import 'import_activity_tracker.dart';
import 'session_repository.dart';

/// Runs the import flow: validates and writes the imported payload, then
/// resyncs config, sessions, and user quotes from whatever actually landed
/// on disk.
class ImportCoordinator {
  final StorageService storageService;
  final QuoteService quoteService;
  final ConfigController configController;
  final SessionRepository sessionRepository;
  final ImportActivityTracker importActivity;

  ImportCoordinator({
    required this.storageService,
    required this.quoteService,
    required this.configController,
    required this.sessionRepository,
    required this.importActivity,
  });

  Future<bool> importData(String content, {bool replaceAll = true}) async {
    // Spans the entire call, including the post-write resync below — not
    // just the storage-level write lock — so that ConfigController's fast
    // path knows to distrust its cached config for as long as ANY import is
    // still active, including the gap between one import's storage
    // transaction finishing and its own resync completing while another
    // overlapping import is still queued or running.
    importActivity.begin();
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
        configController.resync(await storageService.loadConfig());
        sessionRepository.resync(
            List.unmodifiable(await storageService.loadSessions()));
        await quoteService.reloadUserQuotes();
      });
      return success;
    } finally {
      importActivity.end();
    }
  }
}
