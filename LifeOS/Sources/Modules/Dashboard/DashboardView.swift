import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \TaskItem.dueDate) private var tasks: [TaskItem]
    @Query(sort: \TimeBlock.startTime) private var blocks: [TimeBlock]
    @Query(sort: \TransactionItem.date, order: .reverse) private var transactions: [TransactionItem]
    
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
        blocks.filter { Calendar.current.isDateInToday($0.startTime) }
            .sorted { $0.startTime < $1.startTime }
    }
    
    private var currentBlock: TimeBlock? {
        let now = Date()
        return todaysBlocks.first { $0.startTime <= now && $0.endTime > now }
    }
    
    private var pendingTasks: [TaskItem] {
        tasks.filter { !$0.isCompleted }
            .sorted { ($0.priority, $0.energyLevel) > ($1.priority, $1.energyLevel) }
            .prefix(3)
            .map { $0 }
    }
    
    private var todaySpend: Double {
        transactions
            .filter { $0.isExpense && Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var totalPendingTasks: Int {
        tasks.filter { !$0.isCompleted }.count
    }
    
    private var energyScore: Int {
        let pending = tasks.filter { !$0.isCompleted }
        guard !pending.isEmpty else { return 1 }
        let avg = Double(pending.map(\.energyLevel).reduce(0, +)) / Double(pending.count)
        return max(1, min(3, Int(avg.rounded())))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DSSpacing.lg) {
                    // MARK: - Header
                    headerSection
                    
                    // MARK: - Timeline
                    timelineSection
                    
                    // MARK: - Up Next Tasks
                    upNextSection
                    
                    // MARK: - Finance Snapshot
                    financeSection
                    
                    // Bottom spacer for tab bar
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.xs)
            }
            .background(DSColor.background)
            .navigationTitle("Dashboard")
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(greeting + ", Yash")
                .font(DSFont.largeTitle())
                .foregroundStyle(DSColor.textPrimary)
            
            HStack(spacing: DSSpacing.sm) {
                Text(Date(), format: .dateTime.weekday(.wide).month(.wide).day())
                    .font(DSFont.subheadline())
                    .foregroundStyle(DSColor.textSecondary)
                
                Spacer()
                
                // Energy indicator
                HStack(spacing: DSSpacing.xxs) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 11))
                    Text(energyLabel)
                        .font(DSFont.caption())
                }
                .foregroundStyle(energyColor)
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xxs)
                .background(
                    Capsule().fill(energyColor.opacity(0.15))
                )
            }
        }
        .padding(.top, DSSpacing.xs)
    }
    
    private var energyLabel: String {
        switch energyScore {
        case 1: return "Light"
        case 3: return "Intense"
        default: return "Moderate"
        }
    }
    
    private var energyColor: Color {
        switch energyScore {
        case 1: return DSColor.energyLow
        case 3: return DSColor.energyHigh
        default: return DSColor.energyMedium
        }
    }
    
    // MARK: - Timeline Section
    
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            sectionHeader(title: "Today's Schedule", count: todaysBlocks.count)
            
            if todaysBlocks.isEmpty {
                emptyState(icon: "calendar", message: "No events scheduled today")
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
            // Time column
            VStack(alignment: .trailing, spacing: 2) {
                Text(block.startTime, format: .dateTime.hour().minute())
                    .font(DSFont.caption())
                    .foregroundStyle(DSColor.textSecondary)
                Text(block.endTime, format: .dateTime.hour().minute())
                    .font(DSFont.captionSmall())
                    .foregroundStyle(DSColor.textTertiary)
            }
            .frame(width: 52, alignment: .trailing)
            
            // Accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(blockColor)
                .frame(width: 3)
                .padding(.vertical, 4)
            
            // Content
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(block.title)
                    .font(DSFont.headline())
                    .foregroundStyle(DSColor.textPrimary)
                
                HStack(spacing: DSSpacing.xs) {
                    Text(block.formattedDuration)
                        .font(DSFont.captionSmall())
                        .foregroundStyle(DSColor.textTertiary)
                    
                    if isCurrent {
                        Text("NOW")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(DSColor.accent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule().fill(DSColor.accent.opacity(0.15))
                            )
                    }
                }
            }
            
            Spacer()
        }
        .padding(DSSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.md)
                        .fill(blockColor.opacity(isCurrent ? 0.08 : 0.03))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.md)
                        .stroke(isCurrent ? blockColor.opacity(0.3) : DSColor.cardBorder, lineWidth: isCurrent ? 1 : 0.5)
                )
        )
        .shadow(color: isCurrent ? blockColor.opacity(0.15) : .clear, radius: 8, y: 2)
    }
    
    // MARK: - Up Next Section
    
    private var upNextSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            sectionHeader(title: "Up Next", count: totalPendingTasks)
            
            if pendingTasks.isEmpty {
                emptyState(icon: "checkmark.circle", message: "All caught up!")
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
            // Priority indicator
            Circle()
                .fill(priorityColor(task.priority))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                Text(task.title)
                    .font(DSFont.body())
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: DSSpacing.xs) {
                    if let due = task.dueDate {
                        HStack(spacing: 2) {
                            Image(systemName: "calendar")
                            Text(due, format: .dateTime.month(.abbreviated).day())
                        }
                        .font(DSFont.captionSmall())
                        .foregroundStyle(DSColor.textTertiary)
                    }
                    
                    Text(task.formattedTimeEstimate)
                        .font(DSFont.captionSmall())
                        .foregroundStyle(DSColor.textTertiary)
                }
            }
            
            Spacer()
            
            // Energy dots
            energyDots(task.energyLevel)
        }
        .glassCard(padding: DSSpacing.sm)
    }
    
    private func energyDots(_ level: Int) -> some View {
        HStack(spacing: 3) {
            ForEach(1...3, id: \.self) { i in
                Circle()
                    .fill(i <= level ? energyDotColor(level) : DSColor.textTertiary.opacity(0.3))
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
    
    private func priorityColor(_ priority: Int) -> Color {
        switch priority {
        case 0: return DSColor.energyLow
        case 2: return DSColor.error
        default: return DSColor.accent
        }
    }
    
    // MARK: - Finance Section
    
    private var financeSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            sectionHeader(title: "Finance", count: nil)
            
            HStack(spacing: DSSpacing.sm) {
                // Today's spend
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("Today")
                        .font(DSFont.captionSmall())
                        .foregroundStyle(DSColor.textTertiary)
                    
                    Text("$\(todaySpend, specifier: "%.2f")")
                        .font(DSFont.title())
                        .foregroundStyle(todaySpend > 0 ? DSColor.error : DSColor.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard(tint: DSColor.error, padding: DSSpacing.md)
                
                // Net worth
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("Net Worth")
                        .font(DSFont.captionSmall())
                        .foregroundStyle(DSColor.textTertiary)
                    
                    Text("$10,400")
                        .font(DSFont.title())
                        .foregroundStyle(DSColor.success)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard(tint: DSColor.success, padding: DSSpacing.md)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func sectionHeader(title: String, count: Int?) -> some View {
        HStack {
            Text(title)
                .font(DSFont.headline())
                .foregroundStyle(DSColor.textPrimary)
            
            if let count = count, count > 0 {
                Text("\(count)")
                    .font(DSFont.captionSmall())
                    .foregroundStyle(DSColor.textTertiary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule().fill(DSColor.surfaceLight)
                    )
            }
            
            Spacer()
        }
    }
    
    private func emptyState(icon: String, message: String) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(DSColor.textTertiary)
            
            Text(message)
                .font(DSFont.subheadline())
                .foregroundStyle(DSColor.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(padding: DSSpacing.md)
    }
}

#Preview {
    DashboardView()
}
