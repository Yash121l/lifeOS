import Foundation
import EventKit
import SwiftUI

/// Calendar manager that delegates to Google Calendar API for cross-platform sync
@Observable
final class CalendarManager {
    static let shared = CalendarManager()
    
    private let googleService = GoogleCalendarService.shared
    
    var isSyncing: Bool { googleService.isSyncing }
    var isConnected: Bool { googleService.isConnected }
    var lastSyncDate: Date? { googleService.lastSyncDate }
    var syncedEventCount: Int { googleService.syncedEventCount }
    
    private init() {}
    
    // MARK: - Sync
    
    func performSync() async {
        await googleService.performSync()
    }
    
    func fetchEventsForToday() async -> [GoogleCalendarService.GoogleCalendarEvent] {
        await googleService.fetchEvents(for: Date())
        return googleService.events
    }
    
    // MARK: - Create Event from TimeBlock
    
    func addTimeBlockToCalendar(_ block: TimeBlock) async -> Bool {
        return await googleService.createEvent(
            title: block.title,
            startDate: block.startTime,
            endDate: block.endTime,
            description: "Created by LifeOS"
        )
    }
    
    // MARK: - Create Event from Task
    
    func addTaskToCalendar(title: String, startDate: Date, durationMinutes: Int, notes: String?) async -> Bool {
        let endDate = startDate.addingTimeInterval(TimeInterval(durationMinutes * 60))
        return await googleService.createEvent(
            title: title,
            startDate: startDate,
            endDate: endDate,
            description: notes
        )
    }
}
