# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Contapersone is a **Flutter app** (Android, iOS, Web, macOS) for real-time shared people counting. Multiple devices connect to the same counter via QR code or URL link, each running an independent subcounter that syncs in real-time through Firebase Cloud Firestore.

**Bundle ID**: `app.dindondan.contapersone`

## Build & Development Commands

```bash
flutter pub get              # Install dependencies
flutter run                  # Run in debug mode
flutter test                 # Run tests
flutter analyze              # Static analysis
flutter build apk            # Build Android
flutter build ios            # Build iOS
flutter build web            # Build web
flutter gen-l10n             # Regenerate localization files
```

**Requirements**: Dart SDK >=2.12.0 <=3.13.4, Java 17 (Android), Android SDK 35, iOS 12.0+

## Architecture

### Data Flow

The app uses **Firebase Firestore for real-time sync** with no local state management library. State is managed via `StatefulWidget` + `StreamBuilder`/`ValueListenableBuilder` patterns, with `setState` driven by Firestore snapshot listeners.

### Firestore Schema

- `counters/{token}` — main counter doc with `total`, `capacity`, `creator`, `subtotals` (map of all subcounters), `deleted`
- `counters/{token}/subcounters/{userId}` — per-device subcounter with `add_events` (list of timestamps), `subtract_events` (list of timestamps), `label`

Counter tokens are 32-character random hex strings. Each device gets a subcounter identified by the Firebase Auth user ID. The total count is derived from summing all subcounters.

### Authentication

`Auth` class (`lib/common/auth.dart`) extends `ValueNotifier<AuthValue>`. All users start with anonymous Firebase auth. Optional email/password login is available. States: `undefined` → `notLoggedIn` | `loggedInAnonymously` | `loggedIn`.

### Screen Structure

- **HomeScreen** (`lib/home_screen/`) — entry point: create counter, join counter (by token/QR), counter history
- **CounterScreen** (`lib/counter_screen/`) — main counting UI with +/- buttons, real-time Firestore listeners, vibration feedback
- **ShareScreen** (`lib/share_screen/`) — QR code generation and link sharing
- **StatsScreen** (`lib/stats_screen/`) — time-series chart (Syncfusion) with CSV export, built using RxDart BehaviorSubject
- **InfoScreen** (`lib/info_screen/`) — about page

### Deep Linking

Scheme: `app.dindondan.contapersone://?token=<32-char-hex>`. Handled via `app_links` package. Web version parses query string with `window_location_href`.

## Localization

- 5 languages: Italian (primary/template), English, Spanish, German, French
- ARB files in `lib/l10n/`, template is `app_it.arb`
- Generated output: `lib/l10n/app_localizations.dart` (set `synthetic-package: false` in `l10n.yaml`)
- Run `flutter gen-l10n` after editing ARB files

## Key Dependencies

- **Firebase**: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_analytics`
- **Charts**: `syncfusion_flutter_charts` (stats screen)
- **QR**: `qr_flutter` (generation), `mobile_scanner` (scanning)
- **Reactive**: `rxdart` (stats screen streams)
- **Sharing**: `share_plus`, `url_launcher`, `app_links`

## Notes

- Material Design 2 (`useMaterial3: false`) with `ColorScheme.fromSeed` and light/dark theme support
- The `Palette` class (`lib/common/palette.dart`) defines the app's color constants
- iOS Podfile uses a prebuilt Firestore framework — update its tag when changing `cloud_firestore` version (noted in pubspec.yaml)
