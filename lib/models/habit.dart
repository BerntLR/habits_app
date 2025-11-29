enum HabitType {
  boolean,
  count,
}

class Habit {
  final String id;
  final String name;
  final HabitType type;
  final int targetValue;
  final Set<int> activeWeekdays;
  final bool isArchived;
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.name,
    required this.type,
    required this.targetValue,
    required this.activeWeekdays,
    this.isArchived = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Habit copyWith({
    String? id,
    String? name,
    HabitType? type,
    int? targetValue,
    Set<int>? activeWeekdays,
    bool? isArchived,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      activeWeekdays: activeWeekdays ?? this.activeWeekdays,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class HabitEntry {
  final String habitId;
  final DateTime date;
  int value;

  HabitEntry({
    required this.habitId,
    required this.date,
    required this.value,
  });
}

DateTime normalizeDate(DateTime dt) {
  return DateTime(dt.year, dt.month, dt.day);
}
