import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../services/habit_service.dart';
import 'archived_habits_page.dart';
import 'habit_stats_page.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  @override
  Widget build(BuildContext context) {
    final service = context.watch<HabitService>();
    final allHabits = service.habits;
    final activeHabits = allHabits.where((h) => !h.isArchived).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: 'Arkiverte vaner',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ArchivedHabitsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: activeHabits.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Ingen vaner enda.\nTrykk pa + for a legge til.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
              itemCount: activeHabits.length,
              onReorder: (oldIndex, newIndex) {
                context.read<HabitService>().reorderHabits(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final habit = activeHabits[index];
                return _buildHabitTile(context, habit);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHabitTile(BuildContext context, Habit habit) {
    return Dismissible(
      key: ValueKey(habit.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.orange.shade700,
        child: const Icon(
          Icons.archive_outlined,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Arkiver vane'),
            content: Text(
              'Vil du arkivere "${habit.name}"?\nDu mister den fra lister, men historikken beholdes.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Avbryt'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Arkiver'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await context.read<HabitService>().archiveHabit(habit.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Vane arkivert: ${habit.name}'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
          return true;
        }
        return false;
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        title: Text(
          habit.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: _buildHabitSubtitle(habit),
        leading: const Icon(Icons.drag_handle),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Rediger',
          onPressed: () => _showEditHabitSheet(context, habit),
        ),
        onTap: () => _showEditHabitSheet(context, habit),
      ),
    );
  }

  Widget _buildHabitSubtitle(Habit habit) {
    if (habit.type == HabitType.boolean) {
      return const Text(
        'Boolean-vane',
        style: TextStyle(fontSize: 12),
      );
    } else {
      return Text(
        'Mal: ${habit.targetValue} per dag',
        style: const TextStyle(fontSize: 12),
      );
    }
  }

  Future<void> _showAddHabitSheet(BuildContext context) async {
    final nameController = TextEditingController();
    final targetController = TextEditingController(text: '1');
    final targetFocusNode = FocusNode();
    HabitType selectedType = HabitType.boolean;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final bottomInsets = MediaQuery.of(ctx).viewInsets.bottom;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
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
                    'Ny vane',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Navn',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<HabitType>(
                          value: selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: HabitType.boolean,
                              child: Text('Boolean (av/pa)'),
                            ),
                            DropdownMenuItem(
                              value: HabitType.count,
                              child: Text('Telle-vane'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setModalState(() {
                              selectedType = value;
                            });
                            if (value == HabitType.count) {
                              Future.delayed(const Duration(milliseconds: 80),
                                  () {
                                if (targetFocusNode.canRequestFocus) {
                                  FocusScope.of(ctx)
                                      .requestFocus(targetFocusNode);
                                }
                              });
                            } else {
                              FocusScope.of(ctx).unfocus();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: targetController,
                          focusNode: targetFocusNode,
                          enabled: selectedType == HabitType.count,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Mal per dag',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Avbryt'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Vane trenger et navn.'),
                              ),
                            );
                            return;
                          }

                          int? target;
                          if (selectedType == HabitType.count) {
                            final t =
                                int.tryParse(targetController.text.trim());
                            target = (t == null || t <= 0) ? 1 : t;
                          }

                          await context.read<HabitService>().addHabit(
                                name: name,
                                type: selectedType,
                                targetValue: target,
                              );

                          if (context.mounted) {
                            Navigator.of(ctx).pop();
                          }
                        },
                        child: const Text('Lagre'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showEditHabitSheet(
    BuildContext context,
    Habit habit,
  ) async {
    final nameController = TextEditingController(text: habit.name);
    final targetController = TextEditingController(
      text: habit.type == HabitType.count ? '${habit.targetValue}' : '',
    );

    await showModalBottomSheet<void>(
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
                'Rediger vane',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Navn',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (habit.type == HabitType.count)
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Mal per dag',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('Se statistikk'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HabitStatsPage(habit: habit),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dCtx) => AlertDialog(
                          title: const Text('Slett vane'),
                          content: Text(
                            'Er du sikker pa at du vil slette "${habit.name}"?\nHistorikk slettes ogsa.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dCtx).pop(false),
                              child: const Text('Avbryt'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(dCtx).pop(true),
                              child: const Text('Slett'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await context
                            .read<HabitService>()
                            .deleteHabit(habit.id);
                        if (context.mounted) {
                          Navigator.of(ctx).pop();
                        }
                      }
                    },
                    child: const Text(
                      'Slett',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      await context
                          .read<HabitService>()
                          .archiveHabit(habit.id);
                      if (context.mounted) {
                        Navigator.of(ctx).pop();
                      }
                    },
                    child: const Text('Arkiver'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      int? target;
                      if (habit.type == HabitType.count) {
                        final t =
                            int.tryParse(targetController.text.trim());
                        if (t != null && t > 0) {
                          target = t;
                        }
                      }

                      await context.read<HabitService>().updateHabitBasic(
                            habit.id,
                            name: name.isEmpty ? null : name,
                            targetValue: target,
                          );

                      if (context.mounted) {
                        Navigator.of(ctx).pop();
                      }
                    },
                    child: const Text('Lagre'),
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
}
