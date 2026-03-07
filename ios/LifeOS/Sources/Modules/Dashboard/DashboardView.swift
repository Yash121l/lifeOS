import SwiftUI

struct DashboardView: View {
    @State private var authService = AuthService.shared
    @State private var store = FirestoreService.shared
    @State private var showSettings = false
    
    private var userId: String { authService.currentUser?.uid ?? "" }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }
    
    private var todaysBlocks: [TimeBlock] {
        store.timeBlocks
            .filter { Calendar.current.isDateInToday($0.startTime) }
            .sorted { $0.startTime < $1.startTime }
    }
    
    private var currentBlock: TimeBlock? {
        let now = Date()
        return todaysBlocks.first { $0.startTime <= now && $0.endTime > now }
    }
    
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
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            Text("\(greeting),")
                .font(DSFont.subheadline())
                .foregroundStyle(DSColor.textSecondary)
            
            Text(authService.displayName)
                .font(DSFont.largeTitle())
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
            miniStat(value: "\(todaysBlocks.count)", label: "Events", icon: "calendar", tint: DSColor.cyan)
        }
    }
    
    private func miniStat(value: String, label: String, icon: String, tint: Color) -> some View {
        VStack(spacing: DSSpacing.xs) {
            HStack(spacing: DSSpacing.xxs) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(tint)
                Text(value)
                    .font(DSFont.title())
                    .foregroundStyle(.white)
            }
            Text(label)
                .font(DSFont.captionSmall())
                .foregroundStyle(DSColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .glassCard(tint: tint, padding: DSSpacing.sm)
    }
    
    // MARK: - Timeline
    
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            DSSectionHeader("Today's Schedule", count: todaysBlocks.count)
            
            if todaysBlocks.isEmpty {
                DSEmptyState(icon: "calendar", title: "No events today", subtitle: "Your schedule is clear")
                    .glassCard()
            } else {
                VStack(spacing: DSSpacing.xs) {
                    ForEach(todaysBlocks) { block in
                        timeBlockRow(block)
                    }
                }
            }
        }
    }
    
    private func timeBlockRow(_ block: TimeBlock) -> some View {
        let isCurrent = currentBlock?.id == block.id
        let blockColor = Color(hex: block.colorHex)
        
        return HStack(spacing: DSSpacing.sm) {
            // Time
            VStack(alignment: .trailing, spacing: 2) {
                Text(block.startTime, format: .dateTime.hour().minute())
                    .font(DSFont.caption())
                    .foregroundStyle(DSColor.textSecondary)
                Text(block.endTime, format: .dateTime.hour().minute())
                    .font(DSFont.captionSmall())
                    .foregroundStyle(DSColor.textTertiary)
            }
            .frame(width: 50, alignment: .trailing)
            
            // Color bar
            RoundedRectangle(cornerRadius: 2)
                .fill(blockColor)
                .frame(width: 3)
                .padding(.vertical, 4)
            
            // Content
            VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                Text(block.title)
                    .font(DSFont.headline())
                    .foregroundStyle(.white)
                
                HStack(spacing: DSSpacing.xs) {
                    Text(block.formattedDuration)
                        .font(DSFont.captionSmall())
                        .foregroundStyle(DSColor.textTertiary)
                    
                    if isCurrent {
                        Text("NOW")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(blockColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(blockColor.opacity(0.15)))
                    }
                }
            }
            
            Spacer()
        }
        .padding(DSSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(DSColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.md)
                        .fill(blockColor.opacity(isCurrent ? 0.08 : 0.02))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.md)
                        .stroke(isCurrent ? blockColor.opacity(0.3) : DSColor.cardBorder, lineWidth: 1)
                )
        )
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
            // Complete button
            Button {
                DSHaptics.success()
                var updated = task
                updated.isCompleted = true
                Task { try? await store.saveTask(updated, userId: userId) }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(task.isCompleted ? DSColor.success : DSColor.textTertiary)
            }
            
            VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                Text(task.title)
                    .font(DSFont.body())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                HStack(spacing: DSSpacing.xs) {
                    if let due = task.dueDate {
                        HStack(spacing: 2) {
                            Image(systemName: "calendar")
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
        .glassCard(padding: DSSpacing.sm)
    }
    
    private func priorityBadge(_ priority: Int) -> some View {
        let (label, color): (String, Color) = {
            switch priority {
            case 0: return ("Low", DSColor.success)
            case 2: return ("High", DSColor.error)
            default: return ("Med", DSColor.amber)
            }
        }()
        
        return Text(label)
            .font(.system(size: 9, weight: .semibold, design: .rounded))
            .foregroundStyle(color)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Capsule().fill(color.opacity(0.12)))
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
