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

            double progress = 0.0;

            if (habit.type == HabitType.boolean) {
              progress = isDone ? 1.0 : 0.0;
            } else {
              if (habit.targetValue > 0) {
                progress = (count / habit.targetValue).clamp(0.0, 1.0);
              }
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: InkWell(
                onTap: () {
                  if (habit.type == HabitType.boolean) {
                    service.toggleHabit(habit.id, today);
                  } else {
                    service.incrementCount(habit.id, today);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDone ? Colors.greenAccent : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: Colors.grey.shade800,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 1.0
                              ? Colors.greenAccent
                              : Colors.tealAccent,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (habit.type == HabitType.boolean)
                            Text(
                              isDone ? 'Fullført' : 'Ikke fullført',
                              style: const TextStyle(fontSize: 13),
                            )
                          else
                            Text(
                              '$count / ${habit.targetValue}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          Text(
                            'Streak: $streak',
                            style: TextStyle(
                              fontSize: 13,
                              color: streak > 0
                                  ? Colors.tealAccent
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
