import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/config_model.dart';
import 'package:citta/models/session_model.dart';
import 'package:citta/models/timer_mode.dart';
import 'package:citta/providers/config_controller.dart';
import 'package:citta/providers/import_activity_tracker.dart';
import 'package:citta/providers/import_coordinator.dart';
import 'package:citta/providers/session_repository.dart';
import 'package:citta/services/quote_service.dart';
import 'package:citta/services/stats_service.dart';
import 'package:citta/services/storage_service.dart';

String _importJson({
  ConfigModel? config,
  List<SessionModel> sessions = const [],
}) {
  return jsonEncode({
    'version': 1,
    'config': (config ?? ConfigModel()).toJson(),
    'sessions': sessions.map((s) => s.toJson()).toList(),
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImportCoordinator', () {
    late Directory tmpDir;
    late StorageService storage;
    late ImportActivityTracker importActivity;
    late ConfigController configController;
    late SessionRepository sessionRepository;
    late ImportCoordinator coordinator;

    setUp(() {
      tmpDir = Directory.systemTemp.createTempSync('citta_import_coordinator_test_');
      storage = StorageService.withBasePath(tmpDir.path);
      importActivity = ImportActivityTracker();
      configController =
          ConfigController(storageService: storage, importActivity: importActivity);
      sessionRepository =
          SessionRepository(storageService: storage, statsService: const StatsService());
      coordinator = ImportCoordinator(
        storageService: storage,
        quoteService: QuoteService(storage),
        configController: configController,
        sessionRepository: sessionRepository,
        importActivity: importActivity,
      );
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    test('a successful import resyncs config and sessions from what landed on disk',
        () async {
      configController.seed(ConfigModel());
      sessionRepository.seed(const []);
      final content = _importJson(
        config: ConfigModel(userName: 'imported'),
        sessions: [
          SessionModel(
            id: 'imp1',
            date: DateTime.utc(2024, 6, 1),
            duration: 300,
            timerMode: TimerMode.countdown,
          ),
        ],
      );

      final ok = await coordinator.importData(content);

      expect(ok, isTrue);
      expect(configController.config.userName, 'imported');
      expect(sessionRepository.sessions.map((s) => s.id), ['imp1']);
      expect(importActivity.isActive, isFalse);
    });

    test('a failed import still resyncs state from disk and returns false', () async {
      await storage.saveConfig(ConfigModel(userName: 'before'));
      configController.seed(ConfigModel(userName: 'before'));
      sessionRepository.seed(const []);

      final ok = await coordinator.importData('not valid json');

      expect(ok, isFalse);
      expect(configController.config.userName, 'before',
          reason: 'nothing was written, so resyncing from disk must leave '
              'the pre-import config in place');
      expect(importActivity.isActive, isFalse);
    });
  });
}
