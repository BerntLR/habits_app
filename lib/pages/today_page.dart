import 'package:flutter/material.dart';
import '../bullpeak/widgets/bp_swipe_actions.dart';
import '../bullpeak/widgets/bp_list_tile.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../services/habit_service.dart';
import '../bullpeak/widgets/bp_empty_state.dart';
import 'habits_page.dart';
import '../bullpeak/widgets/bp_section_header.dart';
import '../bullpeak/tokens.dart';
import '../bullpeak/widgets/bp_card.dart';

class TodayPage extends StatefulWidget {
  final DateTime? initialDate;
  final bool showBackButton;

  const TodayPage({super.key, this.initialDate, this.showBackButton = false});

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

    if (newDate.isAfter(today)) return;

    setState(() {
      _currentDate = newDate;
    });
  }

  String _formatDate(BuildContext context, DateTime date) {
    final today = _normalizeDate(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    if (date == tomorrow) return 'Tomorrow';

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final habitService = context.watch<HabitService>();
    final rawHabits = habitService.habitsForDate(_currentDate);
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
        } catch (_) {}
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    final content = SafeArea(
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
                ? BPEmptyState(
                    title: 'No habits today',
                    message: 'Add habits on the Habits tab.',
                    icon: Icons.checklist_outlined,
                    actionLabel: 'Add habit',
                    onAction: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HabitsPage()),
                      );
                    },
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

    if (!widget.showBackButton) return content;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: content,
    );
  }

  Widget _buildDateHeader(BuildContext context) {
    final today = _normalizeDate(DateTime.now());
    final isToday = _currentDate == today;
    final subtitle = isToday
        ? 'Your habits today'
        : 'Habits for selected date';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BPSectionHeader(
          _formatDate(context, _currentDate),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Previous day',
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeDay(-1),
              ),
              IconButton(
                tooltip: 'Next day',
                icon: const Icon(Icons.chevron_right),
                onPressed: isToday ? null : () => _changeDay(1),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              BPSpacing.l, 0, BPSpacing.l, BPSpacing.s),
          child: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ],
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
    final summaryText = 'Completed $doneCount of $total habits';

    const tipText = 'Tip: Tap a habit to mark it as done. For count habits, use + and -.';

    return BPCard(
      margin: const EdgeInsets.symmetric(horizontal: BPSpacing.l, vertical: 6),
      padding: const EdgeInsets.all(BPSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summaryText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
          const SizedBox(height: 4),
          Text(
            tipText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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

    return BPSwipeActions(
      onDelete: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          useRootNavigator: true,
          builder: (dCtx) => AlertDialog(
            title: const Text('Delete habit'),
            content: Text('Do you want to delete "${habit.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dCtx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dCtx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (!context.mounted) return;

        if (confirmed == true) {
          final service = context.read<HabitService>();
          await service.deleteHabit(habit.id);
          if (context.mounted) {}
        }
      },
      onEdit: () async {
        _editHabit(context);
      },
      child: BPListTile(
        onTap: () => _handleTap(context, service, done),
        leading: done ? Icons.check_circle : Icons.radio_button_unchecked,
        leadingColor: done ? Theme.of(context).colorScheme.primary : null,
        title: habit.name,
        subtitle: habit.type == HabitType.count ? '$count / ${habit.targetValue}' : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (streak > 0) _StreakChip(streak: streak),
            if (habit.type == HabitType.count) ...[
              const SizedBox(width: 4),
              _buildCountControls(context, service, count),
            ],
          ],
        ),
      ),
    );
  }

  void _editHabit(BuildContext context) {
    final nameController = TextEditingController(text: habit.name);
    final targetController = TextEditingController(
      text: habit.type == HabitType.count ? '${habit.targetValue}' : '',
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final bottomInsets = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(
            bottom: bottomInsets,
            left: 16,
            right: 16,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit habit',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (habit.type == HabitType.count)
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Goal per day',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        barrierDismissible: true,
                        useRootNavigator: true,
                        builder: (dCtx) => AlertDialog(
                          title: const Text('Archive habit'),
                          content: Text('Do you want to archive "${habit.name}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dCtx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(dCtx).pop(true),
                              child: const Text('Archive'),
                            ),
                          ],
                        ),
                      );
                      if (!context.mounted) return;

                      if (confirmed == true) {
                        await context.read<HabitService>().archiveHabit(habit.id);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: const Text('Archive'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      int? target;
                      if (habit.type == HabitType.count) {
                        final t = int.tryParse(targetController.text.trim());
                        if (t != null && t > 0) target = t;
                      }

                      await context.read<HabitService>().updateHabitBasic(
                            habit.id,
                            name: name.isEmpty ? null : name,
                            targetValue: target,
                          );

                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _handleTap(BuildContext context, HabitService service, bool done) {
    if (habit.type == HabitType.boolean) {
      service.toggleHabit(habit.id, date);
    } else {
      service.incrementCount(habit.id, date);
    }
  }

  Widget _buildCountControls(BuildContext context, HabitService service, int count) {
    const resetTooltip = 'Reset this day';
    const incTooltip = 'Increase by 1';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          splashRadius: 20,
          tooltip: resetTooltip,
          onPressed: count > 0 ? () => service.resetForDate(habit.id, date) : null,
        ),
        IconButton(
          icon: const Icon(Icons.add),
          splashRadius: 20,
          tooltip: incTooltip,
          onPressed: () => service.incrementCount(habit.id, date),
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
    if (streak <= 3) return Colors.amberAccent.shade200;
    if (streak <= 14) return Colors.deepOrangeAccent;
    return Colors.greenAccent.shade400;
  }
}

