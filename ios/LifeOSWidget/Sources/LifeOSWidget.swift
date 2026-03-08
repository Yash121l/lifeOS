import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct LifeOSEntry: TimelineEntry {
    let date: Date
    let pendingTaskCount: Int
    let completedTodayCount: Int
    let todayEventCount: Int
    let nextEventTitle: String?
    let nextEventTime: Date?
    let nextEventEndTime: Date?
    let nextEventIsAllDay: Bool
    let nextEventMeetingLink: String?
    let nextEventLocation: String?
    let nextEventDescription: String?
    let nextEventId: String?
    let upcomingTasks: [SharedData.WidgetTask]
    let upcomingEvents: [SharedData.WidgetEvent]
    
    static var placeholder: LifeOSEntry {
        LifeOSEntry(
            date: .now,
            pendingTaskCount: 5,
            completedTodayCount: 3,
            todayEventCount: 4,
            nextEventTitle: "Team Standup",
            nextEventTime: Date().addingTimeInterval(3600),
            nextEventEndTime: Date().addingTimeInterval(5400),
            nextEventIsAllDay: false,
            nextEventMeetingLink: "https://meet.google.com",
            nextEventLocation: nil,
            nextEventDescription: "Daily standup meeting",
            nextEventId: nil,
            upcomingTasks: [],
            upcomingEvents: []
        )
    }
}

// MARK: - Timeline Provider

struct LifeOSProvider: TimelineProvider {
    func placeholder(in context: Context) -> LifeOSEntry {
        .placeholder
    }
    
    func getSnapshot(in context: Context, completion: @escaping (LifeOSEntry) -> ()) {
        completion(makeEntry())
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<LifeOSEntry>) -> ()) {
        let entry = makeEntry()
        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func makeEntry() -> LifeOSEntry {
        LifeOSEntry(
            date: .now,
            pendingTaskCount: SharedData.pendingTaskCount,
            completedTodayCount: SharedData.completedTodayCount,
            todayEventCount: SharedData.todayEventCount,
            nextEventTitle: SharedData.nextEventTitle,
            nextEventTime: SharedData.nextEventTime,
            nextEventEndTime: SharedData.nextEventEndTime,
            nextEventIsAllDay: SharedData.nextEventIsAllDay,
            nextEventMeetingLink: SharedData.nextEventMeetingLink,
            nextEventLocation: SharedData.nextEventLocation,
            nextEventDescription: SharedData.nextEventDescription,
            nextEventId: SharedData.nextEventId,
            upcomingTasks: SharedData.upcomingTasks,
            upcomingEvents: SharedData.upcomingEvents
        )
    }
}

// MARK: - Widget Colors (matching DesignSystem)

private enum WColor {
    static let background = Color(red: 0.02, green: 0.02, blue: 0.03)
    static let surface = Color(red: 0.067, green: 0.067, blue: 0.075)
    static let accent = Color(red: 0.424, green: 0.361, blue: 0.906)
    static let accentLight = Color(red: 0.635, green: 0.608, blue: 0.996)
    static let cyan = Color(red: 0, green: 0.808, blue: 0.788)
    static let amber = Color(red: 0.992, green: 0.796, blue: 0.431)
    static let success = Color(red: 0, green: 0.722, blue: 0.58)
    static let error = Color(red: 1, green: 0.42, blue: 0.42)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.6)
    static let textTertiary = Color.white.opacity(0.3)
    static let cardBorder = Color.white.opacity(0.06)
}

// MARK: - Up Next Widget View

struct UpNextWidgetView: View {
    var entry: LifeOSEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if let title = entry.nextEventTitle {
            eventContent(title: title)
        } else {
            emptyState
        }
    }
    
    private func eventContent(title: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack(spacing: 4) {
                Image(systemName: isMeeting ? "video.fill" : "calendar")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(isMeeting ? WColor.amber : WColor.cyan)
                Text("UP NEXT")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(WColor.textTertiary)
                Spacer()
                if let time = entry.nextEventTime {
                    Text(timeUntil(time))
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundStyle(WColor.accent)
                }
            }
            
            // Event title
            Text(title)
                .font(.system(size: family == .systemSmall ? 15 : 17, weight: .bold, design: .rounded))
                .foregroundStyle(WColor.textPrimary)
                .lineLimit(2)
            
            // Time range
            if let start = entry.nextEventTime {
                if entry.nextEventIsAllDay {
                    Text("All Day")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(WColor.textSecondary)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 9))
                        if let end = entry.nextEventEndTime {
                            Text("\(start, style: .time) – \(end, style: .time)")
                                .font(.system(size: 11, weight: .medium))
                        } else {
                            Text(start, style: .time)
                                .font(.system(size: 11, weight: .medium))
                        }
                    }
                    .foregroundStyle(WColor.textSecondary)
                }
            }
            
            // Location (medium only)
            if family != .systemSmall, let location = entry.nextEventLocation, !location.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 8))
                    Text(location)
                        .font(.system(size: 10))
                        .lineLimit(1)
                }
                .foregroundStyle(WColor.textTertiary)
            }
            
            Spacer(minLength: 0)
            
            // Join Meeting button (if it's a meeting)
            if isMeeting {
                if let link = entry.nextEventMeetingLink, let _ = URL(string: link) {
                    Link(destination: URL(string: link)!) {
                        HStack(spacing: 4) {
                            Image(systemName: "video.fill")
                                .font(.system(size: 10, weight: .semibold))
                            Text("Join Meeting")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(
                                    colors: [WColor.accent, WColor.accentLight],
                                    startPoint: .leading, endPoint: .trailing
                                ))
                        )
                    }
                }
            } else {
                // Deep link to time tab
                Link(destination: URL(string: "lifeos://time")!) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 9, weight: .semibold))
                        Text("View Schedule")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(WColor.accent)
                }
            }
        }
        .containerBackground(for: .widget) {
            WColor.background
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(WColor.textTertiary)
            Text("All Clear")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(WColor.textPrimary)
            Text("No upcoming events")
                .font(.system(size: 11))
                .foregroundStyle(WColor.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            WColor.background
        }
    }
    
    private var isMeeting: Bool {
        entry.nextEventMeetingLink != nil
    }
    
    private func timeUntil(_ date: Date) -> String {
        let diff = date.timeIntervalSince(Date())
        if diff < 0 { return "Now" }
        let mins = Int(diff / 60)
        if mins < 60 { return "in \(mins)m" }
        let hrs = mins / 60
        let remMins = mins % 60
        if remMins == 0 { return "in \(hrs)h" }
        return "in \(hrs)h \(remMins)m"
    }
}

// MARK: - Today Summary Widget View

struct TodaySummaryWidgetView: View {
    var entry: LifeOSEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        VStack(alignment: .leading, spacing: family == .systemSmall ? 6 : 10) {
            // Header
            HStack(spacing: 4) {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(WColor.accent)
                Text("LIFEOS")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(WColor.textTertiary)
                    .tracking(1.5)
                Spacer()
            }
            
            if family == .systemSmall {
                smallStatsView
            } else {
                mediumLargeStatsView
            }
            
            Spacer(minLength: 0)
            
            // Upcoming tasks (large only)
            if family == .systemLarge {
                upcomingTasksList
            }
        }
        .containerBackground(for: .widget) {
            WColor.background
        }
    }
    
    private var smallStatsView: some View {
        VStack(spacing: 8) {
            statBlock(value: "\(entry.pendingTaskCount)", label: "Pending", icon: "circle", color: WColor.amber)
            statBlock(value: "\(entry.completedTodayCount)", label: "Done", icon: "checkmark.circle.fill", color: WColor.success)
            statBlock(value: "\(entry.todayEventCount)", label: "Events", icon: "calendar", color: WColor.cyan)
        }
    }
    
    private var mediumLargeStatsView: some View {
        HStack(spacing: 8) {
            statCard(value: "\(entry.pendingTaskCount)", label: "Pending", icon: "circle", color: WColor.amber)
            statCard(value: "\(entry.completedTodayCount)", label: "Done", icon: "checkmark.circle.fill", color: WColor.success)
            statCard(value: "\(entry.todayEventCount)", label: "Events", icon: "calendar", color: WColor.cyan)
        }
    }
    
    private func statBlock(value: String, label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(color)
                .frame(width: 16)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(WColor.textPrimary)
            
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(WColor.textTertiary)
            
            Spacer()
        }
    }
    
    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(color)
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(WColor.textPrimary)
            }
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(WColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(WColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(WColor.cardBorder, lineWidth: 1)
                )
        )
    }
    
    private var upcomingTasksList: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("UPCOMING TASKS")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(WColor.textTertiary)
                .tracking(1)
            
            if entry.upcomingTasks.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 12))
                        .foregroundStyle(WColor.success)
                    Text("All tasks completed!")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(WColor.textSecondary)
                }
                .padding(.vertical, 4)
            } else {
                ForEach(entry.upcomingTasks.prefix(4), id: \.id) { task in
                    Link(destination: URL(string: "lifeos://tasks")!) {
                        HStack(spacing: 6) {
                            Circle()
                                .stroke(priorityColor(task.priority), lineWidth: 1.5)
                                .frame(width: 14, height: 14)
                            
                            Text(task.title)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(WColor.textPrimary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            if let due = task.dueDate {
                                Text(due, style: .relative)
                                    .font(.system(size: 9))
                                    .foregroundStyle(due < Date() ? WColor.error : WColor.textTertiary)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func priorityColor(_ priority: Int) -> Color {
        switch priority {
        case 0: return WColor.success
        case 2: return WColor.error
        default: return WColor.amber
        }
    }
}

// MARK: - Event Detail Widget View (Medium/Large)

struct EventDetailWidgetView: View {
    var entry: LifeOSEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if entry.upcomingEvents.isEmpty && entry.nextEventTitle == nil {
            emptyState
        } else {
            eventListView
        }
    }
    
    private var eventListView: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack(spacing: 4) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(WColor.cyan)
                Text("EVENTS")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(WColor.textTertiary)
                    .tracking(1.5)
                Spacer()
                Text("\(entry.todayEventCount) today")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(WColor.textTertiary)
            }
            
            ForEach(entry.upcomingEvents.prefix(family == .systemLarge ? 5 : 3), id: \.id) { event in
                eventRow(event)
            }
            
            Spacer(minLength: 0)
        }
        .containerBackground(for: .widget) {
            WColor.background
        }
    }
    
    private func eventRow(_ event: SharedData.WidgetEvent) -> some View {
        let isMeeting = event.meetingLink != nil
        
        return HStack(spacing: 8) {
            // Color bar
            RoundedRectangle(cornerRadius: 2)
                .fill(isMeeting ? WColor.amber : WColor.cyan)
                .frame(width: 3, height: 36)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    if isMeeting {
                        Image(systemName: "video.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(WColor.amber)
                    }
                    Text(event.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(WColor.textPrimary)
                        .lineLimit(1)
                }
                
                if let start = event.startTime {
                    if event.isAllDay {
                        Text("All Day")
                            .font(.system(size: 9))
                            .foregroundStyle(WColor.textTertiary)
                    } else {
                        HStack(spacing: 2) {
                            Text(start, style: .time)
                            if let end = event.endTime {
                                Text("–")
                                Text(end, style: .time)
                            }
                        }
                        .font(.system(size: 9))
                        .foregroundStyle(WColor.textTertiary)
                    }
                }
            }
            
            Spacer(minLength: 0)
            
            // Join button for meetings
            if isMeeting, let link = event.meetingLink, let url = URL(string: link) {
                Link(destination: url) {
                    Text("Join")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(WColor.accent)
                        )
                }
            }
        }
        .padding(.vertical, 2)
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(WColor.textTertiary)
            Text("No Events")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(WColor.textPrimary)
            Text("Your schedule is clear")
                .font(.system(size: 11))
                .foregroundStyle(WColor.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            WColor.background
        }
    }
}

// MARK: - Widget Definitions

struct UpNextWidget: Widget {
    let kind = "UpNextWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LifeOSProvider()) { entry in
            UpNextWidgetView(entry: entry)
        }
        .configurationDisplayName("Up Next")
        .description("Shows your next upcoming event with a join button for meetings.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TodaySummaryWidget: Widget {
    let kind = "TodaySummaryWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LifeOSProvider()) { entry in
            TodaySummaryWidgetView(entry: entry)
        }
        .configurationDisplayName("Today Summary")
        .description("Daily overview of tasks and events.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct EventDetailWidget: Widget {
    let kind = "EventDetailWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LifeOSProvider()) { entry in
            EventDetailWidgetView(entry: entry)
        }
        .configurationDisplayName("Events")
        .description("Your upcoming events with join buttons for meetings.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

// MARK: - Widget Bundle

@main
struct LifeOSWidgets: WidgetBundle {
    var body: some Widget {
        UpNextWidget()
        TodaySummaryWidget()
        EventDetailWidget()
    }
}
