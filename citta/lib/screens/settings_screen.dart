import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_state.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import 'add_quote_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final config = appState.config;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // --- Profile Section ---
          const _SectionHeader(title: 'Profile'),
          _SettingsTile(
            title: 'Name',
            subtitle: config.userName ?? 'Not set',
            onTap: () => _showEditNameDialog(context, appState),
          ),
          const Divider(),

          // --- Appearance Section ---
          const _SectionHeader(title: 'Appearance'),
          _SettingsTile(
            title: 'Theme',
            subtitle: _themeDisplayName(config.themeMode),
            onTap: () => _showThemePicker(context, appState),
          ),
          const Divider(),

          // --- Timer Section ---
          const _SectionHeader(title: 'Timer'),
          _SettingsTile(
            title: 'Default Mode',
            subtitle: config.timerMode == 'countdown'
                ? 'Countdown'
                : 'Stopwatch',
            onTap: () => _showTimerModeDialog(context, appState),
          ),
          if (config.timerMode == 'countdown')
            _SettingsTile(
              title: 'Default Duration',
              subtitle: '${config.countdownDuration ~/ 60} minutes',
              onTap: () => _showDurationPicker(context, appState),
            ),
          const Divider(),

          // --- Bell Sounds ---
          const _SectionHeader(title: 'Bell Sounds'),
          _SettingsTile(
            title: 'Start Bell',
            subtitle: _bellDisplayName(config.bellStart),
            trailing: config.bellStart == 'none'
                ? null
                : IconButton(
                    icon: const Icon(Icons.play_circle_outline, size: 20),
                    onPressed: () =>
                        appState.audioService.previewSound(config.bellStart),
                  ),
            onTap: () => _showBellPicker(
                context, appState, 'Start Bell', config.bellStart,
                (val) {
              appState.updateConfig(config.copyWith(bellStart: val));
            }),
          ),
          _SettingsTile(
            title: 'End Bell',
            subtitle: _bellDisplayName(config.bellEnd),
            trailing: config.bellEnd == 'none'
                ? null
                : IconButton(
                    icon: const Icon(Icons.play_circle_outline, size: 20),
                    onPressed: () =>
                        appState.audioService.previewSound(config.bellEnd),
                  ),
            onTap: () => _showBellPicker(
                context, appState, 'End Bell', config.bellEnd,
                (val) {
              appState.updateConfig(config.copyWith(bellEnd: val));
            }),
          ),
          const Divider(),

          // --- Interval ---
          const _SectionHeader(title: 'Interval Bell'),
          SwitchListTile(
            title: const Text('Enable Interval Bell'),
            subtitle: Text(config.intervalEnabled
                ? 'Every ${config.intervalDuration ~/ 60} min'
                : 'Off'),
            value: config.intervalEnabled,
            activeThumbColor: AppColors.primary,
            onChanged: (val) {
              appState
                  .updateConfig(config.copyWith(intervalEnabled: val));
            },
          ),
          if (config.intervalEnabled) ...[
            _SettingsTile(
              title: 'Interval Duration',
              subtitle: '${config.intervalDuration ~/ 60} minutes',
              onTap: () =>
                  _showIntervalDurationPicker(context, appState),
            ),
            _SettingsTile(
              title: 'Interval Sound',
              subtitle: _bellDisplayName(config.bellInterval),
              trailing: config.bellInterval == 'none'
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.play_circle_outline, size: 20),
                      onPressed: () => appState.audioService
                          .previewSound(config.bellInterval),
                    ),
              onTap: () => _showBellPicker(context, appState,
                  'Interval Sound', config.bellInterval, (val) {
                appState
                    .updateConfig(config.copyWith(bellInterval: val));
              }),
            ),
          ],
          const Divider(),

          // --- Background Music ---
          const _SectionHeader(title: 'Background Music'),
          _SettingsTile(
            title: 'Music File',
            subtitle:
                config.backgroundMusic != null ? 'Selected' : 'None',
            onTap: () => _pickBackgroundMusic(context, appState),
          ),
          if (config.backgroundMusic != null)
            ListTile(
              leading: const Icon(Icons.clear, color: AppColors.error),
              title: const Text('Remove Background Music'),
              onTap: () {
                appState.updateConfig(
                    config.copyWith(backgroundMusic: null));
              },
            ),
          const Divider(),

          // --- Tags ---
          const _SectionHeader(title: 'Tags'),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...config.tags.map((tag) => Chip(
                      label: Text(tag),
                      onDeleted: () => appState.removeTag(tag),
                      deleteIconColor: AppColors.textHint,
                    )),
                ActionChip(
                  label: const Text('+ Add'),
                  onPressed: () => _showAddTagDialog(context, appState),
                ),
              ],
            ),
          ),
          const Divider(),

          // --- Quotes ---
          const _SectionHeader(title: 'Quotes'),
          _SettingsTile(
            title: 'Add Custom Quote',
            subtitle:
                '${appState.quoteService.userQuotes.length} user quotes',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const AddQuoteScreen()),
              );
            },
          ),
          const Divider(),

          // --- Data ---
          const _SectionHeader(title: 'Data'),
          _SettingsTile(
            title: 'Export Data',
            subtitle: 'Share your sessions & config as JSON',
            onTap: () => _exportData(context, appState),
          ),
          _SettingsTile(
            title: 'Import Data',
            subtitle: 'Load from a Citta JSON export file',
            onTap: () => _importData(context, appState),
          ),
        ],
      ),
    );
  }

  String _themeDisplayName(String mode) {
    switch (mode) {
      case 'light':
        return 'Light';
      case 'system':
        return 'System';
      case 'dark':
      default:
        return 'Dark';
    }
  }

  void _showThemePicker(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Theme'),
        children: [
          for (final entry in [
            ('dark', 'Dark', Icons.dark_mode),
            ('light', 'Light', Icons.light_mode),
            ('system', 'System', Icons.settings_brightness),
          ])
            SimpleDialogOption(
              onPressed: () {
                appState.updateConfig(
                    appState.config.copyWith(themeMode: entry.$1));
                Navigator.pop(context);
              },
              child: ListTile(
                leading: Icon(entry.$3,
                    color: appState.config.themeMode == entry.$1
                        ? Theme.of(context).colorScheme.primary
                        : null),
                title: Text(entry.$2),
              ),
            ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, AppState appState) {
    final controller =
        TextEditingController(text: appState.config.userName ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter your name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                appState.updateConfig(
                  appState.config.copyWith(userName: name),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _bellDisplayName(String bellId) {
    if (bellId == 'none') return 'None';
    if (bellId.startsWith('bundled:')) {
      final name = bellId.substring(8);
      return AudioService.soundDisplayNames[name] ?? name;
    }
    if (bellId.startsWith('custom:')) {
      return 'Custom file';
    }
    return bellId;
  }

  void _showTimerModeDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Default Timer Mode'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              appState.updateConfig(
                  appState.config.copyWith(timerMode: 'countdown'));
              Navigator.pop(context);
            },
            child: ListTile(
              leading: Icon(Icons.timer,
                  color: appState.config.timerMode == 'countdown'
                      ? AppColors.primary
                      : null),
              title: const Text('Countdown'),
              subtitle: const Text('Set a duration, timer counts down'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              appState.updateConfig(
                  appState.config.copyWith(timerMode: 'stopwatch'));
              Navigator.pop(context);
            },
            child: ListTile(
              leading: Icon(Icons.timer_off,
                  color: appState.config.timerMode == 'stopwatch'
                      ? AppColors.primary
                      : null),
              title: const Text('Stopwatch'),
              subtitle: const Text('Open-ended, stop manually'),
            ),
          ),
        ],
      ),
    );
  }

  void _showDurationPicker(BuildContext context, AppState appState) {
    final durations = [5, 10, 15, 20, 25, 30, 45, 60, 90, 120];
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Default Duration'),
        children: durations
            .map((mins) => SimpleDialogOption(
                  onPressed: () {
                    appState.updateConfig(appState.config
                        .copyWith(countdownDuration: mins * 60));
                    Navigator.pop(context);
                  },
                  child: Text(
                    '$mins minutes',
                    style: TextStyle(
                      fontWeight:
                          appState.config.countdownDuration == mins * 60
                              ? FontWeight.w600
                              : FontWeight.w400,
                      color:
                          appState.config.countdownDuration == mins * 60
                              ? AppColors.primary
                              : null,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  void _showIntervalDurationPicker(
      BuildContext context, AppState appState) {
    final intervals = [1, 2, 3, 5, 10, 15, 20];
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Interval Duration'),
        children: intervals
            .map((mins) => SimpleDialogOption(
                  onPressed: () {
                    appState.updateConfig(appState.config
                        .copyWith(intervalDuration: mins * 60));
                    Navigator.pop(context);
                  },
                  child: Text(
                    '$mins minutes',
                    style: TextStyle(
                      fontWeight:
                          appState.config.intervalDuration == mins * 60
                              ? FontWeight.w600
                              : FontWeight.w400,
                      color:
                          appState.config.intervalDuration == mins * 60
                              ? AppColors.primary
                              : null,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  void _showBellPicker(BuildContext context, AppState appState,
      String title, String currentValue, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          SimpleDialogOption(
            onPressed: () {
              onSelect('none');
              Navigator.pop(context);
            },
            child: Text(
              'None',
              style: TextStyle(
                fontWeight: currentValue == 'none'
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: currentValue == 'none'
                    ? AppColors.primary
                    : null,
              ),
            ),
          ),
          ...AudioService.bundledSounds.entries.map((entry) {
            final bellId = 'bundled:${entry.key}';
            return SimpleDialogOption(
              onPressed: () {
                onSelect(bellId);
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AudioService.soundDisplayNames[entry.key] ??
                          entry.key,
                      style: TextStyle(
                        fontWeight: currentValue == bellId
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: currentValue == bellId
                            ? AppColors.primary
                            : null,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.play_circle_outline,
                        size: 20),
                    onPressed: () =>
                        appState.audioService.previewSound(bellId),
                  ),
                ],
              ),
            );
          }),
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(context);
              final result = await FilePicker.platform.pickFiles(
                type: FileType.audio,
              );
              if (result != null && result.files.single.path != null) {
                onSelect('custom:${result.files.single.path}');
              }
            },
            child: const Row(
              children: [
                Icon(Icons.folder_open, size: 20),
                SizedBox(width: 12),
                Text('Pick from device...'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickBackgroundMusic(
      BuildContext context, AppState appState) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null && result.files.single.path != null) {
      appState.updateConfig(appState.config
          .copyWith(backgroundMusic: result.files.single.path));
    }
  }

  void _showAddTagDialog(BuildContext context, AppState appState) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration:
              const InputDecoration(hintText: 'e.g., focused'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final tag = controller.text.trim().toLowerCase();
              if (tag.isNotEmpty) {
                appState.addTag(tag);
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(
      BuildContext context, AppState appState) async {
    try {
      final path = await appState.storageService.writeExportFile();
      await Share.shareXFiles([XFile(path)],
          subject: 'Citta Data Export');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _importData(
      BuildContext context, AppState appState) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;

    final file = result.files.single;
    final content = await File(file.path!).readAsString();

    if (!context.mounted) return;

    // Ask merge strategy
    final replaceAll = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text(
            'Replace all existing data, or merge with current data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Merge'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Replace All'),
          ),
        ],
      ),
    );

    if (replaceAll == null || !context.mounted) return;

    final success =
        await appState.importData(content, replaceAll: replaceAll);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Data imported successfully'
              : 'Invalid import file'),
        ),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textHint,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ??
          const Icon(Icons.chevron_right,
              color: AppColors.textHint, size: 20),
      onTap: onTap,
    );
  }
}
