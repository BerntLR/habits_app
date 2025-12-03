import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../services/habit_service.dart';
import '../services/backup_service.dart';

class TodayPage extends StatefulWidget {
  final DateTime? initialDate;

  const TodayPage({super.key, this.initialDate});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  late DateTime _currentDate;
  final BackupService _backupService = BackupService();

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

    // Ikke ga inn i fremtiden
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

  Future<void> _showBackupSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.cloud_upload_outlined),
                title: const Text('Eksporter backup'),
                subtitle: const Text('Lagre vaner og historikk til fil'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _backupService.exportBackup(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cloud_download_outlined),
                title: const Text('Importer backup'),
                subtitle: const Text('Gjenopprett fra tidligere fil'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _backupService.importBackup(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitService = context.watch<HabitService>();
    final rawHabits = habitService.habitsForDate(_currentDate);

    // Sortering for Today:
    // 1) Boolean-vaner først
    // 2) Telle-vaner etterpå
    // 3) Innenfor samme type: sortOrder, fall-back pa navn
    final habits = [...rawHabits]..sort((a, b) {
        if (a.type != b.type) {
          if (a.type == HabitType.boolean && b.type == HabitType.count) {
            return -1;
          }
          if (a.type == HabitType.count && b.type == HabitType.boolean) {
            return 1;
          }
        }
        try {
          final ao = a.sortOrder;
          final bo = b.sortOrder;
          if (ao != bo) {
            return ao.compareTo(bo);
          }
        } catch (_) {
          // Hvis sortOrder ikke finnes, ignorer
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildDateHeader(context),
          const SizedBox(height: 4),
          if (habits.isNotEmpty)
            _buildTodaySummary(context, habitService, habits),
          if (habits.isNotEmpty) const SizedBox(height: 4),
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
            icon: const Icon(Icons.backup_outlined),
            onPressed: () => _showBackupSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: isToday ? null : () => _changeDay(1),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(
    BuildContext context,
    HabitService service,
    List<Habit> habits,
  ) {
    final total = habits.length;
    int doneCount = 0;
    for (final h in habits) {
      if (service.isHabitDone(h.id, _currentDate)) {
        doneCount++;
      }
    }
    final progress = total == 0 ? 0.0 : doneCount / total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fullfort $doneCount av $total vaner',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
            ),
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
