import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../bullpeak/widgets/bp_snackbar.dart';
import '../l10n/app_localizations.dart';
import '../models/habit.dart';
import '../pages/habit_stats_page.dart';
import '../services/habit_service.dart';
import '../services/reminder_service.dart';
import 'confirm_dialog.dart';

/// Opens the sheet for a new habit ([habit] == null) or for editing one.
Future<void> showHabitEditorSheet(BuildContext context, {Habit? habit}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => _HabitEditorSheet(habit: habit, hostContext: context),
  );
}

/// Short weekday names (Mon..Sun) in the app language, index 1..7.
String weekdayShort(String locale, int weekday) {
  // 1 Jan 2024 was a Monday.
  final date = DateTime(2024, 1, weekday);
  final name = DateFormat.E(locale).format(date);
  // Norwegian short names end with a dot ("man."): drop it in the chips.
  return name.endsWith('.') ? name.substring(0, name.length - 1) : name;
}

/// "Every day" or e.g. "Mon, Wed, Fri".
String weekdaysText(AppLocalizations l, Set<int> days) {
  if (days.isEmpty || days.length == 7) return l.everyDay;
  final sorted = days.toList()..sort();
  return sorted.map((d) => weekdayShort(l.localeName, d)).join(', ');
}

String formatMinutes(BuildContext context, int minutes) {
  final t = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  return MaterialLocalizations.of(context).formatTimeOfDay(
    t,
    alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
  );
}

class _HabitEditorSheet extends StatefulWidget {
  const _HabitEditorSheet({required this.habit, required this.hostContext});

  final Habit? habit;

  /// Context of the page that opened the sheet (used for snackbars and
  /// navigation after the sheet is closed).
  final BuildContext hostContext;

  @override
  State<_HabitEditorSheet> createState() => _HabitEditorSheetState();
}

class _HabitEditorSheetState extends State<_HabitEditorSheet> {
  late final TextEditingController _name;
  late final TextEditingController _target;
  final FocusNode _targetFocus = FocusNode();
  late HabitType _type;
  late Set<int> _days;
  int? _reminder;

  bool get _isNew => widget.habit == null;

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _name = TextEditingController(text: h?.name ?? '');
    _type = h?.type ?? HabitType.boolean;
    _target = TextEditingController(
      text: h != null && h.type == HabitType.count ? '${h.targetValue}' : '1',
    );
    _days = {...(h?.activeWeekdays ?? const <int>{})};
    if (_days.isEmpty) _days = {1, 2, 3, 4, 5, 6, 7};
    _reminder = h?.reminderMinutes;
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _targetFocus.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    FocusScope.of(context).unfocus();
    final initial = _reminder ?? 20 * 60;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial ~/ 60, minute: initial % 60),
    );
    // The dialog gives focus back to the name field; keep the keyboard away.
    if (mounted) FocusScope.of(context).unfocus();
    if (picked == null) return;
    setState(() => _reminder = picked.hour * 60 + picked.minute);
  }

  Future<void> _toggleReminder(bool on) async {
    if (!on) {
      setState(() => _reminder = null);
      return;
    }
    setState(() => _reminder = _reminder ?? 20 * 60);
    await _pickTime();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final host = widget.hostContext;
    final name = _name.text.trim();
    if (name.isEmpty) {
      BPSnackbar.error(context, l.habitNeedsName);
      return;
    }
    if (_days.isEmpty) {
      BPSnackbar.error(context, l.pickAtLeastOneDay);
      return;
    }
    final t = int.tryParse(_target.text.trim());
    final target = (t == null || t <= 0) ? 1 : t;
    final service = context.read<HabitService>();

    if (_isNew) {
      await service.addHabit(
        name: name,
        type: _type,
        targetValue: target,
        activeWeekdays: _days,
        reminderMinutes: _reminder,
      );
    } else {
      await service.updateHabit(
        widget.habit!.copyWith(
          name: name,
          targetValue: target,
          activeWeekdays: _days,
          reminderMinutes: _reminder,
          clearReminder: _reminder == null,
        ),
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();

    if (_reminder != null) {
      final allowed = await ReminderService.instance.requestPermission();
      if (!allowed && host.mounted) {
        BPSnackbar.error(host, l.reminderPermissionDenied);
        return;
      }
      // Plan again now that notifications may have been allowed.
      ReminderService.instance.scheduleSoon(service);
    }
    if (host.mounted) BPSnackbar.success(host, l.habitSaved(name));
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context)!;
    final habit = widget.habit!;
    final host = widget.hostContext;
    final ok = await confirmDelete(
      context,
      title: l.deleteHabitTitle,
      message: l.deleteHabitMessage(habit.name),
    );
    if (!ok || !mounted) return;
    await context.read<HabitService>().deleteHabit(habit.id);
    if (!mounted) return;
    Navigator.of(context).pop();
    if (host.mounted) BPSnackbar.success(host, l.habitDeleted(habit.name));
  }

  Future<void> _archive() async {
    final l = AppLocalizations.of(context)!;
    final habit = widget.habit!;
    final host = widget.hostContext;
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l.archiveHabitTitle),
            content: Text(l.archiveHabitMessage(habit.name)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l.archive),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok || !mounted) return;
    await context.read<HabitService>().archiveHabit(habit.id);
    if (!mounted) return;
    Navigator.of(context).pop();
    if (host.mounted) BPSnackbar.success(host, l.habitArchived(habit.name));
  }

  void _openStats() {
    final host = widget.hostContext;
    final habit = widget.habit!;
    Navigator.of(context).pop();
    Navigator.of(host).push(
      MaterialPageRoute(builder: (_) => HabitStatsPage(habit: habit)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // Keyboard, or else the system navigation bar (Android).
    final media = MediaQuery.of(context);
    final bottom = media.viewInsets.bottom > 0
        ? media.viewInsets.bottom
        : media.viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isNew ? l.newHabitTitle : l.editHabitTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              autofocus: _isNew,
              textCapitalization: TextCapitalization.sentences,
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
                    initialValue: _type,
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
                    // The type of an existing habit is fixed, so old
                    // history keeps its meaning.
                    onChanged: _isNew
                        ? (v) {
                            if (v == null) return;
                            setState(() => _type = v);
                            if (v == HabitType.count) {
                              _targetFocus.requestFocus();
                            }
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _target,
                    focusNode: _targetFocus,
                    enabled: _type == HabitType.count,
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
            Text(l.weekdaysLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var d = 1; d <= 7; d++)
                  FilterChip(
                    label: Text(weekdayShort(l.localeName, d)),
                    selected: _days.contains(d),
                    showCheckmark: false,
                    onSelected: (on) => setState(() {
                      on ? _days.add(d) : _days.remove(d);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.reminderLabel),
              subtitle: _reminder == null ? Text(l.reminderOff) : null,
              secondary: const Icon(Icons.notifications_outlined),
              value: _reminder != null,
              onChanged: _toggleReminder,
            ),
            if (_reminder != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: Text(formatMinutes(context, _reminder!)),
                trailing: const Icon(Icons.edit_outlined),
                onTap: _pickTime,
              ),
            if (!_isNew)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.bar_chart),
                  label: Text(l.buttonSeeStats),
                  onPressed: _openStats,
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                if (_isNew)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l.cancel),
                  ),
                if (!_isNew) ...[
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFD32F2F),
                    ),
                    onPressed: _delete,
                    child: Text(l.delete),
                  ),
                  OutlinedButton(
                    onPressed: _archive,
                    child: Text(l.buttonArchive),
                  ),
                ],
                FilledButton(onPressed: _save, child: Text(l.save)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
