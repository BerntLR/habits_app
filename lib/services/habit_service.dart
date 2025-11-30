import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';

const String _habitsStorageKey = 'habits_v1';
const String _entriesStorageKey = 'habit_entries_v1';

class HabitService extends ChangeNotifier {
  final List<Habit> _habits = [];
  final Map<String, Map<DateTime, HabitEntry>> _entriesByHabit = {};

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  List<Habit> get habits => List.unmodifiable(_habits);

  Future<void> init() async {
    if (_isInitialized) return;

    await _loadFromStorage();

    if (_habits.isEmpty) {
      _seedInitialData();
      await _saveToStorage();
    }

    _isInitialized = true;
    notifyListeners();
  }

  void _seedInitialData() {
    _habits.clear();
    _entriesByHabit.clear();

    _habits.addAll([
      Habit(
        id: 'stretch',
        name: 'Toye 5 min',
        type: HabitType.boolean,
        targetValue: 1,
        activeWeekdays: {1, 2, 3, 4, 5, 6, 7},
      ),
      Habit(
        id: 'water',
        name: 'Drikke 5 glass vann',
        type: HabitType.count,
        targetValue: 5,
        activeWeekdays: {1, 2, 3, 4, 5, 6, 7},
      ),
    ]);
  }

  List<Habit> habitsForDate(DateTime date) {
    final d = normalizeDate(date);
    final weekday = d.weekday;
    return _habits
        .where(
          (h) =>
              !h.isArchived &&
              (h.activeWeekdays.isEmpty || h.activeWeekdays.contains(weekday)),
        )
        .toList()
      ..sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
  }

  HabitEntry? entryForHabitOnDate(String habitId, DateTime date) {
    final d = normalizeDate(date);
    final mapForHabit = _entriesByHabit[habitId];
    if (mapForHabit == null) return null;
    return mapForHabit[d];
  }

  bool isHabitDone(String habitId, DateTime date) {
    final entry = entryForHabitOnDate(habitId, date);
    if (entry == null) return false;
    return entry.value > 0;
  }

  int countForHabit(String habitId, DateTime date) {
    final entry = entryForHabitOnDate(habitId, date);
    return entry?.value ?? 0;
  }

  void toggleHabit(String habitId, DateTime date) {
    final d = normalizeDate(date);
    final habit = _habits.firstWhere((h) => h.id == habitId);
    final mapForHabit = _entriesByHabit.putIfAbsent(habitId, () => {});

    final existing = mapForHabit[d];

    if (habit.type == HabitType.boolean) {
      if (existing == null || existing.value == 0) {
        mapForHabit[d] = HabitEntry(
          habitId: habitId,
          date: d,
          value: 1,
        );
      } else {
        mapForHabit[d] = HabitEntry(
          habitId: habitId,
          date: d,
          value: 0,
        );
      }
    } else {
      if (existing == null || existing.value == 0) {
        mapForHabit[d] = HabitEntry(
          habitId: habitId,
          date: d,
          value: habit.targetValue,
        );
      } else {
        mapForHabit[d] = HabitEntry(
          habitId: habitId,
          date: d,
          value: 0,
        );
      }
    }

    _saveToStorage();
    notifyListeners();
  }

  void setCount(String habitId, DateTime date, int value) {
    final d = normalizeDate(date);
    final mapForHabit = _entriesByHabit.putIfAbsent(habitId, () => {});
    mapForHabit[d] = HabitEntry(
      habitId: habitId,
      date: d,
      value: value,
    );
    _saveToStorage();
    notifyListeners();
  }

  int streakForHabit(String habitId, DateTime today) {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    final mapForHabit = _entriesByHabit[habitId] ?? {};
    int streak = 0;
    DateTime cursor = normalizeDate(today);

    while (true) {
      final weekday = cursor.weekday;
      if (!habit.activeWeekdays.contains(weekday)) {
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }

      final entry = mapForHabit[cursor];
      if (entry == null || entry.value <= 0) {
        break;
      }

      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  void addHabit(Habit habit) {
    _habits.add(habit);
    _saveToStorage();
    notifyListeners();
  }

  void updateHabit(Habit updated) {
    final index = _habits.indexWhere((h) => h.id == updated.id);
    if (index == -1) {
      return;
    }
    _habits[index] = updated;
    _saveToStorage();
    notifyListeners();
  }

  void removeHabit(String habitId) {
    _habits.removeWhere((h) => h.id == habitId);
    _entriesByHabit.remove(habitId);
    _saveToStorage();
    notifyListeners();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    final habitsJson = prefs.getString(_habitsStorageKey);
    if (habitsJson != null && habitsJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(habitsJson) as List<dynamic>;
        _habits
          ..clear()
          ..addAll(
            list.map(
              (e) => Habit.fromMap(
                Map<String, dynamic>.from(e as Map),
              ),
            ),
          );
      } catch (e) {
        if (kDebugMode) {
          print('Failed to load habits: $e');
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
          print('Failed to load habit entries: $e');
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
}
