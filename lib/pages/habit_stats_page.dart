import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../services/habit_service.dart';
import 'today_page.dart';

class HabitStatsPage extends StatefulWidget {
  final Habit habit;

  const HabitStatsPage({super.key, required this.habit});

  @override
  State<HabitStatsPage> createState() => _HabitStatsPageState();
}

class _HabitStatsPageState extends State<HabitStatsPage> {
  late DateTime _currentMonth;
  late int _currentYear;
  bool _showYearView = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _currentYear = now.year;
  }

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + delta,
        1,
      );
      _currentYear = _currentMonth.year;
    });
  }

  void _changeYear(int delta) {
    setState(() {
      _currentYear += delta;
    });
  }

  String _monthName(int month) {
    const names = <String>[
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
    return names[month - 1];
  }

  Color _colorForDay({
    required Habit habit,
    required HabitService service,
    required DateTime date,
  }) {
    if (date.month != _currentMonth.month || date.year != _currentMonth.year) {
      return Colors.transparent;
    }

    if (habit.type == HabitType.boolean) {
      final done = service.isHabitDone(habit.id, date);
      if (!done) {
        return Colors.grey.shade900;
      }
      return Colors.greenAccent.shade400;
    } else {
      final value = service.countForHabit(habit.id, date);
      if (value == 0) {
        return Colors.grey.shade900;
      }
      if (habit.targetValue > 0 && value >= habit.targetValue) {
        return Colors.greenAccent.shade400;
      }
      return Colors.amberAccent.withOpacity(0.6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final service = context.watch<HabitService>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(habit.name),
          actions: [
            IconButton(
              icon: Icon(
                _showYearView ? Icons.view_module : Icons.view_list,
              ),
              tooltip: _showYearView ? 'Vis maned' : 'Vis ar',
              onPressed: () {
                setState(() {
                  _showYearView = !_showYearView;
                });
              },
            ),
          ],
        ),
        body: _showYearView
            ? _buildYearView(context, habit, service)
            : _buildMonthView(context, habit, service),
      ),
    );
  }

  Widget _buildMonthView(
    BuildContext context,
    Habit habit,
    HabitService service,
  ) {
    final firstDayOfMonth = _currentMonth;
    final firstWeekday = firstDayOfMonth.weekday; // 1=Mon .. 7=Sun
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;

    final List<Widget> dayCells = [];

    // Ukedags-header
    const weekdayLabels = ['M', 'T', 'O', 'T', 'F', 'L', 'S'];

    dayCells.addAll(
      weekdayLabels
          .map(
            (label) => Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );

    // Tomme celler før 1.
    final leadingEmpty = firstWeekday - 1;
    for (int i = 0; i < leadingEmpty; i++) {
      dayCells.add(const SizedBox.shrink());
    }

    // Dager i måneden
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final color = _colorForDay(
        habit: habit,
        service: service,
        date: date,
      );

      final bool hasActivity =
          color != Colors.transparent && color != Colors.grey.shade900;

      dayCells.add(
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TodayPage(initialDate: date),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: color == Colors.transparent ? Colors.transparent : color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: hasActivity
                    ? Colors.black.withOpacity(0.2)
                    : Colors.grey.shade800,
                width: 0.6,
              ),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 12,
                  color: color == Colors.greenAccent.shade400
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Fyll ut så gridet blir komplett (7 kolonner)
    while (dayCells.length % 7 != 0) {
      dayCells.add(const SizedBox.shrink());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeMonth(-1),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Trykk pa en dag for a apne den',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.count(
              crossAxisCount: 7,
              children: dayCells,
            ),
          ),
        ),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildYearView(
    BuildContext context,
    Habit habit,
    HabitService service,
  ) {
    final List<Widget> monthCards = [];

    for (int month = 1; month <= 12; month++) {
      final DateTime first = DateTime(_currentYear, month, 1);
      final int daysInMonth = DateTime(_currentYear, month + 1, 0).day;

      int activeDays = 0;
      int completedDays = 0;

      for (int day = 1; day <= daysInMonth; day++) {
        final d = DateTime(_currentYear, month, day);

        if (habit.activeWeekdays.isNotEmpty &&
            !habit.activeWeekdays.contains(d.weekday)) {
          continue;
        }

        activeDays++;

        if (habit.type == HabitType.boolean) {
          if (service.isHabitDone(habit.id, d)) {
            completedDays++;
          }
        } else {
          final value = service.countForHabit(habit.id, d);
          if (habit.targetValue > 0 && value >= habit.targetValue) {
            completedDays++;
          }
        }
      }

      double ratio = 0;
      if (activeDays > 0) {
        ratio = completedDays / activeDays;
      }

      Color barColor;
      if (ratio == 0) {
        barColor = Colors.grey.shade800;
      } else if (ratio < 0.5) {
        barColor = Colors.amberAccent;
      } else {
        barColor = Colors.greenAccent.shade400;
      }

      monthCards.add(
        Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    _monthName(month),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8,
                      color: barColor,
                      backgroundColor: Colors.grey.shade900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  activeDays == 0 ? '-' : '${(ratio * 100).round()}%',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final v = details.primaryVelocity;
        if (v == null) return;
        if (v < 0) {
          // swipe venstre => neste ar
          _changeYear(1);
        } else if (v > 0) {
          // swipe hoyre => forrige ar
          _changeYear(-1);
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeYear(-1),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Ar $_currentYear',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeYear(1),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              children: monthCards,
            ),
          ),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    Widget box(Color color) => Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.black.withOpacity(0.2)),
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          box(Colors.grey.shade900),
          const SizedBox(width: 6),
          const Text(
            'Ingen',
            style: TextStyle(fontSize: 11),
          ),
          const SizedBox(width: 12),
          box(Colors.amberAccent.withOpacity(0.6)),
          const SizedBox(width: 6),
          const Text(
            'Delvis',
            style: TextStyle(fontSize: 11),
          ),
          const SizedBox(width: 12),
          box(Colors.greenAccent.shade400),
          const SizedBox(width: 6),
          const Text(
            'Fullfort',
            style: TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
