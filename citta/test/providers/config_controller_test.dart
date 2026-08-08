import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/app_language.dart';
import 'package:citta/models/config_model.dart';
import 'package:citta/providers/config_controller.dart';
import 'package:citta/providers/import_activity_tracker.dart';
import 'package:citta/services/storage_service.dart';

void main() {
  group('ConfigController', () {
    late Directory tmpDir;
    late StorageService storage;
    late ImportActivityTracker importActivity;
    late ConfigController controller;

    setUp(() {
      tmpDir = Directory.systemTemp.createTempSync('citta_config_controller_test_');
      storage = StorageService.withBasePath(tmpDir.path);
      importActivity = ImportActivityTracker();
      controller = ConfigController(storageService: storage, importActivity: importActivity);
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    test('seed() sets config without touching storage', () {
      controller.seed(ConfigModel(userName: 'seeded'));

      expect(controller.config.userName, 'seeded');
      expect(File('${tmpDir.path}/config.json').existsSync(), isFalse);
    });

    test('updateConfig() replaces the config and persists it', () async {
      await controller.updateConfig(ConfigModel(userName: 'harsha'));

      expect(controller.config.userName, 'harsha');
      final persisted = await storage.loadConfig();
      expect(persisted.userName, 'harsha');
    });

    test('mutateConfig() returns false and does not touch storage on a genuine no-op',
        () async {
      controller.seed(ConfigModel(userName: 'same'));

      final changed =
          await controller.mutateConfig((c) => c.copyWith(userName: 'same'));

      expect(changed, isFalse);
      expect(File('${tmpDir.path}/config.json').existsSync(), isFalse,
          reason: 'a no-op mutation must skip the storage round-trip '
              'entirely while no import is active');
    });

    test('mutateConfig() returns true, persists, and re-reads from storage on a real change',
        () async {
      controller.seed(ConfigModel(userName: 'stale-cache'));
      // Simulate storage having moved on from the cached snapshot.
      await storage.saveConfig(ConfigModel(userName: 'on-disk', tags: ['a']));

      final changed =
          await controller.mutateConfig((c) => c.copyWith(tags: [...c.tags, 'b']));

      expect(changed, isTrue);
      expect(controller.config.userName, 'on-disk',
          reason: 'the transform must be applied against the current '
              'storage value, not the stale in-memory cache');
      expect(controller.config.tags, ['a', 'b']);
    });

    test('mutateConfig() skips the speculative no-op check while an import is active',
        () async {
      controller.seed(ConfigModel(userName: 'cached'));
      await storage.saveConfig(ConfigModel(userName: 'cached'));
      importActivity.begin();

      final changed =
          await controller.mutateConfig((c) => c.copyWith(userName: 'cached'));

      expect(changed, isTrue,
          reason: 'while an import is active the cache may be stale '
              'relative to the import, so the fast path must not run');
    });

    test('setLanguage persists the new language', () async {
      final changed = await controller.setLanguage(AppLanguage.hindi);

      expect(changed, isTrue);
      expect(controller.config.language, AppLanguage.hindi);
      expect((await storage.loadConfig()).language, AppLanguage.hindi);
    });

    test('addTag adds a new tag and is a no-op if already present', () async {
      controller.seed(ConfigModel(tags: const ['calm']));

      final added = await controller.addTag('focus');
      expect(added, isTrue);
      expect(controller.config.tags, containsAll(['calm', 'focus']));

      final addedAgain = await controller.addTag('focus');
      expect(addedAgain, isFalse);
    });

    test('removeTag removes a tag and is a no-op if absent', () async {
      controller.seed(ConfigModel(tags: const ['calm', 'focus']));

      final removed = await controller.removeTag('focus');
      expect(removed, isTrue);
      expect(controller.config.tags, isNot(contains('focus')));

      final removedAgain = await controller.removeTag('focus');
      expect(removedAgain, isFalse);
    });

    test('resync() replaces the cached config without writing to storage', () async {
      controller.seed(ConfigModel(userName: 'before'));

      controller.resync(ConfigModel(userName: 'after'));

      expect(controller.config.userName, 'after');
    });
  });
}
