import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../services/habit_service.dart';

class TodayPage extends StatefulWidget {
  final DateTime? initialDate;

  const TodayPage({super.key, this.initialDate});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  late DateTime _selectedDate;

  // Animasjons-state per vane + dato
  final Map<String, bool> _pulseMap = {};
  final Map<String, bool> _glowMap = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = _normalize(widget.initialDate ?? DateTime.now());
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

  String _cardKeyFor(Habit habit) {
    final d = _selectedDate;
    return '${habit.id}_${d.year}-${d.month}-${d.day}';
  }

  void _triggerPulse(String key) {
    setState(() {
      _pulseMap[key] = true;
    });
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() {
        _pulseMap[key] = false;
      });
    });
  }

  void _triggerGlow(String key) {
    setState(() {
      _glowMap[key] = true;
    });
    Future.delayed(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      setState(() {
        _glowMap[key] = false;
      });
    });
  }

  void jumpToDate(DateTime date) {
    setState(() {
      _selectedDate = _normalize(date);
    });
  }

  double _completionRatioForHabit(
    Habit habit,
    HabitService service,
    DateTime date,
  ) {
    if (habit.type == HabitType.boolean) {
      final done = service.isHabitDone(habit.id, date);
      return done ? 1.0 : 0.0;
    } else {
      final current = service.countForHabit(habit.id, date);
      if (habit.targetValue <= 0) {
        return current > 0 ? 1.0 : 0.0;
      }
      final r = current / habit.targetValue;
      return r.clamp(0.0, 1.0);
    }
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

    final List<Habit> habits =
        List<Habit>.from(service.habitsForDate(_selectedDate));

    // Sorter slik at:
    // - ikke fullforte vaner kommer forst
    // - fullforte nederst
    // - teller-vaner sorteres etter hvor naer man er malet
    habits.sort((a, b) {
      final ra = _completionRatioForHabit(a, service, _selectedDate);
      final rb = _completionRatioForHabit(b, service, _selectedDate);

      final aDone = ra >= 1.0;
      final bDone = rb >= 1.0;

      if (aDone != bDone) {
        // ikke fullfort (false) skal forst
        return aDone ? 1 : -1;
      }

      // Blant ikke-fullforte: lavest ratio forst
      // Blant fullforte: spiller mindre rolle
      return ra.compareTo(rb);
    });

    final int total = habits.length;
    int completed = 0;
    for (final h in habits) {
      final r = _completionRatioForHabit(h, service, _selectedDate);
      if (r >= 1.0) {
        completed++;
      }
    }

    final double dayRatio =
        total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('I dag'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Dato-navigasjon
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
            // Dagens progress
            if (total > 0)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Card(
                  color: Colors.grey.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: Colors.grey.shade800,
                      width: 0.8,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$completed av $total vaner fullfort',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: dayRatio,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
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

    final String keyStr = _cardKeyFor(habit);
    final bool pulsing = _pulseMap[keyStr] ?? false;
    final bool glowing = _glowMap[keyStr] ?? false;

    final Color bgColor = done ? Colors.greenAccent : Colors.grey.shade900;
    final Color borderColor =
        done ? Colors.green.shade700 : Colors.grey.shade800;
    final Color textColor = done ? Colors.black : Colors.white;

    return AnimatedScale(
      scale: pulsing ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: glowing
              ? [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.6),
                    blurRadius: 18,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          color: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor, width: 1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              final service = context.read<HabitService>();
              final wasDone =
                  service.isHabitDone(habit.id, _selectedDate);

              service.toggleHabit(habit.id, _selectedDate);

              if (!wasDone) {
                _triggerPulse(keyStr);
                _triggerGlow(keyStr);
              } else {
                _triggerPulse(keyStr);
              }
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    done
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: done
                        ? Colors.green.shade900
                        : Colors.white70,
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
        ),
      ),
    );
  }

  Widget _buildCountHabitCard(BuildContext context, Habit habit) {
    final service = context.watch<HabitService>();
    final current = service.countForHabit(habit.id, _selectedDate);
    final target = habit.targetValue;

    final String keyStr = _cardKeyFor(habit);
    final bool glowing = _glowMap[keyStr] ?? false;

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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: glowing
            ? [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.6),
                  blurRadius: 18,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 1),
        ),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  final service = context.read<HabitService>();
                  final prev =
                      service.countForHabit(habit.id, _selectedDate);
                  service.incrementCount(habit.id, _selectedDate);

                  if (target > 0) {
                    int newValue = prev + 1;
                    if (newValue > target) {
                      newValue = target;
                    }
                    if (prev < target && newValue >= target) {
                      _triggerGlow(keyStr);
                    }
                  }
                },
              ),
            ],
          ),
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
