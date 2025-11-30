import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/habit_service.dart';
import '../models/habit.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HabitService>();
    final today = DateTime.now();

    final todaysHabits = service.habitsForDate(today);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('I dag'),
          centerTitle: true,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: todaysHabits.length,
          itemBuilder: (context, index) {
            final habit = todaysHabits[index];
            final isDone = service.isHabitDone(habit.id, today);
            final count = service.countForHabit(habit.id, today);
            final streak = service.streakForHabit(habit.id, today);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(
                  habit.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDone ? Colors.greenAccent : null,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (habit.type == HabitType.boolean)
                      Text(isDone ? 'Fullført' : 'Ikke fullført'),
                    if (habit.type == HabitType.count)
                      Text('$count / ${habit.targetValue}'),

                    const SizedBox(height: 4),

                    Text(
                      'Streak: $streak dager',
                      style: TextStyle(
                        color: streak > 0 ? Colors.tealAccent : Colors.grey,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  service.toggleHabit(habit.id, today);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
