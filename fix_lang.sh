#!/bin/sh
set -e

# 1) Force app locale to English
perl -0777 -i -pe '
s/supportedLocales:\s*AppLocalizations\.supportedLocales,\s*/locale: const Locale(\x27en\x27),\n        supportedLocales: const [Locale(\x27en\x27)],\n        /s
' lib/main.dart

# 2) Today page: replace Norwegian UI strings with English
perl -0777 -i -pe '
s/\bI dag\b/Today/g;
s/\bI gar\b/Yesterday/g;
s/\bI morgen\b/Tomorrow/g;

s/Ingen vaner for denne dagen\\nLegg til vaner pa Vaner-fanen\./No habits for this day.\\nAdd habits on the Habits tab./g;
s/Legg til vaner pa Vaner-fanen\./Add habits on the Habits tab./g;
s/Legg til vane/Add habit/g;
s/Vaner for valgt dato/Habits for selected date/g;
s/Forrige dag/Previous day/g;
s/Neste dag/Next day/g;

s/Fullfort \$doneCount av \$total vaner/Completed \$doneCount of \$total habits/g;
s/Tips: Trykk pa en vane for a markere den som gjort\. For telle-vaner kan du bruke \+ og -\./Tip: Tap a habit to mark it as done. For count habits, use + and -./g;

s/\x27Slett vane\x27/\x27Delete habit\x27/g;
s/\x27Avbryt\x27/\x27Cancel\x27/g;
s/\x27Slett\x27/\x27Delete\x27/g;

s/\x27Rediger vane\x27/\x27Edit habit\x27/g;
s/labelText:\s*\x27Navn\x27/labelText: \x27Name\x27/g;
s/labelText:\s*\x27Maal per dag\x27/labelText: \x27Goal per day\x27/g;

s/\x27Arkiver vane\x27/\x27Archive habit\x27/g;
s/\x27Arkiver\x27/\x27Archive\x27/g;
s/\x27Lagre\x27/\x27Save\x27/g;
' lib/pages/today_page.dart

# 3) Habit edit page
perl -0777 -i -pe '
s/\x271:\s*\x27Man\x27/1: \x27Mon\x27/g;
s/\x272:\s*\x27Tir\x27/2: \x27Tue\x27/g;
s/\x273:\s*\x27Ons\x27/3: \x27Wed\x27/g;
s/\x274:\s*\x27Tor\x27/4: \x27Thu\x27/g;
s/\x275:\s*\x27Fre\x27/5: \x27Fri\x27/g;
s/\x276:\s*\x27Lør\x27/6: \x27Sat\x27/g;
s/\x277:\s*\x27Søn\x27/7: \x27Sun\x27/g;

s/\x27Slett vane\?\x27/\x27Delete habit?\x27/g;
s/\x27Avbryt\x27/\x27Cancel\x27/g;
s/\x27Slett\x27/\x27Delete\x27/g;

s/\x27Rediger vane\x27/\x27Edit habit\x27/g;
s/\x27Ny vane\x27/\x27New habit\x27/g;

s/labelText:\s*\x27Navn på vane\x27/labelText: \x27Habit name\x27/g;
s/\x27Ukedager\x27/\x27Weekdays\x27/g;
s/\x27Lagre\x27/\x27Save\x27/g;
' lib/pages/habit_edit_page.dart

# 4) Archived habits page
perl -0777 -i -pe '
s/\x27Arkiverte vaner\x27/\x27Archived habits\x27/g;
s/Arkiver en vane fra Vaner-fanen for å rydde i listen\./Archive a habit from the Habits tab to clean up the list./g;

s/\x27Gjenopprett\x27/\x27Restore\x27/g;
s/\x27Slett vane\x27/\x27Delete habit\x27/g;
s/\x27Slette vane\?\x27/\x27Delete habit?\x27/g;
s/\x27Avbryt\x27/\x27Cancel\x27/g;
s/\x27Slett\x27/\x27Delete\x27/g;
' lib/pages/archived_habits_page.dart

# 5) Habits page fallback label
perl -0777 -i -pe 's/Legg til vane/Add habit/g' lib/pages/habits_page.dart

# Verify
rg -n "I dag|I gar|I morgen|Forrige|Neste|Slett|Avbryt|Lagre|Rediger|Ny vane|Navn|Maal|Ukedager|Vaner|Tips|Fullfort|Eksporter|Importer|Arkiver|Gjenopprett|Legg til" lib/pages lib/main.dart || true

flutter analyze
