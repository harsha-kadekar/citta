## Bundled Bell Sounds

These MP3 files are bundled and registered in `AudioService.bundledSounds`
(`lib/services/audio_service.dart`):

- `bell-meditation.mp3`: meditation bell
- `bright-tibetan-bell.mp3`: bright Tibetan bell
- `flat-tibetan-singing-bowl.mp3`: E-flat Tibetan singing bowl
- `indian-temple-bell.mp3`: Indian temple bell (trimmed to 10 s)
- `singing-bell.mp3`: singing bell
- `temple-bells.mp3`: Japanese temple bell
- `wind-chime.mp3`: wind chime
- `shiva-bells.mp3`: Shiva temple bells
- `hindu-temple-bells.mp3`: bells at a Hindu temple
- `ghanta.mp3`: ghanta (puja hand bell)
- `brass-bell.mp3`: brass hand bell

All of them are CC0 recordings from freesound.org. The source URL and author of
each one are recorded in [`ASSETS_LICENSES.md`](../../ASSETS_LICENSES.md).

### Adding or replacing a sound

- Use only FOSS-licensed audio, preferably CC0 (freesound.org, filtered to
  the *Creative Commons 0* license) or your own recordings. "Royalty-free"
  stock licenses are not FOSS-compatible and are rejected by F-Droid.
- Add or update the file's row in `ASSETS_LICENSES.md`. Its Source column must
  be the original's https URL, or start with `Original recording` for your own
  recordings. Also update the list
  above. `test/assets/asset_licenses_test.dart` fails if either drifts from
  the files actually present.
