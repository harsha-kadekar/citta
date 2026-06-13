import 'package:flutter/material.dart';
import 'package:citta/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'add_quote_screen.dart';
import 'settings/settings_widgets.dart';
import 'settings/profile_section.dart';
import 'settings/appearance_section.dart';
import 'settings/timer_section.dart';
import 'settings/bells_section.dart';
import 'settings/bg_music_section.dart';
import 'settings/tags_section.dart';
import 'settings/data_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          SectionHeader(title: l10n.settingsProfile),
          const ProfileSection(),
          const Divider(),

          SectionHeader(title: l10n.settingsAppearance),
          const AppearanceSection(),
          const Divider(),

          SectionHeader(title: l10n.settingsTimer),
          const TimerSection(),
          const Divider(),

          SectionHeader(title: l10n.settingsBellSounds),
          const BellsSection(),
          const Divider(),

          SectionHeader(title: l10n.settingsBgMusic),
          const BgMusicSection(),
          const Divider(),

          SectionHeader(title: l10n.settingsTags),
          const TagsSection(),
          const Divider(),

          SectionHeader(title: l10n.settingsQuotes),
          ListTile(
            title: Text(l10n.settingsAddCustomQuote),
            subtitle: Text(
                l10n.settingsUserQuotes(appState.quoteService.userQuotes.length)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddQuoteScreen()),
            ),
          ),
          const Divider(),

          SectionHeader(title: l10n.settingsData),
          const DataSection(),
        ],
      ),
    );
  }
}
