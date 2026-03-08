import SwiftUI

struct TimeView: View {
    @State private var authService = AuthService.shared
    @State private var store = FirestoreService.shared
    @State private var calService = GoogleCalendarService.shared
    @State private var selectedDate = Date()
    @State private var showAddEvent = false
    @State private var currentTime = Date()
    @State private var googleEvents: [GoogleCalendarService.GoogleCalendarEvent] = []
    @State private var selectedEventPayload: NotificationPayload?
    
    // MARK: - Unified Event Model
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
    
    // MARK: - Layout State
    @State private var layoutEvents: [UnifiedEvent] = []
    
    private var userId: String { authService.currentUser?.uid ?? "" }
    
    // Timer to update current time line
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    private var datesThisWeek: [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (-3...3).compactMap { cal.date(byAdding: .day, value: $0, to: today) }
    }
    
    private var blocksForSelectedDate: [TimeBlock] {
        store.timeBlocks
            .filter { Calendar.current.isDate($0.startTime, inSameDayAs: selectedDate) }
            .sorted { $0.startTime < $1.startTime }
    }
    
    /// Google Calendar events filtered for the selected date
    private var calendarEventsForSelectedDate: [GoogleCalendarService.GoogleCalendarEvent] {
        googleEvents.filter { event in
            guard let start = event.startDate else { return false }
            return Calendar.current.isDate(start, inSameDayAs: selectedDate)
        }
    }
    
    private let startHour = 0
    private let endHour = 24
    private let hourHeight: CGFloat = 60
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Date strip
                    dateStrip
                    
                    Divider().overlay(DSColor.cardBorder)
                    
                    // Timeline
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            ZStack(alignment: .topLeading) {
                                // Hour grid
                                hourGrid
                                
                                // All-day Google Events at top
                                allDayEventsBanner
                                
                                // Unified overlapping blocks
                                unifiedBlocksOverlay
                                
                                // Current time indicator
                                if Calendar.current.isDateInToday(selectedDate) {
                                    currentTimeIndicator
                                }
                            }
                            .frame(height: CGFloat(endHour - startHour) * hourHeight)
                            .padding(.horizontal, DSSpacing.md)
                        }
                        .onAppear {
                            // Scroll to current hour
                            let hour = Calendar.current.component(.hour, from: Date())
                            let targetHour = max(0, hour - 2)
                            proxy.scrollTo(targetHour, anchor: .top)
                        }
                    }
                }
                .background(DSColor.background)
                
                // FAB
                Button {
                    DSHaptics.medium()
                    showAddEvent = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Circle().fill(DSGradient.accent))
                        .shadow(color: DSColor.accent.opacity(0.4), radius: 12, y: 4)
                }
                .padding(.trailing, DSSpacing.lg)
                .padding(.bottom, DSSpacing.lg)
            }
            .navigationTitle("Schedule")
            .sheet(isPresented: $showAddEvent) {
                EventEntryView()
            }
            .sheet(item: $selectedEventPayload) { payload in
                NotificationDetailView(payload: payload)
            }
            .onReceive(timer) { _ in
                currentTime = Date()
            }
            .task {
                await loadGoogleEvents()
                calculateLayout()
            }
            .onChange(of: selectedDate) { _, _ in
                Task {
                    await loadGoogleEvents()
                    calculateLayout()
                }
            }
            .onChange(of: store.timeBlocks) { _, _ in
                calculateLayout()
            }
        }
    }
    
    // MARK: - Load Google Calendar Events
    
    private func loadGoogleEvents() async {
        guard calService.isConnected else { return }
        let cal = Calendar.current
        let start = cal.date(byAdding: .day, value: -3, to: cal.startOfDay(for: Date()))!
        let end = cal.date(byAdding: .day, value: 4, to: cal.startOfDay(for: Date()))!
        let events = await calService.fetchEventsRange(from: start, to: end)
        await MainActor.run { googleEvents = events }
    }
    
    // MARK: - Date Strip
    
    private var dateStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.sm) {
                ForEach(datesThisWeek, id: \.self) { date in
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                    let isToday = Calendar.current.isDateInToday(date)
                    
                    Button {
                        DSHaptics.selection()
                        withAnimation(DSAnimation.springQuick) { selectedDate = date }
                    } label: {
                        VStack(spacing: DSSpacing.xxs) {
                            Text(date, format: .dateTime.weekday(.abbreviated))
                                .font(DSFont.captionSmall())
                                .foregroundStyle(isSelected ? .white : DSColor.textTertiary)
                            
                            Text(date, format: .dateTime.day())
                                .font(DSFont.headline())
                                .foregroundStyle(isSelected ? .white : DSColor.textPrimary)
                            
                            // Event indicator dot — shows if there are time blocks OR google events
                            let hasTimeBlocks = store.timeBlocks.contains { Calendar.current.isDate($0.startTime, inSameDayAs: date) }
                            let hasCalEvents = googleEvents.contains { event in
                                guard let start = event.startDate else { return false }
                                return Calendar.current.isDate(start, inSameDayAs: date)
                            }
                            let hasEvents = hasTimeBlocks || hasCalEvents
                            
                            Circle()
                                .fill(hasEvents ? (isSelected ? .white : DSColor.accent) : .clear)
                                .frame(width: 4, height: 4)
                        }
                        .frame(width: 44, height: 72)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(LinearGradient(colors: [DSColor.accent, DSColor.accent.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .shadow(color: DSColor.accent.opacity(0.4), radius: 8, x: 0, y: 4)
                            } else if isToday {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(DSColor.surfaceElevated)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22)
                                            .stroke(DSColor.accent.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
        }
    }
    
    // MARK: - Hour Grid
    
    private var hourGrid: some View {
        VStack(spacing: 0) {
            ForEach(startHour..<endHour, id: \.self) { hour in
                HStack(alignment: .top, spacing: DSSpacing.sm) {
                    // Time label
                    Text(formatHour(hour))
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(DSColor.textTertiary)
                        .frame(width: 44, alignment: .trailing)
                    
                    // Horizontal line
                    VStack {
                        Rectangle()
                            .fill(DSColor.cardBorder)
                            .frame(height: 0.5)
                        Spacer()
                    }
                }
                .frame(height: hourHeight)
                .id(hour)
            }
        }
    }
    
    // MARK: - Unified Layout Algorithm
    
    private func calculateLayout() {
        var merged: [UnifiedEvent] = []
        
        // 1. Convert TimeBlocks
        for block in store.timeBlocks where Calendar.current.isDate(block.startTime, inSameDayAs: selectedDate) {
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
            // If this event starts after the entire group ends, flush the group and start a new one
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
    
    /// Assigns columns to events that overlap
    private func layoutGroup(_ group: [UnifiedEvent]) -> [UnifiedEvent] {
        var columns: [[Date]] = [] // stores end times for each column
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
    
    // MARK: - All Day Banner
    private var allDayEventsBanner: some View {
        GeometryReader { geo in
            let timelineLeading: CGFloat = 56
            let blockWidth = geo.size.width - timelineLeading - DSSpacing.sm
            
            VStack(spacing: 2) {
                ForEach(calendarEventsForSelectedDate.filter { $0.isAllDay }) { event in
                    HStack(spacing: 6) {
                        Image(systemName: "g.circle.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(Color(red: 0.26, green: 0.52, blue: 0.96))
                        Text(event.title)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Spacer()
                        Text("All day")
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, 6)
                    .frame(width: blockWidth)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadius.sm)
                            .fill(Color(red: 0.26, green: 0.52, blue: 0.96).opacity(0.25))
                            .overlay(
                                RoundedRectangle(cornerRadius: DSRadius.sm)
                                    .stroke(Color(red: 0.26, green: 0.52, blue: 0.96).opacity(0.6), lineWidth: 1)
                            )
                    )
                    .offset(x: timelineLeading, y: 2)
                    .onTapGesture {
                        DSHaptics.light()
                        selectedEventPayload = NotificationPayload.fromEvent(event)
                    }
                }
            }
        }
    }
    
    // MARK: - Unified View Layout Layer
    
    private var unifiedBlocksOverlay: some View {
        GeometryReader { geo in
            let timelineLeading: CGFloat = 56
            let fullWidth = geo.size.width - timelineLeading - DSSpacing.sm
            
            ForEach(layoutEvents) { event in
                let yOffset = yPosition(for: event.startTime)
                // Minimal visual height for very short events
                let height = max(hourHeight * 0.4, yPosition(for: event.endTime) - yOffset)
                
                // Calculate column dimensions
                let columnWidth = fullWidth / CGFloat(event.totalColumns)
                let xOffset = timelineLeading + (CGFloat(event.column) * columnWidth)
                
                HStack(spacing: 0) {
                    // Left color bar
                    RoundedRectangle(cornerRadius: 3)
                        .fill(event.color)
                        .frame(width: 4)
                    
                    VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                        HStack(spacing: 4) {
                            if event.isGoogleEvent {
                                Image(systemName: "g.circle.fill")
                                    .font(.system(size: 9))
                                    .foregroundStyle(event.color)
                            }
                            Text(event.title)
                                .font(DSFont.caption())
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                        }
                        
                        // Only show times if height is enough
                        if height > 36 {
                            Text("\(event.startTime, format: .dateTime.hour().minute()) – \(event.endTime, format: .dateTime.hour().minute())")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundStyle(event.color.opacity(0.9))
                        }
                    }
                    .padding(.leading, DSSpacing.xs)
                    .padding(.vertical, DSSpacing.xxs)
                    
                    Spacer()
                }
                .frame(width: columnWidth - 2, height: height) // slight separation between cols
                .background(
                    RoundedRectangle(cornerRadius: DSRadius.sm)
                        .fill(Material.ultraThin)
                        .background(event.color.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: DSRadius.sm)
                                .stroke(event.color.opacity(0.4), lineWidth: 1)
                        )
                )
                .offset(x: xOffset, y: yOffset)
                .onTapGesture {
                    DSHaptics.light()
                    if let google = event.rawGoogleEvent {
                        selectedEventPayload = NotificationPayload.fromEvent(google)
                    } else if let block = event.rawTimeBlock {
                        selectedEventPayload = NotificationPayload(
                            isTask: false,
                            title: block.title,
                            subtitle: nil,
                            badge: block.blockType.capitalized,
                            description: nil,
                            startTime: block.startTime,
                            endTime: block.endTime,
                            priority: nil,
                            energyLevel: nil,
                            timeEstimate: block.durationMinutes,
                            location: nil,
                            meetingLink: nil,
                            htmlLink: nil,
                            taskId: block.linkedTaskId,
                            eventId: block.id,
                            attendees: nil
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Current Time Indicator
    
    private var currentTimeIndicator: some View {
        let yOffset = yPosition(for: currentTime)
        
        return HStack(spacing: 0) {
            // Time label — sits in the same 44pt column as hour labels
            Text(currentTime, format: .dateTime.hour().minute())
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(DSColor.error)
                .frame(width: 44, alignment: .trailing)
                .padding(.trailing, 4)
            
            // Circle dot at start of line
            ZStack {
                Circle()
                    .fill(DSColor.error)
                    .frame(width: 10, height: 10)
                Circle()
                    .fill(DSColor.error.opacity(0.3))
                    .frame(width: 24, height: 24) // Pulses behind it
            }
            .offset(x: -4)
            
            // Line extending to the right
            Rectangle()
                .fill(DSColor.error)
                .frame(height: 2)
                .shadow(color: DSColor.error.opacity(0.5), radius: 2, x: 0, y: 1)
        }
        .offset(y: yOffset - 5)
    }
    
    // MARK: - Helpers
    
    private func yPosition(for date: Date) -> CGFloat {
        let cal = Calendar.current
        let hour = cal.component(.hour, from: date)
        let minute = cal.component(.minute, from: date)
        let totalMinutes = CGFloat((hour - startHour) * 60 + minute)
        return totalMinutes / 60.0 * hourHeight
    }
    
    private func formatHour(_ hour: Int) -> String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let ampm = hour < 12 ? "AM" : "PM"
        return "\(h) \(ampm)"
    }
}
