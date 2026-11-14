import 'package:flutter_test/flutter_test.dart';
import 'package:habits_app/models/habit.dart';

void main() {
  test('Habit survives toMap/fromMap round trip', () {
    final habit = Habit(
      id: 'h1',
      name: 'Read',
      type: HabitType.count,
      targetValue: 3,
      activeWeekdays: {1, 3, 5},
      isArchived: true,
      createdAt: DateTime(2026, 1, 2, 3, 4),
      sortOrder: 7,
    );

    final copy = Habit.fromMap(habit.toMap());

    expect(copy.id, 'h1');
    expect(copy.name, 'Read');
    expect(copy.type, HabitType.count);
    expect(copy.targetValue, 3);
    expect(copy.activeWeekdays, {1, 3, 5});
    expect(copy.isArchived, isTrue);
    expect(copy.createdAt, DateTime(2026, 1, 2, 3, 4));
    expect(copy.sortOrder, 7);
  });

  test('fromMap uses defaults for older data without new fields', () {
    final habit = Habit.fromMap({
      'id': 'h2',
      'name': 'Walk',
      'type': 'boolean',
      'targetValue': 1,
      'activeWeekdays': [1, 2],
      'createdAt': '2026-01-01T00:00:00.000',
    });

    expect(habit.isArchived, isFalse);
    expect(habit.sortOrder, 0);
  });

  test('normalizeDate strips the time of day', () {
    expect(normalizeDate(DateTime(2026, 5, 6, 23, 59)), DateTime(2026, 5, 6));
  });
}
