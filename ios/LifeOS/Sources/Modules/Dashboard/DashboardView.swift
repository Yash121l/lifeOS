import SwiftUI

struct DashboardView: View {
    @State private var authService = AuthService.shared
    @State private var store = FirestoreService.shared
    @State private var calService = GoogleCalendarService.shared
    @State private var showSettings = false
    @State private var showAnalytics = false
    @State private var focusTimer = FocusTimerManager.shared
    
    private var userId: String { authService.currentUser?.uid ?? "" }
    
    private var greetingWithIcon: (String, String) {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return ("Good Morning", "sun.max.fill")
        case 12..<17: return ("Good Afternoon", "sun.haze.fill")
        case 17..<21: return ("Good Evening", "sunset.fill")
        default: return ("Good Night", "moon.stars.fill")
        }
    }
    
    
    // MARK: - Unified Schedule
    
    struct UnifiedEvent: Identifiable {
        let id: String
        let title: String
        let startTime: Date
        let endTime: Date
        let colorHex: String
        let isGoogleEvent: Bool
        let hasLink: Bool
        
        var formattedDuration: String {
            let mins = Int(endTime.timeIntervalSince(startTime) / 60)
            if mins < 60 { return "\(mins)m" }
            let h = mins / 60
            let m = mins % 60
            return m > 0 ? "\(h)h \(m)m" : "\(h)h"
        }
    }
    
    private var todaysEvents: [UnifiedEvent] {
        var merged: [UnifiedEvent] = []
        let now = Date()
        
        // Add TimeBlocks
        let blocks = store.timeBlocks.filter { Calendar.current.isDateInToday($0.startTime) }
        merged.append(contentsOf: blocks.map {
            UnifiedEvent(id: $0.id, title: $0.title, startTime: $0.startTime, endTime: $0.endTime, colorHex: $0.colorHex, isGoogleEvent: false, hasLink: false)
        })
        
        // Add Google Events
        let events = calService.events.filter { event in
            guard let start = event.startDate else { return false }
            return Calendar.current.isDateInToday(start) && !event.isAllDay
        }
        
        merged.append(contentsOf: events.compactMap { event -> UnifiedEvent? in
            guard let start = event.startDate, let end = event.endDate else { return nil }
            return UnifiedEvent(
                id: event.id,
                title: event.title,
                startTime: start,
                endTime: end,
                colorHex: "#4285F4", // Google Blue
                isGoogleEvent: true,
                hasLink: event.hangoutLink != nil
            )
        })
        
        return merged.sorted { $0.startTime < $1.startTime }
    }
    
    private var currentEvent: UnifiedEvent? {
        let now = Date()
        return todaysEvents.first { $0.startTime <= now && $0.endTime > now }
    }
    
    // MARK: - Task Stats
    
    private var pendingTasks: [TaskItem] {
        Array(store.tasks
            .filter { !$0.isCompleted }
            .sorted { ($0.priority, $0.energyLevel) > ($1.priority, $1.energyLevel) }
            .prefix(5))
    }
    
    private var completedToday: Int {
        store.tasks.filter { $0.isCompleted && Calendar.current.isDateInToday($0.updatedAt) }.count
    }
    
    private var todaySpend: Double {
        store.transactions
            .filter { $0.isExpense && Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var todayIncome: Double {
        store.transactions
            .filter { !$0.isExpense && Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var todayFocusMinutes: Int {
        store.focusSessions
            .filter { Calendar.current.isDateInToday($0.startedAt) }
            .reduce(0) { $0 + ($1.durationSeconds / 60) }
    }
    
    private var dateStr: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.horizontal, DSSpacing.md)
                        .padding(.top, 40)
                    
                    sublineSection
                        .padding(.horizontal, DSSpacing.md)
                        .padding(.top, 14)
                        .padding(.bottom, 18)
                    
                    focusHeroSection
                        .padding(.horizontal, DSSpacing.md)
                        .padding(.bottom, 24)
                    
                    statsRow
                        .padding(.horizontal, DSSpacing.md)
                        .padding(.bottom, 20)
                    
                    analyticsTeaser
                        .padding(.horizontal, DSSpacing.md)
                        .padding(.bottom, 28)
                    
                    upNextSection
                        .padding(.horizontal, DSSpacing.md)
                    
                    Spacer(minLength: 120)
                }
            }
            .background(DSColor.background)
            .toolbar(.hidden)
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showAnalytics) {
                FocusAnalyticsView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(DSColor.background)
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        let (greeting, _) = greetingWithIcon
        return HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(dateStr)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DSColor.textSecondary)
                
                (Text("\(greeting), ").foregroundStyle(Color.white)
                + Text(authService.displayName).foregroundStyle(DSColor.textSecondary))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
            }
            
            Spacer()
            
            HStack(spacing: DSSpacing.sm) {
                Button {
                    DSHaptics.selection()
                } label: {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(DSColor.surface))
                        .overlay(
                            Circle()
                                .fill(DSColor.accent)
                                .frame(width: 8, height: 8)
                                .offset(x: 10, y: -10)
                        )
                }
                
                Button {
                    DSHaptics.selection()
                    showSettings = true
                } label: {
                    DSAvatar(initials: authService.initials, size: 40)
                }
            }
        }
    }
    
    private var sublineSection: some View {
        Group {
            if pendingTasks.isEmpty {
                Text("All caught up. Enjoy the quiet.")
            } else {
                Text("You have ")
                + Text("\(pendingTasks.count) \(pendingTasks.count == 1 ? "task" : "tasks")").bold().foregroundStyle(.white)
                + Text(" and ")
                + Text("\(todaysEvents.count) \(todaysEvents.count == 1 ? "event" : "events")").bold().foregroundStyle(.white)
                + Text(" today.")
            }
        }
        .font(.system(size: 15))
        .foregroundStyle(DSColor.textSecondary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Focus Hero
    
    // MARK: - Focus Hero (Inline Timer)

    private var focusHeroSection: some View {
        Group {
            if focusTimer.hasActiveSession {
                // Active timer card — matches the design reference
                inlineTimerCard
            } else if let focus = pendingTasks.first {
                // Idle state — tap to start
                idleFocusCard(focus)
            }
        }
    }

    private var inlineTimerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header row
            HStack(spacing: 8) {
                Circle()
                    .fill(focusTimer.isRunning ? DSColor.error : DSColor.warning)
                    .frame(width: 6, height: 6)
                    .opacity(focusTimer.isRunning ? 1 : 0.6)
                Text(focusTimer.isRunning ? "FOCUSING" : "PAUSED")
                    .font(.system(size: 12, weight: .bold))
                    .kerning(0.6)
                    .foregroundStyle(focusTimer.isRunning ? DSColor.error : DSColor.warning)
                Spacer()
                Text("Goal · \(focusTimer.goalFormatted)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DSColor.textTertiary)
            }

            // Task title
            Text(focusTimer.taskTitle)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(2)

            // Big elapsed clock
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(focusTimer.elapsedFormatted)
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                Text("/ \(focusTimer.goalFormatted)")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(DSColor.textTertiary)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(DSColor.surfaceElevated)
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(DSColor.accent)
                        .frame(width: geo.size.width * focusTimer.progress, height: 4)
                        .animation(.linear(duration: 0.5), value: focusTimer.progress)
                }
            }
            .frame(height: 4)

            // Percentage + remaining
            HStack {
                Text("\(Int(focusTimer.progress * 100))% complete")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DSColor.accent)
                Spacer()
                Text("\(focusTimer.remainingFormatted) left")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(DSColor.textTertiary)
            }

            // Pause / End buttons
            HStack(spacing: 10) {
                Button {
                    DSHaptics.selection()
                    if focusTimer.isRunning { focusTimer.pause() }
                    else { focusTimer.resume() }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: focusTimer.isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text(focusTimer.isRunning ? "Pause" : "Resume")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(DSColor.surfaceElevated)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button {
                    DSHaptics.medium()
                    focusTimer.end(saveToFirebase: true)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text("End")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(DSColor.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.top, 4)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [DSColor.accent.opacity(0.18), DSColor.surface],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(DSColor.accent.opacity(0.25), lineWidth: 0.5)
                )
        )
    }

    private func idleFocusCard(_ focus: TaskItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(DSColor.accent)
                    .frame(width: 6, height: 6)
                Text("FOCUS NEXT")
                    .font(.system(size: 12, weight: .bold))
                    .kerning(0.6)
                    .foregroundStyle(DSColor.accent)
            }

            Text(focus.title)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Label(focus.formattedTimeEstimate, systemImage: "clock")
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(DSColor.accent.opacity(0.15))
                    .foregroundStyle(DSColor.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                if focus.priority == 2 {
                    Label("High", systemImage: "flame.fill")
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "FF6A4A").opacity(0.15))
                        .foregroundStyle(Color(hex: "FF6A4A"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            HStack {
                Text(focus.formattedTimeEstimate)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    DSHaptics.medium()
                    focusTimer.start(
                        taskId: focus.id,
                        title: focus.title,
                        goalMinutes: focus.timeEstimateMinutes
                    )
                } label: {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(Circle().fill(DSColor.accent))
                }
            }
            .padding(.top, 8)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [DSColor.accent.opacity(0.15), DSColor.surface],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(DSColor.hairline, lineWidth: 0.5)
                )
        )
    }
    
    // MARK: - Stats Row
    
    private var statsRow: some View {
        HStack(spacing: 10) {
            statCard(value: "\(pendingTasks.count)", label: "Pending", hue: DSColor.warning)
        statCard(value: "\(completedToday)", label: "Done", hue: DSColor.success)
        statCard(value: "\(todaysEvents.count)", label: "Events", hue: DSColor.info)
        }
    }
    
    private func statCard(value: String, label: String, hue: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Circle()
                .fill(hue)
                .frame(width: 8, height: 8)
                .padding(.bottom, 6)
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text(label)
                .font(.system(size: 12.5))
                .foregroundStyle(DSColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(DSColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(DSColor.hairline, lineWidth: 0.5)
                )
        )
    }
    
    private var analyticsTeaser: some View {
        Button {
            DSHaptics.light()
            showAnalytics = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(DSColor.accent)
                    .frame(width: 36, height: 36)
                    .background(RoundedRectangle(cornerRadius: 12).fill(DSColor.accent.opacity(0.15)))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Focus analytics")
                        .font(.system(size: 14.5, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    if todayFocusMinutes > 0 {
                        Text("\(todayFocusMinutes)m focused today")
                            .font(.system(size: 12.5))
                            .foregroundStyle(DSColor.textSecondary)
                    } else {
                        Text("See your week, streaks, and history")
                            .font(.system(size: 12.5))
                            .foregroundStyle(DSColor.textSecondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(DSColor.textTertiary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(DSColor.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(DSColor.hairline, lineWidth: 0.5)
                    )
            )
        }
    }
    // MARK: - Timeline
    
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            DSSectionHeader("Today's Schedule", count: todaysEvents.count)
            
            if todaysEvents.isEmpty {
                DSEmptyState(icon: "calendar", title: "No events today", subtitle: "Your schedule is clear")
                    .glassCard()
            } else {
                VStack(spacing: DSSpacing.xs) {
                    ForEach(todaysEvents) { event in
                        timeBlockRow(event)
                    }
                }
            }
        }
    }
    
    private func timeBlockRow(_ block: UnifiedEvent) -> some View {
        let isCurrent = currentEvent?.id == block.id
        let blockColor = Color(hex: block.colorHex)
        
        return HStack(spacing: 0) {
            // Time constraints (fixed width column)
            VStack(alignment: .trailing, spacing: 2) {
                Text(block.startTime, format: .dateTime.hour().minute())
                    .font(DSFont.caption())
                    .foregroundStyle(isCurrent ? blockColor : DSColor.textSecondary)
                    .fontWeight(isCurrent ? .bold : .regular)
                Text(block.endTime, format: .dateTime.hour().minute())
                    .font(DSFont.captionSmall())
                    .foregroundStyle(DSColor.textTertiary)
            }
            .frame(width: 50, alignment: .trailing)
            .padding(.trailing, DSSpacing.sm)
            
            // Continuous Timeline aesthetic
            ZStack {
                Rectangle()
                    .fill(DSColor.cardBorder)
                    .frame(width: 2)
                
                if isCurrent {
                    Circle()
                        .fill(blockColor)
                        .frame(width: 10, height: 10)
                        .background(
                            Circle()
                                .fill(blockColor.opacity(0.3))
                                .frame(width: 20, height: 20)
                        )
                } else {
                    Circle()
                        .fill(blockColor)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(width: 24)
            .padding(.trailing, DSSpacing.xs)
            
            // Event Bubble
            HStack {
                VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                    HStack(spacing: DSSpacing.xs) {
                        Text(block.title)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        
                        if block.isGoogleEvent {
                            Image(systemName: "link.circle.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.white.opacity(0.7))
                        }
                    }
                    
                    HStack(spacing: DSSpacing.xs) {
                        Text(block.formattedDuration)
                            .font(DSFont.captionSmall())
                            .foregroundStyle(blockColor.opacity(0.8))
                        
                        if block.hasLink {
                            Image(systemName: "video.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(blockColor.opacity(0.8))
                        }
                    }
                }
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, DSSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .fill(blockColor.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.md)
                            .stroke(blockColor.opacity(isCurrent ? 0.4 : 0.1), lineWidth: 1)
                    )
            )
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Up Next
    
    private var upNextSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            DSSectionHeader("Up Next", count: store.tasks.filter { !$0.isCompleted }.count)
            
            if pendingTasks.isEmpty {
                DSEmptyState(icon: "checkmark.circle", title: "All caught up!", subtitle: "No pending tasks")
                    .glassCard()
            } else {
                VStack(spacing: DSSpacing.xs) {
                    ForEach(pendingTasks) { task in
                        taskRow(task)
                    }
                }
            }
        }
    }
    
    private func taskRow(_ task: TaskItem) -> some View {
        HStack(spacing: DSSpacing.sm) {
            // Glowing Complete button
            Button {
                DSHaptics.success()
                var updated = task
                updated.isCompleted = true
                Task { try? await store.saveTask(updated, userId: userId) }
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(DSColor.accent.opacity(0.5), lineWidth: 1.5)
                        .background(Circle().fill(DSColor.accent.opacity(0.1)))
                        .frame(width: 24, height: 24)
                    
                    if task.isCompleted {
                        Circle()
                            .fill(DSColor.accent)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                Text(task.title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                HStack(spacing: DSSpacing.xs) {
                    if let due = task.dueDate {
                        HStack(spacing: 2) {
                            Image(systemName: "clock")
                            Text(due, format: .dateTime.month(.abbreviated).day())
                        }
                        .font(DSFont.captionSmall())
                        .foregroundStyle(due < Date() ? DSColor.error : DSColor.textTertiary)
                    }
                    
                    priorityBadge(task.priority)
                }
            }
            
            Spacer()
            
            energyDots(task.energyLevel)
        }
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(DSColor.surfaceElevated.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.lg)
                        .stroke(DSColor.cardBorder.opacity(0.5), lineWidth: 1)
                )
        )
    }
    
    private func priorityBadge(_ priority: Int) -> some View {
        let (label, color, icon): (String, Color, String) = {
            switch priority {
            case 0: return ("Low", DSColor.success, "arrow.down")
            case 2: return ("High", DSColor.error, "flame.fill")
            default: return ("Med", DSColor.warning, "minus")
            }
        }()
        
        return HStack(spacing: 2) {
            Image(systemName: icon)
            Text(label)
        }
        .font(.system(size: 10, weight: .bold, design: .rounded))
        .foregroundStyle(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Capsule().fill(color.opacity(0.15)))
    }
    
    private func energyDots(_ level: Int) -> some View {
        HStack(spacing: 3) {
            ForEach(1...3, id: \.self) { i in
                Circle()
                    .fill(i <= level ? energyDotColor(level) : DSColor.textTertiary.opacity(0.2))
                    .frame(width: 5, height: 5)
            }
        }
    }
    
    private func energyDotColor(_ level: Int) -> Color {
        switch level {
        case 1: return DSColor.energyLow
        case 3: return DSColor.energyHigh
        default: return DSColor.energyMedium
        }
    }
    
    // MARK: - Finance
    
    private var financeSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            DSSectionHeader("Finance")
            
            HStack(spacing: DSSpacing.sm) {
                DSStatCard(
                    title: "Today's Spend",
                    value: "₹\(String(format: "%.0f", todaySpend))",
                    icon: "arrow.up.right",
                    tint: todaySpend > 0 ? DSColor.error : DSColor.textTertiary
                )
                
                DSStatCard(
                    title: "Income",
                    value: "₹\(String(format: "%.0f", todayIncome))",
                    icon: "arrow.down.left",
                    tint: DSColor.success
                )
            }
        }
    }
}

#Preview {
    DashboardView()
}
