import SwiftUI

struct TaskListView: View {
    @State private var authService = AuthService.shared
    @State private var store = FirestoreService.shared
    @State private var searchText = ""
    @State private var selectedFilter = 0 // 0: All, 1: Today, 2: Upcoming
    @State private var showAddTask = false
    @State private var selectedTask: TaskItem?
    
    private var userId: String { authService.currentUser?.uid ?? "" }
    
    private var filteredTasks: [TaskItem] {
        var result = store.tasks
        
        switch selectedFilter {
        case 1:
            result = result.filter { task in
                if let due = task.dueDate {
                    return Calendar.current.isDateInToday(due)
                }
                return false
            }
        case 2:
            result = result.filter { task in
                if let due = task.dueDate {
                    return due > Date()
                }
                return false
            }
        default: break
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result.sorted { lhs, rhs in
            if lhs.isCompleted != rhs.isCompleted { return !lhs.isCompleted }
            if lhs.priority != rhs.priority { return lhs.priority > rhs.priority }
            return lhs.createdAt > rhs.createdAt
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Search & filters
                    VStack(spacing: DSSpacing.sm) {
                        HStack(spacing: DSSpacing.sm) {
                            Image(systemName: DSIcon.search)
                                .foregroundStyle(DSColor.textTertiary)
                            TextField("Search tasks...", text: $searchText)
                                .font(DSFont.body())
                                .foregroundStyle(DSColor.textPrimary)
                        }
                        .padding(DSSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: DSRadius.md)
                                .fill(DSColor.surfaceElevated)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DSRadius.md)
                                        .stroke(DSColor.cardBorder, lineWidth: 1)
                                )
                        )
                        
                        Picker("Filter", selection: $selectedFilter) {
                            Text("All").tag(0)
                            Text("Today").tag(1)
                            Text("Upcoming").tag(2)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.top, DSSpacing.xs)
                    .padding(.bottom, DSSpacing.sm)
                    
                    // Task list with swipe actions
                    if filteredTasks.isEmpty {
                        VStack {
                            DSEmptyState(
                                icon: "checkmark.circle",
                                title: selectedFilter == 0 && searchText.isEmpty ? "No tasks yet" : "No matching tasks",
                                subtitle: "Tap + to create your first task",
                                actionTitle: "Add Task"
                            ) {
                                showAddTask = true
                            }
                            .glassCard()
                            Spacer()
                        }
                        .padding(.horizontal, DSSpacing.md)
                    } else {
                        List {
                            ForEach(filteredTasks) { task in
                                taskCard(task)
                                    .onTapGesture {
                                        DSHaptics.selection()
                                        selectedTask = task
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            DSHaptics.error()
                                            Task { try? await store.deleteTask(task.id, userId: userId) }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button {
                                            DSHaptics.success()
                                            var updated = task
                                            updated.isCompleted.toggle()
                                            Task { try? await store.saveTask(updated, userId: userId) }
                                        } label: {
                                            Label(
                                                task.isCompleted ? "Undo" : "Done",
                                                systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark"
                                            )
                                        }
                                        .tint(DSColor.success)
                                    }
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.visible, edges: .bottom)
                                    .listRowSeparatorTint(DSColor.cardBorder)
                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
                .background(DSColor.background)
                
                // FAB
                Button {
                    DSHaptics.medium()
                    showAddTask = true
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
            .navigationTitle("Tasks")
            .sheet(isPresented: $showAddTask) {
                TaskDetailView(task: nil)
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailView(task: task)
            }
        }
    }
    
    private func taskCard(_ task: TaskItem) -> some View {
        HStack(spacing: DSSpacing.md) {
            Button {
                DSHaptics.success()
                var updated = task
                updated.isCompleted.toggle()
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
                    .foregroundStyle(task.isCompleted ? DSColor.textTertiary : .white)
                    .strikethrough(task.isCompleted)
                    .lineLimit(1)
                
                HStack(spacing: DSSpacing.xs) {
                    if let due = task.dueDate {
                        HStack(spacing: 2) {
                            Image(systemName: "calendar")
                            Text(due, format: .dateTime.month(.abbreviated).day())
                        }
                        .font(DSFont.captionSmall())
                        .foregroundStyle(due < Date() && !task.isCompleted ? DSColor.error : DSColor.textTertiary)
                    }
                    
                    Text(task.formattedTimeEstimate)
                        .font(DSFont.captionSmall())
                        .foregroundStyle(DSColor.textTertiary)
                    
                    priorityIndicator(task.priority)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(DSColor.textTertiary.opacity(0.5))
        }
        .padding(.vertical, DSSpacing.md)
        .padding(.horizontal, DSSpacing.md)
    }
    
    private func priorityIndicator(_ priority: Int) -> some View {
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
}
