# Bundled Asset Licenses

Every file under `assets/` (except READMEs) is listed below with its source,
author and license. Every license is FOSS-compatible, as F-Droid requires
(issue #102). `pubspec.yaml` bundles `assets/data/` and `assets/sounds/`
directly. `assets/icon.png` reaches the app as the launcher icons that
`flutter_launcher_icons` generates from it, and `assets/icon_backup.png` is not
shipped.
`test/assets/asset_licenses_test.dart` enforces this table: adding, removing or
renaming a bundled asset without updating it fails the test suite.

**Do not bundle assets under the Pixabay Content License** or similar
"royalty-free" terms. They are not FOSS licenses. Prefer CC0 sources
(e.g. freesound.org with the *Creative Commons 0* license filter).

The License column uses SPDX identifiers, plus `Public-Domain` (not an SPDX
identifier) for works whose copyright has expired. A `+` joins the licenses of separate parts of one file.

## Sounds (`assets/sounds/`)

Each file is the freesound.org 128 kbps MP3 preview of the linked original,
renamed to the filename the app expects (`AudioService.bundledSounds`).
`indian-temple-bell.mp3` is also trimmed: it keeps the first 10 seconds, with
a 1.5-second linear fade-out, re-encoded at 128 kbps CBR. CC0 permits
modification.

| File | Description | Source | Author | License |
|------|-------------|--------|--------|---------|
| `assets/sounds/bell-meditation.mp3` | Meditation bell, cleaned | https://freesound.org/people/JetRye/sounds/140128/ | JetRye | CC0-1.0 |
| `assets/sounds/bright-tibetan-bell.mp3` | Bright Tibetan bell, B note | https://freesound.org/people/steaq/sounds/346328/ | steaq | CC0-1.0 |
| `assets/sounds/flat-tibetan-singing-bowl.mp3` | E-flat Tibetan singing bowl, struck | https://freesound.org/people/mttvn/sounds/535950/ | mttvn | CC0-1.0 |
| `assets/sounds/indian-temple-bell.mp3` | Indian temple bell, first 10 s with fade-out | https://freesound.org/people/ganiket/sounds/466652/ | ganiket | CC0-1.0 |
| `assets/sounds/shiva-bells.mp3` | Shiva temple bells | https://freesound.org/people/grololo/sounds/34870/ | grololo | CC0-1.0 |
| `assets/sounds/hindu-temple-bells.mp3` | Bells at a Hindu temple | https://freesound.org/people/barryshamir/sounds/876449/ | barryshamir | CC0-1.0 |
| `assets/sounds/ghanta.mp3` | Ghanta (puja hand bell), leather mallet | https://freesound.org/people/the_very_Real_Horst/sounds/274316/ | the_very_Real_Horst | CC0-1.0 |
| `assets/sounds/brass-bell.mp3` | Brass hand bell | https://freesound.org/people/craigsmith/sounds/479978/ | craigsmith | CC0-1.0 |
| `assets/sounds/singing-bell.mp3` | Singing bell hit | https://freesound.org/people/ryancacophony/sounds/202018/ | ryancacophony | CC0-1.0 |
| `assets/sounds/temple-bells.mp3` | Bell at Daitoku-ji temple, Kyoto | https://freesound.org/people/nahmandub/sounds/131348/ | nahmandub | CC0-1.0 |
| `assets/sounds/wind-chime.mp3` | Single wind-chime strike | https://freesound.org/people/jcdecha/sounds/235463/ | jcdecha | CC0-1.0 |

## Data (`assets/data/`)

| File | Description | Source | Author | License |
|------|-------------|--------|--------|---------|
| `assets/data/quotes.json` | Bundled Sanskrit verses with English translations | Bhagavad Gita, Yoga Sutras of Patanjali, Upanishads, Valmiki Ramayana, Mahabharata, and subhashitas (Manusmriti, Chanakya Niti, Hitopadesha, Panchatantra, Bhartrihari and others) | Sanskrit: traditional/ancient authors. Translations: Citta contributors | Public-Domain + MIT |

- **Sanskrit `originalText`**: these texts are thousands of years old and in
  the public domain.
- **English `translation`**: renderings written for this project and released
  under the repository's MIT license. In issue #102 every Bhagavad Gita and
  Yoga Sutra translation, and the Mandukya Upanishad verse, was rewritten from
  the Sanskrit to keep clear of well-known copyrighted editions (Prabhupada,
  Satchidananda, Gambhirananda). `test/assets/asset_licenses_test.dart` rejects
  distinctive phrasing from those editions. Do not add translations copied from
  a published edition unless that edition is in the public domain (e.g. Müller
  1879–84, Arnold 1885).
- **References**: the Bhagavad Gita, Yoga Sutra, Upanishad, Ramayana and
  Mahabharata references were checked verse by verse against the IIT Kanpur
  Heritage Scripture Server (https://heritage.iitk.ac.in). Ramayana numbering
  follows that edition, and Mahabharata numbering follows the BORI critical
  edition. Verses that couldn't be found in the work they were credited to were
  replaced with verified verses. Real verses credited to the wrong epic were
  moved to `subhashita` with their actual source. Those subhashita
  attributions (Manusmriti, Yajnavalkya Smriti, Hitopadesha, Panchatantra,
  Chanakya Niti, Bhartrihari) are standard but were not checked against that
  server, which doesn't host those works. `test/assets/quotes_data_test.dart`
  pins the corrected references.

## App icon (`assets/`)

| File | Description | Source | Author | License |
|------|-------------|--------|--------|---------|
| `assets/icon.png` | Launcher icon (used by `flutter_launcher_icons`) | Created for this project with AI assistance (Claude) | Harsha Kadekar | MIT |
| `assets/icon_backup.png` | Earlier version of the launcher icon | Created for this project with AI assistance (Claude) | Harsha Kadekar | MIT |

## Fonts (`assets/fonts/`)

No font files are bundled at present. The app uses system fonts, and the
`fonts:` block in `pubspec.yaml` is commented out. If the Noto Sans / Noto Sans
Devanagari fonts described in `assets/fonts/README.md` are added later, they
are licensed under the SIL Open Font License 1.1 (`OFL-1.1`). Add a row here for
each `.ttf`, and ship the OFL text alongside them.
