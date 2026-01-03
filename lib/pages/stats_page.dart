import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/habit_service.dart';
import '../models/habit.dart';
import '../l10n/app_localizations.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final service = context.watch<HabitService>();
    final today = DateTime.now();
    final weeklyData = _computeWeeklyData(service, today);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.statsTitle),
        ),
        body: weeklyData.totalHabits == 0
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l.statsNoHabits,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _weeklySummary(context, weeklyData, l),
                    const SizedBox(height: 16),
                    _dailyBars(context, weeklyData, l),
                    const SizedBox(height: 16),
                    _bestHabits(context, weeklyData, l),
                  ],
                ),
              ),
      ),
    );
  }
}

/* ---------- DATA ---------- */

class _DayStat {
  final DateTime date;
  final double progress;
  final bool hasHabits;
  _DayStat(this.date, this.progress, this.hasHabits);
}

class _HabitWeekStat {
  final Habit habit;
  final int completedDays;
  final int activeDays;
  _HabitWeekStat(this.habit, this.completedDays, this.activeDays);

  double get ratio => activeDays == 0 ? 0 : completedDays / activeDays;
}

class _WeeklyData {
  final List<_DayStat> days;
  final List<_HabitWeekStat> habits;
  final double avg;
  final int totalHabits;

  _WeeklyData(this.days, this.habits, this.avg, this.totalHabits);
}

/* ---------- LOGIKK ---------- */

_WeeklyData _computeWeeklyData(HabitService service, DateTime today) {
  final todayN = DateTime(today.year, today.month, today.day);
  final days = <_DayStat>[];
  final habits = service.habits.where((h) => !h.isArchived).toList();

  double sum = 0;
  int used = 0;

  for (int i = 6; i >= 0; i--) {
    final d = todayN.subtract(Duration(days: i));
    final list = service.habitsForDate(d);

    if (list.isEmpty) {
      days.add(_DayStat(d, 0, false));
      continue;
    }

    double daySum = 0;
    for (final h in list) {
      if (h.type == HabitType.boolean) {
        daySum += service.isHabitDone(h.id, d) ? 1 : 0;
      } else {
        final c = service.countForHabit(h.id, d);
        if (h.targetValue > 0) {
          daySum += (c / h.targetValue).clamp(0, 1);
        }
      }
    }

    final p = ((daySum / list.length).clamp(0.0, 1.0) as double);
    days.add(_DayStat(d, p, true));
    sum += p;
    used++;
  }

  final habitStats = <_HabitWeekStat>[];
  for (final h in habits) {
    int done = 0;
    int active = 0;

    for (int i = 0; i < 7; i++) {
      final d = todayN.subtract(Duration(days: i));
      if (h.activeWeekdays.isNotEmpty && !h.activeWeekdays.contains(d.weekday))
        continue;
      active++;
      if (service.isHabitDone(h.id, d)) done++;
    }
    habitStats.add(_HabitWeekStat(h, done, active));
  }

  habitStats.sort((a, b) => b.ratio.compareTo(a.ratio));

  return _WeeklyData(
    days,
    habitStats,
    used == 0 ? 0 : sum / used,
    habits.length,
  );
}

/* ---------- UI ---------- */

Widget _weeklySummary(BuildContext c, _WeeklyData d, AppLocalizations l) {
  final percent = (d.avg * 100).round();
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.statsLast7Days, style: Theme.of(c).textTheme.titleMedium),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: d.avg, minHeight: 10),
        const SizedBox(height: 8),
        Text(l.statsAverage(percent)),
        Text(l.statsActiveHabits(d.totalHabits)),
      ]),
    ),
  );
}

Widget _dailyBars(BuildContext c, _WeeklyData d, AppLocalizations l) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.statsDaysTitle, style: Theme.of(c).textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: d.days.map((e) {
              final p = (e.progress * 100).round();
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('$p%', style: const TextStyle(fontSize: 11)),
                    const SizedBox(height: 4),
                    Container(
                      height: (e.progress * 80) + 4,
                      width: 14,
                      decoration: BoxDecoration(
                        color:
                            e.progress == 0 ? Colors.grey : Colors.tealAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ]),
    ),
  );
}

Widget _bestHabits(BuildContext c, _WeeklyData d, AppLocalizations l) {
  final list = d.habits.where((h) => h.activeDays > 0).take(10).toList();

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.statsBestHabits, style: Theme.of(c).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...list.map((h) {
          final p = (h.ratio * 100).round();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Expanded(child: Text(h.habit.name)),
              Text('${h.completedDays}/${h.activeDays}'),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: LinearProgressIndicator(value: h.ratio),
              ),
              const SizedBox(width: 4),
              Text('$p%'),
            ]),
          );
        }),
      ]),
    ),
  );
}
