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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'targetValue': targetValue,
      'activeWeekdays': activeWeekdays.toList(),
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      type: (map['type'] as String) == 'count'
          ? HabitType.count
          : HabitType.boolean,
      targetValue: map['targetValue'] as int,
      activeWeekdays: (map['activeWeekdays'] as List<dynamic>)
          .map((e) => e as int)
          .toSet(),
      isArchived: (map['isArchived'] as bool?) ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
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

  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'date': date.toIso8601String(),
      'value': value,
    };
  }

  factory HabitEntry.fromMap(Map<String, dynamic> map) {
    return HabitEntry(
      habitId: map['habitId'] as String,
      date: DateTime.parse(map['date'] as String),
      value: map['value'] as int,
    );
  }
}

DateTime normalizeDate(DateTime dt) {
  return DateTime(dt.year, dt.month, dt.day);
}
