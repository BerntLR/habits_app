// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get tabToday => 'I dag';

  @override
  String get tabHabits => 'Vaner';

  @override
  String get tabStats => 'Statistikk';

  @override
  String get habitsTitle => 'Vaner';

  @override
  String get habitsArchiveButtonTooltip => 'Arkiv';

  @override
  String get habitsEmptyText => 'Ingen vaner enda. Trykk + for å legge til.';

  @override
  String get newHabitTitle => 'Ny vane';

  @override
  String get editHabitTitle => 'Rediger vane';

  @override
  String get fieldNameLabel => 'Navn';

  @override
  String get fieldTypeLabel => 'Type';

  @override
  String get targetPerDayLabel => 'Mål per dag';

  @override
  String get habitTypeBoolean => 'Ja/nei';

  @override
  String get habitTypeCount => 'Telle';

  @override
  String get booleanHabitSubtitle => 'Fullfør en gang per dag';

  @override
  String countHabitSubtitle(int target) {
    return '$target per dag';
  }

  @override
  String get habitNeedsName => 'Skriv inn et navn.';

  @override
  String get cancel => 'Avbryt';

  @override
  String get save => 'Lagre';

  @override
  String get archive => 'Arkiver';

  @override
  String get buttonArchive => 'Arkiver';

  @override
  String get archiveHabitTitle => 'Arkiver vane';

  @override
  String archiveHabitMessage(String name) {
    return 'Vil du arkivere \"$name\"?';
  }

  @override
  String get delete => 'Slett';

  @override
  String get deleteHabitTitle => 'Slett vane';

  @override
  String deleteHabitMessage(String name) {
    return 'Vil du slette \"$name\"?';
  }

  @override
  String get buttonSeeStats => 'Se statistikk';

  @override
  String get statsTitle => 'Statistikk';

  @override
  String get statsNoHabits =>
      'Ingen vaner enda. Legg til vaner under \"Vaner\".';

  @override
  String get statsLast7Days => 'Denne uken (siste 7 dager)';

  @override
  String statsAverage(int percent) {
    return '$percent% gjennomsnittlig progresjon';
  }

  @override
  String statsActiveHabits(int count) {
    return '$count aktive vaner';
  }

  @override
  String get statsDaysTitle => 'Dager siste 7 dager';

  @override
  String get statsBestHabits => 'Beste vaner denne uken';

  @override
  String get habitStatsShowMonth => 'Vis måned';

  @override
  String get habitStatsShowYear => 'Vis år';

  @override
  String get habitStatsTapDay => 'Trykk på en dag for å åpne den';

  @override
  String habitStatsYearTitle(int year) {
    return 'År $year';
  }

  @override
  String get legendNone => 'Ingen';

  @override
  String get legendPartial => 'Delvis';

  @override
  String get legendFull => 'Fullført';
}
