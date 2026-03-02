import Foundation
import SwiftData

@Model
final class TaskItem {
    var title: String
    var priority: Int // 0: Low, 1: Medium, 2: High
    var dueDate: Date?
    var isCompleted: Bool
    
    @Relationship(inverse: \Project.tasks)
    var project: Project?
    
    init(title: String, priority: Int = 1, dueDate: Date? = nil, isCompleted: Bool = false) {
        self.title = title
        self.priority = priority
        self.dueDate = dueDate
        self.isCompleted = isCompleted
    }
}
