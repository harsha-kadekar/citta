import 'package:flutter/foundation.dart';
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
  List<SessionModel> _sessions = [];
  bool _isLoading = true;

  AppState({
    required this.storageService,
    required this.quoteService,
    required this.audioService,
    required this.statsService,
  });

  ConfigModel get config => _config;
  List<SessionModel> get sessions => List.unmodifiable(_sessions);
  bool get isLoading => _isLoading;
  StatsResult get stats => statsService.calculateStats(_sessions);

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _config = await storageService.loadConfig();
    _sessions = await storageService.loadSessions();
    await quoteService.initialize();

    _isLoading = false;
    notifyListeners();
  }

  // --- Config ---

  Future<void> updateConfig(ConfigModel config) async {
    _config = config;
    await storageService.saveConfig(config);
    notifyListeners();
  }

  // --- Sessions ---

  Future<void> addSession(SessionModel session) async {
    _sessions.add(session);
    await storageService.saveSessions(_sessions);
    notifyListeners();
  }

  List<SessionModel> get sortedSessions {
    final sorted = List<SessionModel>.from(_sessions);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  List<SessionModel> filterByTag(String tag) {
    return _sessions.where((s) => s.tags.contains(tag)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> deleteSessions(List<String> sessionIds) async {
    _sessions.removeWhere((s) => sessionIds.contains(s.id));
    await storageService.saveSessions(_sessions);
    notifyListeners();
  }

  List<SessionModel> filterByTags(List<String> tags) {
    if (tags.isEmpty) return sortedSessions;
    return _sessions
        .where((s) => tags.any((tag) => s.tags.contains(tag)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // --- Tags ---

  Future<void> addTag(String tag) async {
    if (!_config.tags.contains(tag)) {
      _config.tags.add(tag);
      await storageService.saveConfig(_config);
      notifyListeners();
    }
  }

  Future<void> removeTag(String tag) async {
    _config.tags.remove(tag);
    await storageService.saveConfig(_config);
    notifyListeners();
  }

  // --- Import ---

  Future<bool> importData(String content, {bool replaceAll = true}) async {
    final data = await storageService.validateImportData(content);
    if (data == null) return false;
    await storageService.importData(data, replaceAll: replaceAll);
    _config = await storageService.loadConfig();
    _sessions = await storageService.loadSessions();
    await quoteService.reloadUserQuotes();
    notifyListeners();
    return true;
  }
}
