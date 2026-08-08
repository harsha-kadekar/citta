import '../models/app_language.dart';
import '../models/config_model.dart';
import '../services/storage_service.dart';
import 'import_activity_tracker.dart';

/// Owns the in-memory config and its persistence, including the no-op fast
/// path that lets callers skip a storage round-trip for a genuine no-op
/// mutation.
class ConfigController {
  final StorageService storageService;
  final ImportActivityTracker importActivity;

  ConfigModel _config = ConfigModel();

  ConfigController({required this.storageService, required this.importActivity});

  ConfigModel get config => _config;

  /// Sets the config from data the caller already loaded (bootstrap)
  /// without performing any I/O itself.
  void seed(ConfigModel config) => _config = config;

  /// Alias for [seed] used at post-import resync call sites, where the name
  /// better documents intent than "seed" (which reads as bootstrap-only).
  void resync(ConfigModel config) => seed(config);

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
  }

  /// Applies [transform] to the current config and persists the result.
  /// Returns whether the config actually changed (and was persisted), so
  /// callers can skip notifying listeners on a genuine no-op.
  ///
  /// While no import is active, [transform] is first tried speculatively
  /// against the cached [_config] so a genuine no-op (e.g. adding a tag
  /// that's already present, or setting a field to its current value) skips
  /// the storage round-trip entirely. The no-op check compares by value
  /// (==), not identity: [transform] always allocates a new ConfigModel via
  /// copyWith, so identity would never match even when nothing actually
  /// changed. That speculative check is skipped entirely whenever an import
  /// is active — [_config] may be stale relative to an import that hasn't
  /// finished resyncing yet, so e.g. addTag("a") must not be short-circuited
  /// as a no-op just because the *stale* cache already had "a", when the
  /// import in flight is about to remove it (or vice versa for removeTag).
  /// Only when it would actually change something (or an import might be
  /// active) does this re-read the current value from storage *inside* the
  /// same lock as the write, so the transform is applied to whatever is
  /// actually on disk rather than to a stale in-memory snapshot.
  Future<bool> mutateConfig(
    ConfigModel Function(ConfigModel current) transform,
  ) async {
    if (!importActivity.isActive) {
      final speculative = transform(_config);
      if (speculative == _config) return false;
    }

    _config = await storageService.runExclusive(() async {
      final current = await storageService.loadConfig();
      final next = transform(current);
      await storageService.saveConfig(next);
      return next;
    });
    return true;
  }

  Future<bool> setLanguage(AppLanguage language) =>
      mutateConfig((current) => current.copyWith(language: language));

  Future<bool> addTag(String tag) => mutateConfig((current) {
        if (current.tags.contains(tag)) return current;
        return current.copyWith(tags: [...current.tags, tag]);
      });

  Future<bool> removeTag(String tag) => mutateConfig((current) {
        if (!current.tags.contains(tag)) return current;
        return current.copyWith(
          tags: current.tags.where((t) => t != tag).toList(),
        );
      });
}
