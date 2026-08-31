import 'dart:convert';
import 'dart:io';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:citta/models/config_model.dart';
import 'package:citta/models/encryption_metadata.dart';
import 'package:citta/models/quote_model.dart';
import 'package:citta/models/session_model.dart';
import 'package:citta/models/timer_mode.dart';
import 'package:citta/models/app_theme_mode.dart';
import 'package:citta/models/audio_source.dart';
import 'package:citta/services/crypto_service.dart';
import 'package:citta/services/secure_key_cache.dart';
import 'package:citta/services/storage_service.dart';

/// Argon2id cost params for tests only: fast, not secure. Production code
/// must use [CryptoService]'s default (OWASP-recommended) params. Mirrors
/// `test/services/crypto_service_test.dart`.
CryptoService _testCryptoService() => CryptoService(
      argon2Parallelism: 1,
      argon2MemoryKiB: 8,
      argon2Iterations: 1,
    );

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this._resolve);

  final Future<String> Function() _resolve;

  @override
  Future<String?> getApplicationDocumentsPath() => _resolve();
}

/// A [StorageService] whose 2nd call to [saveConfig] fails, used to force a
/// rollback write to fail while the original forward write succeeded.
class _FlakyConfigStorageService extends StorageService {
  _FlakyConfigStorageService.withBasePath(super.basePath) : super.withBasePath();

  int _saveConfigCalls = 0;

  @override
  Future<void> saveConfig(ConfigModel config) async {
    _saveConfigCalls++;
    if (_saveConfigCalls == 2) {
      throw const FileSystemException('simulated rollback failure');
    }
    await super.saveConfig(config);
  }
}

/// A [StorageService] whose 1st call to [saveSessions] commits the real
/// write and only then throws — simulating `_atomicWrite` reporting failure
/// (e.g. a post-rename cleanup error) even though the new content is
/// already live on disk.
class _FlakyPostCommitSessionsStorageService extends StorageService {
  _FlakyPostCommitSessionsStorageService.withBasePath(super.basePath)
      : super.withBasePath();

  int _saveSessionsCalls = 0;

  @override
  Future<void> saveSessions(List<SessionModel> sessions) async {
    _saveSessionsCalls++;
    await super.saveSessions(sessions);
    if (_saveSessionsCalls == 1) {
      throw const FileSystemException('simulated post-commit failure');
    }
  }
}

/// A [StorageService] whose [deleteEncryptionMetadataFile] always throws —
/// used to simulate a crash between [StorageService.disableEncryption]'s two
/// steps: the plaintext `sessions.json` write has already committed, but the
/// metadata deletion that would normally follow never runs.
class _FlakyDeleteMetadataStorageService extends StorageService {
  _FlakyDeleteMetadataStorageService.withBasePath(super.basePath,
      {super.cryptoService})
      : super.withBasePath();

  @override
  Future<void> deleteEncryptionMetadataFile() async {
    throw const FileSystemException('simulated crash before metadata delete');
  }
}

/// A [StorageService] whose 1st call to [saveSessions] throws before doing
/// any real write — simulating a process crash that happens before
/// [StorageService.enableEncryption]'s final re-encrypt write ever starts,
/// even though the `encryption_meta.json` write immediately before it has
/// already committed.
class _FlakyEnableSessionsStorageService extends StorageService {
  _FlakyEnableSessionsStorageService.withBasePath(super.basePath,
      {super.cryptoService})
      : super.withBasePath();

  int _saveSessionsCalls = 0;

  @override
  Future<void> saveSessions(List<SessionModel> sessions) async {
    _saveSessionsCalls++;
    if (_saveSessionsCalls == 1) {
      throw const FileSystemException(
          'simulated crash before re-encrypt write');
    }
    await super.saveSessions(sessions);
  }
}

/// A [SecureKeyCache] that records every call and fails the test if [read]
/// is invoked when [allowRead] is false — used to assert that a cache read
/// is skipped entirely (e.g. when encryption was never enabled), not just
/// that its result is ignored.
class _SpyKeyCache extends InMemoryKeyCache {
  bool allowRead = true;
  int saveCalls = 0;
  int readCalls = 0;
  int clearCalls = 0;

  @override
  Future<void> save(SecretKey key) async {
    saveCalls++;
    await super.save(key);
  }

  @override
  Future<SecretKey?> read() async {
    readCalls++;
    if (!allowRead) {
      throw StateError('read() should not have been called');
    }
    return super.read();
  }

  @override
  Future<void> clear() async {
    clearCalls++;
    await super.clear();
  }
}

/// A [SecureKeyCache] whose [save] always throws, simulating a real-device
/// keystore write failure (locked keystore, denied permission, etc).
class _ThrowingSaveKeyCache extends InMemoryKeyCache {
  @override
  Future<void> save(SecretKey key) async {
    throw PlatformException(code: 'simulated_keystore_write_failure');
  }
}

/// A [SecureKeyCache] whose [read] always throws, simulating a corrupt
/// stored value or an unavailable OS keystore (e.g. iOS Keychain before
/// first device unlock after reboot).
class _ThrowingReadKeyCache extends InMemoryKeyCache {
  @override
  Future<SecretKey?> read() async {
    throw PlatformException(code: 'simulated_keystore_read_failure');
  }
}

/// A [SecureKeyCache] whose [clear] always throws, simulating a keystore
/// delete failure.
class _ThrowingClearKeyCache extends InMemoryKeyCache {
  @override
  Future<void> clear() async {
    throw PlatformException(code: 'simulated_keystore_delete_failure');
  }
}

SessionModel _makeSession({
  String id = 'session-1',
  int duration = 600,
  TimerMode timerMode = TimerMode.countdown,
  String? notes,
  List<String>? tags,
  bool completedFully = true,
}) =>
    SessionModel(
      id: id,
      date: DateTime.utc(2024, 1, 1, 8, 0),
      duration: duration,
      timerMode: timerMode,
      notes: notes,
      tags: tags ?? [],
      completedFully: completedFully,
    );

QuoteModel _makeQuote({
  String id = 'quote-1',
  String source = 'yoga_sutra',
  bool userAdded = true,
}) =>
    QuoteModel(
      id: id,
      source: source,
      reference: '1.2',
      originalText: 'योगश्चित्तवृत्तिनिरोधः',
      originalLanguage: 'sanskrit',
      translation: 'Yoga is the cessation of the fluctuations of the mind.',
      userAdded: userAdded,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late Directory tempDir;
  late StorageService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('citta_test_');
    service = StorageService.withBasePath(tempDir.path);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  // -------------------------------------------------------------------------
  // recoverIfNeeded
  // -------------------------------------------------------------------------

  group('recoverIfNeeded', () {
    test('does nothing when no files exist', () async {
      final path = '${tempDir.path}/missing.json';
      await service.recoverIfNeeded(path);
      expect(await File(path).exists(), false);
    });

    test('cleans up leftover .tmp and .bak when main file exists', () async {
      final path = '${tempDir.path}/test.json';
      await File(path).writeAsString('{"main": true}');
      await File('$path.tmp').writeAsString('{"tmp": true}');
      await File('$path.bak').writeAsString('{"bak": true}');

      await service.recoverIfNeeded(path);

      expect(await File(path).exists(), true);
      expect(await File('$path.tmp').exists(), false);
      expect(await File('$path.bak').exists(), false);
    });

    test('recovers main file from .tmp when main is missing', () async {
      final path = '${tempDir.path}/test.json';
      await File('$path.tmp').writeAsString('{"recovered": true}');

      await service.recoverIfNeeded(path);

      expect(await File(path).readAsString(), '{"recovered": true}');
      expect(await File('$path.tmp').exists(), false);
    });

    test('recovers main file from .bak when main and .tmp are missing',
        () async {
      final path = '${tempDir.path}/test.json';
      await File('$path.bak').writeAsString('{"backup": true}');

      await service.recoverIfNeeded(path);

      expect(await File(path).readAsString(), '{"backup": true}');
      expect(await File('$path.bak').exists(), false);
    });

    test('prefers .tmp over .bak for recovery', () async {
      final path = '${tempDir.path}/test.json';
      await File('$path.tmp').writeAsString('{"from": "tmp"}');
      await File('$path.bak').writeAsString('{"from": "bak"}');

      await service.recoverIfNeeded(path);

      expect(await File(path).readAsString(), '{"from": "tmp"}');
      expect(await File('$path.tmp').exists(), false);
      expect(await File('$path.bak').exists(), false);
    });
  });

  // -------------------------------------------------------------------------
  // basePath
  // -------------------------------------------------------------------------

  group('basePath', () {
    late PathProviderPlatform originalPlatform;

    setUp(() {
      originalPlatform = PathProviderPlatform.instance;
    });

    tearDown(() {
      PathProviderPlatform.instance = originalPlatform;
    });

    test('resolves the platform directory only once under concurrent calls',
        () async {
      var callCount = 0;
      PathProviderPlatform.instance = _FakePathProviderPlatform(() async {
        callCount++;
        await Future.delayed(const Duration(milliseconds: 10));
        return tempDir.path;
      });

      final freshService = StorageService();

      final results = await Future.wait([
        freshService.basePath,
        freshService.basePath,
        freshService.basePath,
      ]);

      expect(callCount, 1);
      expect(results, [tempDir.path, tempDir.path, tempDir.path]);
    });

    test('retries instead of caching a failed resolution', () async {
      var callCount = 0;
      PathProviderPlatform.instance = _FakePathProviderPlatform(() async {
        callCount++;
        if (callCount == 1) {
          throw PlatformException(code: 'error', message: 'transient failure');
        }
        return tempDir.path;
      });

      final freshService = StorageService();

      await expectLater(
        freshService.basePath,
        throwsA(isA<PlatformException>()),
      );
      expect(await freshService.basePath, tempDir.path);
      expect(callCount, 2);
    });
  });

  // -------------------------------------------------------------------------
  // Config
  // -------------------------------------------------------------------------

  group('loadConfig', () {
    test('returns defaults when file does not exist', () async {
      final config = await service.loadConfig();
      expect(config.timerMode, ConfigModel.defaultTimerMode);
      expect(config.countdownDuration, ConfigModel.defaultCountdownDuration);
      expect(config.bellStart, ConfigModel.defaultBellStart);
      expect(config.bellEnd, ConfigModel.defaultBellEnd);
      expect(config.bellInterval, ConfigModel.defaultBellInterval);
      expect(config.intervalDuration, ConfigModel.defaultIntervalDuration);
      expect(config.intervalEnabled, ConfigModel.defaultIntervalEnabled);
      expect(config.calendarViewEnabled, ConfigModel.defaultCalendarViewEnabled);
      expect(config.themeMode, ConfigModel.defaultThemeMode);
      expect(config.tags, ConfigModel.defaultTags);
      expect(config.quoteSources, ConfigModel.defaultQuoteSources);
    });

    test('returns defaults and saves .bak_corrupt on corrupt JSON', () async {
      final path = '${tempDir.path}/config.json';
      await File(path).writeAsString('not valid json!!!');

      final config = await service.loadConfig();

      expect(config.timerMode, ConfigModel.defaultTimerMode);
      expect(await File('$path.bak_corrupt').exists(), true);
      expect(await File(path).exists(), false);
    });

    test('returns defaults and saves .bak_corrupt on wrong JSON structure',
        () async {
      final path = '${tempDir.path}/config.json';
      // Valid JSON but wrong top-level type (array instead of object)
      await File(path).writeAsString('[1, 2, 3]');

      final config = await service.loadConfig();

      expect(config.timerMode, ConfigModel.defaultTimerMode);
      expect(await File('$path.bak_corrupt').exists(), true);
    });

    test('overwrites previous .bak_corrupt on repeated corruption', () async {
      final path = '${tempDir.path}/config.json';

      // First corruption
      await File(path).writeAsString('corrupt1');
      await service.loadConfig();
      await File('$path.bak_corrupt').writeAsString('old corrupt');

      // Second corruption
      await File(path).writeAsString('corrupt2');
      await service.loadConfig();

      expect(await File('$path.bak_corrupt').readAsString(), 'corrupt2');
    });
  });

  group('saveConfig / loadConfig roundtrip', () {
    test('persists and restores all fields', () async {
      final original = ConfigModel(
        timerMode: TimerMode.stopwatch,
        countdownDuration: 1200,
        bellStart: const AudioSource.bundled('temple_bells'),
        bellEnd: const AudioSource.bundled('wind_chime'),
        bellInterval: const AudioSource.bundled('singing_bell'),
        intervalDuration: 600,
        intervalEnabled: true,
        calendarViewEnabled: true,
        userName: 'Harsha',
        themeMode: AppThemeMode.light,
        tags: ['calm', 'focused'],
        quoteSources: ['yoga_sutra', 'upanishad'],
      );

      await service.saveConfig(original);
      final restored = await service.loadConfig();

      expect(restored.timerMode, TimerMode.stopwatch);
      expect(restored.countdownDuration, 1200);
      expect(restored.bellStart, const AudioSource.bundled('temple_bells'));
      expect(restored.bellEnd, const AudioSource.bundled('wind_chime'));
      expect(restored.bellInterval, const AudioSource.bundled('singing_bell'));
      expect(restored.intervalDuration, 600);
      expect(restored.intervalEnabled, true);
      expect(restored.calendarViewEnabled, true);
      expect(restored.userName, 'Harsha');
      expect(restored.themeMode, AppThemeMode.light);
      expect(restored.tags, ['calm', 'focused']);
      expect(restored.quoteSources, ['yoga_sutra', 'upanishad']);
    });

    test('persists null optional fields', () async {
      final original = ConfigModel(userName: null, backgroundMusic: null);
      await service.saveConfig(original);
      final restored = await service.loadConfig();
      expect(restored.userName, isNull);
      expect(restored.backgroundMusic, isNull);
    });

    test('save produces valid JSON file on disk', () async {
      await service.saveConfig(ConfigModel());
      final path = '${tempDir.path}/config.json';
      final content = await File(path).readAsString();
      expect(() => jsonDecode(content), returnsNormally);
    });
  });

  // -------------------------------------------------------------------------
  // Sessions
  // -------------------------------------------------------------------------

  group('loadSessions', () {
    test('returns empty list when file does not exist', () async {
      expect(await service.loadSessions(), isEmpty);
    });

    test('returns empty list and saves .bak_corrupt on corrupt JSON', () async {
      final path = '${tempDir.path}/sessions.json';
      await File(path).writeAsString('not json');

      final sessions = await service.loadSessions();

      expect(sessions, isEmpty);
      expect(await File('$path.bak_corrupt').exists(), true);
    });

    test('returns empty list when sessions key is missing', () async {
      final path = '${tempDir.path}/sessions.json';
      await File(path).writeAsString('{}');

      expect(await service.loadSessions(), isEmpty);
    });
  });

  group('saveSessions / loadSessions roundtrip', () {
    test('persists and restores a single session', () async {
      final session = _makeSession(notes: 'peaceful sit', tags: ['calm']);
      await service.saveSessions([session]);
      final restored = await service.loadSessions();

      expect(restored.length, 1);
      expect(restored.first.id, 'session-1');
      expect(restored.first.duration, 600);
      expect(restored.first.notes, 'peaceful sit');
      expect(restored.first.tags, ['calm']);
      expect(restored.first.completedFully, true);
    });

    test('persists and restores multiple sessions', () async {
      final sessions = [
        _makeSession(id: 's1', duration: 300),
        _makeSession(id: 's2', duration: 900, timerMode: TimerMode.stopwatch),
        _makeSession(id: 's3', duration: 1800, completedFully: false),
      ];

      await service.saveSessions(sessions);
      final restored = await service.loadSessions();

      expect(restored.length, 3);
      expect(restored.map((s) => s.id).toList(), ['s1', 's2', 's3']);
      expect(restored[1].timerMode, TimerMode.stopwatch);
      expect(restored[2].completedFully, false);
    });

    test('overwrites existing sessions on save', () async {
      await service.saveSessions([_makeSession(id: 's1')]);
      await service.saveSessions([_makeSession(id: 's2'), _makeSession(id: 's3')]);
      final restored = await service.loadSessions();
      expect(restored.length, 2);
      expect(restored.map((s) => s.id).toList(), ['s2', 's3']);
    });

    test('saves empty list', () async {
      await service.saveSessions([_makeSession(id: 's1')]);
      await service.saveSessions([]);
      expect(await service.loadSessions(), isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // sessions.json encryption
  // -------------------------------------------------------------------------

  group('sessions.json encryption', () {
    test('with no master key configured, sessions.json stays plaintext',
        () async {
      final encService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await encService.saveSessions([_makeSession(notes: 'peaceful sit')]);

      final path = '${tempDir.path}/sessions.json';
      final raw = await File(path).readAsString();

      expect(raw, contains('peaceful sit'));
      expect(encService.isUnlocked, false);
      expect(await encService.loadSessions(), hasLength(1));
    });

    test('enableEncryption writes ciphertext bytes, not plaintext, on save',
        () async {
      final encService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await encService.enableEncryption(password: 'correct horse battery staple');
      await encService.saveSessions([_makeSession(notes: 'peaceful sit')]);

      final path = '${tempDir.path}/sessions.json';
      final raw = await File(path).readAsString();

      expect(raw, isNot(contains('peaceful sit')));
      expect(raw, isNot(contains('session-1')));
      expect(jsonDecode(raw), containsPair('encrypted', true));
    });

    test('round-trips sessions through the same unlocked instance', () async {
      final encService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await encService.enableEncryption(password: 'correct horse battery staple');
      final sessions = [
        _makeSession(id: 's1', notes: 'peaceful sit', tags: ['calm']),
        _makeSession(id: 's2', duration: 900),
      ];

      await encService.saveSessions(sessions);
      final restored = await encService.loadSessions();

      expect(restored.map((s) => s.id).toList(), ['s1', 's2']);
      expect(restored.first.notes, 'peaceful sit');
      expect(restored.first.tags, ['calm']);
    });

    test('a fresh instance can unlock with the correct password and decrypt',
        () async {
      final setupService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await setupService.enableEncryption(password: 'correct horse battery staple');
      await setupService.saveSessions([_makeSession(notes: 'peaceful sit')]);

      final freshService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      expect(await freshService.isEncryptionEnabled, true);

      final unlocked =
          await freshService.unlockWithPassword('correct horse battery staple');

      expect(unlocked, true);
      expect(freshService.isUnlocked, true);
      final restored = await freshService.loadSessions();
      expect(restored.single.notes, 'peaceful sit');
    });

    test('unlockWithPassword returns false for the wrong password and leaves '
        'the encrypted file untouched', () async {
      final setupService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await setupService.enableEncryption(password: 'correct horse battery staple');
      await setupService.saveSessions([_makeSession(notes: 'peaceful sit')]);

      final path = '${tempDir.path}/sessions.json';
      final beforeAttempt = await File(path).readAsString();

      final freshService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      final unlocked = await freshService.unlockWithPassword('wrong password');

      expect(unlocked, false);
      expect(freshService.isUnlocked, false);
      expect(await File(path).readAsString(), beforeAttempt);
    });

    test('loadSessions throws StorageLockedException when the file is '
        'encrypted but no master key is available, without touching the file',
        () async {
      final setupService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await setupService.enableEncryption(password: 'correct horse battery staple');
      await setupService.saveSessions([_makeSession(notes: 'peaceful sit')]);

      final path = '${tempDir.path}/sessions.json';
      final beforeAttempt = await File(path).readAsString();

      final freshService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());

      await expectLater(
        freshService.loadSessions(),
        throwsA(isA<StorageLockedException>()),
      );
      expect(await File(path).readAsString(), beforeAttempt);
      expect(await File('$path.bak_corrupt').exists(), false);
    });

    test('saveSessions throws StorageLockedException instead of silently '
        'writing plaintext when encryption is enabled but this instance is '
        'locked', () async {
      final setupService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await setupService.enableEncryption(password: 'correct horse battery staple');
      await setupService.saveSessions([_makeSession(notes: 'peaceful sit')]);

      final path = '${tempDir.path}/sessions.json';
      final beforeAttempt = await File(path).readAsString();

      final lockedService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      // Never unlocked: isUnlocked is false, but encryption IS enabled.

      await expectLater(
        lockedService.saveSessions([_makeSession(notes: 'new plaintext data')]),
        throwsA(isA<StorageLockedException>()),
      );
      // The previously-encrypted file must not have been overwritten with
      // plaintext (or at all).
      expect(await File(path).readAsString(), beforeAttempt);
    });

    test('enableEncryption throws StateError and leaves existing metadata/'
        'master key untouched when encryption is already enabled', () async {
      final encService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await encService.enableEncryption(password: 'first password');

      final metaPath = '${tempDir.path}/encryption_meta.json';
      final metaBefore = await File(metaPath).readAsString();

      await expectLater(
        encService.enableEncryption(password: 'second password'),
        throwsA(isA<StateError>()),
      );

      expect(await File(metaPath).readAsString(), metaBefore);
      // The original master key must still work — a second enableEncryption
      // call must not have discarded it.
      final freshService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      expect(
        await freshService.unlockWithPassword('first password'),
        true,
      );
    });

    test('enableEncryption migrates sessions already on disk to ciphertext '
        'immediately, not only on the next save', () async {
      final encService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await encService.saveSessions([_makeSession(notes: 'pre-existing plaintext')]);

      await encService.enableEncryption(password: 'correct horse battery staple');

      final path = '${tempDir.path}/sessions.json';
      final raw = await File(path).readAsString();
      expect(raw, isNot(contains('pre-existing plaintext')));
      expect(jsonDecode(raw), containsPair('encrypted', true));

      final restored = await encService.loadSessions();
      expect(restored.single.notes, 'pre-existing plaintext');
    });

    test('unlockWithPassword propagates rather than reporting "wrong '
        'password" when the metadata file itself is corrupt', () async {
      final encService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await encService.enableEncryption(password: 'correct horse battery staple');

      final metaPath = '${tempDir.path}/encryption_meta.json';
      await File(metaPath).writeAsString('not valid json!!!');

      final freshService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());

      await expectLater(
        freshService.unlockWithPassword('correct horse battery staple'),
        throwsA(anything),
      );
    });

    test('unlockWithPassword derives using the KDF params recorded in '
        "metadata, not this instance's configured params", () async {
      final setupService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: CryptoService(
          argon2Parallelism: 1,
          argon2MemoryKiB: 8,
          argon2Iterations: 1,
        ),
      );
      await setupService.enableEncryption(password: 'correct horse battery staple');
      await setupService.saveSessions([_makeSession(notes: 'peaceful sit')]);

      // A fresh instance configured with DIFFERENT Argon2 params — as if
      // production defaults changed since this install's data was
      // encrypted. Deriving with these (instead of the params recorded in
      // encryption_meta.json) would produce the wrong key and reject the
      // correct password.
      final freshService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: CryptoService(
          argon2Parallelism: 1,
          argon2MemoryKiB: 16,
          argon2Iterations: 3,
        ),
      );

      final unlocked =
          await freshService.unlockWithPassword('correct horse battery staple');

      expect(unlocked, true);
      expect((await freshService.loadSessions()).single.notes, 'peaceful sit');
    });

    test('enableEncryption serializes with a concurrent runExclusive call '
        'instead of racing it', () async {
      final order = <int>[];
      final encService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());

      final first = encService
          .enableEncryption(password: 'correct horse battery staple')
          .then((_) => order.add(1));
      final second = encService.runExclusive(() async {
        order.add(2);
      });

      await Future.wait([first, second]);

      expect(order, [1, 2],
          reason: 'enableEncryption must take the same write lock as '
              'runExclusive, or a concurrent save could interleave with '
              'setup and observe an inconsistent half-enabled state');
    });
  });

  // -------------------------------------------------------------------------
  // Recovery key setup (issue #52)
  // -------------------------------------------------------------------------

  group('prepareRecoveryKey / commitRecoveryKey', () {
    test('prepareRecoveryKey throws StateError when called before the '
        'instance is unlocked', () async {
      final service =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());

      expect(() => service.prepareRecoveryKey(), throwsStateError);
    });

    test('prepareRecoveryKey writes nothing to encryption_meta.json — the '
        'candidate exists only in memory until committed', () async {
      final service =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await service.enableEncryption(password: 'correct horse battery staple');
      final path = '${tempDir.path}/encryption_meta.json';
      final before = await File(path).readAsString();

      await service.prepareRecoveryKey();

      final after = await File(path).readAsString();
      expect(after, before,
          reason: 'preparing a candidate must not persist anything — only '
              'commitRecoveryKey may write to disk');
    });

    test('a committed recovery key successfully unwraps the master key',
        () async {
      final service =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await service.enableEncryption(password: 'correct horse battery staple');

      final pending = await service.prepareRecoveryKey();
      await service.commitRecoveryKey(pending);

      final path = '${tempDir.path}/encryption_meta.json';
      final json = jsonDecode(await File(path).readAsString()) as Map<String, dynamic>;
      final metadata = EncryptionMetadata.fromJson(json);
      final crypto = _testCryptoService();
      final wrappingKey = await crypto.deriveKeyFromPassword(
        password: pending.recoveryKey,
        salt: metadata.recoverySalt!,
      );
      final unwrapped = await crypto.unwrapKey(
        wrapped: metadata.wrappedMasterKeyRecovery!,
        wrappingKey: wrappingKey,
      );

      // Prove it's the same master key by round-tripping a save/load through
      // a fresh instance manually unlocked with the recovered key's bytes:
      // saveSessions()/loadSessions() only ever go through internal state, so
      // comparing masterKeyVerifier output is the direct, black-box way to
      // confirm this is the same key without reaching into private fields.
      final verifierFromRecovery = await crypto.masterKeyVerifier(unwrapped);
      expect(verifierFromRecovery, metadata.masterKeyVerifier);
    });

    test('commitRecoveryKey persists recoverySalt and '
        'wrappedMasterKeyRecovery to encryption_meta.json', () async {
      final service =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await service.enableEncryption(password: 'correct horse battery staple');

      final pending = await service.prepareRecoveryKey();
      await service.commitRecoveryKey(pending);

      final path = '${tempDir.path}/encryption_meta.json';
      final json = jsonDecode(await File(path).readAsString()) as Map<String, dynamic>;
      final metadata = EncryptionMetadata.fromJson(json);
      expect(metadata.recoverySalt, isNotNull);
      expect(metadata.wrappedMasterKeyRecovery, isNotNull);
      // The password-wrapped copy must be untouched by adding the recovery
      // copy alongside it.
      expect(
        await service.unlockWithPassword('correct horse battery staple'),
        isTrue,
      );
    });

    test('a second commit throws StateError and does not overwrite the '
        'first recovery wrap', () async {
      final service =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await service.enableEncryption(password: 'correct horse battery staple');
      await service.commitRecoveryKey(await service.prepareRecoveryKey());

      final path = '${tempDir.path}/encryption_meta.json';
      final before = await File(path).readAsString();

      await expectLater(
        service.commitRecoveryKey(await service.prepareRecoveryKey()),
        throwsStateError,
      );

      final after = await File(path).readAsString();
      expect(after, before,
          reason: 'a rejected second commit must never regenerate or '
              'overwrite the first recovery key setup, silently or '
              'otherwise');
    });

    test('the plaintext recovery key is never written to '
        'encryption_meta.json', () async {
      final service =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await service.enableEncryption(password: 'correct horse battery staple');

      final pending = await service.prepareRecoveryKey();
      await service.commitRecoveryKey(pending);

      final path = '${tempDir.path}/encryption_meta.json';
      final raw = await File(path).readAsString();
      expect(raw, isNot(contains(pending.recoveryKey)));
    });

    // Regression test for the scenario where a recovery-key screen is shown,
    // a candidate is generated, but the user leaves or the app is killed
    // before acknowledging/committing it (e.g. the screen is disposed and a
    // fresh one is later shown). Discarding an uncommitted candidate must
    // leave the store in a state where setup can still be completed — not
    // permanently stranded on a persisted wrap whose plaintext key is gone.
    test('an abandoned, uncommitted candidate does not block a later '
        'successful setup', () async {
      final service =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await service.enableEncryption(password: 'correct horse battery staple');

      // Simulates a first RecoveryKeyScreen instance generating a candidate
      // and then being disposed (e.g. navigated away from) before the user
      // acknowledges it — the candidate is simply dropped, never committed.
      final abandoned = await service.prepareRecoveryKey();

      // A later visit to the screen must be able to generate a fresh
      // candidate and complete setup normally, without the earlier
      // abandoned one interfering.
      final completed = await service.prepareRecoveryKey();
      await service.commitRecoveryKey(completed);

      final path = '${tempDir.path}/encryption_meta.json';
      final json = jsonDecode(await File(path).readAsString()) as Map<String, dynamic>;
      final metadata = EncryptionMetadata.fromJson(json);
      final crypto = _testCryptoService();

      // The abandoned candidate's key must NOT unwrap the persisted master
      // key — only the completed, committed candidate's key may.
      final wrappingKeyFromAbandoned = await crypto.deriveKeyFromPassword(
        password: abandoned.recoveryKey,
        salt: metadata.recoverySalt!,
      );
      await expectLater(
        crypto.unwrapKey(
          wrapped: metadata.wrappedMasterKeyRecovery!,
          wrappingKey: wrappingKeyFromAbandoned,
        ),
        throwsA(isA<CryptoAuthenticationException>()),
      );

      final wrappingKeyFromCompleted = await crypto.deriveKeyFromPassword(
        password: completed.recoveryKey,
        salt: metadata.recoverySalt!,
      );
      final unwrapped = await crypto.unwrapKey(
        wrapped: metadata.wrappedMasterKeyRecovery!,
        wrappingKey: wrappingKeyFromCompleted,
      );
      expect(
        await crypto.masterKeyVerifier(unwrapped),
        metadata.masterKeyVerifier,
      );
    });
  });

  // -------------------------------------------------------------------------
  // unlockWithRecoveryKey (issue #53)
  // -------------------------------------------------------------------------

  group('unlockWithRecoveryKey', () {
    test('a fresh instance can unlock with the correct recovery key and '
        'decrypt', () async {
      final setupService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await setupService.enableEncryption(password: 'correct horse battery staple');
      final pending = await setupService.prepareRecoveryKey();
      await setupService.commitRecoveryKey(pending);
      await setupService.saveSessions([_makeSession(notes: 'peaceful sit')]);

      final freshService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      final unlocked =
          await freshService.unlockWithRecoveryKey(pending.recoveryKey);

      expect(unlocked, true);
      expect(freshService.isUnlocked, true);
      final restored = await freshService.loadSessions();
      expect(restored.single.notes, 'peaceful sit');
    });

    test('returns false for the wrong recovery key and leaves the encrypted '
        'file and in-memory key untouched', () async {
      final setupService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await setupService.enableEncryption(password: 'correct horse battery staple');
      final pending = await setupService.prepareRecoveryKey();
      await setupService.commitRecoveryKey(pending);
      await setupService.saveSessions([_makeSession(notes: 'peaceful sit')]);

      final path = '${tempDir.path}/sessions.json';
      final beforeAttempt = await File(path).readAsString();

      final freshService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      final unlocked = await freshService
          .unlockWithRecoveryKey('WRNG-WRNG-WRNG-WRNG-WRNG-WRNG-WRNG-WRNG');

      expect(unlocked, false);
      expect(freshService.isUnlocked, false);
      expect(await File(path).readAsString(), beforeAttempt);
    });

    test('returns false when no recovery key has ever been committed',
        () async {
      final setupService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await setupService.enableEncryption(password: 'correct horse battery staple');

      final freshService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      final unlocked = await freshService
          .unlockWithRecoveryKey('AAAA-AAAA-AAAA-AAAA-AAAA-AAAA-AAAA-AAAA');

      expect(unlocked, false);
      expect(freshService.isUnlocked, false);
    });

    test('returns false when encryption has never been enabled', () async {
      final freshService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      final unlocked = await freshService
          .unlockWithRecoveryKey('AAAA-AAAA-AAAA-AAAA-AAAA-AAAA-AAAA-AAAA');

      expect(unlocked, false);
      expect(freshService.isUnlocked, false);
    });

    test('caches the master key on success', () async {
      final setupService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await setupService.enableEncryption(password: 'correct horse battery staple');
      final pending = await setupService.prepareRecoveryKey();
      await setupService.commitRecoveryKey(pending);

      final cache = _SpyKeyCache();
      final freshService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: cache,
      );
      final unlocked =
          await freshService.unlockWithRecoveryKey(pending.recoveryKey);

      expect(unlocked, true);
      expect(cache.saveCalls, 1);
      expect(await cache.read(), isNotNull);
    });
  });

  group('changePassword', () {
    test('throws StateError when encryption is not enabled', () async {
      await expectLater(
        service.changePassword(
          currentPassword: 'anything',
          newPassword: 'new password here',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('returns false for the wrong current password and leaves the '
        'metadata and old password untouched', () async {
      final setupService = StorageService.withBasePath(tempDir.path,
          cryptoService: _testCryptoService());
      await setupService.enableEncryption(
          password: 'correct horse battery staple');

      final metaPath = '${tempDir.path}/encryption_meta.json';
      final beforeAttempt = await File(metaPath).readAsString();

      final changed = await setupService.changePassword(
        currentPassword: 'wrong password',
        newPassword: 'new password here',
      );

      expect(changed, false);
      expect(await File(metaPath).readAsString(), beforeAttempt);

      final freshService = StorageService.withBasePath(tempDir.path,
          cryptoService: _testCryptoService());
      expect(
        await freshService.unlockWithPassword('correct horse battery staple'),
        true,
      );
    });

    test('a successful change makes the old password stop working and the '
        'new one work, on a fresh instance', () async {
      final setupService = StorageService.withBasePath(tempDir.path,
          cryptoService: _testCryptoService());
      await setupService.enableEncryption(
          password: 'correct horse battery staple');

      final changed = await setupService.changePassword(
        currentPassword: 'correct horse battery staple',
        newPassword: 'new password here',
      );
      expect(changed, true);

      final oldPasswordService = StorageService.withBasePath(tempDir.path,
          cryptoService: _testCryptoService());
      expect(
        await oldPasswordService
            .unlockWithPassword('correct horse battery staple'),
        false,
      );

      final newPasswordService = StorageService.withBasePath(tempDir.path,
          cryptoService: _testCryptoService());
      expect(
        await newPasswordService.unlockWithPassword('new password here'),
        true,
      );
    });

    test('the recovery key continues to unlock the data, unchanged, after '
        'a password change', () async {
      final setupService = StorageService.withBasePath(tempDir.path,
          cryptoService: _testCryptoService());
      await setupService.enableEncryption(
          password: 'correct horse battery staple');
      final pending = await setupService.prepareRecoveryKey();
      await setupService.commitRecoveryKey(pending);

      final changed = await setupService.changePassword(
        currentPassword: 'correct horse battery staple',
        newPassword: 'new password here',
      );
      expect(changed, true);

      final freshService = StorageService.withBasePath(tempDir.path,
          cryptoService: _testCryptoService());
      expect(
        await freshService.unlockWithRecoveryKey(pending.recoveryKey),
        true,
      );
    });

    test('sessions saved before the change remain readable through the '
        'same already-unlocked instance afterward, without re-encrypting '
        'sessions.json', () async {
      final setupService = StorageService.withBasePath(tempDir.path,
          cryptoService: _testCryptoService());
      await setupService.enableEncryption(
          password: 'correct horse battery staple');
      await setupService.saveSessions([_makeSession(notes: 'peaceful sit')]);
      final sessionsPath = '${tempDir.path}/sessions.json';
      final sessionsBeforeChange =
          await File(sessionsPath).readAsString();

      final changed = await setupService.changePassword(
        currentPassword: 'correct horse battery staple',
        newPassword: 'new password here',
      );
      expect(changed, true);

      // The master key never changed, so sessions.json (ciphertext under
      // that same master key) is untouched by the password change.
      expect(await File(sessionsPath).readAsString(), sessionsBeforeChange);

      final restored = await setupService.loadSessions();
      expect(restored.single.notes, 'peaceful sit');

      final freshService = StorageService.withBasePath(tempDir.path,
          cryptoService: _testCryptoService());
      await freshService.unlockWithPassword('new password here');
      final restoredFresh = await freshService.loadSessions();
      expect(restoredFresh.single.notes, 'peaceful sit');
    });
  });

  group('unlockWithPassword / unlockWithRecoveryKey — corrupt metadata '
      '(issue #53 review)', () {
    test('unlockWithPassword propagates rather than reporting "wrong '
        'password" when encryption_meta.json is malformed JSON', () async {
      final path = '${tempDir.path}/encryption_meta.json';
      await File(path).writeAsString('not valid json');

      final service =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());

      await expectLater(
        service.unlockWithPassword('anything'),
        throwsFormatException,
      );
      expect(service.isUnlocked, false);
    });

    test('unlockWithRecoveryKey propagates rather than reporting "wrong '
        'recovery key" when encryption_meta.json is malformed JSON',
        () async {
      final path = '${tempDir.path}/encryption_meta.json';
      await File(path).writeAsString('not valid json');

      final service =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());

      await expectLater(
        service.unlockWithRecoveryKey('AAAA-AAAA-AAAA-AAAA-AAAA-AAAA-AAAA-AAAA'),
        throwsFormatException,
      );
      expect(service.isUnlocked, false);
    });
  });

  // -------------------------------------------------------------------------
  // Master key caching (issue #50)
  // -------------------------------------------------------------------------

  group('master key caching', () {
    test('enableEncryption caches the master key', () async {
      final cache = _SpyKeyCache();
      final encService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: cache,
      );

      await encService.enableEncryption(password: 'correct horse battery staple');

      expect(cache.saveCalls, 1);
      expect(await cache.read(), isNotNull);
    });

    test('unlockWithPassword caches the master key on success', () async {
      final setupCache = _SpyKeyCache();
      final setupService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: setupCache,
      );
      await setupService.enableEncryption(password: 'correct horse battery staple');

      final unlockCache = _SpyKeyCache();
      final freshService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: unlockCache,
      );

      final unlocked =
          await freshService.unlockWithPassword('correct horse battery staple');

      expect(unlocked, true);
      expect(unlockCache.saveCalls, 1);
      expect(await unlockCache.read(), isNotNull);
    });

    test('unlockWithPassword does not cache anything on a wrong password',
        () async {
      final setupService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
      );
      await setupService.enableEncryption(password: 'correct horse battery staple');

      final cache = _SpyKeyCache();
      final freshService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: cache,
      );

      final unlocked = await freshService.unlockWithPassword('wrong password');

      expect(unlocked, false);
      expect(cache.saveCalls, 0);
      expect(await cache.read(), isNull);
    });

    test('tryUnlockWithCachedKey restores the master key on a fresh '
        'instance sharing the same cache — simulating a restart', () async {
      final sharedCache = _SpyKeyCache();
      final setupService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: sharedCache,
      );
      await setupService.enableEncryption(password: 'correct horse battery staple');
      await setupService.saveSessions([_makeSession(notes: 'peaceful sit')]);

      final freshService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: sharedCache,
      );
      expect(freshService.isUnlocked, false,
          reason: 'a fresh instance must not start unlocked before trying '
              'the cache');

      final restored = await freshService.tryUnlockWithCachedKey();

      expect(restored, true);
      expect(freshService.isUnlocked, true);
      expect((await freshService.loadSessions()).single.notes, 'peaceful sit');
    });

    test('tryUnlockWithCachedKey returns false and leaves the instance '
        'locked when encryption is enabled but nothing is cached '
        '(simulated cache miss)', () async {
      final setupService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
      );
      await setupService.enableEncryption(password: 'correct horse battery staple');

      final freshService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: InMemoryKeyCache(),
      );

      final restored = await freshService.tryUnlockWithCachedKey();

      expect(restored, false);
      expect(freshService.isUnlocked, false);
      expect(
        () => freshService.loadSessions(),
        throwsA(isA<StorageLockedException>()),
      );
    });

    test('tryUnlockWithCachedKey returns false without touching the cache '
        'when encryption was never enabled', () async {
      final cache = _SpyKeyCache()..allowRead = false;
      final freshService = StorageService.withBasePath(
        tempDir.path,
        secureKeyCache: cache,
      );

      final restored = await freshService.tryUnlockWithCachedKey();

      expect(restored, false);
      expect(freshService.isUnlocked, false);
      expect(cache.readCalls, 0);
    });

    test('tryUnlockWithCachedKey returns true immediately when already '
        'unlocked, without touching the cache', () async {
      final cache = _SpyKeyCache()..allowRead = false;
      final encService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: cache,
      );
      await encService.enableEncryption(password: 'correct horse battery staple');
      cache.allowRead = false;

      final restored = await encService.tryUnlockWithCachedKey();

      expect(restored, true);
      expect(cache.readCalls, 0);
    });

    test('clearCachedMasterKey removes the cached key, so a later '
        'tryUnlockWithCachedKey misses', () async {
      final sharedCache = _SpyKeyCache();
      final setupService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: sharedCache,
      );
      await setupService.enableEncryption(password: 'correct horse battery staple');

      await setupService.clearCachedMasterKey();

      expect(sharedCache.clearCalls, 1);
      expect(await sharedCache.read(), isNull);

      final freshService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: sharedCache,
      );
      expect(await freshService.tryUnlockWithCachedKey(), false);
    });

    test('clearCachedMasterKey does not clear the in-memory key of this '
        'instance', () async {
      final encService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
      );
      await encService.enableEncryption(password: 'correct horse battery staple');

      await encService.clearCachedMasterKey();

      expect(encService.isUnlocked, true,
          reason: 'clearCachedMasterKey only invalidates the persisted '
              'cache; in-memory clearing is lock()\'s job');
    });

    test('tryUnlockWithCachedKey rejects a cached key that cannot decrypt '
        'the on-disk sessions.json, clears the stale entry, and leaves the '
        'file untouched — instead of trusting it and letting loadSessions '
        'mistake the wrong key for corruption', () async {
      final sharedCache = _SpyKeyCache();
      final setupService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: sharedCache,
      );
      await setupService.enableEncryption(password: 'correct horse battery staple');
      await setupService.saveSessions([_makeSession(notes: 'peaceful sit')]);

      // Simulate a keystore entry that has gone stale relative to what's on
      // disk (e.g. documents restored from an older backup than the
      // surviving OS keystore entry) by overwriting the shared cache with
      // an unrelated key.
      final staleKey = await _testCryptoService().generateMasterKey();
      await sharedCache.save(staleKey);

      final freshService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: sharedCache,
      );

      final restored = await freshService.tryUnlockWithCachedKey();

      expect(restored, false);
      expect(freshService.isUnlocked, false);
      expect(await sharedCache.read(), isNull,
          reason: 'the stale entry must be dropped so a later attempt '
              'does not keep retrying the same bad key');

      // The original, correctly-encrypted file must survive untouched —
      // not get renamed to .bak_corrupt by a wrong-key decrypt failure.
      final path = '${tempDir.path}/sessions.json';
      expect(await File(path).exists(), true);
      expect(await File('$path.bak_corrupt').exists(), false);
      final recheckService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
      );
      expect(
        await recheckService.unlockWithPassword('correct horse battery staple'),
        true,
      );
      expect((await recheckService.loadSessions()).single.notes, 'peaceful sit');
    });

    test('tryUnlockWithCachedKey rejects a cached key that does not match '
        "encryption_meta.json's verifier even when sessions.json does not "
        'exist yet — otherwise a later saveSessions would silently encrypt '
        'new data under the wrong key, unrecoverable after a real password '
        'unlock', () async {
      final sharedCache = _SpyKeyCache();
      final setupService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: sharedCache,
      );
      await setupService.enableEncryption(password: 'correct horse battery staple');
      // No sessions saved yet — sessions.json does not exist on disk, so a
      // decrypt-based check alone has nothing to verify the key against.

      final staleKey = await _testCryptoService().generateMasterKey();
      await sharedCache.save(staleKey);

      final freshService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: sharedCache,
      );

      final restored = await freshService.tryUnlockWithCachedKey();

      expect(restored, false);
      expect(freshService.isUnlocked, false);
      expect(await sharedCache.read(), isNull);

      // A real password unlock must still work, and a session saved
      // through it must be readable afterward — proving no data was ever
      // encrypted under the stale, unrelated key.
      final recheckService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
      );
      expect(
        await recheckService.unlockWithPassword('correct horse battery staple'),
        true,
      );
      await recheckService.saveSessions([_makeSession(notes: 'peaceful sit')]);
      expect((await recheckService.loadSessions()).single.notes, 'peaceful sit');
    });

    test('tryUnlockWithCachedKey returns false instead of throwing when '
        'the cache read itself fails (corrupt entry, keystore '
        'unavailable, etc)', () async {
      final setupService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
      );
      await setupService.enableEncryption(password: 'correct horse battery staple');

      final freshService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: _ThrowingReadKeyCache(),
      );

      final restored = await freshService.tryUnlockWithCachedKey();

      expect(restored, false);
      expect(freshService.isUnlocked, false);
    });

    test('enableEncryption still enables encryption and migrates sessions '
        'to ciphertext even if caching the master key fails', () async {
      final encService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: _ThrowingSaveKeyCache(),
      );
      await encService.saveSessions([_makeSession(notes: 'peaceful sit')]);

      await encService.enableEncryption(password: 'correct horse battery staple');

      expect(encService.isUnlocked, true);
      final path = '${tempDir.path}/sessions.json';
      final raw = await File(path).readAsString();
      expect(raw, isNot(contains('peaceful sit')));
      expect(jsonDecode(raw), containsPair('encrypted', true));
    });

    test('unlockWithPassword still returns true when caching the master '
        'key afterward fails', () async {
      final setupService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
      );
      await setupService.enableEncryption(password: 'correct horse battery staple');

      final freshService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: _ThrowingSaveKeyCache(),
      );

      final unlocked =
          await freshService.unlockWithPassword('correct horse battery staple');

      expect(unlocked, true);
      expect(freshService.isUnlocked, true);
    });

    test('lock() also clears the persisted cache, so a fresh instance '
        'sharing it does not silently auto-unlock — an explicit lock must '
        'require the password again', () async {
      final sharedCache = _SpyKeyCache();
      final encService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: sharedCache,
      );
      await encService.enableEncryption(password: 'correct horse battery staple');

      await encService.lock();

      expect(encService.isUnlocked, false);
      expect(await sharedCache.read(), isNull);

      final freshService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: sharedCache,
      );
      expect(await freshService.tryUnlockWithCachedKey(), false);
    });

    test('lock() surfaces a failure clearing the persisted cache instead '
        'of silently leaving a stale entry behind, but still clears the '
        'in-memory key regardless', () async {
      final encService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: _testCryptoService(),
        secureKeyCache: _ThrowingClearKeyCache(),
      );
      await encService.enableEncryption(password: 'correct horse battery staple');

      await expectLater(encService.lock(), throwsA(anything));

      expect(encService.isUnlocked, false,
          reason: 'the in-memory key must be cleared even if persisting '
              'the clear fails');
    });
  });

  // -------------------------------------------------------------------------
  // Legacy metadata migration for masterKeyVerifier (issue #50 follow-up)
  // -------------------------------------------------------------------------

  group('legacy metadata migration for masterKeyVerifier', () {
    /// Writes an `encryption_meta.json` in the exact shape
    /// `EncryptionMetadata.toJson()` produced before `masterKeyVerifier`
    /// existed (no such key at all) — what a real pre-#50-follow-up
    /// encrypted install has on disk — and a matching encrypted
    /// `sessions.json`, without going through `enableEncryption` (which
    /// would always write the current, verifier-including shape).
    Future<SecretKey> seedLegacyEncryptedInstall(
      Directory dir,
      CryptoService crypto, {
      required String password,
    }) async {
      final salt = crypto.generateSalt();
      final passwordKey = await crypto.deriveKeyFromPassword(
        password: password,
        salt: salt,
      );
      final masterKey = await crypto.generateMasterKey();
      final wrapped = await crypto.wrapKey(
        keyToWrap: masterKey,
        wrappingKey: passwordKey,
      );

      final legacyMetaJson = {
        'version': 1,
        'algorithm': 'aes-256-gcm',
        'kdf': {
          'algorithm': 'argon2id',
          'salt': base64Encode(salt),
          'memoryKiB': crypto.argon2MemoryKiB,
          'iterations': crypto.argon2Iterations,
          'parallelism': crypto.argon2Parallelism,
        },
        'wrappedMasterKeyPassword': wrapped.toJson(),
        'wrappedMasterKeyRecovery': null,
        // Deliberately no 'masterKeyVerifier' key — the legacy shape.
      };
      await File('${dir.path}/encryption_meta.json').writeAsString(
        const JsonEncoder.withIndent('  ').convert(legacyMetaJson),
      );

      final sessionsContent = const JsonEncoder.withIndent('  ').convert({
        'sessions': [_makeSession(notes: 'peaceful sit').toJson()],
      });
      final payload = await crypto.encrypt(
        plaintext: utf8.encode(sessionsContent),
        key: masterKey,
      );
      final envelope = {'encrypted': true, 'payload': payload.toJson()};
      await File('${dir.path}/sessions.json').writeAsString(
        const JsonEncoder.withIndent('  ').convert(envelope),
      );

      return masterKey;
    }

    test('unlockWithPassword accepts legacy metadata predating '
        'masterKeyVerifier, reads the existing encrypted sessions, and '
        'migrates the metadata so a later cached unlock can use it',
        () async {
      final crypto = _testCryptoService();
      await seedLegacyEncryptedInstall(
        tempDir,
        crypto,
        password: 'correct horse battery staple',
      );

      final sharedCache = InMemoryKeyCache();
      final freshService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: crypto,
        secureKeyCache: sharedCache,
      );

      final unlocked =
          await freshService.unlockWithPassword('correct horse battery staple');

      expect(unlocked, true);
      expect((await freshService.loadSessions()).single.notes, 'peaceful sit');

      final migratedJson = jsonDecode(
        await File('${tempDir.path}/encryption_meta.json').readAsString(),
      ) as Map<String, dynamic>;
      expect(migratedJson['masterKeyVerifier'], isA<String>(),
          reason: 'a successful password unlock must upgrade legacy '
              'metadata to include a verifier');

      // The migration must actually take effect for auto-unlock: a later
      // instance sharing the (now-populated) cache should unlock without a
      // password and still read the pre-existing session.
      final laterService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: crypto,
        secureKeyCache: sharedCache,
      );
      expect(await laterService.tryUnlockWithCachedKey(), true);
      expect((await laterService.loadSessions()).single.notes, 'peaceful sit');
    });

    test('tryUnlockWithCachedKey never treats a missing verifier as a '
        'match — a cached key from before this fix shipped must not '
        'auto-unlock against unmigrated legacy metadata', () async {
      final crypto = _testCryptoService();
      final masterKey = await seedLegacyEncryptedInstall(
        tempDir,
        crypto,
        password: 'correct horse battery staple',
      );

      // Simulate a cache entry that predates this fix: it holds the
      // genuinely correct master key, but the metadata hasn't been
      // migrated to record a verifier yet.
      final cache = InMemoryKeyCache();
      await cache.save(masterKey);
      final freshService = StorageService.withBasePath(
        tempDir.path,
        cryptoService: crypto,
        secureKeyCache: cache,
      );

      final restored = await freshService.tryUnlockWithCachedKey();

      expect(restored, false,
          reason: 'a missing verifier must never be silently treated as a '
              'match, even if the cached key happens to be correct');
      expect(freshService.isUnlocked, false);
    });
  });

  // -------------------------------------------------------------------------
  // User Quotes
  // -------------------------------------------------------------------------

  group('loadUserQuotes', () {
    test('returns empty list when file does not exist', () async {
      expect(await service.loadUserQuotes(), isEmpty);
    });

    test('returns empty list and saves .bak_corrupt on corrupt JSON', () async {
      final path = '${tempDir.path}/user_quotes.json';
      await File(path).writeAsString('{corrupt}');

      final quotes = await service.loadUserQuotes();

      expect(quotes, isEmpty);
      expect(await File('$path.bak_corrupt').exists(), true);
    });

    test('returns empty list when quotes key is missing', () async {
      final path = '${tempDir.path}/user_quotes.json';
      await File(path).writeAsString('{}');
      expect(await service.loadUserQuotes(), isEmpty);
    });
  });

  group('saveUserQuotes / loadUserQuotes roundtrip', () {
    test('persists and restores a single quote', () async {
      final quote = _makeQuote();
      await service.saveUserQuotes([quote]);
      final restored = await service.loadUserQuotes();

      expect(restored.length, 1);
      expect(restored.first.id, 'quote-1');
      expect(restored.first.source, 'yoga_sutra');
      expect(restored.first.userAdded, true);
      expect(restored.first.translation,
          'Yoga is the cessation of the fluctuations of the mind.');
    });

    test('persists and restores multiple quotes', () async {
      final quotes = [
        _makeQuote(id: 'q1', source: 'yoga_sutra'),
        _makeQuote(id: 'q2', source: 'bhagavad_gita'),
      ];

      await service.saveUserQuotes(quotes);
      final restored = await service.loadUserQuotes();

      expect(restored.length, 2);
      expect(restored.map((q) => q.id).toList(), ['q1', 'q2']);
      expect(restored[1].source, 'bhagavad_gita');
    });

    test('overwrites existing quotes on save', () async {
      await service.saveUserQuotes([_makeQuote(id: 'q1')]);
      await service.saveUserQuotes([_makeQuote(id: 'q2')]);
      final restored = await service.loadUserQuotes();
      expect(restored.length, 1);
      expect(restored.first.id, 'q2');
    });
  });

  // -------------------------------------------------------------------------
  // Export / Import
  // -------------------------------------------------------------------------

  group('validateImportData', () {
    test('returns parsed data for valid structure', () async {
      final content = jsonEncode({
        'version': 1,
        'config': ConfigModel().toJson(),
        'sessions': [],
      });
      final result = await service.validateImportData(content);
      expect(result, isNotNull);
      expect(result!.containsKey('config'), true);
    });

    test('returns parsed data for valid structure including userQuotes',
        () async {
      final content = jsonEncode({
        'version': 1,
        'config': ConfigModel().toJson(),
        'sessions': [_makeSession().toJson()],
        'userQuotes': [_makeQuote().toJson()],
      });
      final result = await service.validateImportData(content);
      expect(result, isNotNull);
    });

    test('returns null when config key is missing', () async {
      final result = await service.validateImportData(
          jsonEncode({'version': 1, 'sessions': []}));
      expect(result, isNull);
    });

    test('returns null when sessions key is missing', () async {
      final result = await service.validateImportData(
          jsonEncode({'version': 1, 'config': ConfigModel().toJson()}));
      expect(result, isNull);
    });

    test('returns null for invalid JSON', () async {
      expect(await service.validateImportData('not json'), isNull);
    });

    test('returns null for empty string', () async {
      expect(await service.validateImportData(''), isNull);
    });

    test('returns null when top-level JSON is not an object', () async {
      expect(await service.validateImportData(jsonEncode([1, 2, 3])), isNull);
    });

    test('returns null when version key is missing', () async {
      final content = jsonEncode({
        'config': ConfigModel().toJson(),
        'sessions': [],
      });
      expect(await service.validateImportData(content), isNull);
    });

    test('returns null when version is the wrong type', () async {
      final content = jsonEncode({
        'version': '1',
        'config': ConfigModel().toJson(),
        'sessions': [],
      });
      expect(await service.validateImportData(content), isNull);
    });

    test('returns null when version is unsupported', () async {
      final content = jsonEncode({
        'version': 999,
        'config': ConfigModel().toJson(),
        'sessions': [],
      });
      expect(await service.validateImportData(content), isNull);
    });

    test('accepts a whole-number double version (e.g. from non-Dart exporters)',
        () async {
      // jsonDecode produces a double for any JSON numeral written with a
      // decimal point, so a hand-written or foreign-tool export of
      // "version": 1.0 must still be treated as version 1.
      final content = jsonEncode({
        'version': 1.0,
        'config': ConfigModel().toJson(),
        'sessions': [],
      });
      expect(await service.validateImportData(content), isNotNull);
    });

    test('returns null when version is a non-whole-number double', () async {
      final content = jsonEncode({
        'version': 1.5,
        'config': ConfigModel().toJson(),
        'sessions': [],
      });
      expect(await service.validateImportData(content), isNull);
    });

    test('returns null when config is not a map', () async {
      final content = jsonEncode({
        'version': 1,
        'config': [1, 2, 3],
        'sessions': [],
      });
      expect(await service.validateImportData(content), isNull);
    });

    test('returns null when config is an empty object', () async {
      // ConfigModel.fromJson({}) happily defaults every field, so an
      // explicit schema check is required to reject a truncated config
      // section instead of silently resetting the user's settings.
      final content = jsonEncode({
        'version': 1,
        'config': {},
        'sessions': [],
      });
      expect(await service.validateImportData(content), isNull);
    });

    test('returns null when a required config field is missing', () async {
      final config = ConfigModel().toJson()..remove('timerMode');
      final content = jsonEncode({
        'version': 1,
        'config': config,
        'sessions': [],
      });
      expect(await service.validateImportData(content), isNull);
    });

    test('returns null when a config field has the wrong type', () async {
      final config = ConfigModel().toJson();
      config['countdownDuration'] = 'not-a-number';
      final content = jsonEncode({
        'version': 1,
        'config': config,
        'sessions': [],
      });
      expect(await service.validateImportData(content), isNull);
    });

    test('returns null when a config list field contains a non-string entry',
        () async {
      final config = ConfigModel().toJson();
      config['tags'] = ['calm', 42];
      final content = jsonEncode({
        'version': 1,
        'config': config,
        'sessions': [],
      });
      expect(await service.validateImportData(content), isNull);
    });

    test('accepts a full config with null backgroundMusic and userName',
        () async {
      final content = jsonEncode({
        'version': 1,
        'config': ConfigModel().toJson(),
        'sessions': [],
      });
      expect(await service.validateImportData(content), isNotNull);
    });

    test('returns null when sessions is not a list', () async {
      final content = jsonEncode({
        'version': 1,
        'config': ConfigModel().toJson(),
        'sessions': 'not-a-list',
      });
      expect(await service.validateImportData(content), isNull);
    });

    test('returns null when a session entry is not a map', () async {
      final content = jsonEncode({
        'version': 1,
        'config': ConfigModel().toJson(),
        'sessions': ['not-a-map'],
      });
      expect(await service.validateImportData(content), isNull);
    });

    test('returns null when a session entry is missing a required field',
        () async {
      final badSession = _makeSession().toJson()..remove('id');
      final content = jsonEncode({
        'version': 1,
        'config': ConfigModel().toJson(),
        'sessions': [badSession],
      });
      expect(await service.validateImportData(content), isNull);
    });

    test('returns null when a session entry has a malformed date', () async {
      final badSession = _makeSession().toJson();
      badSession['date'] = 'not-a-date';
      final content = jsonEncode({
        'version': 1,
        'config': ConfigModel().toJson(),
        'sessions': [badSession],
      });
      expect(await service.validateImportData(content), isNull);
    });

    test('returns null when userQuotes is not a list', () async {
      final content = jsonEncode({
        'version': 1,
        'config': ConfigModel().toJson(),
        'sessions': [],
        'userQuotes': 'not-a-list',
      });
      expect(await service.validateImportData(content), isNull);
    });

    test('returns null when a userQuotes entry is missing a required field',
        () async {
      final badQuote = _makeQuote().toJson()..remove('originalText');
      final content = jsonEncode({
        'version': 1,
        'config': ConfigModel().toJson(),
        'sessions': [],
        'userQuotes': [badQuote],
      });
      expect(await service.validateImportData(content), isNull);
    });
  });

  group('importData — replaceAll', () {
    test('replaces config and sessions', () async {
      await service.saveSessions([_makeSession(id: 'old')]);
      await service.saveConfig(ConfigModel(timerMode: TimerMode.stopwatch));

      final data = {
        'config':
            ConfigModel(timerMode: TimerMode.countdown, countdownDuration: 300)
                .toJson(),
        'sessions': [_makeSession(id: 'new', duration: 300).toJson()],
      };

      await service.importData(data, replaceAll: true);

      final config = await service.loadConfig();
      expect(config.timerMode, TimerMode.countdown);
      expect(config.countdownDuration, 300);

      final sessions = await service.loadSessions();
      expect(sessions.length, 1);
      expect(sessions.first.id, 'new');
    });

    test('resets custom bell paths to defaults', () async {
      final data = {
        'config': ConfigModel(
          bellStart: const AudioSource.custom('/path/to/bell.mp3'),
          bellEnd: const AudioSource.custom('/path/to/end.mp3'),
          bellInterval: const AudioSource.custom('/path/to/interval.mp3'),
        ).toJson(),
        'sessions': [],
      };

      await service.importData(data, replaceAll: true);

      final config = await service.loadConfig();
      expect(config.bellStart, ConfigModel.defaultBellStart);
      expect(config.bellEnd, ConfigModel.defaultBellEnd);
      expect(config.bellInterval, ConfigModel.defaultBellInterval);
    });

    test('preserves bundled bell paths unchanged', () async {
      final data = {
        'config': ConfigModel(
          bellStart: const AudioSource.bundled('temple_bells'),
          bellEnd: const AudioSource.bundled('wind_chime'),
          bellInterval: const AudioSource.bundled('singing_bell'),
        ).toJson(),
        'sessions': [],
      };

      await service.importData(data, replaceAll: true);

      final config = await service.loadConfig();
      expect(config.bellStart, const AudioSource.bundled('temple_bells'));
      expect(config.bellEnd, const AudioSource.bundled('wind_chime'));
      expect(config.bellInterval, const AudioSource.bundled('singing_bell'));
    });

    test('always clears backgroundMusic', () async {
      final data = {
        'config': ConfigModel(backgroundMusic: const AudioSource.custom('/music.mp3'))
            .toJson(),
        'sessions': [],
      };

      await service.importData(data, replaceAll: true);

      final config = await service.loadConfig();
      expect(config.backgroundMusic, isNull);
    });

    test('replaces user quotes when userQuotes key is present', () async {
      await service.saveUserQuotes([_makeQuote(id: 'old-q')]);

      final data = {
        'config': ConfigModel().toJson(),
        'sessions': [],
        'userQuotes': [_makeQuote(id: 'new-q').toJson()],
      };

      await service.importData(data, replaceAll: true);

      final quotes = await service.loadUserQuotes();
      expect(quotes.length, 1);
      expect(quotes.first.id, 'new-q');
    });

    test('leaves user quotes untouched when userQuotes key is absent',
        () async {
      await service.saveUserQuotes([_makeQuote(id: 'existing-q')]);

      final data = {
        'config': ConfigModel().toJson(),
        'sessions': [],
        // no 'userQuotes' key
      };

      await service.importData(data, replaceAll: true);

      final quotes = await service.loadUserQuotes();
      expect(quotes.length, 1);
      expect(quotes.first.id, 'existing-q');
    });
  });

  group('importData — merge', () {
    test('adds new sessions without removing existing ones', () async {
      await service.saveSessions([_makeSession(id: 'existing')]);

      final data = {
        'config': ConfigModel().toJson(),
        'sessions': [_makeSession(id: 'new').toJson()],
      };

      await service.importData(data, replaceAll: false);

      final sessions = await service.loadSessions();
      expect(sessions.length, 2);
      expect(sessions.map((s) => s.id).toSet(), {'existing', 'new'});
    });

    test('does not duplicate sessions with the same id', () async {
      await service.saveSessions([_makeSession(id: 'dup', duration: 300)]);

      final data = {
        'config': ConfigModel().toJson(),
        'sessions': [_makeSession(id: 'dup', duration: 900).toJson()],
      };

      await service.importData(data, replaceAll: false);

      final sessions = await service.loadSessions();
      expect(sessions.length, 1);
      expect(sessions.first.duration, 300); // original preserved
    });

    test('merges user quotes without duplicating by id', () async {
      await service.saveUserQuotes([_makeQuote(id: 'q1')]);

      final data = {
        'config': ConfigModel().toJson(),
        'sessions': [],
        'userQuotes': [
          _makeQuote(id: 'q1').toJson(), // duplicate
          _makeQuote(id: 'q2').toJson(), // new
        ],
      };

      await service.importData(data, replaceAll: false);

      final quotes = await service.loadUserQuotes();
      expect(quotes.length, 2);
      expect(quotes.map((q) => q.id).toSet(), {'q1', 'q2'});
    });
  });

  group('importData — rollback on partial write failure', () {
    test('rolls back config when the sessions write fails', () async {
      final originalConfig = ConfigModel(timerMode: TimerMode.stopwatch);
      await service.saveConfig(originalConfig);
      await service.saveSessions([_makeSession(id: 'original')]);

      // Force the sessions write to fail: a directory at the target path
      // makes the final rename-into-place step throw a FileSystemException,
      // simulating an I/O failure partway through the import.
      final sessionsPath = '${tempDir.path}/sessions.json';
      await File(sessionsPath).delete();
      await Directory(sessionsPath).create();

      final data = {
        'config': ConfigModel(timerMode: TimerMode.countdown).toJson(),
        'sessions': [_makeSession(id: 'imported').toJson()],
      };

      await expectLater(
        service.importData(data, replaceAll: true),
        throwsA(anything),
      );

      final config = await service.loadConfig();
      expect(config.timerMode, TimerMode.stopwatch,
          reason: 'config must be rolled back when a later write fails');
    });

    test('rolls back config and sessions when the quotes write fails',
        () async {
      final originalConfig = ConfigModel(timerMode: TimerMode.stopwatch);
      await service.saveConfig(originalConfig);
      await service.saveSessions([_makeSession(id: 'original')]);
      await service.saveUserQuotes([_makeQuote(id: 'original-q')]);

      final quotesPath = '${tempDir.path}/user_quotes.json';
      await File(quotesPath).delete();
      await Directory(quotesPath).create();

      final data = {
        'config': ConfigModel(timerMode: TimerMode.countdown).toJson(),
        'sessions': [_makeSession(id: 'imported').toJson()],
        'userQuotes': [_makeQuote(id: 'imported-q').toJson()],
      };

      await expectLater(
        service.importData(data, replaceAll: true),
        throwsA(anything),
      );

      final config = await service.loadConfig();
      final sessions = await service.loadSessions();
      expect(config.timerMode, TimerMode.stopwatch,
          reason: 'config must be rolled back when a later write fails');
      expect(sessions.map((s) => s.id).toList(), ['original'],
          reason: 'sessions must be rolled back when a later write fails');
    });

    test(
        'throws ImportRollbackIncompleteException when the rollback write itself fails',
        () async {
      await service.saveConfig(ConfigModel(timerMode: TimerMode.stopwatch));
      await service.saveSessions([_makeSession(id: 'original')]);

      // Force the forward sessions write to fail...
      final sessionsPath = '${tempDir.path}/sessions.json';
      await File(sessionsPath).delete();
      await Directory(sessionsPath).create();

      // ...and force the rollback's saveConfig call (the 2nd saveConfig call
      // on this instance) to also fail, so recovery is itself incomplete.
      final flaky = _FlakyConfigStorageService.withBasePath(tempDir.path);
      final data = {
        'config': ConfigModel(timerMode: TimerMode.countdown).toJson(),
        'sessions': [_makeSession(id: 'imported').toJson()],
      };

      await expectLater(
        flaky.importData(data, replaceAll: true),
        throwsA(isA<ImportRollbackIncompleteException>()),
      );
    });

    test(
        'rolls back a step whose write already committed before it threw',
        () async {
      await service.saveConfig(ConfigModel(timerMode: TimerMode.stopwatch));
      await service.saveSessions([_makeSession(id: 'original')]);

      final flaky =
          _FlakyPostCommitSessionsStorageService.withBasePath(tempDir.path);
      final data = {
        'config': ConfigModel(timerMode: TimerMode.countdown).toJson(),
        'sessions': [_makeSession(id: 'imported').toJson()],
      };

      await expectLater(
        flaky.importData(data, replaceAll: true),
        throwsA(isA<FileSystemException>()),
      );

      final config = await flaky.loadConfig();
      final sessions = await flaky.loadSessions();
      expect(config.timerMode, TimerMode.stopwatch,
          reason: 'config must be rolled back');
      expect(sessions.map((s) => s.id).toList(), ['original'],
          reason: 'the sessions write already committed the imported '
              'session to disk before throwing, so it must be rolled back '
              'too, not skipped because it "failed"');
    });
  });

  group('runExclusive', () {
    test('serializes concurrent calls in FIFO order', () async {
      final order = <int>[];
      final futures = [
        service.runExclusive(() async {
          // Queued first but slowest — must still finish before the ones
          // queued behind it are allowed to start, proving this is a real
          // queue and not just "whichever finishes first wins."
          await Future.delayed(const Duration(milliseconds: 20));
          order.add(1);
        }),
        service.runExclusive(() async {
          order.add(2);
        }),
        service.runExclusive(() async {
          order.add(3);
        }),
      ];

      await Future.wait(futures);

      expect(order, [1, 2, 3]);
    });

    test('a later call still runs after an earlier one that threw', () async {
      final order = <int>[];
      final first = service.runExclusive(() async {
        order.add(1);
        throw StateError('boom');
      });
      final second = service.runExclusive(() async {
        order.add(2);
      });

      await expectLater(first, throwsStateError);
      await second;

      expect(order, [1, 2],
          reason: 'a failure in one queued action must not block the next');
    });
  });

  group('importData — concurrency', () {
    test('queues a second import instead of rejecting it', () async {
      final data = {
        'config': ConfigModel().toJson(),
        'sessions': [_makeSession().toJson()],
      };

      final first = service.importData(data, replaceAll: true);
      final second = service.importData(data, replaceAll: true);

      await expectLater(Future.wait([first, second]), completes);
    });

    test(
        'a normal write queued via runExclusive during an import runs only after it, and its value wins',
        () async {
      // Uses countdownDuration (rather than timerMode) as the distinguishable
      // sentinel here — timerMode is now a two-value enum and can't encode
      // three distinguishable states.
      await service.saveConfig(ConfigModel(countdownDuration: 111));

      final data = {
        'config': ConfigModel(countdownDuration: 222).toJson(),
        'sessions': [_makeSession(id: 'imported').toJson()],
      };

      final importFuture = service.importData(data, replaceAll: true);
      // Submitted synchronously right after the import claims the lock, so
      // by runExclusive's FIFO guarantee this can only run once the import
      // (snapshot, write, and any rollback) has fully finished.
      final concurrentWrite = service.runExclusive(
        () => service.saveConfig(ConfigModel(countdownDuration: 333)),
      );

      await importFuture;
      await concurrentWrite;

      final config = await service.loadConfig();
      expect(config.countdownDuration, 333,
          reason: 'a write queued behind an import must win, not be '
              'dropped or overwritten by the import');
    });
  });

  group('importValidated', () {
    test('returns false for malformed content without touching storage',
        () async {
      await service.saveConfig(ConfigModel(timerMode: TimerMode.stopwatch));

      final ok = await service.importValidated('not json');

      expect(ok, isFalse);
      expect((await service.loadConfig()).timerMode, TimerMode.stopwatch);
    });

    test('parses the payload once and applies it for a valid replaceAll payload',
        () async {
      final content = jsonEncode({
        'version': 1,
        'config': ConfigModel(timerMode: TimerMode.countdown).toJson(),
        'sessions': [_makeSession(id: 'imported').toJson()],
        'userQuotes': [_makeQuote(id: 'imported-q').toJson()],
      });

      final ok = await service.importValidated(content, replaceAll: true);

      expect(ok, isTrue);
      expect((await service.loadConfig()).timerMode, TimerMode.countdown);
      expect((await service.loadSessions()).map((s) => s.id).toList(),
          ['imported']);
      expect((await service.loadUserQuotes()).map((q) => q.id).toList(),
          ['imported-q']);
    });

    test('returns false without throwing when the underlying write fails',
        () async {
      await service.saveConfig(ConfigModel(timerMode: TimerMode.stopwatch));

      final sessionsPath = '${tempDir.path}/sessions.json';
      await Directory(sessionsPath).create();

      final content = jsonEncode({
        'version': 1,
        'config': ConfigModel(timerMode: TimerMode.countdown).toJson(),
        'sessions': [_makeSession(id: 'imported').toJson()],
      });

      final ok = await service.importValidated(content, replaceAll: true);

      expect(ok, isFalse);
      expect((await service.loadConfig()).timerMode, TimerMode.stopwatch,
          reason: 'a failed importValidated must roll back like importData');
    });

    test('propagates StorageLockedException instead of reporting a plain '
        'false when the store is locked (encrypted sessions.json, no '
        'master key)', () async {
      final setupService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());
      await setupService.enableEncryption(password: 'correct horse battery staple');
      await setupService.saveSessions([_makeSession(notes: 'peaceful sit')]);

      final lockedService =
          StorageService.withBasePath(tempDir.path, cryptoService: _testCryptoService());

      final content = jsonEncode({
        'version': 1,
        'config': ConfigModel().toJson(),
        'sessions': [_makeSession(id: 'imported').toJson()],
      });

      await expectLater(
        lockedService.importValidated(content),
        throwsA(isA<StorageLockedException>()),
      );
    });
  });

  group('exportAllData', () {
    test('export contains required top-level keys', () async {
      final json = jsonDecode(await service.exportAllData())
          as Map<String, dynamic>;
      expect(json.containsKey('version'), true);
      expect(json.containsKey('exportDate'), true);
      expect(json.containsKey('config'), true);
      expect(json.containsKey('sessions'), true);
      expect(json.containsKey('userQuotes'), true);
    });

    test('export version is 1', () async {
      final json = jsonDecode(await service.exportAllData())
          as Map<String, dynamic>;
      expect(json['version'], 1);
    });

    test('exported data survives import roundtrip', () async {
      await service.saveSessions([
        _makeSession(id: 's1', duration: 300),
        _makeSession(id: 's2', duration: 900),
      ]);
      await service.saveUserQuotes([_makeQuote(id: 'q1')]);
      await service.saveConfig(ConfigModel(timerMode: TimerMode.stopwatch));

      final exportJson = await service.exportAllData();
      final parsed = await service.validateImportData(exportJson);
      expect(parsed, isNotNull);

      // Import into a fresh service instance (new temp dir)
      final importDir =
          await Directory.systemTemp.createTemp('citta_import_test_');
      try {
        final importService = StorageService.withBasePath(importDir.path);
        await importService.importData(parsed!, replaceAll: true);

        final sessions = await importService.loadSessions();
        expect(sessions.length, 2);
        expect(sessions.map((s) => s.id).toSet(), {'s1', 's2'});

        final quotes = await importService.loadUserQuotes();
        expect(quotes.length, 1);
        expect(quotes.first.id, 'q1');

        final config = await importService.loadConfig();
        expect(config.timerMode, TimerMode.stopwatch);
      } finally {
        await importDir.delete(recursive: true);
      }
    });
  });

  // -------------------------------------------------------------------------
  // ConfigModel
  // -------------------------------------------------------------------------

  group('ConfigModel defaults', () {
    test('all static defaults match constructor defaults', () {
      final config = ConfigModel();
      expect(config.timerMode, ConfigModel.defaultTimerMode);
      expect(config.countdownDuration, ConfigModel.defaultCountdownDuration);
      expect(config.bellStart, ConfigModel.defaultBellStart);
      expect(config.bellEnd, ConfigModel.defaultBellEnd);
      expect(config.bellInterval, ConfigModel.defaultBellInterval);
      expect(config.intervalDuration, ConfigModel.defaultIntervalDuration);
      expect(config.intervalEnabled, ConfigModel.defaultIntervalEnabled);
      expect(config.calendarViewEnabled, ConfigModel.defaultCalendarViewEnabled);
      expect(config.themeMode, ConfigModel.defaultThemeMode);
      expect(config.tags, ConfigModel.defaultTags);
      expect(config.quoteSources, ConfigModel.defaultQuoteSources);
      expect(config.backgroundMusic, isNull);
      expect(config.userName, isNull);
    });

    test('fromJson falls back to defaults for missing keys', () {
      final config = ConfigModel.fromJson({});
      expect(config.timerMode, ConfigModel.defaultTimerMode);
      expect(config.countdownDuration, ConfigModel.defaultCountdownDuration);
      expect(config.tags, ConfigModel.defaultTags);
      expect(config.quoteSources, ConfigModel.defaultQuoteSources);
    });

    test('two default ConfigModel instances have independent tags lists', () {
      final a = ConfigModel();
      final b = ConfigModel();
      // Both are unmodifiable wrappers — mutation is impossible, so
      // cross-instance contamination is structurally prevented.
      expect(() => a.tags.add('extra'), throwsUnsupportedError);
      expect(b.tags, ConfigModel.defaultTags,
          reason: 'b.tags must be unaffected by any attempted mutation of a.tags');
    });
  });

  group('ConfigModel fromJson / toJson', () {
    test('roundtrip preserves all fields', () {
      final original = ConfigModel(
        timerMode: TimerMode.stopwatch,
        countdownDuration: 1800,
        bellStart: const AudioSource.bundled('temple_bells'),
        bellEnd: const AudioSource.bundled('wind_chime'),
        bellInterval: const AudioSource.bundled('singing_bell'),
        intervalDuration: 600,
        intervalEnabled: true,
        calendarViewEnabled: true,
        userName: 'Test User',
        themeMode: AppThemeMode.light,
        tags: ['focused', 'restless'],
        quoteSources: ['yoga_sutra'],
      );
      final restored = ConfigModel.fromJson(original.toJson());
      expect(restored.timerMode, original.timerMode);
      expect(restored.countdownDuration, original.countdownDuration);
      expect(restored.bellStart, original.bellStart);
      expect(restored.bellEnd, original.bellEnd);
      expect(restored.bellInterval, original.bellInterval);
      expect(restored.intervalDuration, original.intervalDuration);
      expect(restored.intervalEnabled, original.intervalEnabled);
      expect(restored.calendarViewEnabled, original.calendarViewEnabled);
      expect(restored.userName, original.userName);
      expect(restored.themeMode, original.themeMode);
      expect(restored.tags, original.tags);
      expect(restored.quoteSources, original.quoteSources);
    });
  });

  group('ConfigModel copyWith', () {
    test('returns new instance with updated fields', () {
      final original = ConfigModel();
      final updated = original.copyWith(
          timerMode: TimerMode.stopwatch, themeMode: AppThemeMode.light);
      expect(updated.timerMode, TimerMode.stopwatch);
      expect(updated.themeMode, AppThemeMode.light);
      expect(updated.countdownDuration, original.countdownDuration);
    });

    test('tags list is unmodifiable', () {
      final config = ConfigModel(tags: ['calm']);
      expect(
        () => config.tags.add('focused'),
        throwsUnsupportedError,
        reason: 'tags must be unmodifiable so mutations always go through copyWith',
      );
    });
  });

  // -------------------------------------------------------------------------
  // SessionModel
  // -------------------------------------------------------------------------

  group('SessionModel fromJson / toJson', () {
    test('roundtrip preserves all fields', () {
      final now = DateTime.utc(2024, 6, 15, 7, 30);
      final original = SessionModel(
        id: 'abc-123',
        date: now,
        duration: 900,
        timerMode: TimerMode.countdown,
        notes: 'deep focus',
        tags: ['calm', 'deep'],
        completedFully: false,
      );
      final restored = SessionModel.fromJson(original.toJson());
      expect(restored.id, 'abc-123');
      expect(restored.date.toUtc(), now);
      expect(restored.duration, 900);
      expect(restored.timerMode, TimerMode.countdown);
      expect(restored.notes, 'deep focus');
      expect(restored.tags, ['calm', 'deep']);
      expect(restored.completedFully, false);
    });

    test('completedFully defaults to true when missing from JSON', () {
      final json = {
        'id': 'x',
        'date': DateTime.utc(2024).toIso8601String(),
        'duration': 300,
        'timerMode': 'stopwatch',
        'tags': [],
      };
      expect(SessionModel.fromJson(json).completedFully, true);
    });

    test('date is stored in UTC', () {
      final session = _makeSession();
      final restored = SessionModel.fromJson(session.toJson());
      expect(restored.date.isUtc, true);
    });
  });

  // -------------------------------------------------------------------------
  // QuoteModel
  // -------------------------------------------------------------------------

  group('QuoteModel fromJson / toJson', () {
    test('roundtrip preserves all fields', () {
      final original = _makeQuote();
      final restored = QuoteModel.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.source, original.source);
      expect(restored.reference, original.reference);
      expect(restored.originalText, original.originalText);
      expect(restored.originalLanguage, original.originalLanguage);
      expect(restored.translation, original.translation);
      expect(restored.userAdded, original.userAdded);
    });

    test('originalLanguage defaults to sanskrit when missing from JSON', () {
      final json = {
        'id': 'q1',
        'source': 'yoga_sutra',
        'originalText': 'text',
        'translation': 'trans',
        'userAdded': false,
      };
      expect(QuoteModel.fromJson(json).originalLanguage, 'sanskrit');
    });

    test('reference defaults to empty string when missing from JSON', () {
      final json = {
        'id': 'q1',
        'source': 'yoga_sutra',
        'originalText': 'text',
        'translation': 'trans',
        'userAdded': false,
      };
      expect(QuoteModel.fromJson(json).reference, '');
    });
  });

  // -------------------------------------------------------------------------
  // In-Progress Session
  // -------------------------------------------------------------------------

  group('saveInProgressSession / loadInProgressSession roundtrip', () {
    test('persists and restores all fields', () async {
      final startDate = DateTime.utc(2024, 6, 15, 8, 0);
      await service.saveInProgressSession(
        id: 'session-ip-1',
        startDate: startDate,
        elapsedSeconds: 300,
        timerMode: 'countdown',
        targetDuration: 1200,
      );

      final data = await service.loadInProgressSession();

      expect(data, isNotNull);
      expect(data!['id'], 'session-ip-1');
      expect(DateTime.parse(data['startDate'] as String).toUtc(), startDate);
      expect(data['elapsedSeconds'], 300);
      expect(data['timerMode'], 'countdown');
      expect(data['targetDuration'], 1200);
    });

    test('overwrites previous marker on repeated saves', () async {
      await service.saveInProgressSession(
        id: 'first',
        startDate: DateTime.utc(2024),
        elapsedSeconds: 100,
        timerMode: 'countdown',
        targetDuration: 600,
      );
      await service.saveInProgressSession(
        id: 'second',
        startDate: DateTime.utc(2024),
        elapsedSeconds: 200,
        timerMode: 'stopwatch',
        targetDuration: 0,
      );

      final data = await service.loadInProgressSession();
      expect(data!['id'], 'second');
      expect(data['elapsedSeconds'], 200);
      expect(data['timerMode'], 'stopwatch');
    });
  });

  group('loadInProgressSession', () {
    test('returns null when file does not exist', () async {
      expect(await service.loadInProgressSession(), isNull);
    });

    test('returns null and saves .bak_corrupt on corrupt JSON', () async {
      final path = '${tempDir.path}/in_progress_session.json';
      await File(path).writeAsString('not valid json!!!');

      final data = await service.loadInProgressSession();

      expect(data, isNull);
      expect(await File('$path.bak_corrupt').exists(), true);
    });
  });

  group('clearInProgressSession', () {
    test('deletes the in-progress file', () async {
      await service.saveInProgressSession(
        id: 'x',
        startDate: DateTime.utc(2024),
        elapsedSeconds: 60,
        timerMode: 'countdown',
        targetDuration: 600,
      );

      await service.clearInProgressSession();

      expect(await service.loadInProgressSession(), isNull);
    });

    test('is idempotent when file does not exist', () async {
      await expectLater(service.clearInProgressSession(), completes);
    });
  });

  // -------------------------------------------------------------------------
  // disableEncryption
  // -------------------------------------------------------------------------

  group('disableEncryption', () {
    test('throws StateError when encryption is not enabled', () async {
      await expectLater(
        service.disableEncryption(),
        throwsA(isA<StateError>()),
      );
    });

    test('throws StorageLockedException when this instance is locked',
        () async {
      final setupService = StorageService.withBasePath(tempDir.path,
          cryptoService: _testCryptoService());
      await setupService.enableEncryption(
          password: 'correct horse battery staple');

      final freshService = StorageService.withBasePath(tempDir.path,
          cryptoService: _testCryptoService());

      await expectLater(
        freshService.disableEncryption(),
        throwsA(isA<StorageLockedException>()),
      );
      expect(await freshService.isEncryptionEnabled, true);
    });

    test(
        'decrypts sessions.json back to plaintext, deletes metadata, and '
        'clears the master key', () async {
      final cache = InMemoryKeyCache();
      final encService = StorageService.withBasePath(tempDir.path,
          cryptoService: _testCryptoService(), secureKeyCache: cache);
      await encService.enableEncryption(
          password: 'correct horse battery staple');
      final sessions = [
        _makeSession(id: 's1', notes: 'peaceful sit', tags: ['calm']),
        _makeSession(id: 's2', duration: 900),
      ];
      await encService.saveSessions(sessions);

      await encService.disableEncryption();

      final path = '${tempDir.path}/sessions.json';
      final raw = await File(path).readAsString();
      expect(raw, contains('peaceful sit'));
      expect(jsonDecode(raw), isNot(containsPair('encrypted', true)));

      expect(await File('${tempDir.path}/encryption_meta.json').exists(),
          false);
      expect(await encService.isEncryptionEnabled, false);
      expect(encService.isUnlocked, false);
      expect(await cache.read(), isNull);

      final restored = await encService.loadSessions();
      expect(restored.map((s) => s.id).toList(), ['s1', 's2']);
      expect(restored.first.notes, 'peaceful sit');
      expect(restored.first.tags, ['calm']);
    });

    test('a fresh instance reads the decrypted sessions without unlocking',
        () async {
      final encService = StorageService.withBasePath(tempDir.path,
          cryptoService: _testCryptoService());
      await encService.enableEncryption(
          password: 'correct horse battery staple');
      await encService.saveSessions([_makeSession(notes: 'peaceful sit')]);

      await encService.disableEncryption();

      final freshService = StorageService.withBasePath(tempDir.path,
          cryptoService: _testCryptoService());
      expect(await freshService.isEncryptionEnabled, false);
      final restored = await freshService.loadSessions();
      expect(restored.single.notes, 'peaceful sit');
    });

    test(
        'still disables encryption even if clearing the cached master key '
        'fails', () async {
      final encService = StorageService.withBasePath(tempDir.path,
          cryptoService: _testCryptoService(),
          secureKeyCache: _ThrowingClearKeyCache());
      await encService.enableEncryption(
          password: 'correct horse battery staple');
      await encService.saveSessions([_makeSession(notes: 'peaceful sit')]);

      // The device is already fully decrypted on disk by this point, so a
      // keystore failure clearing the now-orphaned cached key must not be
      // reported as disableEncryption() having failed.
      await expectLater(encService.disableEncryption(), completes);

      expect(await encService.isEncryptionEnabled, false);
      final restored = await encService.loadSessions();
      expect(restored.single.notes, 'peaceful sit');
    });

    test(
        'interrupted between the plaintext write and metadata delete leaves '
        'sessions intact and still unlockable with the original password',
        () async {
      const password = 'correct horse battery staple';
      final flakyService = _FlakyDeleteMetadataStorageService.withBasePath(
          tempDir.path,
          cryptoService: _testCryptoService());
      await flakyService.enableEncryption(password: password);
      final sessions = [_makeSession(notes: 'peaceful sit')];
      await flakyService.saveSessions(sessions);

      await expectLater(
        flakyService.disableEncryption(),
        throwsA(isA<FileSystemException>()),
      );

      // The plaintext write committed before the simulated crash.
      final path = '${tempDir.path}/sessions.json';
      final raw = await File(path).readAsString();
      expect(raw, contains('peaceful sit'));
      expect(jsonDecode(raw), isNot(containsPair('encrypted', true)));

      // Metadata was never removed, so a fresh instance still reports
      // encryption enabled and the original password still unlocks it —
      // nothing was lost, even though the toggle didn't fully complete.
      final freshService = StorageService.withBasePath(tempDir.path,
          cryptoService: _testCryptoService());
      expect(await freshService.isEncryptionEnabled, true);
      expect(await freshService.unlockWithPassword(password), true);
      final restored = await freshService.loadSessions();
      expect(restored.single.notes, 'peaceful sit');

      // Retrying disableEncryption() on this now-unlocked instance completes
      // cleanly the second time.
      await freshService.disableEncryption();
      expect(await freshService.isEncryptionEnabled, false);
    });
  });

  // -------------------------------------------------------------------------
  // enableEncryption interrupted
  // -------------------------------------------------------------------------

  group('enableEncryption interrupted', () {
    test(
        'crash before the re-encrypt write leaves the original plaintext '
        'sessions.json untouched and still readable after unlocking',
        () async {
      const password = 'correct horse battery staple';
      final path = '${tempDir.path}/sessions.json';
      final plainService = StorageService.withBasePath(tempDir.path,
          cryptoService: _testCryptoService());
      await plainService.saveSessions([_makeSession(notes: 'peaceful sit')]);
      final beforeAttempt = await File(path).readAsString();

      final flakyService = _FlakyEnableSessionsStorageService.withBasePath(
          tempDir.path,
          cryptoService: _testCryptoService());

      await expectLater(
        flakyService.enableEncryption(password: password),
        throwsA(isA<FileSystemException>()),
      );

      // Metadata committed (it's written before the flaky saveSessions
      // call), but sessions.json is untouched by the interrupted write.
      expect(await File(path).readAsString(), beforeAttempt);

      final freshService = StorageService.withBasePath(tempDir.path,
          cryptoService: _testCryptoService());
      expect(await freshService.isEncryptionEnabled, true);
      expect(await freshService.unlockWithPassword(password), true);
      final restored = await freshService.loadSessions();
      expect(restored.single.notes, 'peaceful sit');
    });
  });
}
