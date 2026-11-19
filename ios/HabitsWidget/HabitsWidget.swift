import SwiftUI
import WidgetKit

// Home screen widget: how many of today's habits are done.
// The app writes the numbers to the shared app group (see
// lib/services/home_widget_service.dart).

private let appGroup = "group.com.bullpeak.karoshabits"

struct HabitsEntry: TimelineEntry {
  let date: Date
  let title: String
  let done: Int
  let total: Int
  let summary: String
}

private func dayKey(_ date: Date) -> String {
  let f = DateFormatter()
  f.locale = Locale(identifier: "en_US_POSIX")
  f.calendar = Calendar(identifier: .gregorian)
  f.dateFormat = "yyyy-MM-dd"
  return f.string(from: date)
}

private func readEntry(for date: Date) -> HabitsEntry {
  let d = UserDefaults(suiteName: appGroup)
  let key = dayKey(date)
  var total = 0
  if let json = d?.string(forKey: "totals"),
    let data = json.data(using: .utf8),
    let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Int]
  {
    total = obj[key] ?? 0
  }
  // After midnight the saved count belongs to yesterday: start at 0.
  let done = d?.string(forKey: "doneDate") == key ? (d?.integer(forKey: "done") ?? 0) : 0
  let pattern = d?.string(forKey: "summaryPattern") ?? "{done} / {total}"
  let summary = total == 0
    ? (d?.string(forKey: "noHabits") ?? "")
    : pattern.replacingOccurrences(of: "{done}", with: "\(done)")
      .replacingOccurrences(of: "{total}", with: "\(total)")
  return HabitsEntry(
    date: date,
    title: d?.string(forKey: "title") ?? "Karos Habits",
    done: done,
    total: total,
    summary: summary
  )
}

struct HabitsProvider: TimelineProvider {
  func placeholder(in context: Context) -> HabitsEntry {
    HabitsEntry(date: Date(), title: "Today", done: 2, total: 4, summary: "2 of 4 done")
  }

  func getSnapshot(in context: Context, completion: @escaping (HabitsEntry) -> Void) {
    completion(readEntry(for: Date()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<HabitsEntry>) -> Void) {
    let now = Date()
    let cal = Calendar.current
    // One entry now and one just after midnight, so the new day starts at 0.
    let midnight = cal.startOfDay(for: cal.date(byAdding: .day, value: 1, to: now)!)
      .addingTimeInterval(5)
    let entries = [readEntry(for: now), readEntry(for: midnight)]
    completion(Timeline(entries: entries, policy: .after(midnight)))
  }
}

struct HabitsWidgetView: View {
  var entry: HabitsEntry
  private let accent = Color(red: 0x1F / 255, green: 0x5F / 255, blue: 0xBF / 255)

  var body: some View {
    let progress = entry.total == 0 ? 0 : Double(entry.done) / Double(entry.total)
    VStack(alignment: .leading, spacing: 6) {
      Text("Karos Habits")
        .font(.caption)
        .fontWeight(.bold)
        .foregroundColor(accent)
      Text(entry.title)
        .font(.subheadline)
        .foregroundColor(.secondary)
      Spacer(minLength: 0)
      Text("\(entry.done) / \(entry.total)")
        .font(.system(size: 34, weight: .bold, design: .rounded))
      ProgressView(value: progress)
        .tint(accent)
      Text(entry.summary)
        .font(.caption2)
        .foregroundColor(.secondary)
        .lineLimit(2)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    .widgetBackground()
  }
}

extension View {
  @ViewBuilder
  func widgetBackground() -> some View {
    if #available(iOS 17.0, *) {
      containerBackground(for: .widget) { Color(UIColor.systemBackground) }
    } else {
      padding().background(Color(UIColor.systemBackground))
    }
  }
}

@main
struct HabitsWidget: Widget {
  let kind = "HabitsWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: HabitsProvider()) { entry in
      HabitsWidgetView(entry: entry)
    }
    .configurationDisplayName("Karos Habits")
    .description(NSLocalizedString("widget_description", comment: ""))
    .supportedFamilies([.systemSmall])
  }
}
