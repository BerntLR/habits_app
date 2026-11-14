import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../services/habit_service.dart';

class ArchivedHabitsPage extends StatelessWidget {
  const ArchivedHabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final habitService = context.watch<HabitService>();

    final allHabits = habitService.habits;
    final archived = allHabits.where((h) => h.isArchived).toList()
      ..sort((a, b) {
        // Sorter alfabetisk som fallback.
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived habits'),
      ),
      body: SafeArea(
        child: archived.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No archived habits yet.\n'
                    'Archive a habit from the Habits tab to clean up the list.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                itemCount: archived.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final habit = archived[index];
                  return _ArchivedHabitTile(habit: habit);
                },
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
    final habitService = context.read<HabitService>();

    String subtitle;
    if (habit.type == HabitType.count) {
      subtitle = 'Telle-vane • mal per dag: ${habit.targetValue}';
    } else {
      subtitle = 'Boolsk vane';
    }

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
              tooltip: 'Restore',
              icon: const Icon(Icons.unarchive_outlined),
              onPressed: () {
                // Vi antar at archiveHabit toggler arkivstatus.
                habitService.archiveHabit(habit.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Vane gjenopprettet: ${habit.name}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            IconButton(
              tooltip: 'Delete habit',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete habit?'),
                        content: Text(
                          'Vil du slette vanen "${habit.name}" permanent?\n'
                          'Historikk for denne vanen vil ogsa forsvinne.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ) ??
                    false;

                if (!ok) return;

                if (!context.mounted) return;

                habitService.deleteHabit(habit.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Vane slettet: ${habit.name}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
