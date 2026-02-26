import 'package:flutter/material.dart';
import 'package:citta/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/quote_model.dart';
import '../providers/app_state.dart';


class AddQuoteScreen extends StatefulWidget {
  const AddQuoteScreen({super.key});

  @override
  State<AddQuoteScreen> createState() => _AddQuoteScreenState();
}

class _AddQuoteScreenState extends State<AddQuoteScreen> {
  final _originalTextController = TextEditingController();
  final _translationController = TextEditingController();
  final _sourceController = TextEditingController();
  final _referenceController = TextEditingController();
  String _language = 'sanskrit';

  bool get _isValid =>
      _originalTextController.text.trim().isNotEmpty &&
      _translationController.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!_isValid) return;

    final appState = context.read<AppState>();
    final l10n = AppLocalizations.of(context)!;
    final quote = QuoteModel(
      id: 'user-${const Uuid().v4()}',
      source: _sourceController.text.trim().isEmpty
          ? 'personal'
          : _sourceController.text.trim(),
      reference: _referenceController.text.trim(),
      originalText: _originalTextController.text.trim(),
      originalLanguage: _language,
      translation: _translationController.text.trim(),
      userAdded: true,
    );

    await appState.quoteService.addUserQuote(quote);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addQuoteAdded)),
      );
    }
  }

  @override
  void dispose() {
    _originalTextController.dispose();
    _translationController.dispose();
    _sourceController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final languageOptions = [
      ('english', l10n.langEnglish),
      ('hindi', l10n.langHindi),
      ('kannada', l10n.langKannada),
      ('sanskrit', l10n.langSanskrit),
      ('telugu', l10n.langTelugu),
      ('tamil', l10n.langTamil),
      ('malayalam', l10n.langMalayalam),
      ('marathi', l10n.langMarathi),
      ('gujarati', l10n.langGujarati),
      ('odia', l10n.langOdia),
      ('bengali', l10n.langBengali),
      ('tulu', l10n.langTulu),
      ('konkani', l10n.langKonkani),
      ('urdu', l10n.langUrdu),
      ('assamese', l10n.langAssamese),
      ('punjabi', l10n.langPunjabi),
      ('maithili', l10n.langMaithili),
      ('french', l10n.langFrench),
      ('german', l10n.langGerman),
      ('italian', l10n.langItalian),
      ('spanish', l10n.langSpanish),
      ('portuguese', l10n.langPortuguese),
      ('russian', l10n.langRussian),
      ('arabic', l10n.langArabic),
      ('japanese', l10n.langJapanese),
      ('chinese', l10n.langChinese),
      ('hebrew', l10n.langHebrew),
      ('other', l10n.langOther),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addQuoteTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.addQuoteOriginalText,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _originalTextController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: l10n.addQuoteOriginalHint,
              ),
            ),
            const SizedBox(height: 20),
            Text(l10n.addQuoteLanguage,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _language,
              decoration: const InputDecoration(),
              items: languageOptions
                  .map((entry) => DropdownMenuItem(
                        value: entry.$1,
                        child: Text(entry.$2),
                      ))
                  .toList(),
              onChanged: (val) =>
                  setState(() => _language = val ?? 'sanskrit'),
            ),
            const SizedBox(height: 20),
            Text(l10n.addQuoteTranslation,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _translationController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.addQuoteTranslationHint,
              ),
            ),
            const SizedBox(height: 20),
            Text(l10n.addQuoteSource,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _sourceController,
              decoration: InputDecoration(
                hintText: l10n.addQuoteSourceHint,
              ),
            ),
            const SizedBox(height: 20),
            Text(l10n.addQuoteReference,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _referenceController,
              decoration: InputDecoration(
                hintText: l10n.addQuoteReferenceHint,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValid ? _save : null,
                child: Text(l10n.addQuoteSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
