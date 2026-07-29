enum AppThemeMode { dark, light, system }

extension AppThemeModeStorage on AppThemeMode {
  String toStorageString() => switch (this) {
        AppThemeMode.dark => 'dark',
        AppThemeMode.light => 'light',
        AppThemeMode.system => 'system',
      };

  static AppThemeMode fromStorageString(
    String? value, {
    AppThemeMode fallback = AppThemeMode.dark,
  }) {
    return switch (value) {
      'dark' => AppThemeMode.dark,
      'light' => AppThemeMode.light,
      'system' => AppThemeMode.system,
      _ => fallback,
    };
  }
}
