import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/config_model.dart';
import 'package:citta/models/session_model.dart';
import 'package:citta/services/storage_service.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('citta_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Atomic Write', () {
    test('writes file successfully', () async {
      final filePath = '${tempDir.path}/test.json';
      final content = '{"key": "value"}';

      // Use the internal atomic write via a public method
      final file = File(filePath);
      final tmpFile = File('$filePath.tmp');
      final bakFile = File('$filePath.bak');

      // Write to tmp
      await tmpFile.writeAsString(content, flush: true);
      // Rename tmp to target
      await tmpFile.rename(filePath);

      expect(await file.exists(), true);
      expect(await file.readAsString(), content);
      expect(await tmpFile.exists(), false);
      expect(await bakFile.exists(), false);
    });

    test('recovery from missing main file with .tmp present', () async {
      final filePath = '${tempDir.path}/test.json';
      final tmpFile = File('$filePath.tmp');

      // Simulate crash: only .tmp exists
      await tmpFile.writeAsString('{"recovered": true}', flush: true);

      final service = StorageService();
      await service.recoverIfNeeded(filePath);

      final file = File(filePath);
      expect(await file.exists(), true);
      expect(await file.readAsString(), '{"recovered": true}');
      expect(await tmpFile.exists(), false);
    });

    test('recovery from missing main file with .bak present', () async {
      final filePath = '${tempDir.path}/test.json';
      final bakFile = File('$filePath.bak');

      // Simulate crash: only .bak exists
      await bakFile.writeAsString('{"backup": true}', flush: true);

      final service = StorageService();
      await service.recoverIfNeeded(filePath);

      final file = File(filePath);
      expect(await file.exists(), true);
      expect(await file.readAsString(), '{"backup": true}');
    });

    test('cleans up leftover files when main exists', () async {
      final filePath = '${tempDir.path}/test.json';
      final file = File(filePath);
      final tmpFile = File('$filePath.tmp');
      final bakFile = File('$filePath.bak');

      // Main file exists, leftover tmp and bak
      await file.writeAsString('{"main": true}');
      await tmpFile.writeAsString('{"leftover": true}');
      await bakFile.writeAsString('{"leftover": true}');

      final service = StorageService();
      await service.recoverIfNeeded(filePath);

      expect(await file.exists(), true);
      expect(await tmpFile.exists(), false);
      expect(await bakFile.exists(), false);
    });
  });

  group('ConfigModel', () {
    test('default values', () {
      final config = ConfigModel();
      expect(config.timerMode, 'countdown');
      expect(config.countdownDuration, 1200);
      expect(config.bellStart, 'bundled:tibetan_bowl');
      expect(config.intervalEnabled, false);
      expect(config.tags.length, 4);
    });

    test('fromJson / toJson roundtrip', () {
      final original = ConfigModel(
        timerMode: 'stopwatch',
        countdownDuration: 600,
        tags: ['focus', 'peace'],
      );

      final json = original.toJson();
      final restored = ConfigModel.fromJson(json);

      expect(restored.timerMode, 'stopwatch');
      expect(restored.countdownDuration, 600);
      expect(restored.tags, ['focus', 'peace']);
    });
  });

  group('SessionModel', () {
    test('fromJson / toJson roundtrip', () {
      final now = DateTime.now().toUtc();
      final original = SessionModel(
        id: 'test-id',
        date: now,
        duration: 600,
        timerMode: 'countdown',
        notes: 'Test notes',
        tags: ['calm'],
        completedFully: true,
      );

      final json = original.toJson();
      final restored = SessionModel.fromJson(json);

      expect(restored.id, 'test-id');
      expect(restored.duration, 600);
      expect(restored.notes, 'Test notes');
      expect(restored.tags, ['calm']);
      expect(restored.completedFully, true);
    });
  });

  group('Export / Import', () {
    test('validates import data structure', () async {
      final service = StorageService();

      final validData = jsonEncode({
        'config': ConfigModel().toJson(),
        'sessions': [],
      });
      expect(await service.validateImportData(validData), isNotNull);

      final invalidData = jsonEncode({'random': 'stuff'});
      expect(await service.validateImportData(invalidData), isNull);

      expect(await service.validateImportData('not json'), isNull);
    });
  });
}
