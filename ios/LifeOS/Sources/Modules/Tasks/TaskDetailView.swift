import SwiftUI

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var authService = AuthService.shared
    @State private var store = FirestoreService.shared
    
    @State private var title: String
    @State private var notes: String
    @State private var priority: Int
    @State private var energyLevel: Int
    @State private var timeEstimate: Int
    @State private var urgency: Int
    @State private var dueDate: Date
    @State private var hasDueDate: Bool
    @State private var showCustomTime = false
    
    private let existingTask: TaskItem?
    private var userId: String { authService.currentUser?.uid ?? "" }
    
    private var isNew: Bool { existingTask == nil }
    
    init(task: TaskItem?) {
        self.existingTask = task
        _title = State(initialValue: task?.title ?? "")
        _notes = State(initialValue: task?.notes ?? "")
        _priority = State(initialValue: task?.priority ?? 1)
        _energyLevel = State(initialValue: task?.energyLevel ?? 2)
        _timeEstimate = State(initialValue: task?.timeEstimateMinutes ?? 30)
        _urgency = State(initialValue: task?.urgency ?? 0)
        _dueDate = State(initialValue: task?.dueDate ?? Date())
        _hasDueDate = State(initialValue: task?.dueDate != nil)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Task Name", text: $title)
                        .font(.headline)
                    
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                }
                
                Section {
                    Picker("Priority", selection: $priority) {
                        Text("Low").tag(0)
                        Text("Medium").tag(1)
                        Text("High").tag(2)
                    }
                    
                    Picker("Energy Level", selection: $energyLevel) {
                        Text("Low").tag(1)
                        Text("Medium").tag(2)
                        Text("High").tag(3)
                    }
                    
                    Picker("Estimate", selection: $timeEstimate) {
                        Text("15m").tag(15)
                        Text("30m").tag(30)
                        Text("45m").tag(45)
                        Text("1h").tag(60)
                        Text("2h").tag(120)
                    }
                }
                
                Section {
                    Toggle("Has Due Date", isOn: $hasDueDate.animation())
                    
                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                if !isNew {
                    Section {
                        Button(role: .destructive) {
                            DSHaptics.error()
                            Task {
                                try? await store.deleteTask(existingTask!.id, userId: userId)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Task")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isNew ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveTask() }
                        .fontWeight(.bold)
                        .disabled(title.isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func saveTask() {
        DSHaptics.success()
        var task = existingTask ?? TaskItem(title: title)
        task.title = title
        task.priority = priority
        task.energyLevel = energyLevel
        task.timeEstimateMinutes = timeEstimate
        task.urgency = urgency
        task.notes = notes
        task.dueDate = hasDueDate ? dueDate : nil
        task.updatedAt = .now
        
        Task {
            try? await store.saveTask(task, userId: userId)
            dismiss()
        }
    }
    
    private func formatTime(_ minutes: Int) -> String {
        if minutes < 60 { return "\(minutes)m" }
        let h = minutes / 60
        let m = minutes % 60
        return m > 0 ? "\(h)h \(m)m" : "\(h)h"
    }
}
