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

## Release

- iOS: `flutter build ipa`
- Android: `flutter build appbundle`

### Android signing (Google Play)

The release build is signed with the upload key from `android/key.properties`.
Without that file it falls back to the debug key, and Google Play will reject the build.
The key and passwords are never stored in git.

1. Create the upload key (once). `keytool` asks for passwords, so keep them in a password manager:
   ```bash
   keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Copy `android/key.properties.example` to `android/key.properties` and fill in the passwords.
3. Back up `upload-keystore.jks` and the passwords outside the Mac. Without them, updates can only be uploaded after a key reset in Play Console.
