import Foundation

struct FocusSession: Codable, Identifiable, Hashable {
    var id: String
    var userId: String
    var taskId: String?
    var taskTitle: String
    var startedAt: Date
    var durationSeconds: Int
    var goalSeconds: Int
    var isCompleted: Bool
    var createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        userId: String = "",
        taskId: String? = nil,
        taskTitle: String,
        startedAt: Date = .now,
        durationSeconds: Int,
        goalSeconds: Int,
        isCompleted: Bool,
        createdAt: Date = .now
    ) {
        self.id = id
        self.userId = userId
        self.taskId = taskId
        self.taskTitle = taskTitle
        self.startedAt = startedAt
        self.durationSeconds = durationSeconds
        self.goalSeconds = goalSeconds
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}
