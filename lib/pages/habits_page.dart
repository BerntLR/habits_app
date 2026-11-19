import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bullpeak/widgets/bp_card.dart';
import '../bullpeak/widgets/bp_empty_state.dart';
import '../bullpeak/widgets/bp_list_tile.dart';
import '../bullpeak/widgets/bp_snackbar.dart';
import '../bullpeak/widgets/bp_swipe_actions.dart';
import '../l10n/app_localizations.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/habit_editor_sheet.dart';
import '../widgets/watermark.dart';
import 'archived_habits_page.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HabitService>();
    final activeHabits = service.habits.where((h) => !h.isArchived).toList();
    final l = AppLocalizations.of(context)!;

    final content = activeHabits.isEmpty
        ? BPEmptyState(
            icon: Icons.list_alt_outlined,
            title: l.habitsEmptyTitle,
            message: l.habitsEmptyText,
            actionLabel: l.addHabit,
            onAction: () => showHabitEditorSheet(context),
          )
        : ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
            itemCount: activeHabits.length,
            buildDefaultDragHandles: false,
            onReorderItem: (oldIndex, newIndex) {
              context.read<HabitService>().reorderHabits(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final habit = activeHabits[index];
              return Padding(
                key: ValueKey('habit_${habit.id}'),
                padding: const EdgeInsets.only(bottom: 6),
                child: _HabitTile(habit: habit, index: index),
              );
            },
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(l.habitsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: l.habitsArchiveButtonTooltip,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ArchivedHabitsPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(children: [const Watermark(), content]),
      floatingActionButton: FloatingActionButton(
        tooltip: l.addHabit,
        onPressed: () => showHabitEditorSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  const _HabitTile({required this.habit, required this.index});

  final Habit habit;
  final int index;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final parts = <String>[
      habit.type == HabitType.boolean
          ? l.booleanHabitSubtitle
          : l.countHabitSubtitle(habit.targetValue),
      weekdaysText(l, habit.activeWeekdays),
      if (habit.reminderMinutes != null)
        l.reminderAt(formatMinutes(context, habit.reminderMinutes!)),
    ];

    return BPSwipeActions(
      dismissKey: ValueKey('swipe_${habit.id}'),
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
          title: habit.name,
          subtitle: parts.join(' · '),
          trailing: ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.drag_handle),
            ),
          ),
          onTap: () => showHabitEditorSheet(context, habit: habit),
        ),
      ),
    );
  }
}
