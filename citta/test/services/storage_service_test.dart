import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/config_model.dart';
import 'package:citta/models/quote_model.dart';
import 'package:citta/models/session_model.dart';
import 'package:citta/services/storage_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SessionModel _makeSession({
  String id = 'session-1',
  int duration = 600,
  String timerMode = 'countdown',
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
        timerMode: 'stopwatch',
        countdownDuration: 1200,
        bellStart: 'bundled:temple_bells',
        bellEnd: 'bundled:wind_chime',
        bellInterval: 'bundled:singing_bell',
        intervalDuration: 600,
        intervalEnabled: true,
        calendarViewEnabled: true,
        userName: 'Harsha',
        themeMode: 'light',
        tags: ['calm', 'focused'],
        quoteSources: ['yoga_sutra', 'upanishad'],
      );

      await service.saveConfig(original);
      final restored = await service.loadConfig();

      expect(restored.timerMode, 'stopwatch');
      expect(restored.countdownDuration, 1200);
      expect(restored.bellStart, 'bundled:temple_bells');
      expect(restored.bellEnd, 'bundled:wind_chime');
      expect(restored.bellInterval, 'bundled:singing_bell');
      expect(restored.intervalDuration, 600);
      expect(restored.intervalEnabled, true);
      expect(restored.calendarViewEnabled, true);
      expect(restored.userName, 'Harsha');
      expect(restored.themeMode, 'light');
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
        _makeSession(id: 's2', duration: 900, timerMode: 'stopwatch'),
        _makeSession(id: 's3', duration: 1800, completedFully: false),
      ];

      await service.saveSessions(sessions);
      final restored = await service.loadSessions();

      expect(restored.length, 3);
      expect(restored.map((s) => s.id).toList(), ['s1', 's2', 's3']);
      expect(restored[1].timerMode, 'stopwatch');
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

  group('addSession', () {
    test('appends session to empty store', () async {
      await service.addSession(_makeSession(id: 's1'));
      final sessions = await service.loadSessions();
      expect(sessions.length, 1);
      expect(sessions.first.id, 's1');
    });

    test('appends session to existing sessions', () async {
      await service.saveSessions([_makeSession(id: 's1')]);
      await service.addSession(_makeSession(id: 's2'));
      final sessions = await service.loadSessions();
      expect(sessions.length, 2);
      expect(sessions.last.id, 's2');
    });

    test('multiple addSession calls accumulate', () async {
      for (var i = 1; i <= 5; i++) {
        await service.addSession(_makeSession(id: 's$i'));
      }
      expect(await service.loadSessions(), hasLength(5));
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
        'config': ConfigModel().toJson(),
        'sessions': [],
      });
      final result = await service.validateImportData(content);
      expect(result, isNotNull);
      expect(result!.containsKey('config'), true);
    });

    test('returns null when config key is missing', () async {
      final result = await service.validateImportData(
          jsonEncode({'sessions': []}));
      expect(result, isNull);
    });

    test('returns null when sessions key is missing', () async {
      final result = await service.validateImportData(
          jsonEncode({'config': ConfigModel().toJson()}));
      expect(result, isNull);
    });

    test('returns null for invalid JSON', () async {
      expect(await service.validateImportData('not json'), isNull);
    });

    test('returns null for empty string', () async {
      expect(await service.validateImportData(''), isNull);
    });
  });

  group('importData — replaceAll', () {
    test('replaces config and sessions', () async {
      await service.saveSessions([_makeSession(id: 'old')]);
      await service.saveConfig(ConfigModel(timerMode: 'stopwatch'));

      final data = {
        'config': ConfigModel(timerMode: 'countdown', countdownDuration: 300)
            .toJson(),
        'sessions': [_makeSession(id: 'new', duration: 300).toJson()],
      };

      await service.importData(data, replaceAll: true);

      final config = await service.loadConfig();
      expect(config.timerMode, 'countdown');
      expect(config.countdownDuration, 300);

      final sessions = await service.loadSessions();
      expect(sessions.length, 1);
      expect(sessions.first.id, 'new');
    });

    test('resets custom bell paths to defaults', () async {
      final data = {
        'config': ConfigModel(
          bellStart: 'custom:/path/to/bell.mp3',
          bellEnd: 'custom:/path/to/end.mp3',
          bellInterval: 'custom:/path/to/interval.mp3',
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
          bellStart: 'bundled:temple_bells',
          bellEnd: 'bundled:wind_chime',
          bellInterval: 'bundled:singing_bell',
        ).toJson(),
        'sessions': [],
      };

      await service.importData(data, replaceAll: true);

      final config = await service.loadConfig();
      expect(config.bellStart, 'bundled:temple_bells');
      expect(config.bellEnd, 'bundled:wind_chime');
      expect(config.bellInterval, 'bundled:singing_bell');
    });

    test('always clears backgroundMusic', () async {
      final data = {
        'config': ConfigModel(backgroundMusic: 'custom:/music.mp3').toJson(),
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
      await service.saveConfig(ConfigModel(timerMode: 'stopwatch'));

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
        expect(config.timerMode, 'stopwatch');
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

    test('tags list is a mutable copy, not shared reference', () {
      final a = ConfigModel();
      final b = ConfigModel();
      a.tags.add('extra');
      expect(b.tags, isNot(contains('extra')));
    });
  });

  group('ConfigModel fromJson / toJson', () {
    test('roundtrip preserves all fields', () {
      final original = ConfigModel(
        timerMode: 'stopwatch',
        countdownDuration: 1800,
        bellStart: 'bundled:temple_bells',
        bellEnd: 'bundled:wind_chime',
        bellInterval: 'bundled:singing_bell',
        intervalDuration: 600,
        intervalEnabled: true,
        calendarViewEnabled: true,
        userName: 'Test User',
        themeMode: 'light',
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
      final updated = original.copyWith(timerMode: 'stopwatch', themeMode: 'light');
      expect(updated.timerMode, 'stopwatch');
      expect(updated.themeMode, 'light');
      expect(updated.countdownDuration, original.countdownDuration);
    });

    test('tags copy is independent of original', () {
      final original = ConfigModel(tags: ['calm']);
      final copy = original.copyWith();
      copy.tags.add('focused');
      expect(original.tags, ['calm']);
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
        timerMode: 'countdown',
        notes: 'deep focus',
        tags: ['calm', 'deep'],
        completedFully: false,
      );
      final restored = SessionModel.fromJson(original.toJson());
      expect(restored.id, 'abc-123');
      expect(restored.date.toUtc(), now);
      expect(restored.duration, 900);
      expect(restored.timerMode, 'countdown');
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
}
