import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../services/habit_service.dart';

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
        body: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(habit.name),
                subtitle: Text(
                  habit.type == HabitType.boolean
                      ? 'Ja/Nei vane'
                      : 'Tellende vane (mal: ${habit.targetValue})',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Slett vane?'),
                          content: Text(
                            'Er du sikker på at du vil slette "${habit.name}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Avbryt'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                service.removeHabit(habit.id);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Slett'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await _showAddHabitDialog(context);
          },
          icon: const Icon(Icons.add),
          label: const Text('Ny vane'),
        ),
      ),
    );
  }

  Future<void> _showAddHabitDialog(BuildContext context) async {
    final service = context.read<HabitService>();
    final nameController = TextEditingController();
    HabitType selectedType = HabitType.boolean;
    final targetController = TextEditingController(text: '1');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ny vane'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Navn på vane',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<HabitType>(
                      value: selectedType,
                      items: const [
                        DropdownMenuItem(
                          value: HabitType.boolean,
                          child: Text('Ja/Nei'),
                        ),
                        DropdownMenuItem(
                          value: HabitType.count,
                          child: Text('Antall'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          selectedType = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Type',
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (selectedType == HabitType.count)
                      TextField(
                        controller: targetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText:
                              'Mal (for eksempel 10 minutter eller 5 glass)',
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Avbryt'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    final target = selectedType == HabitType.count
                        ? (int.tryParse(targetController.text) ?? 1)
                        : 1;

                    final newHabit = Habit(
                      id: '${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      type: selectedType,
                      targetValue: target,
                      activeWeekdays: {1, 2, 3, 4, 5, 6, 7},
                    );

                    service.addHabit(newHabit);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Lagre'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
