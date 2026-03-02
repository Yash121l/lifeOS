import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var task: TaskItem
    
    var body: some View {
        Form {
            TextField("Task Title", text: $task.title)
            
            Picker("Priority", selection: $task.priority) {
                Text("Low").tag(0)
                Text("Medium").tag(1)
                Text("High").tag(2)
            }
            
            Toggle("Completed", isOn: $task.isCompleted)
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if task.modelContext == nil {
                        modelContext.insert(task)
                    }
                    dismiss()
                }
                .disabled(task.title.isEmpty)
            }
        }
    }
}
