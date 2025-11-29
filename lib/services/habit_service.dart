import 'package:flutter/foundation.dart';

import '../models/habit.dart';

class HabitService extends ChangeNotifier {
  final List<Habit> _habits = [];
  final Map<String, Map<DateTime, HabitEntry>> _entriesByHabit = {};

  List<Habit> get habits => List.unmodifiable(_habits);

  void loadInitialData() {
    if (_habits.isNotEmpty) return;

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

    notifyListeners();
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
    notifyListeners();
  }

  void removeHabit(String habitId) {
    _habits.removeWhere((h) => h.id == habitId);
    _entriesByHabit.remove(habitId);
    notifyListeners();
  }
}
