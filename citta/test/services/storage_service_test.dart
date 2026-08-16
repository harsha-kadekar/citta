import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:citta/models/config_model.dart';
import 'package:citta/models/quote_model.dart';
import 'package:citta/models/session_model.dart';
import 'package:citta/models/timer_mode.dart';
import 'package:citta/models/app_theme_mode.dart';
import 'package:citta/models/audio_source.dart';
import 'package:citta/services/crypto_service.dart';
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
}
