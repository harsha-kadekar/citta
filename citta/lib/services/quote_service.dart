import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/quote_model.dart';
import 'storage_service.dart';

class QuoteService {
  final StorageService _storageService;
  List<QuoteModel> _bundledQuotes = [];
  List<QuoteModel> _userQuotes = [];
  QuoteModel? _todayQuote;
  final _random = Random();
  final List<String> _recentQuoteIds = [];
  static const int _recentHistorySize = 10;

  QuoteService(this._storageService);

  QuoteModel? get todayQuote => _todayQuote;
  List<QuoteModel> get userQuotes => List.unmodifiable(_userQuotes);
  List<QuoteModel> get allQuotes => [..._bundledQuotes, ..._userQuotes];

  Future<void> initialize() async {
    await _loadBundledQuotes();
    await _loadUserQuotes();
    _selectTodayQuote();
  }

  Future<void> _loadBundledQuotes() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/quotes.json');
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      _bundledQuotes = (json['quotes'] as List<dynamic>)
          .map((e) => QuoteModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _bundledQuotes = [];
    }
  }

  Future<void> _loadUserQuotes() async {
    _userQuotes = await _storageService.loadUserQuotes();
  }

  void _selectTodayQuote() {
    final all = allQuotes;
    if (all.isEmpty) {
      _todayQuote = null;
      return;
    }

    // Try to pick a quote not in recent history
    final candidates =
        all.where((q) => !_recentQuoteIds.contains(q.id)).toList();
    final pool = candidates.isNotEmpty ? candidates : all;

    _todayQuote = pool[_random.nextInt(pool.length)];

    if (_todayQuote != null) {
      _recentQuoteIds.add(_todayQuote!.id);
      if (_recentQuoteIds.length > _recentHistorySize) {
        _recentQuoteIds.removeAt(0);
      }
    }
  }

  /// Force a new random quote selection.
  void refreshQuote() {
    _selectTodayQuote();
  }

  Future<void> addUserQuote(QuoteModel quote) async {
    _userQuotes.add(quote);
    await _storageService.saveUserQuotes(_userQuotes);
  }

  Future<void> removeUserQuote(String quoteId) async {
    _userQuotes.removeWhere((q) => q.id == quoteId);
    await _storageService.saveUserQuotes(_userQuotes);
  }

  Future<void> reloadUserQuotes() async {
    await _loadUserQuotes();
  }
}
