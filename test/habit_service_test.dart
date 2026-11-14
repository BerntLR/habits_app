import 'package:flutter_test/flutter_test.dart';
import 'package:habits_app/models/habit.dart';
import 'package:habits_app/services/habit_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late HabitService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    service = HabitService();
    await service.init();
  });

  Future<Habit> add(String name,
      {HabitType type = HabitType.boolean, int target = 1}) async {
    await service.addHabit(
      name: name,
      type: type,
      targetValue: target,
      activeWeekdays: {1, 2, 3, 4, 5, 6, 7},
    );
    return service.habits.firstWhere((h) => h.name == name);
  }

  test('toggleHabit marks and unmarks a yes/no habit', () async {
    final habit = await add('Read');
    final day = DateTime(2026, 3, 10, 14);

    expect(service.isHabitDone(habit.id, day), isFalse);
    service.toggleHabit(habit.id, day);
    expect(service.isHabitDone(habit.id, day), isTrue);
    service.toggleHabit(habit.id, day);
    expect(service.isHabitDone(habit.id, day), isFalse);
  });

  test('count habit is done when the target is reached', () async {
    final habit = await add('Water', type: HabitType.count, target: 2);
    final day = DateTime(2026, 3, 10);

    service.incrementCount(habit.id, day);
    expect(service.countForHabit(habit.id, day), 1);
    expect(service.isHabitDone(habit.id, day), isFalse);

    service.incrementCount(habit.id, day);
    expect(service.isHabitDone(habit.id, day), isTrue);

    service.resetForDate(habit.id, day);
    expect(service.countForHabit(habit.id, day), 0);
  });

  test('streak counts consecutive completed days backwards', () async {
    final habit = await add('Walk');
    final today = DateTime(2026, 3, 10);

    for (var i = 0; i < 3; i++) {
      service.toggleHabit(habit.id, today.subtract(Duration(days: i)));
    }
    // Gap on day 4, then one more completed day.
    service.toggleHabit(habit.id, today.subtract(const Duration(days: 4)));

    expect(service.streakForHabit(habit.id, today), 3);
  });

  test('reorderHabits moves a habit to its final position', () async {
    await add('A');
    await add('B');
    await add('C');

    await service.reorderHabits(0, 2);

    expect(service.habits.map((h) => h.name).toList(), ['B', 'C', 'A']);
  });

  test('export and import round trip keeps habits and entries', () async {
    final habit = await add('Read');
    final day = DateTime(2026, 3, 10);
    service.toggleHabit(habit.id, day);

    final data = service.exportData();

    SharedPreferences.setMockInitialValues({});
    final restored = HabitService();
    await restored.init();
    await restored.importData(data);

    expect(restored.habits.single.name, 'Read');
    expect(restored.isHabitDone(habit.id, day), isTrue);
  });

  test('importData with a broken file leaves current data untouched', () async {
    final habit = await add('Read');
    final day = DateTime(2026, 3, 10);
    service.toggleHabit(habit.id, day);

    await expectLater(
      service.importData({
        'habits': [
          {'id': 'x', 'name': 'Broken'}, // missing required fields
        ],
        'entries': [],
      }),
      throwsFormatException,
    );

    expect(service.habits.single.name, 'Read');
    expect(service.isHabitDone(habit.id, day), isTrue);
  });

  test('archive and restore a habit', () async {
    final habit = await add('Read');

    await service.archiveHabit(habit.id);
    expect(service.habits.single.isArchived, isTrue);

    await service.unarchiveHabit(habit.id);
    expect(service.habits.single.isArchived, isFalse);
  });

  test('deleteHabit removes the habit and its history', () async {
    final habit = await add('Read');
    service.toggleHabit(habit.id, DateTime(2026, 3, 10));

    await service.deleteHabit(habit.id);

    expect(service.habits, isEmpty);
    expect(service.countForHabit(habit.id, DateTime(2026, 3, 10)), 0);
  });
}
