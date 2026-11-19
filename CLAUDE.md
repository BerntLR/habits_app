# Karos Habits – notater for Claude

Gjelder i tillegg til `~/Developer/CLAUDE.md` og `_karo_standard`.

- Bundle/pakke-ID `com.bullpeak.karoshabits` (publisert – aldri endre). ASC app 6757344382,
  Play app 4973408320824792832. Tips: `karos_habits_tip_29/59/99`.
- Tekster: gen-l10n (`lib/l10n/app_en.arb` + `app_nb.arb`, `flutter gen-l10n`), ikke `app_strings.dart`.
- Lagring: `shared_preferences` (`habits_v1`, `habit_entries_v1`). Nye felt i `Habit` må være valgfrie
  i `fromMap` (eldre data og backupfiler skal fortsatt lastes). Backup har `app`, `schemaVersion`, `exportedAt`.

## Påminnelser (1.1.0)
- `lib/services/reminder_service.dart` (flutter_local_notifications + timezone). Planlegger
  enkeltvarsler for 7 dager framover (maks 60, iOS-grense 64), hopper over i dag hvis vanen er gjort.
  Planlegges på nytt ved endring av vaner, dagens avkrysninger og når appen åpnes.
- Android: inexact alarm (ingen exact-alarm-tillatelse), kan komme litt sent. Ikon `drawable/ic_notification`.
- iOS: `AppDelegate` setter `UNUserNotificationCenter.delegate`. Tillatelse spørres først når en
  vane får påminnelse.

## Hjemskjerm-widget (1.1.0)
- Dart: `lib/services/home_widget_service.dart` (home_widget). App group `group.com.bullpeak.karoshabits`.
- iOS: eget mål `HabitsWidget` (ios/HabitsWidget, SwiftUI/WidgetKit), lagt til med `xcodeproj`-gem.
  Versjonsnummer hentes fra `Flutter/Generated.xcconfig` via `HabitsWidget.xcconfig`.
  «Embed Foundation Extensions» må ligge før «Thin Binary» (ellers syklus-feil).
- Android: `HabitsWidgetProvider.kt` + `res/layout/habits_widget.xml` + `res/xml/habits_widget_info.xml`.
- Widgeten får antall vaner for de neste 7 dagene, så den viser 0 av N etter midnatt.

## Android-bygg
- `compileSdk = 37` og desugaring (kreves av flutter_local_notifications).
- `androidx.core` er låst til 1.17.0 i `build.gradle.kts`: 1.19 krever Android Gradle Plugin 9.1.

## Testdata i simulatoren
- `defaults write` på `flutter.habits_v1` ble ikke lest av appen (nov. 2026). Legg heller inn
  vaner via appen, eller importer en backupfil.
