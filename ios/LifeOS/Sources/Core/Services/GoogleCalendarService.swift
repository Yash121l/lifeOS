import Foundation

/// Direct Google Calendar REST API service — works cross-platform (same events on iOS & Android)
@Observable
final class GoogleCalendarService {
    static let shared = GoogleCalendarService()
    
    private let baseURL = "https://www.googleapis.com/calendar/v3"
    
    // MARK: - State
    var isConnected = false
    var isSyncing = false
    var lastSyncDate: Date?
    var syncedEventCount = 0
    var calendarList: [GoogleCalendar] = []
    var events: [GoogleCalendarEvent] = []
    var selectedCalendarId = "primary"
    var userEmail: String?
    
    /// Google OAuth access token — set after Google Sign-In
    var accessToken: String? {
        didSet {
            isConnected = accessToken != nil
            if isConnected { Task { await fetchCalendarList() } }
        }
    }
    
    private init() {
        lastSyncDate = UserDefaults.standard.object(forKey: "lastGoogleCalendarSync") as? Date
    }
    
    // MARK: - Models
    
    struct GoogleCalendar: Identifiable, Codable {
        let id: String
        let summary: String
        let backgroundColor: String?
        let primary: Bool?
        let accessRole: String?
    }
    
    struct GoogleCalendarEvent: Identifiable, Codable {
        let id: String
        let summary: String?
        let description: String?
        let start: EventDateTime?
        let end: EventDateTime?
        let status: String?
        let htmlLink: String?
        let colorId: String?
        let location: String?
        let hangoutLink: String?
        let attendees: [GoogleAttendee]?
        
        var title: String { summary ?? "Untitled" }
        
        var startDate: Date? {
            if let dateTime = start?.dateTime {
                return ISO8601DateFormatter().date(from: dateTime)
            }
            if let dateStr = start?.date {
                let fmt = DateFormatter()
                fmt.dateFormat = "yyyy-MM-dd"
                return fmt.date(from: dateStr)
            }
            return nil
        }
        
        var endDate: Date? {
            if let dateTime = end?.dateTime {
                return ISO8601DateFormatter().date(from: dateTime)
            }
            if let dateStr = end?.date {
                let fmt = DateFormatter()
                fmt.dateFormat = "yyyy-MM-dd"
                return fmt.date(from: dateStr)
            }
            return nil
        }
        
        var isAllDay: Bool { start?.date != nil }
    }
    
    struct EventDateTime: Codable {
        let dateTime: String?
        let date: String?
        let timeZone: String?
    }
    
    struct GoogleAttendee: Codable, Identifiable {
        var id: String { email ?? UUID().uuidString }
        let email: String?
        let displayName: String?
        let responseStatus: String?
        let selfAttendee: Bool?
        
        enum CodingKeys: String, CodingKey {
            case email
            case displayName
            case responseStatus
            case selfAttendee = "self"
        }
    }
    
    private struct CalendarListResponse: Codable {
        let items: [GoogleCalendar]?
    }
    
    private struct EventsListResponse: Codable {
        let items: [GoogleCalendarEvent]?
    }
    
    // MARK: - Calendar List
    
    func fetchCalendarList() async {
        guard let token = accessToken else { return }
        
        guard let url = URL(string: "\(baseURL)/users/me/calendarList") else { return }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(CalendarListResponse.self, from: data)
            await MainActor.run {
                calendarList = response.items ?? []
                if let primary = calendarList.first(where: { $0.primary == true }) {
                    selectedCalendarId = primary.id
                }
            }
        } catch {
            Logger.e("Failed to fetch calendar list: \(error)", category: .network)
        }
    }
    
    // MARK: - Fetch Events
    
    func fetchEvents(for date: Date) async {
        guard let token = accessToken else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let formatter = ISO8601DateFormatter()
        let timeMin = formatter.string(from: startOfDay)
        let timeMax = formatter.string(from: endOfDay)
        
        guard let url = URL(string: "\(baseURL)/calendars/\(selectedCalendarId)/events?timeMin=\(timeMin)&timeMax=\(timeMax)&singleEvents=true&orderBy=startTime") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(EventsListResponse.self, from: data)
            await MainActor.run {
                events = response.items?.filter { $0.status != "cancelled" } ?? []
            }
        } catch {
            Logger.e("Failed to fetch events: \(error)", category: .network)
        }
    }
    
    func fetchEventsRange(from start: Date, to end: Date) async -> [GoogleCalendarEvent] {
        guard let token = accessToken else { return [] }
        
        let formatter = ISO8601DateFormatter()
        let timeMin = formatter.string(from: start)
        let timeMax = formatter.string(from: end)
        
        guard let url = URL(string: "\(baseURL)/calendars/\(selectedCalendarId)/events?timeMin=\(timeMin)&timeMax=\(timeMax)&singleEvents=true&orderBy=startTime&maxResults=50") else { return [] }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(EventsListResponse.self, from: data)
            return response.items?.filter { $0.status != "cancelled" } ?? []
        } catch {
            Logger.e("Failed to fetch events range: \(error)", category: .network)
            return []
        }
    }
    
    // MARK: - Create Event
    
    func createEvent(title: String, startDate: Date, endDate: Date, description: String? = nil) async -> Bool {
        guard let token = accessToken else { return false }
        
        guard let url = URL(string: "\(baseURL)/calendars/\(selectedCalendarId)/events") else { return false }
        
        let formatter = ISO8601DateFormatter()
        
        let body: [String: Any] = [
            "summary": title,
            "description": description ?? "",
            "start": ["dateTime": formatter.string(from: startDate), "timeZone": TimeZone.current.identifier],
            "end": ["dateTime": formatter.string(from: endDate), "timeZone": TimeZone.current.identifier]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            Logger.e("Failed to create event: \(error)", category: .network)
            return false
        }
    }
    
    // MARK: - Delete Event
    
    func deleteEvent(_ eventId: String) async -> Bool {
        guard let token = accessToken else { return false }
        
        guard let url = URL(string: "\(baseURL)/calendars/\(selectedCalendarId)/events/\(eventId)") else { return false }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            return code == 204 || code == 200
        } catch {
            Logger.e("Failed to delete event: \(error)", category: .network)
            return false
        }
    }
    
    // MARK: - Full Sync
    
    func performSync() async {
        await MainActor.run { isSyncing = true }
        
        // Sync ±3 days from today (matches the date strip)
        let cal = Calendar.current
        let now = Date()
        let start = cal.date(byAdding: .day, value: -3, to: cal.startOfDay(for: now))!
        let end = cal.date(byAdding: .day, value: 4, to: cal.startOfDay(for: now))!
        let fetched = await fetchEventsRange(from: start, to: end)
        
        await MainActor.run {
            events = fetched
            syncedEventCount = fetched.count
            lastSyncDate = Date()
            isSyncing = false
            UserDefaults.standard.set(lastSyncDate, forKey: "lastGoogleCalendarSync")
            
            // Schedule notifications for upcoming events
            NotificationManager.shared.scheduleRemindersForUpcomingEvents(fetched)
        }
    }
    
    // MARK: - Disconnect
    
    func disconnect() {
        accessToken = nil
        isConnected = false
        calendarList = []
        events = []
        syncedEventCount = 0
        userEmail = nil
    }
}
