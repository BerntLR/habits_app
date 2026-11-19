import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../bullpeak/tokens.dart';
import '../bullpeak/widgets/bp_card.dart';
import '../bullpeak/widgets/bp_empty_state.dart';
import '../bullpeak/widgets/bp_list_tile.dart';
import '../bullpeak/widgets/bp_section_header.dart';
import '../bullpeak/widgets/bp_snackbar.dart';
import '../bullpeak/widgets/bp_swipe_actions.dart';
import '../l10n/app_localizations.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/habit_editor_sheet.dart';
import '../widgets/watermark.dart';

class TodayPage extends StatefulWidget {
  final DateTime? initialDate;
  final bool showBackButton;

  const TodayPage({super.key, this.initialDate, this.showBackButton = false});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> with WidgetsBindingObserver {
  late DateTime _currentDate;

  /// The day that counted as "today" when the page last looked. Used to move
  /// along to the new day after midnight.
  late DateTime _knownToday;
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    _knownToday = normalizeDate(DateTime.now());
    _currentDate = normalizeDate(widget.initialDate ?? _knownToday);
    WidgetsBinding.instance.addObserver(this);
    _scheduleMidnightCheck();
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkNewDay();
  }

  void _scheduleMidnightCheck() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(
      nextMidnight.difference(now) + const Duration(seconds: 1),
      _checkNewDay,
    );
  }

  /// If a new day has started and the page was showing "today", show the
  /// new today. A day the user picked on purpose is left alone.
  void _checkNewDay() {
    if (!mounted) return;
    final today = normalizeDate(DateTime.now());
    if (today != _knownToday) {
      setState(() {
        if (_currentDate == _knownToday) _currentDate = today;
        _knownToday = today;
      });
    }
    _scheduleMidnightCheck();
  }

  void _changeDay(int delta) {
    final newDate = DateTime(
      _currentDate.year,
      _currentDate.month,
      _currentDate.day + delta,
    );
    final today = normalizeDate(DateTime.now());

    if (newDate.isAfter(today)) return;

    setState(() {
      _currentDate = newDate;
    });
  }

  String _formatDate(BuildContext context, DateTime date) {
    final today = normalizeDate(DateTime.now());
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final l = AppLocalizations.of(context)!;
    if (date == today) return l.dateToday;
    if (date == yesterday) return l.dateYesterday;

    return DateFormat.yMMMMEEEEd(l.localeName).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final habitService = context.watch<HabitService>();
    // Same order as on the Habits tab (the order the user has chosen).
    final habits = habitService.habitsForDate(_currentDate);

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
                    title: l.todayEmptyTitle,
                    message: l.todayEmptyText,
                    icon: Icons.checklist_outlined,
                    actionLabel: l.addHabit,
                    onAction: () => showHabitEditorSheet(context),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
                    itemCount: habits.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
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

    final body = Stack(children: [const Watermark(), content]);

    if (!widget.showBackButton) return Scaffold(body: body);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: body,
    );
  }

  Widget _buildDateHeader(BuildContext context) {
    final today = normalizeDate(DateTime.now());
    final isToday = _currentDate == today;
    final l = AppLocalizations.of(context)!;
    final subtitle = isToday ? l.todaySubtitle : l.selectedDateSubtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BPSectionHeader(
          _formatDate(context, _currentDate),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: l.previousDay,
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeDay(-1),
              ),
              IconButton(
                tooltip: l.nextDay,
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
    final l = AppLocalizations.of(context)!;
    final summaryText = l.todaySummary(doneCount, total);

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
          const SizedBox(height: 8),
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
    final l = AppLocalizations.of(context)!;
    final service = context.watch<HabitService>();
    final done = service.isHabitDone(habit.id, date);
    final count = service.countForHabit(habit.id, date);
    final streak = service.streakForHabit(habit.id, date);

    return BPSwipeActions(
      key: ValueKey('today_${habit.id}'),
      dismissKey: ValueKey('today_${habit.id}'),
      onDelete: () async {
        final confirmed = await confirmDelete(
          context,
          title: l.deleteHabitTitle,
          message: l.deleteHabitMessage(habit.name),
        );
        if (!confirmed || !context.mounted) return;
        await context.read<HabitService>().deleteHabit(habit.id);
        if (!context.mounted) return;
        BPSnackbar.success(context, l.habitDeleted(habit.name));
      },
      onEdit: () => showHabitEditorSheet(context, habit: habit),
      child: BPCard(
        padding: EdgeInsets.zero,
        child: BPListTile(
          onTap: () => _handleTap(service),
          leading: done ? Icons.check_circle : Icons.radio_button_unchecked,
          leadingColor: done ? Theme.of(context).colorScheme.primary : null,
          title: habit.name,
          subtitle: habit.type == HabitType.count
              ? '$count / ${habit.targetValue}'
              : null,
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
      ),
    );
  }

  void _handleTap(HabitService service) {
    if (habit.type == HabitType.boolean) {
      service.toggleHabit(habit.id, date);
    } else {
      service.incrementCount(habit.id, date);
    }
  }

  Widget _buildCountControls(
      BuildContext context, HabitService service, int count) {
    final l = AppLocalizations.of(context)!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          splashRadius: 20,
          tooltip: l.decreaseByOne,
          onPressed:
              count > 0 ? () => service.decrementCount(habit.id, date) : null,
        ),
        IconButton(
          icon: const Icon(Icons.add),
          splashRadius: 20,
          tooltip: l.increaseByOne,
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
