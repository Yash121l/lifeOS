import Foundation
import EventKit
import SwiftUI

@Observable
final class CalendarManager {
    static let shared = CalendarManager()
    
    private let eventStore = EKEventStore()
    var authorizationStatus: EKAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)
    
    func requestAccess() async -> Bool {
        do {
            if #available(iOS 17.0, *) {
                let granted = try await eventStore.requestWriteOnlyAccessToEvents()
                authorizationStatus = EKEventStore.authorizationStatus(for: .event)
                return granted
            } else {
                let granted = try await eventStore.requestAccess(to: .event)
                authorizationStatus = EKEventStore.authorizationStatus(for: .event)
                return granted
            }
        } catch {
            print("Failed to request calendar access: \(error)")
            return false
        }
    }
    
    func addEventToCalendar(title: String, startDate: Date, durationMinutes: Int, notes: String?) async -> Bool {
        // Ensure calendar sync is enabled in settings
        guard SettingsManager.shared.isCalendarSyncEnabled else { return false }
        
        if authorizationStatus != .fullAccess && authorizationStatus != .writeOnly {
            let granted = await requestAccess()
            if !granted { return false }
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = startDate.addingTimeInterval(TimeInterval(durationMinutes * 60))
        event.notes = notes
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            return true
        } catch {
            print("Failed to save event to calendar: \(error)")
            return false
        }
    }
}
