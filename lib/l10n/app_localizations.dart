import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nb.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nb')
  ];

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabHabits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get tabHabits;

  /// No description provided for @tabStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get tabStats;

  /// No description provided for @habitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habitsTitle;

  /// No description provided for @habitsArchiveButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get habitsArchiveButtonTooltip;

  /// No description provided for @habitsEmptyText.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first habit.'**
  String get habitsEmptyText;

  /// No description provided for @newHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'New habit'**
  String get newHabitTitle;

  /// No description provided for @editHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get editHabitTitle;

  /// No description provided for @fieldNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldNameLabel;

  /// No description provided for @fieldTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get fieldTypeLabel;

  /// No description provided for @targetPerDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Target per day'**
  String get targetPerDayLabel;

  /// No description provided for @habitTypeBoolean.
  ///
  /// In en, this message translates to:
  /// **'Yes/No'**
  String get habitTypeBoolean;

  /// No description provided for @habitTypeCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get habitTypeCount;

  /// No description provided for @booleanHabitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete once per day'**
  String get booleanHabitSubtitle;

  /// No description provided for @countHabitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{target} per day'**
  String countHabitSubtitle(int target);

  /// No description provided for @habitNeedsName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name.'**
  String get habitNeedsName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @buttonArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get buttonArchive;

  /// No description provided for @archiveHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive habit'**
  String get archiveHabitTitle;

  /// No description provided for @archiveHabitMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to archive \"{name}\"?'**
  String archiveHabitMessage(String name);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete habit'**
  String get deleteHabitTitle;

  /// No description provided for @deleteHabitMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete \"{name}\"?'**
  String deleteHabitMessage(String name);

  /// No description provided for @buttonSeeStats.
  ///
  /// In en, this message translates to:
  /// **'See stats'**
  String get buttonSeeStats;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @statsNoHabits.
  ///
  /// In en, this message translates to:
  /// **'No habits yet. Add habits under \"Habits\".'**
  String get statsNoHabits;

  /// No description provided for @statsLast7Days.
  ///
  /// In en, this message translates to:
  /// **'This week (last 7 days)'**
  String get statsLast7Days;

  /// No description provided for @statsAverage.
  ///
  /// In en, this message translates to:
  /// **'{percent}% average progress'**
  String statsAverage(int percent);

  /// No description provided for @statsActiveHabits.
  ///
  /// In en, this message translates to:
  /// **'{count} active habits'**
  String statsActiveHabits(int count);

  /// No description provided for @statsDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Days last 7 days'**
  String get statsDaysTitle;

  /// No description provided for @statsBestHabits.
  ///
  /// In en, this message translates to:
  /// **'Best habits this week'**
  String get statsBestHabits;

  /// No description provided for @habitStatsShowMonth.
  ///
  /// In en, this message translates to:
  /// **'Show month'**
  String get habitStatsShowMonth;

  /// No description provided for @habitStatsShowYear.
  ///
  /// In en, this message translates to:
  /// **'Show year'**
  String get habitStatsShowYear;

  /// No description provided for @habitStatsTapDay.
  ///
  /// In en, this message translates to:
  /// **'Tap a day to open it'**
  String get habitStatsTapDay;

  /// No description provided for @habitStatsYearTitle.
  ///
  /// In en, this message translates to:
  /// **'Year {year}'**
  String habitStatsYearTitle(int year);

  /// No description provided for @legendNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get legendNone;

  /// No description provided for @legendPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get legendPartial;

  /// No description provided for @legendFull.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get legendFull;

  /// No description provided for @tabInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get tabInfo;

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// No description provided for @dateTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dateTomorrow;

  /// No description provided for @todaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your habits today'**
  String get todaySubtitle;

  /// No description provided for @selectedDateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Habits for selected date'**
  String get selectedDateSubtitle;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

  /// No description provided for @todayEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No habits today'**
  String get todayEmptyTitle;

  /// No description provided for @todayEmptyText.
  ///
  /// In en, this message translates to:
  /// **'Add habits on the Habits tab.'**
  String get todayEmptyText;

  /// No description provided for @addHabit.
  ///
  /// In en, this message translates to:
  /// **'Add habit'**
  String get addHabit;

  /// No description provided for @habitsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No habits yet'**
  String get habitsEmptyTitle;

  /// No description provided for @todaySummary.
  ///
  /// In en, this message translates to:
  /// **'Completed {done} of {total} habits'**
  String todaySummary(int done, int total);

  /// No description provided for @todayTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Tap a habit to mark it as done. For count habits, use + and -.'**
  String get todayTip;

  /// No description provided for @resetDay.
  ///
  /// In en, this message translates to:
  /// **'Reset this day'**
  String get resetDay;

  /// No description provided for @increaseByOne.
  ///
  /// In en, this message translates to:
  /// **'Increase by 1'**
  String get increaseByOne;

  /// No description provided for @archivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Archived habits'**
  String get archivedTitle;

  /// No description provided for @archivedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No archived habits yet.\nArchive a habit from the Habits tab to clean up the list.'**
  String get archivedEmpty;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @habitRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored: {name}'**
  String habitRestored(String name);

  /// No description provided for @habitDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted: {name}'**
  String habitDeleted(String name);

  /// No description provided for @habitArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived: {name}'**
  String habitArchived(String name);

  /// No description provided for @habitSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved: {name}'**
  String habitSaved(String name);

  /// No description provided for @deletePermanentMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" permanently? Its history will be deleted too.'**
  String deletePermanentMessage(String name);

  /// No description provided for @infoIntro.
  ///
  /// In en, this message translates to:
  /// **'Track habits day by day. Review your history in Stats.'**
  String get infoIntro;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupTitle;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get importData;

  /// No description provided for @backupHint.
  ///
  /// In en, this message translates to:
  /// **'Export creates a JSON backup file. Import replaces your current data.'**
  String get backupHint;

  /// No description provided for @importConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace all data?'**
  String get importConfirmTitle;

  /// No description provided for @importConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Importing replaces all habits and history on this phone with the content of the backup file.'**
  String get importConfirmMessage;

  /// No description provided for @importButton.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importButton;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup imported.'**
  String get importSuccess;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the backup file. Nothing was changed.'**
  String get importFailed;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not export the data.'**
  String get exportFailed;

  /// No description provided for @linksTitle.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get linksTitle;

  /// No description provided for @linkLetter.
  ///
  /// In en, this message translates to:
  /// **'Send me a letter'**
  String get linkLetter;

  /// No description provided for @linkWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get linkWebsite;

  /// No description provided for @linkPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get linkPrivacy;

  /// No description provided for @linkSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get linkSupport;

  /// No description provided for @linkMoreApps.
  ///
  /// In en, this message translates to:
  /// **'More from BullPeak'**
  String get linkMoreApps;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support the developer'**
  String get supportTitle;

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Donate {price}'**
  String donate(String price);

  /// No description provided for @tipsChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking if tips are available...'**
  String get tipsChecking;

  /// No description provided for @tipsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Tips are available. Thank you for your support!'**
  String get tipsAvailable;

  /// No description provided for @tipsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Tips are not available right now.'**
  String get tipsUnavailable;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you!'**
  String get thankYou;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get couldNotOpenLink;

  /// No description provided for @couldNotOpenMail.
  ///
  /// In en, this message translates to:
  /// **'Could not open the mail app'**
  String get couldNotOpenMail;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nb'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nb':
      return AppLocalizationsNb();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
