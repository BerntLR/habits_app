import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/habit_service.dart';
import '../models/habit.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HabitService>();
    final today = DateTime.now();

    final weeklyData = _computeWeeklyData(service, today);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Statistikk'),
          centerTitle: true,
        ),
        body: weeklyData.totalHabits == 0
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Ingen vaner enda. Legg til vaner under "Vaner" for å se statistikk.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWeeklySummaryCard(context, weeklyData),
                    const SizedBox(height: 16),
                    _buildDailyBarsCard(context, weeklyData),
                    const SizedBox(height: 16),
                    _buildBestHabitsCard(context, weeklyData),
                  ],
                ),
              ),
      ),
    );
  }
}

class _DayStat {
  final DateTime date;
  final double progress; // 0.0 - 1.0
  final bool hasHabits;

  _DayStat({
    required this.date,
    required this.progress,
    required this.hasHabits,
  });
}

class _HabitWeekStat {
  final Habit habit;
  final int completedDays; // antall dager siste 7 der den er fullført
  final int activeDays; // antall dager den var aktiv

  _HabitWeekStat({
    required this.habit,
    required this.completedDays,
    required this.activeDays,
  });

  double get ratio {
    if (activeDays == 0) return 0.0;
    return completedDays / activeDays;
  }
}

class _WeeklyData {
  final List<_DayStat> dayStats;
  final List<_HabitWeekStat> habitStats;
  final double averageProgress; // 0.0 - 1.0
  final int totalHabits;

  _WeeklyData({
    required this.dayStats,
    required this.habitStats,
    required this.averageProgress,
    required this.totalHabits,
  });
}

_WeeklyData _computeWeeklyData(HabitService service, DateTime today) {
  final DateTime todayNorm =
      DateTime(today.year, today.month, today.day);

  final List<_DayStat> dayStats = [];
  final habits = service.habits.where((h) => !h.isArchived).toList();

  double sumProgressForAverage = 0.0;
  int daysWithHabits = 0;

  for (int i = 6; i >= 0; i--) {
    final date = todayNorm.subtract(Duration(days: i));
    final habitsForDate = service.habitsForDate(date);

    bool hasHabits = habitsForDate.isNotEmpty;
    double dayProgress = 0.0;

    if (hasHabits) {
      double sum = 0.0;
      for (final habit in habitsForDate) {
        double p = 0.0;
        if (habit.type == HabitType.boolean) {
          final done = service.isHabitDone(habit.id, date);
          p = done ? 1.0 : 0.0;
        } else {
          final count = service.countForHabit(habit.id, date);
          if (habit.targetValue > 0) {
            p = (count / habit.targetValue).clamp(0.0, 1.0);
          }
        }
        sum += p;
      }
      dayProgress = (sum / habitsForDate.length).clamp(0.0, 1.0);
      sumProgressForAverage += dayProgress;
      daysWithHabits++;
    }

    dayStats.add(
      _DayStat(
        date: date,
        progress: dayProgress,
        hasHabits: hasHabits,
      ),
    );
  }

  final double averageProgress =
      daysWithHabits == 0 ? 0.0 : (sumProgressForAverage / daysWithHabits);

  final List<_HabitWeekStat> habitStats = [];
  for (final habit in habits) {
    int completedDays = 0;
    int activeDays = 0;

    for (int i = 0; i < 7; i++) {
      final date = todayNorm.subtract(Duration(days: i));
      final weekday = date.weekday;
      if (habit.activeWeekdays.isNotEmpty &&
          !habit.activeWeekdays.contains(weekday)) {
        continue;
      }

      activeDays++;

      final done = service.isHabitDone(habit.id, date);
      if (done) {
        completedDays++;
      }
    }

    habitStats.add(
      _HabitWeekStat(
        habit: habit,
        completedDays: completedDays,
        activeDays: activeDays,
      ),
    );
  }

  habitStats.sort((a, b) {
    if (a.completedDays == b.completedDays) {
      return b.activeDays.compareTo(a.activeDays);
    }
    return b.completedDays.compareTo(a.completedDays);
  });

  return _WeeklyData(
    dayStats: dayStats,
    habitStats: habitStats,
    averageProgress: averageProgress.clamp(0.0, 1.0),
    totalHabits: habits.length,
  );
}

Widget _buildWeeklySummaryCard(
  BuildContext context,
  _WeeklyData data,
) {
  final percent = (data.averageProgress * 100).round();

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Denne uken (siste 7 dager)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: data.averageProgress,
            minHeight: 10,
          ),
          const SizedBox(height: 8),
          Text(
            '$percent % gjennomsnittlig progresjon',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '${data.totalHabits} aktive vaner',
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDailyBarsCard(
  BuildContext context,
  _WeeklyData data,
) {
  final dayStats = data.dayStats;
  final hasAnyDay = dayStats.any((d) => d.hasHabits);

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dager siste 7 dager',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (!hasAnyDay)
            const Text(
              'Ingen registrerte vaner denne uken enda.',
              style: TextStyle(fontSize: 13),
            )
          else
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: dayStats.map((d) {
                  final label =
                      '${d.date.day.toString().padLeft(2, '0')}.${d.date.month.toString().padLeft(2, '0')}';
                  final percent = (d.progress * 100).round();

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$percent%',
                          style: const TextStyle(fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 14,
                              height: (d.progress * 80) + 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: d.progress == 0.0
                                    ? Colors.grey.shade700
                                    : Colors.tealAccent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    ),
  );
}

Widget _buildBestHabitsCard(
  BuildContext context,
  _WeeklyData data,
) {
  final stats = data.habitStats
      .where((h) => h.activeDays > 0)
      .toList();

  if (stats.isEmpty) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Beste vaner denne uken',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Ingen aktive vaner denne uken enda.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  final top = stats.take(10).toList();

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Beste vaner denne uken',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Column(
            children: top.map((s) {
              final ratioPercent = (s.ratio * 100).round();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.habit.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${s.completedDays}/${s.activeDays} dager',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: LinearProgressIndicator(
                        value: s.ratio,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$ratioPercent%',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}
