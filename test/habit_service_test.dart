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

    expect(service.streakForHabit(habit.id, today, now: today), 3);
  });

  test('today not done yet keeps the streak from yesterday', () async {
    final habit = await add('Read');
    final today = DateTime(2026, 3, 10);
    for (var i = 1; i <= 5; i++) {
      service.toggleHabit(habit.id, today.subtract(Duration(days: i)));
    }
    expect(service.streakForHabit(habit.id, today, now: today), 5);
    service.toggleHabit(habit.id, today);
    expect(service.streakForHabit(habit.id, today, now: today), 6);
    // A past day that was missed still breaks the streak.
    expect(
      service.streakForHabit(
        habit.id,
        today.add(const Duration(days: 2)),
        now: today.add(const Duration(days: 3)),
      ),
      0,
    );
  });

  test('streak skips days the habit is not active', () async {
    await service.addHabit(
      name: 'Gym',
      type: HabitType.boolean,
      activeWeekdays: {1, 3, 5},
    );
    final habit = service.habits.single;
    // Mon 9, Wed 11, Fri 13 March 2026.
    for (final d in [9, 11, 13]) {
      service.toggleHabit(habit.id, DateTime(2026, 3, d));
    }
    final sat = DateTime(2026, 3, 14);
    expect(service.streakForHabit(habit.id, sat, now: sat), 3);
    expect(service.habitsForDate(sat), isEmpty);
    expect(service.habitsForDate(DateTime(2026, 3, 13)).single.name, 'Gym');
  });

  test('decrementCount lowers by one and removes at zero', () async {
    final habit = await add('Water', type: HabitType.count, target: 3);
    final day = DateTime(2026, 3, 10);
    service.incrementCount(habit.id, day);
    service.incrementCount(habit.id, day);
    service.decrementCount(habit.id, day);
    expect(service.countForHabit(habit.id, day), 1);
    service.decrementCount(habit.id, day);
    expect(service.countForHabit(habit.id, day), 0);
    service.decrementCount(habit.id, day);
    expect(service.countForHabit(habit.id, day), 0);
  });

  test('reminder and weekdays are saved, and old data without them loads',
      () async {
    await service.addHabit(
      name: 'Stretch',
      type: HabitType.boolean,
      activeWeekdays: {2, 4},
      reminderMinutes: 20 * 60 + 30,
    );
    final h = service.habits.single;
    expect(h.reminderMinutes, 1230);
    await service.updateHabit(h.copyWith(clearReminder: true));
    expect(service.habits.single.reminderMinutes, isNull);
    expect(service.habits.single.activeWeekdays, {2, 4});

    final old = Habit.fromMap({
      'id': 'x',
      'name': 'Old',
      'type': 'boolean',
      'targetValue': 1,
      'activeWeekdays': [1, 2, 3, 4, 5, 6, 7],
      'createdAt': '2025-01-01T00:00:00.000',
    });
    expect(old.reminderMinutes, isNull);
    expect(old.isArchived, isFalse);
  });

  test('export has app name, schema version and time', () async {
    await add('Read');
    final data = service.exportData();
    expect(data['app'], 'karos_habits');
    expect(data['schemaVersion'], 2);
    expect(DateTime.tryParse(data['exportedAt'] as String), isNotNull);
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
