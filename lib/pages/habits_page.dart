import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../services/habit_service.dart';
import 'habit_edit_page.dart';
import 'habit_stats_page.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HabitService>();
    final habits = service.habits;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vaner'),
          centerTitle: true,
        ),
        body: habits.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Ingen vaner enda. Legg til en vane med knappen nederst.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                itemCount: habits.length,
                onReorder: (oldIndex, newIndex) {
                  context
                      .read<HabitService>()
                      .reorderHabits(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  return Card(
                    key: ValueKey(habit.id),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(habit.name),
                      subtitle: Text(
                        habit.type == HabitType.boolean
                            ? 'Ja/Nei vane'
                            : 'Tellende (${habit.targetValue})',
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => HabitStatsPage(habit: habit),
                          ),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.archive_outlined),
                            tooltip: 'Arkiver vane',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title: const Text('Arkiver vane'),
                                    content: Text(
                                      'Vil du arkivere vanen "${habit.name}"?\n\n'
                                      'Den forsvinner fra listen, men historikk beholdes.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop(false);
                                        },
                                        child: const Text('Avbryt'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(ctx).pop(true);
                                        },
                                        child: const Text('Arkiver'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirm == true) {
                                context
                                    .read<HabitService>()
                                    .archiveHabit(habit.id);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      HabitEditPage(existing: habit),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const HabitEditPage(),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Ny vane'),
        ),
      ),
    );
  }
}
