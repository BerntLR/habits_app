import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../services/habit_service.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _normalize(DateTime.now());
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  bool get _isToday {
    final now = _normalize(DateTime.now());
    return now.year == _selectedDate.year &&
        now.month == _selectedDate.month &&
        now.day == _selectedDate.day;
  }

  void _changeDay(int delta) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: delta));
    });
  }

  String _weekdayName(int weekday) {
    const names = <String>[
      'Man',
      'Tir',
      'Ons',
      'Tor',
      'Fre',
      'Lor',
      'Son',
    ];
    return names[weekday - 1];
  }

  String _dateLabel(DateTime d) {
    return '${_weekdayName(d.weekday)} ${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HabitService>();

    if (!service.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final habits = service.habitsForDate(_selectedDate);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('I dag'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => _changeDay(-1),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _dateLabel(_selectedDate),
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        if (_isToday)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              'Dagens vaner',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => _changeDay(1),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: habits.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Ingen vaner denne dagen.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      itemCount: habits.length,
                      itemBuilder: (context, index) {
                        final habit = habits[index];
                        if (habit.type == HabitType.boolean) {
                          return _buildBooleanHabitCard(context, habit);
                        } else {
                          return _buildCountHabitCard(context, habit);
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooleanHabitCard(BuildContext context, Habit habit) {
    final service = context.watch<HabitService>();
    final done = service.isHabitDone(habit.id, _selectedDate);

    final Color bgColor = done ? Colors.greenAccent : Colors.grey.shade900;
    final Color borderColor =
        done ? Colors.green.shade700 : Colors.grey.shade800;
    final Color textColor = done ? Colors.black : Colors.white;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.read<HabitService>().toggleHabit(habit.id, _selectedDate);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                done
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: done ? Colors.green.shade900 : Colors.white70,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  habit.name,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildStreakChip(context, habit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountHabitCard(BuildContext context, Habit habit) {
    final service = context.watch<HabitService>();
    final current = service.countForHabit(habit.id, _selectedDate);
    final target = habit.targetValue;

    double ratio = 0.0;
    if (target > 0) {
      ratio = (current / target).clamp(0.0, 1.0);
    }

    Color bgColor;
    Color textColor = Colors.white;
    Color borderColor = Colors.grey.shade800;

    if (ratio >= 1.0 && target > 0) {
      bgColor = Colors.greenAccent;
      textColor = Colors.black;
      borderColor = Colors.green.shade700;
    } else if (ratio > 0.0) {
      bgColor = Colors.amberAccent.withOpacity(0.25);
      borderColor = Colors.amber.shade700;
    } else {
      bgColor = Colors.grey.shade900;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.countertops_outlined,
              color: textColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        target > 0 ? '$current / $target' : '$current',
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (target > 0)
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 6,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              tooltip: 'Nullstill for i dag',
              onPressed: () {
                context
                    .read<HabitService>()
                    .resetForDate(habit.id, _selectedDate);
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Ok ett steg',
              onPressed: () {
                context
                    .read<HabitService>()
                    .incrementCount(habit.id, _selectedDate);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakChip(BuildContext context, Habit habit) {
    final service = context.watch<HabitService>();
    final streak = service.streakForHabit(habit.id, _selectedDate);
    if (streak <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_outlined,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '${streak}d',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
