# Citta — Dhyana Tracking App — Detailed Plan

## Overview

Citta is a personal dhyana (meditation) tracking app built with Flutter. The app follows the philosophy that **the user owns their data** — all data is stored locally as human-readable JSON files.

## Technology Stack

- **Framework:** Flutter (Dart) — iOS + Android single codebase
- **Storage:** JSON files with atomic writes + backup for crash safety
- **Audio:** `just_audio` for bells/music
- **File access:** `file_picker` for user audio/import, `share_plus` for export
- **State management:** Provider

## Architecture

```
lib/
├── main.dart              # App entry point
├── models/                # Data models (ConfigModel, SessionModel, QuoteModel)
├── providers/             # State management (AppState)
├── screens/               # Full screens (Home, History, Stats, Settings, etc.)
├── services/              # Business logic (Storage, Timer, Audio, Quote, Stats)
├── theme/                 # App theme and colors
└── widgets/               # Reusable widgets (TimerDisplay, QuoteCard, etc.)
```

## Data Files

- `config.json` — Timer defaults, sound selections, preferences
- `sessions.json` — Array of session records
- `user_quotes.json` — User-added quotes
- Bundled `assets/data/quotes.json` — Curated spiritual quotes

## Atomic Write Pattern

Write to `.tmp` → rename original to `.bak` → rename `.tmp` to target → delete `.bak`

On startup, recovery logic checks for `.tmp`/`.bak` files and recovers gracefully.

## Milestones

1. Project Setup & Foundation
2. Quotes System & Splash Screen
3. Data Layer (models, storage, atomic writes)
4. Timer Engine (countdown + stopwatch)
5. Audio System (bells, background music)
6. Timer Screen UI
7. Session Notes (word limit, tags, markdown)
8. Session History (list, detail, filter)
9. Consistency Stats (streaks, calendar)
10. Settings Screen
11. Export & Import
12. Polish & Testing

See the full plan with detailed task breakdowns in the project README or GitHub issues.
