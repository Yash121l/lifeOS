import SwiftUI

struct DashboardView: View {
    @State private var authService = AuthService.shared
    @State private var store = FirestoreService.shared
    @State private var calService = GoogleCalendarService.shared
    @State private var showSettings = false
    
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
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DSSpacing.xl) {
                    headerSection
                    statsRow
                    timelineSection
                    upNextSection
                    financeSection
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.xs)
            }
            .background(DSColor.background)
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        DSHaptics.selection()
                        showSettings = true
                    } label: {
                        DSAvatar(initials: authService.initials, size: 32)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .task {
                if calService.isConnected && calService.events.isEmpty {
                    await calService.performSync()
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        let (greeting, icon) = greetingWithIcon
        
        return VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: icon)
                    .foregroundStyle(DSColor.accent)
                    .font(.system(size: 14))
                Text("\(greeting),")
                    .font(DSFont.subheadline())
                    .foregroundStyle(DSColor.textSecondary)
            }
            
            Text(authService.displayName)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, DSSpacing.xs)
    }
    
    // MARK: - Stats Row
    
    private var statsRow: some View {
        HStack(spacing: DSSpacing.sm) {
            miniStat(value: "\(pendingTasks.count)", label: "Pending", icon: "circle", tint: DSColor.amber)
            miniStat(value: "\(completedToday)", label: "Done", icon: "checkmark.circle.fill", tint: DSColor.success)
            miniStat(value: "\(todaysEvents.count)", label: "Events", icon: "calendar", tint: DSColor.cyan)
        }
    }
    
    private func miniStat(value: String, label: String, icon: String, tint: Color) -> some View {
        VStack(spacing: DSSpacing.xs) {
            HStack(spacing: DSSpacing.xxs) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(tint)
                    .shadow(color: tint.opacity(0.5), radius: 4, x: 0, y: 0)
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            Text(label)
                .font(DSFont.captionSmall())
                .foregroundStyle(DSColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(DSColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.lg)
                        .stroke(LinearGradient(colors: [tint.opacity(0.3), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                )
        )
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
            default: return ("Med", DSColor.amber, "minus")
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
