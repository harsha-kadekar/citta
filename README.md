# Citta

A personal dhyana (meditation) tracking app. Local-first, data-portable, minimalistic.

## Philosophy

- **You own your data** — all data is stored locally as human-readable JSON
- **Minimalistic** — clean UI focused on practice, not features
- **No cloud required** — works entirely offline
- **Portable** — export/import your data anytime

## Features

- Timer with countdown and stopwatch modes
- Configurable bell sounds (start, end, interval)
- Optional background music during sessions
- Post-session notes with markdown support and tags
- Consistency tracking (streaks, stats, calendar)
- Daily spiritual quotes (Bhagavad Gita, Yoga Sutras, Upanishads, and more)
- Export/import via OS share sheet

## Getting Started

### Prerequisites

- Flutter SDK (>=3.2.0)
- iOS Simulator or Android Emulator

### Setup

```bash
cd citta
flutter pub get
flutter run
```

### Running Tests

```bash
flutter test
```

## Project Structure

```
citta/
├── lib/
│   ├── main.dart
│   ├── models/          # Data models
│   ├── providers/       # State management
│   ├── screens/         # App screens
│   ├── services/        # Business logic
│   ├── theme/           # App theme
│   └── widgets/         # Reusable widgets
├── assets/
│   ├── data/            # Bundled quotes
│   └── sounds/          # Bundled bell sounds
├── test/                # Unit & widget tests
└── docs/                # Detailed plan
```

## Detailed Plan

See [docs/PLAN.md](docs/PLAN.md) for the full implementation plan.

## Source Code

GitHub: https://github.com/harsha-kadekar/citta
