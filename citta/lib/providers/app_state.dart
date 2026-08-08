import 'package:flutter/widgets.dart';
import '../models/config_model.dart';
import '../models/session_model.dart';
import '../models/timer_mode.dart';
import '../models/app_language.dart';
import '../services/storage_service.dart';
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

    _isLoading = false;
    notifyListeners();
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

  Future<void> deleteSessions(List<String> sessionIds) async {
    await _sessionRepository.delete(sessionIds);
    notifyListeners();
  }

  List<SessionModel> filterByTags(List<String> tags) =>
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
