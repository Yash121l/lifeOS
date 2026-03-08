import Foundation

/// Shared data bridge between the main app and widget extension via App Group UserDefaults.
/// This file is compiled into BOTH targets, so it must NOT reference any main-app-only types.
struct SharedData {
    static let appGroupId = "group.com.yashlunawat.LifeOS"
    
    private static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }
    
    // MARK: - Keys
    
    private enum Keys {
        static let pendingTaskCount = "widget_pendingTaskCount"
        static let completedTodayCount = "widget_completedTodayCount"
        static let totalTaskCount = "widget_totalTaskCount"
        static let todayEventCount = "widget_todayEventCount"
        static let nextEventTitle = "widget_nextEventTitle"
        static let nextEventTime = "widget_nextEventTime"
        static let nextEventEndTime = "widget_nextEventEndTime"
        static let nextEventIsAllDay = "widget_nextEventIsAllDay"
        static let nextEventMeetingLink = "widget_nextEventMeetingLink"
        static let nextEventLocation = "widget_nextEventLocation"
        static let nextEventDescription = "widget_nextEventDescription"
        static let nextEventId = "widget_nextEventId"
        static let upcomingTasks = "widget_upcomingTasks"
        static let upcomingEvents = "widget_upcomingEvents"
        static let lastUpdated = "widget_lastUpdated"
    }
    
    // MARK: - Codable Models (shared between app and widget)
    
    struct WidgetTask: Codable {
        let id: String
        let title: String
        let priority: Int
        let dueDate: Date?
        let isCompleted: Bool
        let energyLevel: Int
        let timeEstimateMinutes: Int
    }
    
    struct WidgetEvent: Codable {
        let id: String
        let title: String
        let startTime: Date?
        let endTime: Date?
        let isAllDay: Bool
        let meetingLink: String?
        let location: String?
        let description: String?
    }
    
    // MARK: - Write Raw Data (called from main app via wrappers)
    
    static func writeStats(pending: Int, completed: Int, total: Int, eventCount: Int) {
        guard let defaults = sharedDefaults else { return }
        defaults.set(pending, forKey: Keys.pendingTaskCount)
        defaults.set(completed, forKey: Keys.completedTodayCount)
        defaults.set(total, forKey: Keys.totalTaskCount)
        defaults.set(eventCount, forKey: Keys.todayEventCount)
        defaults.set(Date().timeIntervalSince1970, forKey: Keys.lastUpdated)
    }
    
    static func writeNextEvent(
        title: String?,
        startTime: Date?,
        endTime: Date?,
        isAllDay: Bool,
        meetingLink: String?,
        location: String?,
        description: String?,
        id: String?
    ) {
        guard let defaults = sharedDefaults else { return }
        if let title = title {
            defaults.set(title, forKey: Keys.nextEventTitle)
        } else {
            defaults.removeObject(forKey: Keys.nextEventTitle)
        }
        if let start = startTime {
            defaults.set(start.timeIntervalSince1970, forKey: Keys.nextEventTime)
        } else {
            defaults.removeObject(forKey: Keys.nextEventTime)
        }
        if let end = endTime {
            defaults.set(end.timeIntervalSince1970, forKey: Keys.nextEventEndTime)
        } else {
            defaults.removeObject(forKey: Keys.nextEventEndTime)
        }
        defaults.set(isAllDay, forKey: Keys.nextEventIsAllDay)
        if let link = meetingLink {
            defaults.set(link, forKey: Keys.nextEventMeetingLink)
        } else {
            defaults.removeObject(forKey: Keys.nextEventMeetingLink)
        }
        if let loc = location {
            defaults.set(loc, forKey: Keys.nextEventLocation)
        } else {
            defaults.removeObject(forKey: Keys.nextEventLocation)
        }
        if let desc = description {
            defaults.set(desc, forKey: Keys.nextEventDescription)
        } else {
            defaults.removeObject(forKey: Keys.nextEventDescription)
        }
        if let id = id {
            defaults.set(id, forKey: Keys.nextEventId)
        } else {
            defaults.removeObject(forKey: Keys.nextEventId)
        }
    }
    
    static func writeTasks(_ tasks: [WidgetTask]) {
        guard let defaults = sharedDefaults else { return }
        if let data = try? JSONEncoder().encode(tasks) {
            defaults.set(data, forKey: Keys.upcomingTasks)
        }
    }
    
    static func writeEvents(_ events: [WidgetEvent]) {
        guard let defaults = sharedDefaults else { return }
        if let data = try? JSONEncoder().encode(events) {
            defaults.set(data, forKey: Keys.upcomingEvents)
        }
    }
    
    // MARK: - Read Data (called from widget)
    
    static var pendingTaskCount: Int {
        sharedDefaults?.integer(forKey: Keys.pendingTaskCount) ?? 0
    }
    
    static var completedTodayCount: Int {
        sharedDefaults?.integer(forKey: Keys.completedTodayCount) ?? 0
    }
    
    static var totalTaskCount: Int {
        sharedDefaults?.integer(forKey: Keys.totalTaskCount) ?? 0
    }
    
    static var todayEventCount: Int {
        sharedDefaults?.integer(forKey: Keys.todayEventCount) ?? 0
    }
    
    static var nextEventTitle: String? {
        sharedDefaults?.string(forKey: Keys.nextEventTitle)
    }
    
    static var nextEventTime: Date? {
        guard let interval = sharedDefaults?.object(forKey: Keys.nextEventTime) as? TimeInterval else { return nil }
        return Date(timeIntervalSince1970: interval)
    }
    
    static var nextEventEndTime: Date? {
        guard let interval = sharedDefaults?.object(forKey: Keys.nextEventEndTime) as? TimeInterval else { return nil }
        return Date(timeIntervalSince1970: interval)
    }
    
    static var nextEventIsAllDay: Bool {
        sharedDefaults?.bool(forKey: Keys.nextEventIsAllDay) ?? false
    }
    
    static var nextEventMeetingLink: String? {
        sharedDefaults?.string(forKey: Keys.nextEventMeetingLink)
    }
    
    static var nextEventLocation: String? {
        sharedDefaults?.string(forKey: Keys.nextEventLocation)
    }
    
    static var nextEventDescription: String? {
        sharedDefaults?.string(forKey: Keys.nextEventDescription)
    }
    
    static var nextEventId: String? {
        sharedDefaults?.string(forKey: Keys.nextEventId)
    }
    
    static var upcomingTasks: [WidgetTask] {
        guard let data = sharedDefaults?.data(forKey: Keys.upcomingTasks) else { return [] }
        return (try? JSONDecoder().decode([WidgetTask].self, from: data)) ?? []
    }
    
    static var upcomingEvents: [WidgetEvent] {
        guard let data = sharedDefaults?.data(forKey: Keys.upcomingEvents) else { return [] }
        return (try? JSONDecoder().decode([WidgetEvent].self, from: data)) ?? []
    }
    
    static var lastUpdated: Date? {
        guard let interval = sharedDefaults?.object(forKey: Keys.lastUpdated) as? TimeInterval else { return nil }
        return Date(timeIntervalSince1970: interval)
    }
}
