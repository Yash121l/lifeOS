import SwiftUI

struct TimeView: View {
    @State private var authService = AuthService.shared
    @State private var store = FirestoreService.shared
    @State private var calService = GoogleCalendarService.shared
    @State private var selectedDate = Date()
    @State private var showAddEvent = false
    @State private var currentTime = Date()
    @State private var googleEvents: [GoogleCalendarService.GoogleCalendarEvent] = []
    
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
                                
                                // Google Calendar event blocks
                                googleEventBlocksOverlay
                                
                                // LifeOS time blocks overlay
                                eventBlocksOverlay
                                
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
            .onReceive(timer) { _ in
                currentTime = Date()
            }
            .task {
                await loadGoogleEvents()
            }
            .onChange(of: selectedDate) { _, _ in
                Task { await loadGoogleEvents() }
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
                        .background(
                            RoundedRectangle(cornerRadius: DSRadius.md)
                                .fill(isSelected ? DSColor.accent : (isToday ? DSColor.surfaceElevated : .clear))
                                .overlay(
                                    RoundedRectangle(cornerRadius: DSRadius.md)
                                        .stroke(isToday && !isSelected ? DSColor.accent.opacity(0.3) : .clear, lineWidth: 1)
                                )
                        )
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
    
    // MARK: - Google Calendar Event Blocks
    
    private var googleEventBlocksOverlay: some View {
        GeometryReader { geo in
            let timelineLeading: CGFloat = 56
            let blockWidth = geo.size.width - timelineLeading - DSSpacing.sm
            
            ForEach(calendarEventsForSelectedDate) { event in
                if let startDate = event.startDate, let endDate = event.endDate, !event.isAllDay {
                    let yOffset = yPosition(for: startDate)
                    let height = max(hourHeight * 0.4, yPosition(for: endDate) - yOffset)
                    let eventColor = Color(red: 0.26, green: 0.52, blue: 0.96) // Google blue
                    
                    HStack(spacing: 0) {
                        // Color bar
                        RoundedRectangle(cornerRadius: 3)
                            .fill(eventColor)
                            .frame(width: 4)
                        
                        // Content
                        VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                            HStack(spacing: 4) {
                                Image(systemName: "g.circle.fill")
                                    .font(.system(size: 9))
                                    .foregroundStyle(eventColor)
                                Text(event.title)
                                    .font(DSFont.caption())
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                            }
                            
                            if height > 36 {
                                Text("\(startDate, format: .dateTime.hour().minute()) – \(endDate, format: .dateTime.hour().minute())")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }
                        .padding(.leading, DSSpacing.xs)
                        .padding(.vertical, DSSpacing.xxs)
                        
                        Spacer()
                    }
                    .frame(width: blockWidth, height: height)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadius.sm)
                            .fill(eventColor.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: DSRadius.sm)
                                    .stroke(eventColor.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .offset(x: timelineLeading, y: yOffset)
                }
                
                // All-day events banner at the top
                if event.isAllDay {
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
                            .fill(Color(red: 0.26, green: 0.52, blue: 0.96).opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: DSRadius.sm)
                                    .stroke(Color(red: 0.26, green: 0.52, blue: 0.96).opacity(0.3), lineWidth: 1)
                            )
                    )
                    .offset(x: timelineLeading, y: 2)
                }
            }
        }
    }
    
    // MARK: - LifeOS Event Blocks Overlay
    
    private var eventBlocksOverlay: some View {
        GeometryReader { geo in
            let timelineLeading: CGFloat = 56  // time label + spacing
            let blockWidth = geo.size.width - timelineLeading - DSSpacing.sm
            
            ForEach(blocksForSelectedDate) { block in
                let yOffset = yPosition(for: block.startTime)
                let height = max(hourHeight * 0.4, yPosition(for: block.endTime) - yOffset)
                let color = Color(hex: block.colorHex)
                
                HStack(spacing: 0) {
                    // Color bar
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: 4)
                    
                    // Content
                    VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                        Text(block.title)
                            .font(DSFont.caption())
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        
                        if height > 36 {
                            Text("\(block.startTime, format: .dateTime.hour().minute()) – \(block.endTime, format: .dateTime.hour().minute())")
                                .font(.system(size: 9))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .padding(.leading, DSSpacing.xs)
                    .padding(.vertical, DSSpacing.xxs)
                    
                    Spacer()
                }
                .frame(width: blockWidth, height: height)
                .background(
                    RoundedRectangle(cornerRadius: DSRadius.sm)
                        .fill(color.opacity(0.18))
                        .overlay(
                            RoundedRectangle(cornerRadius: DSRadius.sm)
                                .stroke(color.opacity(0.3), lineWidth: 1)
                        )
                )
                .offset(x: timelineLeading, y: yOffset)
            }
        }
    }
    
    // MARK: - Current Time Indicator
    
    private var currentTimeIndicator: some View {
        let yOffset = yPosition(for: currentTime)
        
        return HStack(spacing: 0) {
            // Time label — sits in the same 44pt column as hour labels
            Text(currentTime, format: .dateTime.hour().minute())
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(DSColor.error)
                .frame(width: 44, alignment: .trailing)
                .padding(.trailing, 4)
            
            // Circle dot at start of line
            Circle()
                .fill(DSColor.error)
                .frame(width: 8, height: 8)
            
            // Line extending to the right
            Rectangle()
                .fill(DSColor.error)
                .frame(height: 1.5)
        }
        .offset(y: yOffset - 4)
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
