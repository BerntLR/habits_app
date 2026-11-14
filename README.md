# Karos Habits

A simple daily habit tracker from Team BullPeak, built with Flutter for iOS and Android.

## Features

- Yes/no habits and count habits with a daily target
- Choose which weekdays each habit is active
- Streaks, plus month and year statistics
- Archive and reorder habits
- Backup and restore (JSON export and import)
- TipJar (in-app purchase)

Data is stored locally on the device with `shared_preferences`.

## Structure

```
lib/
  main.dart          App, theme, intro and tab navigation
  bullpeak/          Shared BullPeak theme and widgets
  l10n/              Texts (English)
  models/            Habit and HabitEntry
  pages/             Screens
  services/          HabitService, BackupService, TipJarService
test/                Unit tests
```

## Development

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Release: `flutter build ipa` / `flutter build appbundle`.
