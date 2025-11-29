import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../services/habit_service.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HabitService>();
    final today = DateTime.now();
    final habits = service.habitsForDate(today);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('I dag'),
          centerTitle: true,
        ),
        body: habits.isEmpty
            ? const Center(
                child: Text('Ingen vaner i dag enda.'),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  final isDone = service.isHabitDone(habit.id, today);
                  final streak = service.streakForHabit(habit.id, today);
                  final count = service.countForHabit(habit.id, today);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      onTap: () {
                        service.toggleHabit(habit.id, today);
                      },
                      leading: Icon(
                        isDone
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                      ),
                      title: Text(habit.name),
                      subtitle: Row(
                        children: [
                          Text('Streak: $streak dager'),
                          if (habit.type == HabitType.count) ...[
                            const SizedBox(width: 12),
                            Text('I dag: $count / ${habit.targetValue}'),
                          ],
                        ],
                      ),
                      trailing: habit.type == HabitType.count
                          ? IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final controller = TextEditingController(
                                  text: count.toString(),
                                );
                                final newValue = await showDialog<int>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Sett verdi for "${habit.name}"',
                                      ),
                                      content: TextField(
                                        controller: controller,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Antall',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('Avbryt'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            final value =
                                                int.tryParse(controller.text) ??
                                                    0;
                                            Navigator.of(context).pop(value);
                                          },
                                          child: const Text('Lagre'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (newValue != null) {
                                  service.setCount(habit.id, today, newValue);
                                }
                              },
                            )
                          : null,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
