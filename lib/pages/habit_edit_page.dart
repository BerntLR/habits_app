import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../services/habit_service.dart';

class HabitEditPage extends StatefulWidget {
  final Habit? existing;

  const HabitEditPage({
    super.key,
    this.existing,
  });

  @override
  State<HabitEditPage> createState() => _HabitEditPageState();
}

class _HabitEditPageState extends State<HabitEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _targetController;
  late HabitType _selectedType;
  late Set<int> _weekdays;

  static const Map<int, String> _weekdayLabels = {
    1: 'Man',
    2: 'Tir',
    3: 'Ons',
    4: 'Tor',
    5: 'Fre',
    6: 'Lør',
    7: 'Søn',
  };

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _selectedType = existing?.type ?? HabitType.boolean;
    _targetController = TextEditingController(
      text: existing != null ? existing.targetValue.toString() : '1',
    );
    _weekdays = (existing?.activeWeekdays.toSet() ?? {1, 2, 3, 4, 5, 6, 7});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _save() {
    final service = context.read<HabitService>();

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    final target = _selectedType == HabitType.count
        ? (int.tryParse(_targetController.text) ?? 1)
        : 1;

    if (_isEditing && widget.existing != null) {
      final updated = widget.existing!.copyWith(
        name: name,
        type: _selectedType,
        targetValue: target,
        activeWeekdays: _weekdays,
      );
      service.updateHabit(updated);
    } else {
      final newHabit = Habit(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        type: _selectedType,
        targetValue: target,
        activeWeekdays: _weekdays,
      );
      service.addHabit(newHabit);
    }

    Navigator.of(context).pop();
  }

  void _delete() {
    if (!_isEditing || widget.existing == null) {
      return;
    }
    final service = context.read<HabitService>();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Slett vane?'),
          content: Text(
            'Er du sikker på at du vil slette "${widget.existing!.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Avbryt'),
            ),
            ElevatedButton(
              onPressed: () {
                service.removeHabit(widget.existing!.id);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Slett'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Rediger vane' : 'Ny vane';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Navn på vane',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<HabitType>(
              value: _selectedType,
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
                  _selectedType = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedType == HabitType.count)
              TextField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Mal (for eksempel 10 minutter eller 5 glass)',
                  border: OutlineInputBorder(),
                ),
              ),
            if (_selectedType == HabitType.count) const SizedBox(height: 16),
            Text(
              'Ukedager',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: _weekdayLabels.entries.map((entry) {
                final day = entry.key;
                final label = entry.value;
                final selected = _weekdays.contains(day);
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        _weekdays.remove(day);
                      } else {
                        _weekdays.add(day);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('Lagre'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
