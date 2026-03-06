import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), taskCount: 3)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), taskCount: 3)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = SimpleEntry(date: Date(), taskCount: 4)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let taskCount: Int
}

struct LifeOSWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Tasks Today")
                .font(.caption)
            Text("\(entry.taskCount)")
                .font(.title)
                .bold()
        }
        .containerBackground(for: .widget) {
            Color.blue.opacity(0.2)
        }
    }
}

@main
struct LifeOSWidget: Widget {
    let kind: String = "LifeOSWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LifeOSWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("LifeOS Status")
        .description("Keep track of your daily tasks.")
        .supportedFamilies([.systemSmall])
    }
}
