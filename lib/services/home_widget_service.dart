import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../l10n/app_locale.dart';
import '../l10n/app_localizations.dart';
import 'habit_service.dart';
import 'today_summary.dart';

/// Sends today's progress to the home screen widget (iOS + Android).
///
/// The widget gets the number of habits for each of the next 7 days, so it
/// can show "0 of N" after midnight even if the app has not been opened.
class HomeWidgetService {
  HomeWidgetService._();
  static final HomeWidgetService instance = HomeWidgetService._();

  static const String appGroupId = 'group.com.bullpeak.karoshabits';
  static const String iOSName = 'HabitsWidget';
  static const String androidName =
      'com.bullpeak.karoshabits.HabitsWidgetProvider';

  Timer? _debounce;
  bool _groupSet = false;

  bool get _supported => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  void updateSoon(HabitService service) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      update(service);
    });
  }

  Future<void> update(HabitService service) async {
    if (!_supported) return;
    try {
      if (!_groupSet) {
        await HomeWidget.setAppGroupId(appGroupId);
        _groupSet = true;
      }
      final l = lookupAppLocalizations(
        resolveAppLocale(
          PlatformDispatcher.instance.locale,
          AppLocalizations.supportedLocales,
        ),
      );
      final now = DateTime.now();
      final today = summaryFor(service, now);
      final totals = <String, int>{};
      for (var i = 0; i < 7; i++) {
        final d = DateTime(now.year, now.month, now.day + i);
        totals[dateKey(d)] = summaryFor(service, d).total;
      }

      await HomeWidget.saveWidgetData<String>('title', l.dateToday);
      await HomeWidget.saveWidgetData<String>('doneDate', dateKey(now));
      await HomeWidget.saveWidgetData<int>('done', today.done);
      await HomeWidget.saveWidgetData<String>('totals', jsonEncode(totals));
      // Text patterns the native side fills in ("{done} of {total} done").
      await HomeWidget.saveWidgetData<String>(
        'summaryPattern',
        l.widgetSummary(-1, -2).replaceAll('-1', '{done}').replaceAll(
              '-2',
              '{total}',
            ),
      );
      await HomeWidget.saveWidgetData<String>('noHabits', l.widgetNoHabits);
      await HomeWidget.updateWidget(
        iOSName: iOSName,
        qualifiedAndroidName: androidName,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Home widget update failed: $e');
    }
  }
}
