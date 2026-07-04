import 'package:flutter/material.dart';
import 'package:citta/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/session_model.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'session_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Set<String> _selectedFilterTags = {};
  bool _selectionMode = false;
  final Set<String> _selectedSessionIds = {};

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedSessionIds.clear();
    });
  }

  void _toggleSessionSelection(String id) {
    setState(() {
      if (_selectedSessionIds.contains(id)) {
        _selectedSessionIds.remove(id);
        if (_selectedSessionIds.isEmpty) {
          _selectionMode = false;
        }
      } else {
        _selectedSessionIds.add(id);
      }
    });
  }

  void _enterSelectionMode(String id) {
    setState(() {
      _selectionMode = true;
      _selectedSessionIds.add(id);
    });
  }

  Future<void> _deleteSelected() async {
    final l10n = AppLocalizations.of(context)!;
    final count = _selectedSessionIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.historyDeleteTitle),
        content: Text(l10n.historyDeleteConfirm(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.actionDelete,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AppState>().deleteSessions(_selectedSessionIds.toList());
      _exitSelectionMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allTags =
        context.select<AppState, List<String>>((s) => s.config.tags);
    final sortedSessions =
        context.select<AppState, List<SessionModel>>((s) => s.sortedSessions);

    // Drop any selected tags that no longer exist in config so a deleted tag
    // never leaves an invisible active filter.  Mutating the set directly here
    // (no setState) is safe: this build frame already incorporates the update.
    _selectedFilterTags.retainAll(allTags);

    final sessions = _selectedFilterTags.isEmpty
        ? sortedSessions
        : sortedSessions
            .where((s) => _selectedFilterTags.any((t) => s.tags.contains(t)))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: _selectionMode
            ? Text(l10n.historySelected(_selectedSessionIds.length))
            : Text(l10n.historyTitle),
        leading: _selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
              )
            : null,
        actions: [
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _selectedSessionIds.isNotEmpty ? _deleteSelected : null,
            ),
        ],
      ),
      body: Column(
        children: [
          // Tag filter
          if (allTags.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(context, l10n.historyFilterAll, _selectedFilterTags.isEmpty, () {
                      setState(() => _selectedFilterTags.clear());
                    }),
                    const SizedBox(width: 8),
                    ...allTags.map((tag) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(
                            context,
                            tag,
                            _selectedFilterTags.contains(tag),
                            () {
                              setState(() {
                                if (_selectedFilterTags.contains(tag)) {
                                  _selectedFilterTags.remove(tag);
                                } else {
                                  _selectedFilterTags.add(tag);
                                }
                              });
                            },
                          ),
                        )),
                  ],
                ),
              ),
            ),
          // Session list
          Expanded(
            child: sessions.isEmpty
                ? _buildEmptyState(context, l10n)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      return _buildSessionCard(context, sessions[index], l10n);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool selected, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceVariant = isDark ? DarkAppColors.surfaceVariant : AppColors.surfaceVariant;
    final textSecondary = isDark ? DarkAppColors.textSecondary : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.15)
              : surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(color: colorScheme.primary, width: 1)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? colorScheme.primary : textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard(
      BuildContext context, SessionModel session, AppLocalizations l10n) {
    final date = session.date.toLocal();
    final localeStr = currentLocaleStr(context);
    final dateStr = formatSessionDate(date, localeStr);
    final timeStr = formatSessionTime(date, localeStr);
    final duration = formatDuration(session.duration);
    final isSelected = _selectedSessionIds.contains(session.id);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceVariant = isDark ? DarkAppColors.surfaceVariant : AppColors.surfaceVariant;
    final textSecondary = isDark ? DarkAppColors.textSecondary : AppColors.textSecondary;
    final textHint = isDark ? DarkAppColors.textHint : AppColors.textHint;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          if (_selectionMode) {
            _toggleSessionSelection(session.id);
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    SessionDetailScreen(session: session),
              ),
            );
          }
        },
        onLongPress: () {
          if (!_selectionMode) {
            _enterSelectionMode(session.id);
          }
        },
        leading: _selectionMode
            ? Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleSessionSelection(session.id),
                activeColor: colorScheme.primary,
              )
            : null,
        title: Row(
          children: [
            Text(
              dateStr,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Text(
              timeStr,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 14, color: textHint),
                const SizedBox(width: 4),
                Text(duration,
                    style: Theme.of(context).textTheme.bodyMedium),
                if (session.completedFully) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check_circle, size: 14, color: colorScheme.primary),
                ],
              ],
            ),
            if (session.tags.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                children: session.tags
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                                fontSize: 11,
                                color: textSecondary),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
        trailing: _selectionMode
            ? null
            : Icon(Icons.chevron_right, color: textHint, size: 20),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textHint = isDark ? DarkAppColors.textHint : AppColors.textHint;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.self_improvement,
              size: 64, color: textHint.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            l10n.historyEmpty,
            style: TextStyle(
              fontSize: 18,
              color: textHint,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.historyEmptyHint,
            style: TextStyle(
              fontSize: 14,
              color: textHint.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
