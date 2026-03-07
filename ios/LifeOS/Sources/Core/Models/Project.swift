import Foundation

struct Project: Codable, Identifiable, Hashable {
    var id: String
    var userId: String
    var name: String
    var colorHex: String
    var taskIds: [String]
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        userId: String = "",
        name: String,
        colorHex: String = "007AFF",
        taskIds: [String] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.colorHex = colorHex
        self.taskIds = taskIds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
