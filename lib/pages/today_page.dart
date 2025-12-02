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
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentDate = _normalizeDate(widget.initialDate ?? now);
  }

  DateTime _normalizeDate(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  void _changeDay(int delta) {
    final newDate = _currentDate.add(Duration(days: delta));
    final today = _normalizeDate(DateTime.now());

    // Ikke gå inn i fremtiden
    if (newDate.isAfter(today)) return;

    setState(() {
      _currentDate = newDate;
    });
  }

  String _formatDate(DateTime date) {
    final today = _normalizeDate(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    if (date == today) return 'I dag';
    if (date == yesterday) return 'I gar';
    if (date == tomorrow) return 'I morgen';

    const months = [
      'januar',
      'februar',
      'mars',
      'april',
      'mai',
      'juni',
      'juli',
      'august',
      'september',
      'oktober',
      'november',
      'desember',
    ];

    return '${date.day}. ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final habitService = context.watch<HabitService>();
    final habits = habitService.habitsForDate(_currentDate);

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildDateHeader(context),
          const SizedBox(height: 8),
          Expanded(
            child: habits.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Ingen vaner for denne dagen.\nLegg til vaner pa Vaner-fanen.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
                    itemCount: habits.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return _TodayHabitTile(
                        habit: habit,
                        date: _currentDate,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context) {
    final today = _normalizeDate(DateTime.now());
    final isToday = _currentDate == today;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeDay(-1),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _formatDate(_currentDate),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isToday ? 'Dine vaner i dag' : 'Vaner for valgt dato',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: isToday ? null : () => _changeDay(1),
          ),
        ],
      ),
    );
  }
}

class _TodayHabitTile extends StatelessWidget {
  final Habit habit;
  final DateTime date;

  const _TodayHabitTile({
    required this.habit,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HabitService>();
    final done = service.isHabitDone(habit.id, date);
    final count = service.countForHabit(habit.id, date);
    final streak = service.streakForHabit(habit.id, date);

    return Card(
      elevation: 1,
      child: InkWell(
        onTap: () {
          _handleTap(context, service, done);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              _buildLeadingCheckbox(context, done),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTexts(context, done, count, streak),
              ),
              if (habit.type == HabitType.count) ...[
                const SizedBox(width: 8),
                _buildCountControls(context, service, count),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(
    BuildContext context,
    HabitService service,
    bool done,
  ) {
    if (habit.type == HabitType.boolean) {
      service.toggleHabit(habit.id, date);
    } else {
      // For telle-vaner: tap pa raden oker antall med 1
      service.incrementCount(habit.id, date);
    }
  }

  Widget _buildLeadingCheckbox(BuildContext context, bool done) {
    if (habit.type == HabitType.boolean) {
      return Checkbox(
        value: done,
        onChanged: (_) {
          final service = context.read<HabitService>();
          service.toggleHabit(habit.id, date);
        },
      );
    } else {
      return Icon(
        done ? Icons.check_circle : Icons.radio_button_unchecked,
        color: done
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).disabledColor,
      );
    }
  }

  Widget _buildTexts(
    BuildContext context,
    bool done,
    int count,
    int streak,
  ) {
    final titleStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
      color: done
          ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
          : Theme.of(context).colorScheme.onSurface,
    );

    final subtitleStyle = TextStyle(
      fontSize: 12,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(habit.name, style: titleStyle),
        const SizedBox(height: 2),
        Row(
          children: [
            if (habit.type == HabitType.count)
              Text(
                '$count / ${habit.targetValue}',
                style: subtitleStyle,
              ),
            if (habit.type == HabitType.count && streak > 0)
              const SizedBox(width: 12),
            if (streak > 0)
              _StreakChip(
                streak: streak,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCountControls(
    BuildContext context,
    HabitService service,
    int count,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          splashRadius: 20,
          onPressed: count > 0
              ? () {
                  // Reset til 0 ved denne datoen
                  service.resetForDate(habit.id, date);
                }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.add),
          splashRadius: 20,
          onPressed: () {
            service.incrementCount(habit.id, date);
          },
        ),
      ],
    );
  }
}

class _StreakChip extends StatefulWidget {
  final int streak;

  const _StreakChip({required this.streak});

  @override
  State<_StreakChip> createState() => _StreakChipState();
}

class _StreakChipState extends State<_StreakChip> {
  double _scale = 1.0;
  int _prevStreak = 0;

  @override
  void initState() {
    super.initState();
    _prevStreak = widget.streak;
  }

  @override
  void didUpdateWidget(covariant _StreakChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.streak > _prevStreak) {
      _animatePop();
      _prevStreak = widget.streak;
    } else {
      _prevStreak = widget.streak;
    }
  }

  void _animatePop() async {
    setState(() {
      _scale = 1.15;
    });
    await Future.delayed(const Duration(milliseconds: 140));
    if (!mounted) return;
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForStreak(context, widget.streak);

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            '${widget.streak}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForStreak(BuildContext context, int streak) {
    final scheme = Theme.of(context).colorScheme;
    if (streak <= 0) return scheme.onSurfaceVariant;
    if (streak <= 3) {
      return Colors.amberAccent.shade200;
    }
    if (streak <= 14) {
      return Colors.deepOrangeAccent;
    }
    return Colors.greenAccent.shade400;
  }
}
