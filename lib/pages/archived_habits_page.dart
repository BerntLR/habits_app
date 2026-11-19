import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bullpeak/widgets/bp_snackbar.dart';
import '../l10n/app_localizations.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../widgets/confirm_dialog.dart';

class ArchivedHabitsPage extends StatelessWidget {
  const ArchivedHabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final habitService = context.watch<HabitService>();

    final archived = habitService.habits.where((h) => h.isArchived).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        title: Text(l.archivedTitle),
      ),
      body: SafeArea(
        child: archived.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l.archivedEmpty,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                itemCount: archived.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) =>
                    _ArchivedHabitTile(habit: archived[index]),
              ),
      ),
    );
  }
}

class _ArchivedHabitTile extends StatelessWidget {
  final Habit habit;

  const _ArchivedHabitTile({required this.habit});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final habitService = context.read<HabitService>();

    final subtitle = habit.type == HabitType.count
        ? l.countHabitSubtitle(habit.targetValue)
        : l.booleanHabitSubtitle;

    return Card(
      elevation: 1,
      child: ListTile(
        title: Text(
          habit.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: l.restore,
              icon: const Icon(Icons.unarchive_outlined),
              onPressed: () async {
                await habitService.unarchiveHabit(habit.id);
                if (!context.mounted) return;
                BPSnackbar.success(context, l.habitRestored(habit.name));
              },
            ),
            IconButton(
              tooltip: l.deleteHabitTitle,
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await confirmDelete(
                  context,
                  title: l.deleteHabitTitle,
                  message: l.deletePermanentMessage(habit.name),
                );
                if (!ok) return;

                await habitService.deleteHabit(habit.id);
                if (!context.mounted) return;
                BPSnackbar.success(context, l.habitDeleted(habit.name));
              },
            ),
          ],
        ),
      ),
    );
  }
}
