import SwiftUI
import Combine

// Unified Event Model
struct UnifiedEvent: Identifiable {
    let id: String
    let title: String
    let startTime: Date
    let endTime: Date
    let isAllDay: Bool
    let color: Color
    let isGoogleEvent: Bool
    let rawGoogleEvent: GoogleCalendarService.GoogleCalendarEvent?
    let rawTimeBlock: TimeBlock?
    
    // Layout attributes computed during rendering
    var column: Int = 0
    var totalColumns: Int = 1
}

@MainActor
final class TimeViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var currentTime = Date()
    @Published var layoutEvents: [UnifiedEvent] = []
    
    // Services
    private var authService: AuthService?
    private var database: FirestoreService?
    private var calService: GoogleCalendarService?
    
    // Raw Data
    private var googleEvents: [GoogleCalendarService.GoogleCalendarEvent] = []
    private var timeBlocks: [TimeBlock] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    func setup(auth: AuthService, database: FirestoreService, calService: GoogleCalendarService = .shared) {
        self.authService = auth
        self.database = database
        self.calService = calService
        
        // Listen to database changes using Observation framework
        startObservingDatabase()
            
        // Timer for current time
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.currentTime = date
            }
            .store(in: &cancellables)
    }
    
    private func startObservingDatabase() {
        guard let db = database else { return }
        withObservationTracking {
            let blocks = db.timeBlocks
            DispatchQueue.main.async { [weak self] in
                self?.timeBlocks = blocks
                self?.calculateLayout()
            }
        } onChange: { [weak self] in
            DispatchQueue.main.async {
                self?.startObservingDatabase()
            }
        }
    }
    
    func changeDate(_ date: Date) {
        selectedDate = date
        Task {
            await loadGoogleEvents()
            calculateLayout()
        }
    }
    
    func loadGoogleEvents() async {
        guard let calService = calService, calService.isConnected else { return }
        let cal = Calendar.current
        let start = cal.date(byAdding: .day, value: -3, to: cal.startOfDay(for: selectedDate)) ?? selectedDate
        let end = cal.date(byAdding: .day, value: 4, to: cal.startOfDay(for: selectedDate)) ?? selectedDate
        
        let events = await calService.fetchEventsRange(from: start, to: end)
        self.googleEvents = events
        calculateLayout()
    }
    
    // Computed properties for the view
    var datesThisWeek: [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (-3...3).compactMap { cal.date(byAdding: .day, value: $0, to: today) }
    }
    
    var calendarEventsForSelectedDate: [GoogleCalendarService.GoogleCalendarEvent] {
        googleEvents.filter { event in
            guard let start = event.startDate else { return false }
            return Calendar.current.isDate(start, inSameDayAs: selectedDate)
        }
    }
    
    func hasEvents(on date: Date) -> Bool {
        let hasTimeBlocks = timeBlocks.contains { Calendar.current.isDate($0.startTime, inSameDayAs: date) }
        let hasCalEvents = googleEvents.contains { event in
            guard let start = event.startDate else { return false }
            return Calendar.current.isDate(start, inSameDayAs: date)
        }
        return hasTimeBlocks || hasCalEvents
    }
    
    // MARK: - Unified Layout Algorithm
    
    func calculateLayout() {
        var merged: [UnifiedEvent] = []
        
        // 1. Convert TimeBlocks
        for block in timeBlocks where Calendar.current.isDate(block.startTime, inSameDayAs: selectedDate) {
            merged.append(UnifiedEvent(
                id: block.id,
                title: block.title,
                startTime: block.startTime,
                endTime: block.endTime,
                isAllDay: false,
                color: Color(hex: block.colorHex),
                isGoogleEvent: false,
                rawGoogleEvent: nil,
                rawTimeBlock: block
            ))
        }
        
        // 2. Convert Google Events (exclude all day for main grid)
        for event in googleEvents {
            guard let start = event.startDate, Calendar.current.isDate(start, inSameDayAs: selectedDate), !event.isAllDay, let end = event.endDate else { continue }
            merged.append(UnifiedEvent(
                id: event.id,
                title: event.title,
                startTime: start,
                endTime: end,
                isAllDay: false,
                color: Color(red: 0.26, green: 0.52, blue: 0.96),
                isGoogleEvent: true,
                rawGoogleEvent: event,
                rawTimeBlock: nil
            ))
        }
        
        // 3. Sort by start time, then by end time descending (longest first)
        merged.sort { a, b in
            if a.startTime != b.startTime { return a.startTime < b.startTime }
            return a.endTime > b.endTime
        }
        
        // 4. Overlap Grouping Algorithm
        var result: [UnifiedEvent] = []
        var currentGroup: [UnifiedEvent] = []
        var groupEnd: Date = .distantPast
        
        for event in merged {
            if event.startTime >= groupEnd && !currentGroup.isEmpty {
                result.append(contentsOf: layoutGroup(currentGroup))
                currentGroup = []
                groupEnd = event.endTime
            } else {
                groupEnd = max(groupEnd, event.endTime)
            }
            currentGroup.append(event)
        }
        
        // Flush remaining
        if !currentGroup.isEmpty {
            result.append(contentsOf: layoutGroup(currentGroup))
        }
        
        self.layoutEvents = result
    }
    
    private func layoutGroup(_ group: [UnifiedEvent]) -> [UnifiedEvent] {
        var columns: [[Date]] = []
        var assignedEvents: [UnifiedEvent] = []
        
        for var event in group {
            var placed = false
            for colIdx in 0..<columns.count {
                if let lastEnd = columns[colIdx].last, event.startTime >= lastEnd {
                    columns[colIdx].append(event.endTime)
                    event.column = colIdx
                    placed = true
                    break
                }
            }
            
            if !placed {
                columns.append([event.endTime])
                event.column = columns.count - 1
            }
            assignedEvents.append(event)
        }
        
        let totalColumns = columns.count
        return assignedEvents.map { var e = $0; e.totalColumns = totalColumns; return e }
    }
}
