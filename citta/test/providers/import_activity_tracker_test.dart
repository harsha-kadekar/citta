import 'package:flutter_test/flutter_test.dart';
import 'package:citta/providers/import_activity_tracker.dart';

void main() {
  group('ImportActivityTracker', () {
    test('isActive is false before any import begins', () {
      final tracker = ImportActivityTracker();
      expect(tracker.isActive, isFalse);
    });

    test('isActive becomes true after begin()', () {
      final tracker = ImportActivityTracker();
      tracker.begin();
      expect(tracker.isActive, isTrue);
    });

    test('isActive becomes false again after a matching end()', () {
      final tracker = ImportActivityTracker();
      tracker.begin();
      tracker.end();
      expect(tracker.isActive, isFalse);
    });

    test('overlapping imports keep isActive true until every begin() has a matching end()',
        () {
      final tracker = ImportActivityTracker();
      tracker.begin();
      tracker.begin();
      expect(tracker.isActive, isTrue,
          reason: 'a second overlapping import must not be reported as '
              'inactive just because it is not the first one');

      tracker.end();
      expect(tracker.isActive, isTrue,
          reason: 'one of two overlapping imports finishing must not '
              'report "no import in flight" while the other is still '
              'queued or running');

      tracker.end();
      expect(tracker.isActive, isFalse);
    });
  });
}
