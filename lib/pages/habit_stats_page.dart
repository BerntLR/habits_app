import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../services/habit_service.dart';

class HabitStatsPage extends StatelessWidget {
  final Habit habit;

  const HabitStatsPage({
    super.key,
    required this.habit,
  });

  bool _isActiveOnDate(Habit habit, DateTime date) {
    if (habit.activeWeekdays.isEmpty) return true;
    return habit.activeWeekdays.contains(date.weekday);
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HabitService>();
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    final monthStats = _computeMonthStats(service, habit, currentYear, currentMonth);
    final yearStats = _computeYearStats(service, habit, currentYear);

    return Scaffold(
      appBar: AppBar(
        title: Text('Historikk: ${habit.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthSection(context, monthStats),
            const SizedBox(height: 24),
            _buildYearSection(context, yearStats),
          ],
        ),
      ),
    );
  }

  List<_DayHabitStat> _computeMonthStats(
    HabitService service,
    Habit habit,
    int year,
    int month,
  ) {
    final int daysInMonth = DateUtils.getDaysInMonth(year, month);
    final List<_DayHabitStat> stats = [];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final bool isActive = _isActiveOnDate(habit, date);

      double progress = 0.0;
      bool done = false;

      if (isActive) {
        if (habit.type == HabitType.boolean) {
          done = service.isHabitDone(habit.id, date);
          progress = done ? 1.0 : 0.0;
        } else {
          final count = service.countForHabit(habit.id, date);
          if (habit.targetValue > 0) {
            progress = (count / habit.targetValue).clamp(0.0, 1.0);
          }
          done = progress >= 1.0;
        }
      }

      stats.add(
        _DayHabitStat(
          date: date,
          isActive: isActive,
          progress: progress,
          done: done,
        ),
      );
    }

    return stats;
  }

  List<_MonthHabitStat> _computeYearStats(
    HabitService service,
    Habit habit,
    int year,
  ) {
    final List<_MonthHabitStat> result = [];

    for (int month = 1; month <= 12; month++) {
      final int daysInMonth = DateUtils.getDaysInMonth(year, month);

      int activeDays = 0;
      int completedDays = 0;
      double sumProgress = 0.0;

      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(year, month, day);
        if (!_isActiveOnDate(habit, date)) {
          continue;
        }

        activeDays++;

        double progress = 0.0;
        bool done = false;

        if (habit.type == HabitType.boolean) {
          done = service.isHabitDone(habit.id, date);
          progress = done ? 1.0 : 0.0;
        } else {
          final count = service.countForHabit(habit.id, date);
          if (habit.targetValue > 0) {
            progress = (count / habit.targetValue).clamp(0.0, 1.0);
          }
          done = progress >= 1.0;
        }

        if (done) {
          completedDays++;
        }
        sumProgress += progress;
      }

      double ratio = 0.0;
      if (activeDays > 0) {
        ratio = (sumProgress / activeDays).clamp(0.0, 1.0);
      }

      result.add(
        _MonthHabitStat(
          year: year,
          month: month,
          activeDays: activeDays,
          completedDays: completedDays,
          ratio: ratio,
        ),
      );
    }

    return result;
  }

  Widget _buildMonthSection(
    BuildContext context,
    List<_DayHabitStat> monthStats,
  ) {
    if (monthStats.isEmpty) {
      return const SizedBox.shrink();
    }

    final DateTime anyDate = monthStats.first.date;
    final String title =
        'Denne måneden (${anyDate.month.toString().padLeft(2, '0')}.${anyDate.year})';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: monthStats.map((d) {
                Color bg;
                Color border = Colors.transparent;

                if (!d.isActive) {
                  bg = Colors.grey.shade900;
                  border = Colors.grey.shade800;
                } else if (d.progress >= 1.0) {
                  bg = Colors.greenAccent;
                } else if (d.progress > 0.0) {
                  bg = Colors.tealAccent.withOpacity(0.7);
                } else {
                  bg = Colors.grey.shade700;
                }

                return Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: border,
                      width: border == Colors.transparent ? 0.0 : 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      d.date.day.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        color: d.progress >= 1.0
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            _buildMonthLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthLegend() {
    Widget box(Color color) {
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      );
    }

    return Row(
      children: [
        box(Colors.greenAccent),
        const SizedBox(width: 4),
        const Text('Fullført'),
        const SizedBox(width: 12),
        box(Colors.tealAccent),
        const SizedBox(width: 4),
        const Text('Delvis (for tellende vaner)'),
        const SizedBox(width: 12),
        box(Colors.grey),
        const SizedBox(width: 4),
        const Text('Ingen registrering'),
        const SizedBox(width: 12),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.grey.shade800),
          ),
        ),
        const SizedBox(width: 4),
        const Text('Ikke aktiv dag'),
      ],
    );
  }

  Widget _buildYearSection(
    BuildContext context,
    List<_MonthHabitStat> yearStats,
  ) {
    if (yearStats.isEmpty) {
      return const SizedBox.shrink();
    }

    final int year = yearStats.first.year;
    const monthNames = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mai',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dette året ($year)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Column(
              children: yearStats.map((m) {
                final label = monthNames[m.month - 1];
                final percent = (m.ratio * 100).round();

                if (m.activeDays == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Text(label),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Ingen aktive dager',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(label),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: m.ratio,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$percent%',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${m.completedDays}/${m.activeDays}',
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
}

class _DayHabitStat {
  final DateTime date;
  final bool isActive;
  final double progress;
  final bool done;

  _DayHabitStat({
    required this.date,
    required this.isActive,
    required this.progress,
    required this.done,
  });
}

class _MonthHabitStat {
  final int year;
  final int month;
  final int activeDays;
  final int completedDays;
  final double ratio;

  _MonthHabitStat({
    required this.year,
    required this.month,
    required this.activeDays,
    required this.completedDays,
    required this.ratio,
  });
}
