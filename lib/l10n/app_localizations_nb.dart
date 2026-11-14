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
  String get habitsEmptyText => 'Trykk + for å legge til din første vane.';

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
  String get booleanHabitSubtitle => 'Fullfør én gang per dag';

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
    return 'Vil du arkivere «$name»?';
  }

  @override
  String get delete => 'Slett';

  @override
  String get deleteHabitTitle => 'Slett vane';

  @override
  String deleteHabitMessage(String name) {
    return 'Vil du slette «$name»?';
  }

  @override
  String get buttonSeeStats => 'Se statistikk';

  @override
  String get statsTitle => 'Statistikk';

  @override
  String get statsNoHabits => 'Ingen vaner ennå. Legg til vaner under «Vaner».';

  @override
  String get statsLast7Days => 'Denne uken (siste 7 dager)';

  @override
  String statsAverage(int percent) {
    return '$percent % gjennomsnittlig fremgang';
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

  @override
  String get tabInfo => 'Info';

  @override
  String get dateToday => 'I dag';

  @override
  String get dateYesterday => 'I går';

  @override
  String get dateTomorrow => 'I morgen';

  @override
  String get todaySubtitle => 'Dine vaner i dag';

  @override
  String get selectedDateSubtitle => 'Vaner for valgt dag';

  @override
  String get previousDay => 'Forrige dag';

  @override
  String get nextDay => 'Neste dag';

  @override
  String get todayEmptyTitle => 'Ingen vaner i dag';

  @override
  String get todayEmptyText => 'Legg til vaner i fanen Vaner.';

  @override
  String get addHabit => 'Legg til vane';

  @override
  String get habitsEmptyTitle => 'Ingen vaner ennå';

  @override
  String todaySummary(int done, int total) {
    return 'Fullført $done av $total vaner';
  }

  @override
  String get todayTip =>
      'Tips: Trykk på en vane for å krysse den av. For tellevaner bruker du + og -.';

  @override
  String get resetDay => 'Nullstill denne dagen';

  @override
  String get increaseByOne => 'Øk med 1';

  @override
  String get archivedTitle => 'Arkiverte vaner';

  @override
  String get archivedEmpty =>
      'Ingen arkiverte vaner ennå.\nArkiver en vane i fanen Vaner for å rydde i lista.';

  @override
  String get restore => 'Gjenopprett';

  @override
  String habitRestored(String name) {
    return 'Gjenopprettet: $name';
  }

  @override
  String habitDeleted(String name) {
    return 'Slettet: $name';
  }

  @override
  String habitArchived(String name) {
    return 'Arkivert: $name';
  }

  @override
  String habitSaved(String name) {
    return 'Lagret: $name';
  }

  @override
  String deletePermanentMessage(String name) {
    return 'Vil du slette «$name» for godt? Historikken for vanen slettes også.';
  }

  @override
  String get infoIntro =>
      'Følg vanene dine dag for dag. Se historikken under Statistikk.';

  @override
  String get backupTitle => 'Sikkerhetskopi';

  @override
  String get exportData => 'Eksporter data';

  @override
  String get importData => 'Importer data';

  @override
  String get backupHint =>
      'Eksport lager en JSON-fil med alle data. Import erstatter dataene du har nå.';

  @override
  String get importConfirmTitle => 'Erstatte alle data?';

  @override
  String get importConfirmMessage =>
      'Import erstatter alle vaner og all historikk på denne telefonen med innholdet i backupfila.';

  @override
  String get importButton => 'Importer';

  @override
  String get importSuccess => 'Sikkerhetskopien er importert.';

  @override
  String get importFailed =>
      'Kunne ikke lese backupfila. Ingenting ble endret.';

  @override
  String get exportFailed => 'Kunne ikke eksportere dataene.';

  @override
  String get linksTitle => 'Lenker';

  @override
  String get linkLetter => 'Send meg et brev';

  @override
  String get linkWebsite => 'Nettside';

  @override
  String get linkPrivacy => 'Personvern';

  @override
  String get linkSupport => 'Support';

  @override
  String get linkMoreApps => 'Mer fra BullPeak';

  @override
  String get supportTitle => 'Støtt utvikleren';

  @override
  String donate(String price) {
    return 'Gi $price';
  }

  @override
  String get tipsChecking => 'Sjekker om tips er tilgjengelig ...';

  @override
  String get tipsAvailable => 'Tips er tilgjengelig. Takk for støtten!';

  @override
  String get tipsUnavailable => 'Tips er ikke tilgjengelig akkurat nå.';

  @override
  String get thankYou => 'Tusen takk!';

  @override
  String get couldNotOpenLink => 'Kunne ikke åpne lenken';

  @override
  String get couldNotOpenMail => 'Kunne ikke åpne e-postappen';
}
