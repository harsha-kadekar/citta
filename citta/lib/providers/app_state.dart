import 'package:flutter/widgets.dart';
import '../models/config_model.dart';
import '../models/session_model.dart';
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

  Locale? get locale =>
      _config.language == 'system' ? null : Locale(_config.language);

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
        timerMode: data['timerMode'] as String? ?? 'countdown',
        completedFully: false,
      );
      _sessions = List.unmodifiable([..._sessions, session]);
      await storageService.saveSessions(_sessions);
    }

    await storageService.clearInProgressSession();
  }

  // --- In-Progress Session ---

  Future<void> saveInProgressSession({
    required String id,
    required DateTime startDate,
    required int elapsedSeconds,
    required String timerMode,
    required int targetDuration,
  }) =>
      storageService.saveInProgressSession(
        id: id,
        startDate: startDate,
        elapsedSeconds: elapsedSeconds,
        timerMode: timerMode,
        targetDuration: targetDuration,
      );

  Future<void> clearInProgressSession() =>
      storageService.clearInProgressSession();

  // --- Config ---

  Future<void> updateConfig(ConfigModel config) async {
    _config = config;
    await storageService.saveConfig(config);
    notifyListeners();
  }

  Future<void> setLanguage(String code) =>
      updateConfig(_config.copyWith(language: code));

  // --- Sessions ---

  Future<void> addSession(SessionModel session) async {
    _sessions = List.unmodifiable([..._sessions, session]);
    await storageService.saveSessions(_sessions);
    _refreshDerivedData();
    notifyListeners();
  }

  List<SessionModel> get sortedSessions => _sortedSessions;

  List<SessionModel> filterByTag(String tag) {
    return _sessions.where((s) => s.tags.contains(tag)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> deleteSessions(List<String> sessionIds) async {
    _sessions = List.unmodifiable(
      _sessions.where((s) => !sessionIds.contains(s.id)),
    );
    await storageService.saveSessions(_sessions);
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

  Future<void> addTag(String tag) async {
    if (!_config.tags.contains(tag)) {
      _config = _config.copyWith(tags: [..._config.tags, tag]);
      await storageService.saveConfig(_config);
      notifyListeners();
    }
  }

  Future<void> removeTag(String tag) async {
    if (!_config.tags.contains(tag)) return;
    _config = _config.copyWith(
      tags: _config.tags.where((t) => t != tag).toList(),
    );
    await storageService.saveConfig(_config);
    notifyListeners();
  }

  // --- Import ---

  Future<bool> importData(String content, {bool replaceAll = true}) async {
    final data = await storageService.validateImportData(content);
    if (data == null) return false;
    await storageService.importData(data, replaceAll: replaceAll);
    _config = await storageService.loadConfig();
    _sessions = List.unmodifiable(await storageService.loadSessions());
    _refreshDerivedData();
    await quoteService.reloadUserQuotes();
    notifyListeners();
    return true;
  }
}
