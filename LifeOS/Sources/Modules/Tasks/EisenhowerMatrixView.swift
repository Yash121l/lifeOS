import SwiftUI
import SwiftData

struct EisenhowerMatrixView: View {
    @Query private var tasks: [TaskItem]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                MatrixQuadrantView(title: "Do First", color: .red, tasks: urgentImportant)
                MatrixQuadrantView(title: "Schedule", color: .blue, tasks: notUrgentImportant)
            }
            HStack(spacing: 0) {
                MatrixQuadrantView(title: "Delegate", color: .orange, tasks: urgentNotImportant)
                MatrixQuadrantView(title: "Don't Do", color: .gray, tasks: notUrgentNotImportant)
            }
        }
        .navigationTitle("Eisenhower Matrix")
    }
    
    private var urgentImportant: [TaskItem] { tasks.filter { $0.priority == 2 && isUrgent($0) } }
    private var notUrgentImportant: [TaskItem] { tasks.filter { $0.priority == 2 && !isUrgent($0) } }
    private var urgentNotImportant: [TaskItem] { tasks.filter { $0.priority < 2 && isUrgent($0) } }
    private var notUrgentNotImportant: [TaskItem] { tasks.filter { $0.priority < 2 && !isUrgent($0) } }
    
    private func isUrgent(_ task: TaskItem) -> Bool {
        guard let due = task.dueDate else { return false }
        return due.timeIntervalSinceNow < 172800 // 48 hours
    }
}

struct MatrixQuadrantView: View {
    let title: String
    let color: Color
    let tasks: [TaskItem]
    
    var body: some View {
        VStack {
            Text(title).font(.headline).foregroundColor(color)
            List(tasks) { task in
                Text(task.title).font(.caption)
            }
            .listStyle(.plain)
        }
        .padding(4)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .border(Color.secondary, width: 0.5)
    }
}
