enum _AudioSourceKind { none, bundled, custom }

/// A bell or background-music source identifier.
///
/// Centralizes the `bundled:<name>` / `custom:<path>` / `none` string
/// convention that used to be parsed ad hoc wherever a config's audio field
/// was read (config sanitization, playback, and settings UI).
class AudioSource {
  final _AudioSourceKind _kind;
  final String? _value;

  const AudioSource._(this._kind, this._value);

  static const AudioSource none = AudioSource._(_AudioSourceKind.none, null);

  const AudioSource.bundled(String name) : this._(_AudioSourceKind.bundled, name);

  const AudioSource.custom(String path) : this._(_AudioSourceKind.custom, path);

  bool get isNone => _kind == _AudioSourceKind.none;
  bool get isBundled => _kind == _AudioSourceKind.bundled;
  bool get isCustom => _kind == _AudioSourceKind.custom;

  /// The bundled sound's key (e.g. into `AudioService.bundledSounds`), or
  /// null unless [isBundled].
  String? get bundledName => isBundled ? _value : null;

  /// The device-local file path, or null unless [isCustom].
  String? get path => isCustom ? _value : null;

  String toStorageString() => switch (_kind) {
        _AudioSourceKind.none => 'none',
        _AudioSourceKind.bundled => 'bundled:$_value',
        _AudioSourceKind.custom => 'custom:$_value',
      };

  /// Parses a persisted identifier using the `bundled:`/`custom:`/`none`
  /// convention.
  ///
  /// Set [allowBundled] to false for callers (background music) that don't
  /// support bundled options, so a value that happens to start with
  /// `bundled:` is treated as a literal path instead. Set [allowRawPath] for
  /// callers that must also accept legacy configs saved before the `custom:`
  /// prefix convention existed — an unrecognized value is then treated as a
  /// raw custom path rather than falling back to [none].
  static AudioSource fromStorageString(
    String value, {
    bool allowBundled = true,
    bool allowRawPath = false,
  }) {
    if (value == 'none') return AudioSource.none;
    if (allowBundled && value.startsWith('bundled:')) {
      return AudioSource.bundled(value.substring(8));
    }
    if (value.startsWith('custom:')) {
      return AudioSource.custom(value.substring(7));
    }
    if (allowRawPath) return AudioSource.custom(value);
    return AudioSource.none;
  }

  @override
  bool operator ==(Object other) =>
      other is AudioSource && other._kind == _kind && other._value == _value;

  @override
  int get hashCode => Object.hash(_kind, _value);

  @override
  String toString() => 'AudioSource(${toStorageString()})';
}
