import 'package:flutter/material.dart';
import '../bullpeak/widgets/bp_list_tile.dart';
import '../bullpeak/widgets/bp_card.dart';
import '../bullpeak/widgets/bp_swipe_actions.dart';
import 'package:provider/provider.dart';

import '../bullpeak/widgets/bp_button.dart';
import '../bullpeak/widgets/bp_empty_state.dart';
import '../bullpeak/widgets/bp_snackbar.dart';
import '../l10n/app_localizations.dart';
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
  bool _isEnglish(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode.toLowerCase() == 'en';
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HabitService>();
    final allHabits = service.habits;
    final activeHabits = allHabits.where((h) => !h.isArchived).toList();
    final l = AppLocalizations.of(context)!;
    final isEn = _isEnglish(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.habitsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: l.habitsArchiveButtonTooltip,
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
          ? BPEmptyState(
              icon: Icons.list_alt_outlined,
              title: isEn ? 'No habits yet' : 'Ingen vaner enda',
              message: l.habitsEmptyText,
              actionLabel: isEn ? 'Add habit' : 'Legg til vane',
              onAction: () => _showAddHabitSheet(context, l),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
              itemCount: activeHabits.length,
              onReorder: (oldIndex, newIndex) {
                context.read<HabitService>().reorderHabits(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final habit = activeHabits[index];
                return _buildHabitTile(context, habit, l, index);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitSheet(context, l),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHabitTile(
    BuildContext context,
    Habit habit,
    AppLocalizations l,
    int index,
  ) {
    return BPSwipeActions(
      key: ValueKey('habit_${habit.id}'),
      dismissKey: ValueKey('habit_${habit.id}'),
      // BPSwipeActions is locked: LEFT => delete, RIGHT => edit.
      // Here we use LEFT as "delete" (destructive).
      onDelete: () async {
        () async {
          final confirmed = await showDialog<bool>(
            context: context,
            barrierDismissible: true,
            useRootNavigator: true,
            builder: (ctx) => AlertDialog(
              title: Text(l.deleteHabitTitle),
              content: Text(l.deleteHabitMessage(habit.name)),
              actions: [
                BPButton(
                  label: l.cancel,
                  kind: BPButtonKind.tertiary,
                  onPressed: () => Navigator.of(ctx).pop(false),
                ),
                BPButton(
                  label: l.delete,
                  kind: BPButtonKind.primary,
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            
            await context.read<HabitService>().deleteHabit(habit.id);
            if (context.mounted) {
              BPSnackbar.success(context, '${l.delete}: ${habit.name}');
            }
          }
        }();
      },
      onEdit: () => _showEditHabitSheet(context, habit, l),
      child: BPCard(
        padding: EdgeInsets.zero,
        child: BPListTile(
          title: habit.name,
          subtitle: habit.type == HabitType.boolean
              ? l.booleanHabitSubtitle
              : l.countHabitSubtitle(habit.targetValue),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l.editHabitTitle,
                onPressed: () => _showEditHabitSheet(context, habit, l),
              ),
            ],
          ),
          onTap: () => _showEditHabitSheet(context, habit, l),
        ),
      ),
    );
  }

Widget _buildHabitSubtitle(Habit habit, AppLocalizations l) {
    if (habit.type == HabitType.boolean) {
      return Text(l.booleanHabitSubtitle);
    }
    return Text(l.countHabitSubtitle(habit.targetValue));
  }

  Future<void> _showAddHabitSheet(
    BuildContext context,
    AppLocalizations l,
  ) async {
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
                  Text(l.newHabitTitle, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l.fieldNameLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<HabitType>(
                          value: selectedType,
                          decoration: InputDecoration(
                            labelText: l.fieldTypeLabel,
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: HabitType.boolean,
                              child: Text(l.habitTypeBoolean),
                            ),
                            DropdownMenuItem(
                              value: HabitType.count,
                              child: Text(l.habitTypeCount),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setModalState(() {
                              selectedType = value;
                            });
                            if (value == HabitType.count) {
                              Future.delayed(const Duration(milliseconds: 80), () {
                                if (targetFocusNode.canRequestFocus) {
                                  FocusScope.of(ctx).requestFocus(targetFocusNode);
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
                          decoration: InputDecoration(
                            labelText: l.targetPerDayLabel,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      BPButton(
                        label: l.cancel,
                        kind: BPButtonKind.tertiary,
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                      const SizedBox(width: 8),
                      BPButton(
                        label: l.save,
                        kind: BPButtonKind.primary,
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            if (context.mounted) {
                              BPSnackbar.error(context, l.habitNeedsName);
                            }
                            return;
                          }

                          int? target;
                          if (selectedType == HabitType.count) {
                            final t = int.tryParse(targetController.text.trim());
                            target = (t == null || t <= 0) ? 1 : t;
                          }

                          await context.read<HabitService>().addHabit(
                                name: name,
                                type: selectedType,
                                targetValue: target,
                              );

                          if (context.mounted) {
                            Navigator.of(ctx).pop();
                            BPSnackbar.success(context, '${l.save}: $name');
                          }
                        },
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
    AppLocalizations l,
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
              Text(l.editHabitTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l.fieldNameLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (habit.type == HabitType.count)
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l.targetPerDayLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.bar_chart),
                      label: Text(l.buttonSeeStats),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => HabitStatsPage(habit: habit),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      BPButton(
                        label: l.delete,
                        kind: BPButtonKind.destructive,
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            barrierDismissible: true,
                            useRootNavigator: true,
                            builder: (dCtx) => AlertDialog(
                              title: Text(l.deleteHabitTitle),
                              content: Text(l.deleteHabitMessage(habit.name)),
                              actions: [
                                BPButton(
                                  label: l.cancel,
                                  kind: BPButtonKind.tertiary,
                                  onPressed: () => Navigator.of(dCtx).pop(false),
                                ),
                                BPButton(
                                  label: l.delete,
                                  kind: BPButtonKind.destructive,
                                  onPressed: () => Navigator.of(dCtx).pop(true),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            
            await context.read<HabitService>().archiveHabit(habit.id);
                            if (context.mounted) {
                              Navigator.of(ctx).pop();
                              BPSnackbar.success(context, '${l.delete}: ${habit.name}');
                            }
                          }
                        },
                      ),
                      BPButton(
                        label: l.buttonArchive,
                        kind: BPButtonKind.secondary,
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            barrierDismissible: true,
                            useRootNavigator: true,
                            builder: (dCtx) => AlertDialog(
                              title: Text(l.archiveHabitTitle),
                              content: Text(l.archiveHabitMessage(habit.name)),
                              actions: [
                                BPButton(
                                  label: l.cancel,
                                  kind: BPButtonKind.tertiary,
                                  onPressed: () => Navigator.of(dCtx).pop(false),
                                ),
                                BPButton(
                                  label: l.archive,
                                  kind: BPButtonKind.primary,
                                  onPressed: () => Navigator.of(dCtx).pop(true),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            
            await context.read<HabitService>().archiveHabit(habit.id);
                            if (context.mounted) {
                              Navigator.of(ctx).pop();
                              BPSnackbar.success(context, '${l.archive}: ${habit.name}');
                            }
                          }
                        },
                      ),
                      BPButton(
                        label: l.save,
                        kind: BPButtonKind.primary,
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
                            Navigator.of(ctx).pop();
                            BPSnackbar.success(context, l.save);
                          }
                        },
                      ),
                    ],
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
