import SwiftUI

struct TaskListView: View {
    @State private var authService = AuthService.shared
    @State private var store = FirestoreService.shared
    enum Filter: String, CaseIterable, CustomStringConvertible {
        case all = "All"
        case today = "Today"
        case upcoming = "Upcoming"
        case done = "Done"
        
        var description: String { self.rawValue }
    }
    
    @State private var selectedFilter: Filter = .all
    @State private var searchText = ""
    @State private var showAddTask = false
    @State private var selectedTask: TaskItem?
    @State private var activeFocusTask: TaskItem?
    
    private var userId: String { authService.currentUser?.uid ?? "" }
    
    private var filteredTasks: [TaskItem] {
        var result = store.tasks
        
        switch selectedFilter {
        case .today:
            result = result.filter { !$0.isCompleted }.filter { task in
                if let due = task.dueDate {
                    return Calendar.current.isDateInToday(due)
                }
                return true
            }
        case .upcoming:
            result = result.filter { !$0.isCompleted }.filter { task in
                if let due = task.dueDate {
                    return !Calendar.current.isDateInToday(due) && due > Date()
                }
                return false
            }
        case .done:
            result = result.filter { $0.isCompleted }
        case .all:
            result = result.filter { !$0.isCompleted }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerSection
                        
                        // Search
                        searchBar
                            .padding(.horizontal, 22)
                            .padding(.bottom, 14)
                        
                        // Filter segments
                        DSSegmentedControl(options: Filter.allCases, selection: $selectedFilter)
                            .padding(.horizontal, 22)
                            .padding(.bottom, 22)
                        
                        // Groups
                        taskGroups
                        
                        if filteredTasks.isEmpty {
                            DSEmptyState(
                                icon: "checkmark.circle",
                                title: searchText.isEmpty ? "Nothing here yet" : "No matches",
                                subtitle: searchText.isEmpty ? "Tap + to add your first task." : "Try a different search."
                            )
                            .padding(.top, 40)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
                .background(DSColor.background)
                
                // FAB
                Button {
                    DSHaptics.medium()
                    showAddTask = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Circle().fill(DSColor.accent))
                        .shadow(color: DSColor.accent.opacity(0.35), radius: 12, y: 8)
                }
                .padding(.trailing, 18)
                .padding(.bottom, 30)
            }
            .toolbar(.hidden)
            .sheet(isPresented: $showAddTask) {
                TaskDetailView(task: nil)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(DSColor.background)
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailView(task: task)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(DSColor.background)
            }
            .fullScreenCover(item: $activeFocusTask) { task in
                FocusView(task: task)
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("To do")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DSColor.textSecondary)
                
                Text("Tasks")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .kerning(-1.2)
            }
            
            Spacer()
            
            Button { DSHaptics.selection() } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(DSColor.surface))
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 22)
        .padding(.top, 60)
        .padding(.bottom, 22)
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(DSColor.textSecondary)
            
            TextField("Search tasks", text: $searchText)
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .kerning(-0.2)
            
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DSColor.textTertiary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(DSColor.surface.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DSColor.hairline, lineWidth: 0.5)
        )
    }
    
    // MARK: - Task Groups
    
    private var taskGroups: some View {
        let sections = ["Today", "Tomorrow", "Later", "Completed"]
        let grouped = Dictionary(grouping: filteredTasks) { task -> String in
            if task.isCompleted { return "Completed" }
            if let due = task.dueDate {
                if Calendar.current.isDateInToday(due) { return "Today" }
                if Calendar.current.isDateInTomorrow(due) { return "Tomorrow" }
                return "Later"
            }
            return "Today"
        }

        return VStack(spacing: 22) {
            ForEach(sections, id: \.self) { section in
                if let tasks = grouped[section], !tasks.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        DSSectionHeader(section, count: tasks.count)

                        List {
                            ForEach(tasks) { task in
                                taskRow(task, isLast: false)
                                    .listRowBackground(DSColor.surface)
                                    .listRowSeparatorTint(DSColor.hairline)
                                    .listRowInsets(EdgeInsets())
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            DSHaptics.medium()
                                            Task { try? await store.deleteTask(task.id, userId: userId) }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .listStyle(.plain)
                        .scrollDisabled(true)
                        .frame(height: CGFloat(tasks.count) * 58)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(DSColor.hairline, lineWidth: 0.5)
                        )
                        .padding(.horizontal, 18)
                    }
                }
            }
        }
    }
    
    private func taskRow(_ task: TaskItem, isLast: Bool) -> some View {
        Button {
            selectedTask = task
        } label: {
            HStack(spacing: 14) {
                // Checkbox
                Button {
                    DSHaptics.success()
                    var updated = task
                    updated.isCompleted.toggle()
                    Task { try? await store.saveTask(updated, userId: userId) }
                } label: {
                    ZStack {
                        Circle()
                            .stroke(task.isCompleted ? DSColor.accent : DSColor.textTertiary, lineWidth: 1.6)
                            .frame(width: 24, height: 24)
                        
                        if task.isCompleted {
                            Circle()
                                .fill(DSColor.accent)
                                .frame(width: 14, height: 14)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(task.isCompleted ? DSColor.textSecondary : .white)
                        .strikethrough(task.isCompleted)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        if let due = task.dueDate, !task.isCompleted {
                            Text(due.formatted(.dateTime.day().month()))
                                .font(.system(size: 12))
                                .foregroundStyle(Calendar.current.isDateInToday(due) ? DSColor.accent : DSColor.textSecondary)
                        }
                        
                        Text(task.formattedTimeEstimate)
                            .font(.system(size: 12))
                            .foregroundStyle(DSColor.textTertiary)
                        
                        if task.priority == 2 {
                            DSPill(text: "High", color: DSColor.error)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(DSColor.textTertiary.opacity(0.3))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .overlay(alignment: .bottom) {
                if !isLast {
                    Divider()
                        .background(DSColor.hairline)
                        .padding(.leading, 56)
                }
            }
        }
        .swipeActions(edge: .leading) {
            if !task.isCompleted {
                Button {
                    activeFocusTask = task
                } label: {
                    Label("Focus", systemImage: "play.fill")
                }
                .tint(DSColor.accent)
            }
        }
    }
    
    private func priorityIndicator(_ priority: Int) -> some View {
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
}
