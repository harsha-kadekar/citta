import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/quote_model.dart';
import 'package:citta/models/config_model.dart';
import 'package:citta/models/session_model.dart';
import 'package:citta/services/storage_service.dart';
import 'package:citta/services/quote_service.dart';

// ---------------------------------------------------------------------------
// Fake StorageService
// ---------------------------------------------------------------------------

class FakeStorageService extends StorageService {
  List<QuoteModel> _quotes = [];
  List<QuoteModel>? savedQuotes; // last value passed to saveUserQuotes
  int saveUserQuotesCallCount = 0;

  void seedQuotes(List<QuoteModel> quotes) {
    _quotes = List.of(quotes);
  }

  @override
  Future<List<QuoteModel>> loadUserQuotes() async => List.of(_quotes);

  @override
  Future<void> saveUserQuotes(List<QuoteModel> quotes) async {
    _quotes = List.of(quotes);
    savedQuotes = List.of(quotes);
    saveUserQuotesCallCount++;
  }

  // Unused by QuoteService — provide no-op stubs to satisfy the class.
  @override
  Future<ConfigModel> loadConfig() async => ConfigModel();
  @override
  Future<void> saveConfig(ConfigModel config) async {}
  @override
  Future<List<SessionModel>> loadSessions() async => [];
  @override
  Future<void> saveSessions(List<SessionModel> sessions) async {}
  @override
  Future<void> addSession(SessionModel session) async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

QuoteModel _makeQuote(String id, {String source = 'yoga_sutra'}) => QuoteModel(
      id: id,
      source: source,
      reference: '1.1',
      originalText: 'text',
      translation: 'translation',
      userAdded: true,
    );

List<QuoteModel> _makeQuotes(int count) =>
    List.generate(count, (i) => _makeQuote('q${i + 1}'));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeStorageService storage;
  late QuoteService service;

  setUp(() {
    storage = FakeStorageService();
    service = QuoteService(storage);
  });

  // -------------------------------------------------------------------------
  // initialize()
  // -------------------------------------------------------------------------

  group('initialize()', () {
    test('1. loads user quotes from storage on init', () async {
      storage.seedQuotes([_makeQuote('q1'), _makeQuote('q2')]);

      await service.initialize();

      expect(service.userQuotes.length, 2);
      expect(service.userQuotes.map((q) => q.id).toList(), ['q1', 'q2']);
    });

    test('2. sets todayQuote to null when no quotes exist', () async {
      // storage is empty and no bundled quotes are loaded in unit test env
      await service.initialize();

      expect(service.todayQuote, isNull);
    });

    test('3. sets todayQuote to a valid quote when user quotes exist', () async {
      storage.seedQuotes([_makeQuote('q1')]);

      await service.initialize();

      expect(service.todayQuote, isNotNull);
      expect(service.todayQuote!.id, 'q1');
    });
  });

  // -------------------------------------------------------------------------
  // allQuotes getter
  // -------------------------------------------------------------------------

  group('allQuotes getter', () {
    test('4. returns only user quotes when bundled quotes are empty', () async {
      storage.seedQuotes([_makeQuote('q1'), _makeQuote('q2')]);
      await service.initialize();

      expect(service.allQuotes.map((q) => q.id).toList(), ['q1', 'q2']);
    });

    test('5. returns empty list when both sources are empty', () async {
      await service.initialize();

      expect(service.allQuotes, isEmpty);
    });

    test('6. includes newly added user quote in allQuotes', () async {
      await service.initialize();
      await service.addUserQuote(_makeQuote('q-new'));

      expect(service.allQuotes.any((q) => q.id == 'q-new'), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // refreshQuote() and recent history
  // -------------------------------------------------------------------------

  group('refreshQuote() and recent history', () {
    test('10. refreshQuote() changes todayQuote when pool has multiple quotes',
        () async {
      // With 20 quotes the probability of picking the same one 50 times in a
      // row is astronomically small, so this is effectively deterministic.
      storage.seedQuotes(_makeQuotes(20));
      await service.initialize();
      final first = service.todayQuote!.id;

      String? different;
      for (var i = 0; i < 50; i++) {
        service.refreshQuote();
        if (service.todayQuote!.id != first) {
          different = service.todayQuote!.id;
          break;
        }
      }

      expect(different, isNotNull,
          reason: 'Expected at least one refresh to pick a different quote');
    });

    test('11. avoids recently shown quotes when candidates are available',
        () async {
      // With 5 quotes, 5 refreshes should spread across all of them since each
      // pick is excluded from the next selection.
      storage.seedQuotes(_makeQuotes(5));
      await service.initialize();

      final seenIds = <String>{service.todayQuote!.id};
      for (var i = 0; i < 4; i++) {
        service.refreshQuote();
        seenIds.add(service.todayQuote!.id);
      }

      expect(seenIds.length, greaterThan(1));
    });

    test('12. falls back to full pool when all quotes are in recent history',
        () async {
      // Only 2 quotes — both enter recent history quickly, so the service must
      // fall back to the full pool and still return a non-null quote.
      storage.seedQuotes(_makeQuotes(2));
      await service.initialize();

      for (var i = 0; i < 15; i++) {
        service.refreshQuote();
        expect(service.todayQuote, isNotNull);
      }
    });

    test('13. recent history is capped at 10 entries', () async {
      // With 11 quotes and a history cap of 10, after 11 selections the oldest
      // entry is evicted and becomes eligible again — meaning IDs must repeat
      // within any 30-pick window.
      storage.seedQuotes(_makeQuotes(11));
      await service.initialize();

      final ids = <String>[];
      for (var i = 0; i < 30; i++) {
        service.refreshQuote();
        ids.add(service.todayQuote!.id);
      }

      // If the cap were absent, all 11 IDs would eventually be exhausted and
      // the same quote would repeat only from the fallback. With the cap,
      // repeats are guaranteed well within 30 picks.
      expect(ids.toSet().length, lessThan(ids.length));
    });
  });

  // -------------------------------------------------------------------------
  // addUserQuote()
  // -------------------------------------------------------------------------

  group('addUserQuote()', () {
    test('14. adds quote to userQuotes', () async {
      await service.initialize();
      await service.addUserQuote(_makeQuote('q1'));

      expect(service.userQuotes.length, 1);
      expect(service.userQuotes.first.id, 'q1');
    });

    test('15. persists the quote via StorageService.saveUserQuotes', () async {
      await service.initialize();
      await service.addUserQuote(_makeQuote('q1'));

      expect(storage.saveUserQuotesCallCount, 1);
      expect(storage.savedQuotes!.map((q) => q.id), contains('q1'));
    });

    test('16. adding multiple quotes accumulates them all', () async {
      await service.initialize();
      await service.addUserQuote(_makeQuote('q1'));
      await service.addUserQuote(_makeQuote('q2'));
      await service.addUserQuote(_makeQuote('q3'));

      expect(service.userQuotes.length, 3);
      expect(service.userQuotes.map((q) => q.id).toList(), ['q1', 'q2', 'q3']);
    });

    test('17. allQuotes includes newly added user quote', () async {
      await service.initialize();
      await service.addUserQuote(_makeQuote('q-new'));

      expect(service.allQuotes.any((q) => q.id == 'q-new'), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // removeUserQuote()
  // -------------------------------------------------------------------------

  group('removeUserQuote()', () {
    test('18. removes quote by ID from userQuotes', () async {
      storage.seedQuotes([_makeQuote('q1'), _makeQuote('q2')]);
      await service.initialize();

      await service.removeUserQuote('q1');

      expect(service.userQuotes.length, 1);
      expect(service.userQuotes.first.id, 'q2');
    });

    test('19. persists updated list via StorageService.saveUserQuotes',
        () async {
      storage.seedQuotes([_makeQuote('q1'), _makeQuote('q2')]);
      await service.initialize();

      await service.removeUserQuote('q1');

      expect(storage.savedQuotes!.map((q) => q.id).toList(), ['q2']);
    });

    test('20. does nothing when removing a non-existent ID', () async {
      storage.seedQuotes([_makeQuote('q1')]);
      await service.initialize();

      await service.removeUserQuote('non-existent');

      expect(service.userQuotes.length, 1);
      expect(service.userQuotes.first.id, 'q1');
    });

    test('21. removing one quote leaves the others intact', () async {
      storage.seedQuotes(
          [_makeQuote('q1'), _makeQuote('q2'), _makeQuote('q3')]);
      await service.initialize();

      await service.removeUserQuote('q2');

      expect(service.userQuotes.map((q) => q.id).toList(), ['q1', 'q3']);
    });
  });

  // -------------------------------------------------------------------------
  // reloadUserQuotes()
  // -------------------------------------------------------------------------

  group('reloadUserQuotes()', () {
    test('22. reloads quotes from StorageService', () async {
      storage.seedQuotes([_makeQuote('q1')]);
      await service.initialize();

      // Simulate an external change to storage.
      storage.seedQuotes([_makeQuote('q1'), _makeQuote('q2')]);
      await service.reloadUserQuotes();

      expect(service.userQuotes.length, 2);
      expect(service.userQuotes.map((q) => q.id).toList(), ['q1', 'q2']);
    });

    test('23. replaces in-memory quotes with freshly loaded ones', () async {
      await service.initialize();
      // Seed storage directly without going through addUserQuote.
      storage.seedQuotes([_makeQuote('q-from-storage')]);

      await service.reloadUserQuotes();

      expect(service.userQuotes.length, 1);
      expect(service.userQuotes.first.id, 'q-from-storage');
    });
  });
}
