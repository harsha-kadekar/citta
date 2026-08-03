import 'package:flutter_test/flutter_test.dart';
import 'package:citta/models/quote_model.dart';

QuoteModel _quote({
  String id = 'q1',
  String source = 'subhashita',
  String reference = 'ref-1',
  String originalText = 'original',
  String originalLanguage = 'sanskrit',
  String translation = 'translation',
  bool userAdded = false,
}) =>
    QuoteModel(
      id: id,
      source: source,
      reference: reference,
      originalText: originalText,
      originalLanguage: originalLanguage,
      translation: translation,
      userAdded: userAdded,
    );

void main() {
  group('QuoteModel value equality', () {
    test('two quotes with identical fields are ==', () {
      final a = _quote();
      final b = _quote();
      expect(identical(a, b), isFalse);
      expect(a == b, isTrue);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('quotes differing only in id are not ==', () {
      expect(_quote(id: 'a') == _quote(id: 'b'), isFalse);
    });

    test('quotes differing only in translation are not ==', () {
      expect(
        _quote(translation: 'one') == _quote(translation: 'two'),
        isFalse,
      );
    });

    test('quotes differing only in userAdded are not ==', () {
      expect(
        _quote(userAdded: true) == _quote(userAdded: false),
        isFalse,
      );
    });

    test('quotes differing only in source are not ==', () {
      expect(_quote(source: 'subhashita') == _quote(source: 'yoga_sutra'), isFalse);
    });

    test('quotes differing only in reference are not ==', () {
      expect(_quote(reference: 'ref-1') == _quote(reference: 'ref-2'), isFalse);
    });

    test('quotes differing only in originalText are not ==', () {
      expect(
        _quote(originalText: 'one') == _quote(originalText: 'two'),
        isFalse,
      );
    });

    test('quotes differing only in originalLanguage are not ==', () {
      expect(
        _quote(originalLanguage: 'sanskrit') == _quote(originalLanguage: 'kannada'),
        isFalse,
      );
    });
  });

  group('QuoteModel JSON round trip', () {
    test('toJson/fromJson round-trips all fields', () {
      final quote = _quote(userAdded: true);
      final restored = QuoteModel.fromJson(quote.toJson());
      expect(restored, equals(quote));
    });
  });
}
