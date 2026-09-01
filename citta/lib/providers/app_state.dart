import 'package:flutter/widgets.dart';
import '../models/config_model.dart';
import '../models/session_model.dart';
import '../models/timer_mode.dart';
import '../models/app_language.dart';
import '../services/storage_service.dart';
import '../services/crypto_service.dart';
import '../services/quote_service.dart';
import '../services/audio_service.dart';
import '../services/stats_service.dart';
import 'app_bootstrapper.dart';
import 'config_controller.dart';
import 'import_activity_tracker.dart';
import 'import_coordinator.dart';
import 'session_repository.dart';

/// Thin `ChangeNotifier` facade over the app's persisted state. Bootstrap,
/// recovery, config mutation, session mutation, and import are each owned
/// by a focused collaborator (see `lib/providers/`); this class composes
/// them, exposes the API screens depend on, and is the sole place that
/// calls [notifyListeners].
class AppState extends ChangeNotifier {
  final StorageService storageService;
  final QuoteService quoteService;
  final AudioService audioService;
  final StatsService statsService;

  final AppBootstrapper _bootstrapper = const AppBootstrapper();
  late final ImportActivityTracker _importActivity;
  late final ConfigController _configController;
  late final SessionRepository _sessionRepository;
  late final ImportCoordinator _importCoordinator;

  bool _isLoading = true;
  bool _needsUnlock = false;

  AppState({
    required this.storageService,
    required this.quoteService,
    required this.audioService,
    required this.statsService,
  }) {
    _importActivity = ImportActivityTracker();
    _configController = ConfigController(
      storageService: storageService,
      importActivity: _importActivity,
    );
    _sessionRepository = SessionRepository(
      storageService: storageService,
      statsService: statsService,
    );
    _importCoordinator = ImportCoordinator(
      storageService: storageService,
      quoteService: quoteService,
      configController: _configController,
      sessionRepository: _sessionRepository,
      importActivity: _importActivity,
    );
  }

  ConfigModel get config => _configController.config;
  List<SessionModel> get sessions => _sessionRepository.sessions;
  List<SessionModel> get sortedSessions => _sessionRepository.sortedSessions;
  StatsResult get stats => _sessionRepository.stats;
  bool get isLoading => _isLoading;

  /// True when encryption is enabled and this run hasn't unlocked the
  /// master key yet — see [BootstrapResult.needsUnlock]. While true, no
  /// encrypted data has been read; [sessions] stays empty until
  /// [unlockWithPassword] or [unlockWithRecoveryKey] succeeds.
  bool get needsUnlock => _needsUnlock;

  Locale? get locale =>
      config.language == AppLanguage.system ? null : Locale(config.language.code);

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final result = await _bootstrapper.run(
      storageService: storageService,
      quoteService: quoteService,
      audioService: audioService,
    );
    _configController.seed(result.config);
    _sessionRepository.seed(result.sessions);
    _needsUnlock = result.needsUnlock;

    _isLoading = false;
    notifyListeners();
  }

  // --- Unlock ---

  /// Attempts to unlock with [password]. On success, loads the sessions that
  /// were skipped at startup while [needsUnlock] was true, clears
  /// [needsUnlock], and notifies listeners. Returns whether the unlock
  /// succeeded either way.
  Future<bool> unlockWithPassword(String password) =>
      _unlock(() => storageService.unlockWithPassword(password));

  /// Attempts to unlock with [recoveryKey]. Otherwise identical to
  /// [unlockWithPassword].
  Future<bool> unlockWithRecoveryKey(String recoveryKey) =>
      _unlock(() => storageService.unlockWithRecoveryKey(recoveryKey));

  /// Tries [input] first as a password, then — only if that fails — as a
  /// recovery key, normalizing it (trimmed, uppercased) to match the
  /// all-uppercase alphabet [CryptoService.generateRecoveryKey] produces,
  /// so a hand-transcribed key still unlocks even if the user typed it in
  /// lowercase or with stray whitespace. The password attempt is left
  /// untouched — passwords are case- and whitespace-sensitive by design.
  ///
  /// This ordering is centralized here (rather than in each caller) so
  /// every unlock entry point gets the same "never reveal which form was
  /// attempted" guarantee: a caller only sees a single bool, whether the
  /// input turned out to be a password, a recovery key, or neither.
  Future<bool> unlockWithPasswordOrRecoveryKey(String input) async {
    if (await unlockWithPassword(input)) return true;
    return unlockWithRecoveryKey(
      CryptoService.normalizeRecoveryKeyInput(input),
    );
  }

  Future<bool> _unlock(Future<bool> Function() attempt) async {
    final unlocked = await attempt();
    if (!unlocked) return false;

    final sessions = await _bootstrapper.loadUnlockedSessions(storageService);
    _sessionRepository.seed(sessions);
    _needsUnlock = false;
    notifyListeners();
    return true;
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

  Future<void> updateConfig(ConfigModel config) async {
    await _configController.updateConfig(config);
    notifyListeners();
  }

  Future<void> mutateConfig(
    ConfigModel Function(ConfigModel current) transform,
  ) async {
    if (await _configController.mutateConfig(transform)) notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (await _configController.setLanguage(language)) notifyListeners();
  }

  // --- Sessions ---

  Future<void> addSession(SessionModel session) async {
    await _sessionRepository.add(session);
    notifyListeners();
  }

  List<SessionModel> filterByTag(String tag) =>
      _sessionRepository.filterByTag(tag);

  Future<void> deleteSessions(Iterable<String> sessionIds) async {
    await _sessionRepository.delete(sessionIds);
    notifyListeners();
  }

  List<SessionModel> filterByTags(Iterable<String> tags) =>
      _sessionRepository.filterByTags(tags);

  // --- Tags ---

  Future<void> addTag(String tag) async {
    if (await _configController.addTag(tag)) notifyListeners();
  }

  Future<void> removeTag(String tag) async {
    if (await _configController.removeTag(tag)) notifyListeners();
  }

  // --- Import ---

  Future<bool> importData(String content, {bool replaceAll = true}) async {
    final success =
        await _importCoordinator.importData(content, replaceAll: replaceAll);
    notifyListeners();
    return success;
  }
}
