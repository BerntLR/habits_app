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

    final List<Habit> sortedHabits = List<Habit>.from(todaysHabits);

    sortedHabits.sort((a, b) {
      if (a.type == HabitType.boolean && b.type != HabitType.boolean) {
        return -1;
      }
      if (a.type != HabitType.boolean && b.type == HabitType.boolean) {
        return 1;
      }

      if (a.type == HabitType.boolean && b.type == HabitType.boolean) {
        final aDone = service.isHabitDone(a.id, today);
        final bDone = service.isHabitDone(b.id, today);

        if (aDone == bDone) return 0;
        return aDone ? 1 : -1;
      }

      final aCount = service.countForHabit(a.id, today);
      final bCount = service.countForHabit(b.id, today);

      final double aProgress = a.targetValue > 0
          ? (aCount / a.targetValue).clamp(0.0, 1.0)
          : 0.0;
      final double bProgress = b.targetValue > 0
          ? (bCount / b.targetValue).clamp(0.0, 1.0)
          : 0.0;

      return aProgress.compareTo(bProgress);
    });

    double dailyProgress = 0.0;
    int completedHabits = 0;

    if (sortedHabits.isNotEmpty) {
      double sumProgress = 0.0;

      for (final habit in sortedHabits) {
        double p = 0.0;
        if (habit.type == HabitType.boolean) {
          final done = service.isHabitDone(habit.id, today);
          p = done ? 1.0 : 0.0;
        } else {
          final count = service.countForHabit(habit.id, today);
          if (habit.targetValue > 0) {
            p = (count / habit.targetValue).clamp(0.0, 1.0);
          }
        }

        sumProgress += p;
        if (p >= 1.0) {
          completedHabits++;
        }
      }

      dailyProgress = (sumProgress / sortedHabits.length).clamp(0.0, 1.0);
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('I dag'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildDailySummaryCard(
              context: context,
              progress: dailyProgress,
              completed: completedHabits,
              total: sortedHabits.length,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: sortedHabits.length,
                itemBuilder: (context, index) {
                  final habit = sortedHabits[index];
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

                  Color streakColor;
                  if (streak <= 0) {
                    streakColor = Colors.grey;
                  } else if (streak <= 2) {
                    streakColor = Colors.tealAccent;
                  } else if (streak <= 6) {
                    streakColor = Colors.greenAccent;
                  } else {
                    streakColor = Colors.amberAccent;
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    habit.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDone
                                          ? Colors.greenAccent
                                          : null,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.whatshot,
                                      size: 16,
                                      color: streakColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Streak: $streak',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: streakColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
          ],
        ),
      ),
    );
  }
}

Widget _buildDailySummaryCard({
  required BuildContext context,
  required double progress,
  required int completed,
  required int total,
}) {
  if (total == 0) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: const [
              Icon(Icons.info_outline),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ingen vaner for i dag. Legg til vaner under "Vaner".',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final int percent = (progress * 100).round();

  return Padding(
    padding: const EdgeInsets.all(16),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dagens progresjon',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            Text(
              '$percent % fullført',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              '$completed av $total vaner fullført',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    ),
  );
}
