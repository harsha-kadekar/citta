import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/quote_model.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

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
        const SnackBar(content: Text('Quote added')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Quote'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Original Text *',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _originalTextController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter the quote in original script...',
              ),
            ),
            const SizedBox(height: 20),
            Text('Language',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _language,
              decoration: const InputDecoration(),
              items: const [
                DropdownMenuItem(value: 'sanskrit', child: Text('Sanskrit')),
                DropdownMenuItem(value: 'kannada', child: Text('Kannada')),
                DropdownMenuItem(value: 'hindi', child: Text('Hindi')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (val) => setState(() => _language = val ?? 'sanskrit'),
            ),
            const SizedBox(height: 20),
            Text('English Translation *',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _translationController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter the English translation...',
              ),
            ),
            const SizedBox(height: 20),
            Text('Source', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _sourceController,
              decoration: const InputDecoration(
                hintText: 'e.g., Bhagavad Gita',
              ),
            ),
            const SizedBox(height: 20),
            Text('Reference', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _referenceController,
              decoration: const InputDecoration(
                hintText: 'e.g., Chapter 2, Verse 47',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValid ? _save : null,
                child: const Text('Save Quote'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
