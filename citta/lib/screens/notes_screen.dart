import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/session_model.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class NotesScreen extends StatefulWidget {
  final SessionModel session;

  const NotesScreen({super.key, required this.session});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _notesController = TextEditingController();
  final Set<String> _selectedTags = {};
  int _wordCount = 0;
  static const int _maxWords = 500;

  @override
  void initState() {
    super.initState();
    _notesController.addListener(_updateWordCount);
  }

  void _updateWordCount() {
    final text = _notesController.text.trim();
    final words = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    setState(() => _wordCount = words);
  }

  void _onTextChanged(String value) {
    final text = value.trim();
    if (text.isEmpty) return;
    final words = text.split(RegExp(r'\s+'));
    if (words.length > _maxWords) {
      // Truncate to max words
      final truncated = words.take(_maxWords).join(' ');
      _notesController.text = truncated;
      _notesController.selection = TextSelection.fromPosition(
        TextPosition(offset: truncated.length),
      );
    }
  }

  Future<void> _saveSession({bool skip = false}) async {
    final appState = context.read<AppState>();
    final session = widget.session.copyWith(
      notes: skip ? null : _notesController.text.trim(),
      tags: skip ? [] : _selectedTags.toList(),
    );
    await appState.addSession(session);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    if (mins == 0) return '${secs}s';
    return secs > 0 ? '${mins}m ${secs}s' : '${mins}m';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final availableTags = appState.config.tags;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Notes'),
        leading: const SizedBox.shrink(),
        actions: [
          TextButton(
            onPressed: () => _saveSession(skip: true),
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Session summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.self_improvement,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _formatDuration(widget.session.duration),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (widget.session.completedFully) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 18),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Notes input
              Text(
                'How was your practice?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 8,
                onChanged: _onTextChanged,
                decoration: InputDecoration(
                  hintText:
                      'Write about your experience... (plain text or markdown)',
                  counterText: '$_wordCount / $_maxWords words',
                  counterStyle: TextStyle(
                    color: _wordCount >= _maxWords
                        ? AppColors.error
                        : AppColors.textHint,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Tags
              Text(
                'Tags',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableTags.map((tag) {
                  final selected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                    selectedColor: AppColors.primaryLight.withValues(alpha:0.3),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _saveSession(),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
