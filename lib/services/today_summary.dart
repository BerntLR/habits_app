import '../models/habit.dart';
import 'habit_service.dart';

/// Done / total for the habits that apply on [date].
class DaySummary {
  const DaySummary(this.done, this.total);
  final int done;
  final int total;
}

DaySummary summaryFor(HabitService service, DateTime date) {
  final habits = service.habitsForDate(date);
  final done = habits.where((h) => service.isHabitDone(h.id, date)).length;
  return DaySummary(done, habits.length);
}

String dateKey(DateTime d) {
  final n = normalizeDate(d);
  final m = n.month.toString().padLeft(2, '0');
  final day = n.day.toString().padLeft(2, '0');
  return '${n.year}-$m-$day';
}
