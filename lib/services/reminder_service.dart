import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_locale.dart';
import '../l10n/app_localizations.dart';
import '../models/habit.dart';
import 'habit_service.dart';

/// Local reminders for habits.
///
/// Instead of repeating notifications, one notification per habit and day is
/// planned for the next [_daysAhead] days. That way today's reminder can be
/// skipped when the habit is already done. Everything is planned again each
/// time the habits or today's entries change, and when the app starts.
class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  static const int _daysAhead = 7;

  /// iOS keeps at most 64 pending notifications per app.
  static const int _maxPending = 60;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;
  Timer? _debounce;

  bool get _supported => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  Future<void> init() async {
    if (_ready || !_supported) return;
    try {
      tzdata.initializeTimeZones();
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Unknown zone: keep UTC rather than failing.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  /// Asks for permission to show notifications. Returns true if allowed.
  Future<bool> requestPermission() async {
    if (!_supported) return false;
    await init();
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(
            alert: true,
            sound: true,
            badge: false,
          ) ??
          false;
    }
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  /// Plans the reminders again, a moment after the last change.
  void scheduleSoon(HabitService service) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      reschedule(service);
    });
  }

  Future<void> reschedule(HabitService service) async {
    if (!_supported) return;
    await init();

    final withReminder = service.habits
        .where((h) => !h.isArchived && h.reminderMinutes != null)
        .toList();

    await _plugin.cancelAll();
    if (withReminder.isEmpty) return;

    final l = lookupAppLocalizations(
      resolveAppLocale(
        PlatformDispatcher.instance.locale,
        AppLocalizations.supportedLocales,
      ),
    );
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'habit_reminders',
        'Reminders',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    final now = tz.TZDateTime.now(tz.local);
    var id = 0;
    for (var offset = 0; offset < _daysAhead; offset++) {
      final day = DateTime(now.year, now.month, now.day + offset);
      for (final habit in withReminder) {
        if (id >= _maxPending) return;
        if (!_activeOn(habit, day)) continue;
        if (offset == 0 && service.isHabitDone(habit.id, day)) continue;

        final minutes = habit.reminderMinutes!;
        final when = tz.TZDateTime(
          tz.local,
          day.year,
          day.month,
          day.day,
          minutes ~/ 60,
          minutes % 60,
        );
        if (!when.isAfter(now)) continue;

        await _plugin.zonedSchedule(
          id: id++,
          scheduledDate: when,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          body: l.reminderBody(habit.name),
        );
      }
    }
  }

  bool _activeOn(Habit habit, DateTime day) =>
      habit.activeWeekdays.isEmpty ||
      habit.activeWeekdays.contains(day.weekday);
}
