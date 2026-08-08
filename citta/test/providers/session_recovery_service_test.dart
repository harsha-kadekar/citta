import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/session_model.dart';
import 'package:citta/models/timer_mode.dart';
import 'package:citta/providers/session_recovery_service.dart';
import 'package:citta/services/storage_service.dart';

void main() {
  group('SessionRecoveryService', () {
    late Directory tmpDir;
    late StorageService storage;
    const service = SessionRecoveryService();

    setUp(() {
      tmpDir = Directory.systemTemp.createTempSync('citta_recovery_test_');
      storage = StorageService.withBasePath(tmpDir.path);
    });

    tearDown(() => tmpDir.deleteSync(recursive: true));

    test('returns the sessions unchanged when there is no in-progress session', () async {
      final existing = <SessionModel>[];

      final result = await service.recover(storage, existing);

      expect(identical(result, existing), isTrue);
    });

    test('appends the interrupted session, persists it, and clears the marker', () async {
      await storage.saveInProgressSession(
        id: 'recovered-1',
        startDate: DateTime.utc(2024, 6, 1, 10),
        elapsedSeconds: 120,
        timerMode: TimerMode.countdown.toStorageString(),
        targetDuration: 900,
      );

      final result = await service.recover(storage, const []);

      expect(result.map((s) => s.id), ['recovered-1']);
      expect(result.single.completedFully, isFalse);
      expect(result.single.duration, 120);

      final persisted = await storage.loadSessions();
      expect(persisted.map((s) => s.id), ['recovered-1']);

      expect(await storage.loadInProgressSession(), isNull,
          reason: 'a successfully recovered session must clear the marker '
              'so it is not recovered again on next launch');
    });

    test('does not duplicate a session that already exists, but still clears the marker',
        () async {
      await storage.saveInProgressSession(
        id: 'already-there',
        startDate: DateTime.utc(2024, 6, 1, 10),
        elapsedSeconds: 120,
        timerMode: TimerMode.countdown.toStorageString(),
        targetDuration: 900,
      );
      final existing = [
        SessionModel(
          id: 'already-there',
          date: DateTime.utc(2024, 6, 1, 10),
          duration: 900,
          timerMode: TimerMode.countdown,
        ),
      ];

      final result = await service.recover(storage, existing);

      expect(result.length, 1);
      expect(await storage.loadInProgressSession(), isNull);
    });

    test('ignores a marker with zero elapsed seconds, but still clears it', () async {
      await storage.saveInProgressSession(
        id: 'not-started',
        startDate: DateTime.utc(2024, 6, 1, 10),
        elapsedSeconds: 0,
        timerMode: TimerMode.countdown.toStorageString(),
        targetDuration: 900,
      );

      final result = await service.recover(storage, const []);

      expect(result, isEmpty);
      expect(await storage.loadInProgressSession(), isNull);
    });

    test(
        'a persistence failure while saving the recovered session does not '
        'throw, and still returns the recovered session for this run',
        () async {
      await storage.saveInProgressSession(
        id: 'recovered-1',
        startDate: DateTime.utc(2024, 6, 1, 10),
        elapsedSeconds: 120,
        timerMode: TimerMode.countdown.toStorageString(),
        targetDuration: 900,
      );
      // Force the sessions.json write inside recover() to fail.
      Directory('${tmpDir.path}/sessions.json').createSync();

      final result = await service.recover(storage, const []);

      expect(result.map((s) => s.id), ['recovered-1'],
          reason: 'even though persisting it failed, the recovered session '
              'must still surface for the rest of this run rather than '
              'being silently dropped');
      expect(await storage.loadInProgressSession(), isNull,
          reason: 'the marker must still be cleared as a fallback so the '
              'app does not get stuck retrying the same failed recovery '
              'on every launch');
    });
  });
}
