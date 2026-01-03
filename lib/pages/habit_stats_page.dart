import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
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

  static const Color _todayBorderColor = Color(0xFFF58B3B);

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

  String _monthLabel(BuildContext context, int year, int month) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dt = DateTime(year, month, 1);
    return DateFormat('MMM yyyy', locale).format(dt);
  }

  List<String> _weekdayLabels(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final monday = DateTime(2020, 1, 6); // Monday
    final labels = <String>[];
    for (int i = 0; i < 7; i++) {
      final d = monday.add(Duration(days: i));
      final s = DateFormat('E', locale).format(d);
      labels.add(s.isEmpty ? '' : s.characters.first.toUpperCase());
    }
    return labels;
  }

  Color _colorForDayMonth({
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

  Color _colorForDayYear({
    required Habit habit,
    required HabitService service,
    required DateTime date,
  }) {
    if (habit.activeWeekdays.isNotEmpty &&
        !habit.activeWeekdays.contains(date.weekday)) {
      return Colors.grey.shade900;
    }

    if (habit.type == HabitType.boolean) {
      final done = service.isHabitDone(habit.id, date);
      return done ? Colors.greenAccent.shade400 : Colors.grey.shade900;
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
    final l = AppLocalizations.of(context)!;
    final habit = widget.habit;
    final service = context.watch<HabitService>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(habit.name),
          actions: [
            IconButton(
              icon: Icon(_showYearView ? Icons.view_module : Icons.view_list),
              tooltip:
                  _showYearView ? l.habitStatsShowMonth : l.habitStatsShowYear,
              onPressed: () {
                setState(() {
                  _showYearView = !_showYearView;
                });
              },
            ),
          ],
        ),
        body: _showYearView
            ? _buildYearView(context, l, habit, service)
            : _buildMonthView(context, l, habit, service),
      ),
    );
  }

  Widget _buildMonthView(
    BuildContext context,
    AppLocalizations l,
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

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<Widget> dayCells = [];

    final weekdayLabels = _weekdayLabels(context);

    dayCells.addAll(
      weekdayLabels
          .map(
            (label) => Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );

    final leadingEmpty = firstWeekday - 1;
    for (int i = 0; i < leadingEmpty; i++) {
      dayCells.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isToday = DateTime(date.year, date.month, date.day) == today;

      final color = _colorForDayMonth(
        habit: habit,
        service: service,
        date: date,
      );

      final bool hasActivity =
          color != Colors.transparent && color != Colors.grey.shade900;

      final borderColor = isToday
          ? _todayBorderColor
          : hasActivity
              ? Colors.black.withOpacity(0.2)
              : Colors.grey.shade800;

      final borderWidth = isToday ? 1.4 : 0.6;

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
                color: borderColor,
                width: borderWidth,
              ),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
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
                      _monthLabel(
                          context, _currentMonth.year, _currentMonth.month),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.black87,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.habitStatsTapDay,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
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
        const StatusLegend(),
      ],
    );
  }

  Widget _buildYearView(
    BuildContext context,
    AppLocalizations l,
    Habit habit,
    HabitService service,
  ) {
    final List<Widget> monthTiles = [];
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int month = 1; month <= 12; month++) {
      final int daysInMonth = DateTime(_currentYear, month + 1, 0).day;
      final List<Widget> dots = [];

      final bool isCurrentMonth =
          _currentYear == now.year && month == now.month;

      for (int day = 1; day <= daysInMonth; day++) {
        final d = DateTime(_currentYear, month, day);
        final normalized = DateTime(d.year, d.month, d.day);
        final isToday = normalized == today;

        final color = _colorForDayYear(
          habit: habit,
          service: service,
          date: d,
        );

        dots.add(
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: isToday
                  ? Border.all(
                      color: _todayBorderColor,
                      width: 1.5,
                    )
                  : null,
            ),
          ),
        );
      }

      final Color cardColor = isCurrentMonth
          ? theme.colorScheme.secondary.withOpacity(0.12)
          : Colors.white;
      final Color borderColor = isCurrentMonth
          ? theme.colorScheme.secondary
          : Colors.black.withOpacity(0.08);

      final locale = Localizations.localeOf(context).toLanguageTag();
      final monthName =
          DateFormat('MMM', locale).format(DateTime(2020, month, 1));

      monthTiles.add(
        Card(
          margin: const EdgeInsets.all(4),
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: borderColor,
              width: isCurrentMonth ? 1.4 : 0.8,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
            child: Column(
              children: [
                Text(
                  monthName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isCurrentMonth
                        ? theme.colorScheme.primary
                        : theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Center(
                    child: Wrap(
                      spacing: 2,
                      runSpacing: 2,
                      alignment: WrapAlignment.center,
                      children: dots,
                    ),
                  ),
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
          _changeYear(1);
        } else if (v > 0) {
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
                      l.habitStatsYearTitle(_currentYear),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.black87,
                          ),
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
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              children: monthTiles,
            ),
          ),
          const StatusLegend(),
        ],
      ),
    );
  }
}

class StatusLegend extends StatelessWidget {
  const StatusLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final noneColor = Colors.grey.shade900;
    final partialColor = Colors.amberAccent.withOpacity(0.6);
    final fullColor = Colors.greenAccent.shade400;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            LegendItem(color: noneColor, label: l.legendNone),
            LegendItem(color: partialColor, label: l.legendPartial),
            LegendItem(color: fullColor, label: l.legendFull),
          ],
        ),
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({
    super.key,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
