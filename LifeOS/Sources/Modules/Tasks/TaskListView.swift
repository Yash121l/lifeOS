import SwiftUI
import SwiftData

enum TaskSegment: String, CaseIterable {
    case today = "Today"
    case upcoming = "Upcoming"
    case projects = "Projects"
    case matrix = "Matrix"
}

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]
    @Query private var projects: [Project]
    @State private var selectedSegment: TaskSegment = .today
    @State private var showingAddTask = false
    
    private var todayTasks: [TaskItem] {
        tasks.filter { task in
            guard !task.isCompleted else { return false }
            guard let due = task.dueDate else { return true }
            return Calendar.current.isDateInToday(due) || due < Date()
        }
        .sorted { $0.priority > $1.priority }
    }
    
    private var upcomingTasks: [TaskItem] {
        tasks.filter { task in
            guard !task.isCompleted, let due = task.dueDate else { return false }
            return due > Date() && !Calendar.current.isDateInToday(due)
        }
        .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // NLP Input
                TaskNLPInputView()
                    .padding(.horizontal, DSSpacing.md)
                
                // Segment picker
                segmentPicker
                
                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DSSpacing.xs) {
                        switch selectedSegment {
                        case .today:
                            tasksList(todayTasks, emptyMessage: "No tasks for today. Enjoy!")
                        case .upcoming:
                            tasksList(upcomingTasks, emptyMessage: "Nothing upcoming")
                        case .projects:
                            projectsList
                        case .matrix:
                            EisenhowerMatrixView()
                                .frame(minHeight: 500)
                        }
                    }
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.bottom, 120)
                }
            }
            .background(DSColor.background)
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(DSColor.accent)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                NavigationStack {
                    TaskDetailView(task: TaskItem(title: ""))
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Segment Picker
    
    private var segmentPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.xs) {
                ForEach(TaskSegment.allCases, id: \.self) { segment in
                    let isSelected = selectedSegment == segment
                    
                    Button {
                        DSHaptics.selection()
                        withAnimation(DSAnimation.springQuick) {
                            selectedSegment = segment
                        }
                    } label: {
                        Text(segment.rawValue)
                            .font(DSFont.caption())
                            .foregroundStyle(isSelected ? .white : DSColor.textSecondary)
                            .padding(.horizontal, DSSpacing.md)
                            .padding(.vertical, DSSpacing.xs)
                            .background(
                                Capsule()
                                    .fill(isSelected ? DSColor.accent : DSColor.surfaceLight)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
        }
    }
    
    // MARK: - Task List
    
    private func tasksList(_ taskItems: [TaskItem], emptyMessage: String) -> some View {
        Group {
            if taskItems.isEmpty {
                emptyState(message: emptyMessage)
            } else {
                ForEach(taskItems) { task in
                    NavigationLink(destination: TaskDetailView(task: task)) {
                        TaskCardView(task: task)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var projectsList: some View {
        Group {
            if projects.isEmpty {
                emptyState(message: "No projects yet")
            } else {
                ForEach(projects) { project in
                    let projectTasks = project.tasks ?? []
                    let completed = projectTasks.filter(\.isCompleted).count
                    
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        HStack {
                            Circle()
                                .fill(Color(hex: project.colorHex))
                                .frame(width: 10, height: 10)
                            
                            Text(project.name)
                                .font(DSFont.headline())
                                .foregroundStyle(DSColor.textPrimary)
                            
                            Spacer()
                            
                            Text("\(completed)/\(projectTasks.count)")
                                .font(DSFont.captionSmall())
                                .foregroundStyle(DSColor.textTertiary)
                        }
                        
                        // Progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(DSColor.surfaceLight)
                                    .frame(height: 4)
                                
                                Capsule()
                                    .fill(Color(hex: project.colorHex))
                                    .frame(width: projectTasks.isEmpty ? 0 : geo.size.width * CGFloat(completed) / CGFloat(projectTasks.count), height: 4)
                            }
                        }
                        .frame(height: 4)
                    }
                    .glassCard(padding: DSSpacing.md)
                }
            }
        }
    }
    
    private func emptyState(message: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 18))
                .foregroundStyle(DSColor.textTertiary)
            Text(message)
                .font(DSFont.subheadline())
                .foregroundStyle(DSColor.textTertiary)
            Spacer()
        }
        .glassCard(padding: DSSpacing.md)
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(tasks[index])
            }
        }
    }
}

// MARK: - Task Card

struct TaskCardView: View {
    let task: TaskItem
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            // Completion button
            Button {
                DSHaptics.success()
                withAnimation(DSAnimation.springQuick) {
                    task.isCompleted.toggle()
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(task.isCompleted ? DSColor.success : DSColor.textTertiary)
            }
            .buttonStyle(.plain)
            
            // Content
            VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                Text(task.title)
                    .font(DSFont.body())
                    .foregroundStyle(task.isCompleted ? DSColor.textTertiary : DSColor.textPrimary)
                    .strikethrough(task.isCompleted, color: DSColor.textTertiary)
                    .lineLimit(1)
                
                HStack(spacing: DSSpacing.xs) {
                    if let due = task.dueDate {
                        Label {
                            Text(due, format: .dateTime.month(.abbreviated).day())
                        } icon: {
                            Image(systemName: "calendar")
                        }
                        .font(DSFont.captionSmall())
                        .foregroundStyle(isDueOverdue(due) ? DSColor.error : DSColor.textTertiary)
                    }
                    
                    // Time estimate
                    Label {
                        Text(task.formattedTimeEstimate)
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .font(DSFont.captionSmall())
                    .foregroundStyle(DSColor.textTertiary)
                }
            }
            
            Spacer()
            
            // Energy dots
            HStack(spacing: 3) {
                ForEach(1...3, id: \.self) { i in
                    Circle()
                        .fill(i <= task.energyLevel ? energyDotColor(task.energyLevel) : DSColor.textTertiary.opacity(0.2))
                        .frame(width: 5, height: 5)
                }
            }
            
            // Priority badge
            if task.priority == 2 {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(DSColor.error)
            }
        }
        .glassCard(padding: DSSpacing.sm)
        .opacity(task.isCompleted ? 0.6 : 1)
    }
    
    private func isDueOverdue(_ date: Date) -> Bool {
        date < Date() && !Calendar.current.isDateInToday(date)
    }
    
    private func energyDotColor(_ level: Int) -> Color {
        switch level {
        case 1: return DSColor.energyLow
        case 3: return DSColor.energyHigh
        default: return DSColor.energyMedium
        }
    }
}
