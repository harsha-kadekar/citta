import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the accuracy of the bundled scripture quotes (issue #102 follow-up).
/// References were checked verse-by-verse against heritage.iitk.ac.in (Gita
/// Supersite, Valmiki Ramayana, BORI critical-edition Mahabharata, Upanishads).

List<Map<String, dynamic>> _quotes() =>
    ((jsonDecode(File('assets/data/quotes.json').readAsStringSync())
            as Map)['quotes'] as List)
        .cast<Map<String, dynamic>>();

Map<String, dynamic> _byId(String id) =>
    _quotes().firstWhere((q) => q['id'] == id);

void main() {
  test('quote ids are unique', () {
    final ids = _quotes().map((q) => q['id']).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('no verse is bundled twice', () {
    final texts = _quotes().map((q) => q['originalText']).toList();
    expect(texts.toSet().length, texts.length);
  });

  test('every source keeps at least 10 verses', () {
    final counts = <String, int>{};
    for (final q in _quotes()) {
      counts[q['source'] as String] = (counts[q['source']] ?? 0) + 1;
    }
    for (final source in [
      'bhagavad_gita',
      'yoga_sutras',
      'upanishads',
      'subhashita',
      'ramayana',
      'mahabharata',
    ]) {
      expect(counts[source], greaterThanOrEqualTo(10), reason: source);
    }
  });

  group('Bhagavad Gita verses are not filed under the Mahabharata', () {
    const gitaVerses = {
      'श्रेयान्स्वधर्मो': 'Chapter 3, Verse 35',
      'सर्वस्य चाहं': 'Chapter 15, Verse 15',
      'ध्यानेनात्मनि': 'Chapter 13, Verse 25',
    };
    gitaVerses.forEach((opening, reference) {
      test(reference, () {
        final q = _quotes().firstWhere(
            (q) => (q['originalText'] as String).startsWith(opening));
        expect(q['source'], 'bhagavad_gita');
        expect(q['reference'], reference);
      });
    });
  });

  test('Gita 15.15 is the complete genuine verse', () {
    final q = _byId('bundled-059');
    expect(q['originalText'], contains('वेदैश्च सर्वैरहमेव वेद्यो'));
    expect(q['originalText'], isNot(contains('प्रविलीयन्ते')));
  });

  test('Shanti Parva 316.6 uses the critical-edition reading', () {
    // BORI 12.316.6 reads "नास्ति विद्यासमं तपः" (knowledge, twice). The
    // popular "सत्यसमं" variant comes from the vulgate, which numbers the verse
    // differently, so pairing it with this BORI reference would misattribute.
    final q = _byId('bundled-056');
    expect(q['originalText'], 'नास्ति विद्यासमं चक्षुर्नास्ति विद्यासमं तपः। '
        'नास्ति रागसमं दुःखं नास्ति त्यागसमं सुखम्॥');
  });

  test('gem-and-glass subhashita keeps its buying-and-selling image', () {
    // क्रयविक्रयवेलायां = "at the time of buying and selling".
    expect(_byId('bundled-049')['translation'],
        contains('buying and selling'));
  });

  test('fabricated or garbled verses are no longer bundled', () {
    const fabricated = [
      'धर्ममेव तु गोचरम्', // fake "Ramayana" chariot verse
      'धैर्यमात्मनि सन्दध्यात्',
      'नात्मनो नाऽपि जीवित',
      'चलो हि धर्मात्',
      'मनः पूतं समाचरेत्। बुद्धिश्च',
      'कर्णे कर्णे जपति',
      'धर्म हिंसा तथैव च', // spurious second line of "ahimsa paramo dharmah"
    ];
    final all = _quotes().map((q) => q['originalText'] as String).join('\n');
    for (final snippet in fabricated) {
      expect(all, isNot(contains(snippet)), reason: snippet);
    }
  });

  test('ids of removed fabricated verses are retired, not reused', () {
    // These ids held fabricated verses. Reusing them for different verses
    // would make any stored id silently point at another quote.
    const retired = [
      'bundled-041',
      'bundled-044',
      'bundled-048',
      'bundled-050',
      'bundled-051',
      'bundled-053',
    ];
    final ids = _quotes().map((q) => q['id']).toSet();
    for (final id in retired) {
      expect(ids, isNot(contains(id)), reason: id);
    }
  });

  test('Manusmriti 8.15 is the complete verse, not a fragment', () {
    expect(_byId('bundled-042')['originalText'],
        startsWith('धर्म एव हतो हन्ति धर्मो रक्षति रक्षितः।'));
  });

  group('verified references', () {
    // Numbering follows heritage.iitk.ac.in: Gita Press-style Ramayana and
    // BORI critical-edition Mahabharata. Other editions may differ by a verse.
    const expected = {
      'bundled-021': 'Katha Upanishad 1.3.3',
      'bundled-027': 'Brihadaranyaka Upanishad 4.4.19',
      'bundled-043': 'Valmiki Ramayana, Kishkindha Kanda 1.121',
      'bundled-046': 'Valmiki Ramayana, Ayodhya Kanda 109.13',
      'bundled-047': 'Valmiki Ramayana, Ayodhya Kanda 109.31',
      'bundled-061': 'Valmiki Ramayana, Ayodhya Kanda 18.30',
      'bundled-062': 'Valmiki Ramayana, Yuddha Kanda 18.32',
      'bundled-063': 'Valmiki Ramayana, Ayodhya Kanda 109.10',
      'bundled-070': 'Valmiki Ramayana, Aranya Kanda 37.13',
      'bundled-071': 'Valmiki Ramayana, Sundara Kanda 12.10',
      'bundled-072': 'Valmiki Ramayana, Aranya Kanda 9.31',
      'bundled-073': 'Valmiki Ramayana, Aranya Kanda 37.2',
      'bundled-052': 'Mahabharata, Anushasana Parva 117.37',
      'bundled-056': 'Mahabharata, Shanti Parva 316.6',
      'bundled-064': 'Mahabharata, Udyoga Parva 39.57 (Vidura Niti)',
      'bundled-065': 'Mahabharata, Udyoga Parva 39.58 (Vidura Niti)',
      'bundled-066': 'Mahabharata, Udyoga Parva 33.66 (Vidura Niti)',
      'bundled-067': 'Mahabharata, Shanti Parva 316.12',
      'bundled-068': 'Mahabharata, Shanti Parva 316.13',
      'bundled-069': 'Mahabharata, Shanti Parva 316.11',
      'bundled-074': 'Mahabharata, Udyoga Parva 33.48 (Vidura Niti)',
      'bundled-075': 'Mahabharata, Udyoga Parva 35.49 (Vidura Niti)',
    };
    expected.forEach((id, reference) {
      test(id, () => expect(_byId(id)['reference'], reference));
    });
  });

  group('verses from other works are filed as subhashita', () {
    const refiled = {
      'bundled-031': 'Hitopadesha, Prastavika',
      'bundled-042': 'Manusmriti 8.15',
      'bundled-054': 'Manusmriti 6.92',
      'bundled-055': 'Yajnavalkya Smriti 1.351',
      'bundled-058': 'Panchatantra, Mitrabheda',
    };
    refiled.forEach((id, reference) {
      test(id, () {
        final q = _byId(id);
        expect(q['source'], 'subhashita');
        expect(q['reference'], reference);
      });
    });
  });
}
