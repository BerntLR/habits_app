import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';

class HabitService extends ChangeNotifier {
  static const String _habitsStorageKey = 'habits_v1';
  static const String _entriesStorageKey = 'habit_entries_v1';

  final List<Habit> _habits = [];
  final Map<String, Map<DateTime, HabitEntry>> _entriesByHabit = {};
  bool _initialized = false;

  /// Bumped every time the list of habits (not the daily entries) changes.
  /// Used to know when reminders must be rescheduled.
  int _habitsRevision = 0;
  int get habitsRevision => _habitsRevision;

  bool get isInitialized => _initialized;

  /// Alle vaner, sortert etter sortOrder og createdAt. Arkiverte nederst.
  List<Habit> get habits {
    final list = List<Habit>.from(_habits);
    list.sort((a, b) {
      if (a.isArchived != b.isArchived) {
        return a.isArchived ? 1 : -1;
      }
      if (a.sortOrder != b.sortOrder) {
        return a.sortOrder.compareTo(b.sortOrder);
      }
      return a.createdAt.compareTo(b.createdAt);
    });
    return list;
  }

  /// Vaner som gjelder for gitt dato (brukes pa Today-skjermen).
  List<Habit> habitsForDate(DateTime date) {
    final normalized = normalizeDate(date);
    final weekday = normalized.weekday;
    final list = _habits.where((h) {
      if (h.isArchived) return false;
      if (h.activeWeekdays.isEmpty) return true;
      return h.activeWeekdays.contains(weekday);
    }).toList();

    list.sort((a, b) {
      if (a.sortOrder != b.sortOrder) {
        return a.sortOrder.compareTo(b.sortOrder);
      }
      return a.createdAt.compareTo(b.createdAt);
    });

    return list;
  }

  Future<void> init() async {
    await _loadFromStorage();
    _initialized = true;
    notifyListeners();
  }

  /// Legg til ny vane.
  Future<void> addHabit({
    required String name,
    required HabitType type,
    int? targetValue,
    Set<int>? activeWeekdays,
    int? reminderMinutes,
  }) async {
    final now = DateTime.now();
    final int nextSortOrder;
    if (_habits.isEmpty) {
      nextSortOrder = 0;
    } else {
      nextSortOrder =
          _habits.map((h) => h.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    }

    final habit = Habit(
      id: 'h_${now.microsecondsSinceEpoch}',
      name: name.trim(),
      type: type,
      targetValue: type == HabitType.boolean ? 1 : (targetValue ?? 1),
      activeWeekdays: activeWeekdays ?? {1, 2, 3, 4, 5, 6, 7},
      isArchived: false,
      createdAt: now,
      sortOrder: nextSortOrder,
      reminderMinutes: reminderMinutes,
    );

    _habits.add(habit);
    _habitsRevision++;
    await _saveToStorage();
    notifyListeners();
  }

  /// Full update of a habit (name, type, target, weekdays).
  Future<void> updateHabit(Habit updated) async {
    final index = _habits.indexWhere((h) => h.id == updated.id);
    if (index == -1) return;

    final old = _habits[index];
    final newName =
        updated.name.trim().isEmpty ? old.name : updated.name.trim();
    final newType = updated.type;
    final newTarget = newType == HabitType.boolean ? 1 : updated.targetValue;
    final newWeekdays = updated.activeWeekdays.isEmpty
        ? {1, 2, 3, 4, 5, 6, 7}
        : updated.activeWeekdays;

    _habits[index] = old.copyWith(
      name: newName,
      type: newType,
      targetValue: newTarget,
      activeWeekdays: newWeekdays,
      reminderMinutes: updated.reminderMinutes,
      clearReminder: updated.reminderMinutes == null,
    );
    _habitsRevision++;

    await _saveToStorage();
    notifyListeners();
  }

  /// Arkiver en vane (fjernes fra lister, men beholdes i historikk).
  Future<void> archiveHabit(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final old = _habits[index];
    _habits[index] = old.copyWith(isArchived: true);
    _habitsRevision++;

    await _saveToStorage();
    notifyListeners();
  }

  /// Restore an archived habit to the active list.
  Future<void> unarchiveHabit(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    _habits[index] = _habits[index].copyWith(isArchived: false);
    _habitsRevision++;

    await _saveToStorage();
    notifyListeners();
  }

  /// Slett en vane helt (inkluderer tilhorende entries).
  Future<void> deleteHabit(String habitId) async {
    _habits.removeWhere((h) => h.id == habitId);
    _entriesByHabit.remove(habitId);
    _habitsRevision++;
    await _saveToStorage();
    notifyListeners();
  }

  /// Reorders the non-archived habits. [newIndex] is the final position of
  /// the moved item (as given by `ReorderableListView.onReorderItem`).
  Future<void> reorderHabits(int oldIndex, int newIndex) async {
    final visible = habits.where((h) => !h.isArchived).toList();
    if (visible.isEmpty) return;

    final moved = visible.removeAt(oldIndex);
    visible.insert(newIndex, moved);

    for (int i = 0; i < visible.length; i++) {
      final h = visible[i];
      final index = _habits.indexWhere((orig) => orig.id == h.id);
      if (index != -1) {
        _habits[index] = _habits[index].copyWith(sortOrder: i);
      }
    }

    await _saveToStorage();
    notifyListeners();
  }

  // -------------- Logging / verdier --------------

  bool isHabitDone(String habitId, DateTime date) {
    final normalized = normalizeDate(date);
    final mapForHabit = _entriesByHabit[habitId];
    if (mapForHabit == null) return false;
    final entry = mapForHabit[normalized];
    if (entry == null) return false;

    final habit = _habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => Habit(
        id: habitId,
        name: '',
        type: HabitType.boolean,
        targetValue: 1,
        activeWeekdays: const {},
        isArchived: false,
        createdAt: normalized,
        sortOrder: 0,
      ),
    );

    if (habit.type == HabitType.boolean) {
      return entry.value > 0;
    } else {
      if (habit.targetValue <= 0) {
        return entry.value > 0;
      }
      return entry.value >= habit.targetValue;
    }
  }

  void toggleHabit(String habitId, DateTime date) {
    final normalized = normalizeDate(date);
    final mapForHabit = _entriesByHabit.putIfAbsent(habitId, () => {});
    final existing = mapForHabit[normalized];

    if (existing == null || existing.value == 0) {
      mapForHabit[normalized] = HabitEntry(
        habitId: habitId,
        date: normalized,
        value: 1,
      );
    } else {
      mapForHabit.remove(normalized);
    }

    _saveToStorage();
    notifyListeners();
  }

  int countForHabit(String habitId, DateTime date) {
    final normalized = normalizeDate(date);
    final mapForHabit = _entriesByHabit[habitId];
    if (mapForHabit == null) return 0;
    final entry = mapForHabit[normalized];
    return entry?.value ?? 0;
  }

  void incrementCount(String habitId, DateTime date) {
    final normalized = normalizeDate(date);
    final mapForHabit = _entriesByHabit.putIfAbsent(habitId, () => {});
    final existing = mapForHabit[normalized];

    if (existing == null) {
      mapForHabit[normalized] = HabitEntry(
        habitId: habitId,
        date: normalized,
        value: 1,
      );
    } else {
      // HabitEntry er immutabel, sa vi lager en ny med oket verdi.
      mapForHabit[normalized] = HabitEntry(
        habitId: existing.habitId,
        date: existing.date,
        value: existing.value + 1,
      );
    }

    _saveToStorage();
    notifyListeners();
  }

  /// Lowers a count habit by one for [date] (removes the entry at zero).
  void decrementCount(String habitId, DateTime date) {
    final normalized = normalizeDate(date);
    final mapForHabit = _entriesByHabit[habitId];
    final existing = mapForHabit?[normalized];
    if (mapForHabit == null || existing == null) return;

    if (existing.value <= 1) {
      mapForHabit.remove(normalized);
      if (mapForHabit.isEmpty) _entriesByHabit.remove(habitId);
    } else {
      mapForHabit[normalized] = HabitEntry(
        habitId: existing.habitId,
        date: existing.date,
        value: existing.value - 1,
      );
    }

    _saveToStorage();
    notifyListeners();
  }

  void resetForDate(String habitId, DateTime date) {
    final normalized = normalizeDate(date);
    final mapForHabit = _entriesByHabit[habitId];
    if (mapForHabit == null) return;

    mapForHabit.remove(normalized);
    if (mapForHabit.isEmpty) {
      _entriesByHabit.remove(habitId);
    }

    _saveToStorage();
    notifyListeners();
  }

  /// Streak backwards from [fromDate] (only active weekdays count).
  /// If [fromDate] is today and the habit is not done yet, today does not
  /// break the streak: the day is not over, so the streak from yesterday is
  /// shown until the user checks it off.
  int streakForHabit(String habitId, DateTime fromDate, {DateTime? now}) {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return 0;

    final habit = _habits[habitIndex];
    int streak = 0;
    DateTime cursor = normalizeDate(fromDate);
    final today = normalizeDate(now ?? DateTime.now());
    final earliest =
        normalizeDate(habit.createdAt).subtract(const Duration(days: 1));

    // Ends at the first missed active day (or, as a guard, year 2000).
    while (!cursor.isBefore(DateTime(2000))) {
      if (habit.activeWeekdays.isNotEmpty &&
          !habit.activeWeekdays.contains(cursor.weekday)) {
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }

      final value = countForHabit(habitId, cursor);
      bool ok;
      if (habit.type == HabitType.boolean) {
        ok = value > 0;
      } else {
        if (habit.targetValue <= 0) {
          ok = value > 0;
        } else {
          ok = value >= habit.targetValue;
        }
      }

      if (!ok) {
        if (cursor == today) {
          cursor = cursor.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }

      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  // -------------- Persistens --------------

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    final habitsJson = prefs.getString(_habitsStorageKey);
    if (habitsJson != null && habitsJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(habitsJson) as List<dynamic>;
        _habits.clear();
        for (final item in list) {
          final map = Map<String, dynamic>.from(item as Map);
          final habit = Habit.fromMap(map);
          _habits.add(habit);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to load habits: $e');
        }
        _habits.clear();
      }
    }

    final entriesJson = prefs.getString(_entriesStorageKey);
    if (entriesJson != null && entriesJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(entriesJson) as List<dynamic>;
        _entriesByHabit.clear();
        for (final item in list) {
          final map = Map<String, dynamic>.from(item as Map);
          final entry = HabitEntry.fromMap(map);
          final normalizedDate = normalizeDate(entry.date);
          final mapForHabit =
              _entriesByHabit.putIfAbsent(entry.habitId, () => {});
          mapForHabit[normalizedDate] = HabitEntry(
            habitId: entry.habitId,
            date: normalizedDate,
            value: entry.value,
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to load habit entries: $e');
        }
        _entriesByHabit.clear();
      }
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    final habitsList = _habits.map((h) => h.toMap()).toList();
    await prefs.setString(_habitsStorageKey, jsonEncode(habitsList));

    final List<Map<String, dynamic>> allEntries = [];
    _entriesByHabit.forEach((habitId, dateMap) {
      for (final entry in dateMap.values) {
        allEntries.add(entry.toMap());
      }
    });
    await prefs.setString(_entriesStorageKey, jsonEncode(allEntries));
  }

  Map<String, dynamic> exportData() {
    return {
      'app': 'karos_habits',
      'schemaVersion': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'habits': _habits.map((h) => h.toMap()).toList(),
      'entries': _entriesByHabit.values
          .expand((m) => m.values)
          .map((e) => e.toMap())
          .toList(),
    };
  }

  /// Replaces all habits and entries with [data] (from [exportData]).
  /// The data is parsed completely first, so a broken file throws a
  /// [FormatException] and leaves the current data untouched.
  Future<void> importData(Map<String, dynamic> data) async {
    final List<Habit> newHabits;
    final Map<String, Map<DateTime, HabitEntry>> newEntries = {};
    try {
      newHabits = (data['habits'] as List)
          .map((h) => Habit.fromMap(Map<String, dynamic>.from(h as Map)))
          .toList();
      for (final e in data['entries'] as List) {
        final entry = HabitEntry.fromMap(Map<String, dynamic>.from(e as Map));
        final date = normalizeDate(entry.date);
        newEntries.putIfAbsent(entry.habitId, () => {})[date] = HabitEntry(
          habitId: entry.habitId,
          date: date,
          value: entry.value,
        );
      }
    } catch (e) {
      throw FormatException('Invalid backup file: $e');
    }

    _habits
      ..clear()
      ..addAll(newHabits);
    _entriesByHabit
      ..clear()
      ..addAll(newEntries);
    _habitsRevision++;

    await _saveToStorage();
    notifyListeners();
  }
}
