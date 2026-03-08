import Foundation
import UserNotifications
import UIKit

@Observable
final class NotificationManager: NSObject {
    static let shared = NotificationManager()
    
    var isAuthorized = false
    var taskRemindersEnabled = true
    var eventRemindersEnabled = true
    var reminderMinutesBefore = 15
    
    private let center = UNUserNotificationCenter.current()
    
    // Deep-link payload keys
    static let taskIdKey = "taskId"
    static let eventIdKey = "eventId"
    static let eventTitleKey = "eventTitle"
    static let eventStartKey = "eventStart"
    static let eventEndKey = "eventEnd"
    static let eventDescriptionKey = "eventDescription"
    static let eventLocationKey = "eventLocation"
    static let eventMeetingLinkKey = "eventMeetingLink"
    static let eventIsAllDayKey = "eventIsAllDay"
    static let notificationTypeKey = "notificationType"
    
    // Notification categories
    static let taskCategory = "TASK_REMINDER"
    static let eventCategory = "EVENT_REMINDER"
    static let meetingCategory = "MEETING_REMINDER"
    
    // Actions
    static let markCompleteAction = "MARK_COMPLETE"
    static let joinMeetingAction = "JOIN_MEETING"
    static let snoozeAction = "SNOOZE"
    
    private override init() {
        super.init()
        loadSettings()
        registerCategories()
        checkAuthorization()
    }
    
    // MARK: - Settings Persistence
    
    private func loadSettings() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "taskRemindersEnabled") != nil {
            taskRemindersEnabled = defaults.bool(forKey: "taskRemindersEnabled")
        }
        if defaults.object(forKey: "eventRemindersEnabled") != nil {
            eventRemindersEnabled = defaults.bool(forKey: "eventRemindersEnabled")
        }
        if defaults.integer(forKey: "reminderMinutesBefore") > 0 {
            reminderMinutesBefore = defaults.integer(forKey: "reminderMinutesBefore")
        }
    }
    
    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(taskRemindersEnabled, forKey: "taskRemindersEnabled")
        defaults.set(eventRemindersEnabled, forKey: "eventRemindersEnabled")
        defaults.set(reminderMinutesBefore, forKey: "reminderMinutesBefore")
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge, .provisional])
            await MainActor.run { isAuthorized = granted }
        } catch {
            print("Notification authorization failed: \(error)")
        }
    }
    
    func checkAuthorization() {
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
            }
        }
    }
    
    func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Categories & Actions
    
    private func registerCategories() {
        // Task reminder: Mark Complete + Snooze
        let markComplete = UNNotificationAction(
            identifier: Self.markCompleteAction,
            title: "Mark Complete",
            options: [.foreground]
        )
        let snooze = UNNotificationAction(
            identifier: Self.snoozeAction,
            title: "Snooze 10 min",
            options: []
        )
        let taskCategory = UNNotificationCategory(
            identifier: Self.taskCategory,
            actions: [markComplete, snooze],
            intentIdentifiers: [],
            options: []
        )
        
        // Event reminder: Snooze
        let eventCategory = UNNotificationCategory(
            identifier: Self.eventCategory,
            actions: [snooze],
            intentIdentifiers: [],
            options: []
        )
        
        // Meeting reminder: Join Meeting + Snooze
        let joinMeeting = UNNotificationAction(
            identifier: Self.joinMeetingAction,
            title: "Join Meeting",
            options: [.foreground]
        )
        let meetingCategory = UNNotificationCategory(
            identifier: Self.meetingCategory,
            actions: [joinMeeting, snooze],
            intentIdentifiers: [],
            options: []
        )
        
        center.setNotificationCategories([taskCategory, eventCategory, meetingCategory])
    }
    
    // MARK: - Schedule Task Reminder
    
    func scheduleTaskReminder(task: TaskItem) {
        guard taskRemindersEnabled, let dueDate = task.dueDate else { return }
        
        // Cancel any existing notification for this task
        cancelTaskReminder(taskId: task.id)
        
        let reminderDate = dueDate.addingTimeInterval(-Double(reminderMinutesBefore * 60))
        guard reminderDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "⏰ Task Due Soon"
        content.body = task.title
        content.sound = .default
        content.categoryIdentifier = Self.taskCategory
        content.userInfo = [
            Self.notificationTypeKey: "task",
            Self.taskIdKey: task.id
        ]
        
        // Add subtitle with priority
        let priorityText = task.priority == 2 ? "🔴 High Priority" : task.priority == 1 ? "🟡 Medium" : "🟢 Low"
        content.subtitle = "\(priorityText) · Due \(formatTime(dueDate))"
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: "task-\(task.id)", content: content, trigger: trigger)
        center.add(request) { error in
            if let error { print("Failed to schedule task notification: \(error)") }
        }
    }
    
    func cancelTaskReminder(taskId: String) {
        center.removePendingNotificationRequests(withIdentifiers: ["task-\(taskId)"])
    }
    
    // MARK: - Schedule Event Reminder
    
    func scheduleEventReminder(
        eventId: String,
        title: String,
        startDate: Date,
        endDate: Date?,
        description: String? = nil,
        location: String? = nil,
        meetingLink: String? = nil,
        isAllDay: Bool = false
    ) {
        guard eventRemindersEnabled else { return }
        
        // Cancel existing
        cancelEventReminder(eventId: eventId)
        
        let reminderDate = startDate.addingTimeInterval(-Double(reminderMinutesBefore * 60))
        guard reminderDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = .default
        
        let isMeeting = meetingLink != nil
        content.categoryIdentifier = isMeeting ? Self.meetingCategory : Self.eventCategory
        
        if isAllDay {
            content.subtitle = "All Day Event"
        } else {
            let timeStr = formatTime(startDate)
            if let end = endDate {
                content.subtitle = "\(timeStr) – \(formatTime(end))"
            } else {
                content.subtitle = "Starting at \(timeStr)"
            }
        }
        
        if let desc = description, !desc.isEmpty {
            content.body = desc
        } else if isMeeting {
            content.body = "📹 Meeting starting soon — tap to join"
        } else {
            content.body = "Event starting in \(reminderMinutesBefore) min"
        }
        
        var userInfo: [String: Any] = [
            Self.notificationTypeKey: "event",
            Self.eventIdKey: eventId,
            Self.eventTitleKey: title,
            Self.eventStartKey: startDate.timeIntervalSince1970,
            Self.eventIsAllDayKey: isAllDay
        ]
        if let end = endDate { userInfo[Self.eventEndKey] = end.timeIntervalSince1970 }
        if let desc = description { userInfo[Self.eventDescriptionKey] = desc }
        if let loc = location { userInfo[Self.eventLocationKey] = loc }
        if let link = meetingLink { userInfo[Self.eventMeetingLinkKey] = link }
        content.userInfo = userInfo
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: "event-\(eventId)", content: content, trigger: trigger)
        center.add(request) { error in
            if let error { print("Failed to schedule event notification: \(error)") }
        }
    }
    
    func cancelEventReminder(eventId: String) {
        center.removePendingNotificationRequests(withIdentifiers: ["event-\(eventId)"])
    }
    
    // MARK: - Schedule Upcoming Events (batch)
    
    func scheduleRemindersForUpcomingEvents(_ events: [GoogleCalendarService.GoogleCalendarEvent]) {
        guard eventRemindersEnabled else { return }
        
        let now = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        
        for event in events {
            guard let start = event.startDate, start > now, start < tomorrow else { continue }
            
            scheduleEventReminder(
                eventId: event.id,
                title: event.title,
                startDate: start,
                endDate: event.endDate,
                description: event.description,
                location: event.location,
                meetingLink: event.hangoutLink
            )
        }
    }
    
    // MARK: - Helpers
    
    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
    
    // MARK: - Testing
    
    func sendTestNotification() {
        guard isAuthorized else {
            Logger.w("Cannot send test notification: Not authorized", category: .notifications)
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "✅ Test Notification"
        content.body = "Notifications are working properly!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
        let request = UNNotificationRequest(identifier: "test-notification-\(UUID().uuidString)", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                Logger.e("Failed to send test notification", error: error, category: .notifications)
            } else {
                Logger.i("Test notification scheduled successfully", category: .notifications)
            }
        }
    }
}
