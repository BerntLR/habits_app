// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabToday => 'Today';

  @override
  String get tabHabits => 'Habits';

  @override
  String get tabStats => 'Stats';

  @override
  String get habitsTitle => 'Habits';

  @override
  String get habitsArchiveButtonTooltip => 'Archive';

  @override
  String get habitsEmptyText => 'No habits yet. Tap + to add one.';

  @override
  String get newHabitTitle => 'New habit';

  @override
  String get editHabitTitle => 'Edit habit';

  @override
  String get fieldNameLabel => 'Name';

  @override
  String get fieldTypeLabel => 'Type';

  @override
  String get targetPerDayLabel => 'Target per day';

  @override
  String get habitTypeBoolean => 'Yes/No';

  @override
  String get habitTypeCount => 'Count';

  @override
  String get booleanHabitSubtitle => 'Complete once per day';

  @override
  String countHabitSubtitle(int target) {
    return '$target per day';
  }

  @override
  String get habitNeedsName => 'Please enter a name.';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get archive => 'Archive';

  @override
  String get buttonArchive => 'Archive';

  @override
  String get archiveHabitTitle => 'Archive habit';

  @override
  String archiveHabitMessage(String name) {
    return 'Do you want to archive \"$name\"?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get deleteHabitTitle => 'Delete habit';

  @override
  String deleteHabitMessage(String name) {
    return 'Do you want to delete \"$name\"?';
  }

  @override
  String get buttonSeeStats => 'See stats';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsNoHabits => 'No habits yet. Add habits under \"Habits\".';

  @override
  String get statsLast7Days => 'This week (last 7 days)';

  @override
  String statsAverage(int percent) {
    return '$percent% average progress';
  }

  @override
  String statsActiveHabits(int count) {
    return '$count active habits';
  }

  @override
  String get statsDaysTitle => 'Days last 7 days';

  @override
  String get statsBestHabits => 'Best habits this week';

  @override
  String get habitStatsShowMonth => 'Show month';

  @override
  String get habitStatsShowYear => 'Show year';

  @override
  String get habitStatsTapDay => 'Tap a day to open it';

  @override
  String habitStatsYearTitle(int year) {
    return 'Year $year';
  }

  @override
  String get legendNone => 'None';

  @override
  String get legendPartial => 'Partial';

  @override
  String get legendFull => 'Completed';
}
