import Foundation

struct TaskItem: Codable, Identifiable, Hashable {
    var id: String
    var userId: String
    var title: String
    var priority: Int // 0: Low, 1: Medium, 2: High
    var dueDate: Date?
    var isCompleted: Bool
    var energyLevel: Int // 1: Low, 2: Medium, 3: High
    var timeEstimateMinutes: Int
    var notes: String
    var urgency: Int // 0: Not urgent, 1: Urgent (Eisenhower)
    var projectId: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        userId: String = "",
        title: String,
        priority: Int = 1,
        dueDate: Date? = nil,
        isCompleted: Bool = false,
        energyLevel: Int = 2,
        timeEstimateMinutes: Int = 30,
        notes: String = "",
        urgency: Int = 0,
        projectId: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.priority = priority
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.energyLevel = energyLevel
        self.timeEstimateMinutes = timeEstimateMinutes
        self.notes = notes
        self.urgency = urgency
        self.projectId = projectId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var energyColor: String {
        switch energyLevel {
        case 1: return "low"
        case 3: return "high"
        default: return "medium"
        }
    }
    
    var priorityLabel: String {
        switch priority {
        case 0: return "Low"
        case 2: return "High"
        default: return "Medium"
        }
    }
    
    var formattedTimeEstimate: String {
        if timeEstimateMinutes < 60 {
            return "\(timeEstimateMinutes)m"
        } else {
            let hours = timeEstimateMinutes / 60
            let mins = timeEstimateMinutes % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
    }
}
