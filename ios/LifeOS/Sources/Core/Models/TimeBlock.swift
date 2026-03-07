import Foundation

struct TimeBlock: Codable, Identifiable, Hashable {
    var id: String
    var userId: String
    var title: String
    var startTime: Date
    var endTime: Date
    var colorHex: String
    var isCompleted: Bool
    var blockType: String // deepWork, meeting, personal, routine
    var linkedTaskId: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        userId: String = "",
        title: String,
        startTime: Date,
        endTime: Date,
        linkedTaskId: String? = nil,
        colorHex: String = "007AFF",
        isCompleted: Bool = false,
        blockType: String = "deepWork",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.linkedTaskId = linkedTaskId
        self.colorHex = colorHex
        self.isCompleted = isCompleted
        self.blockType = blockType
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var durationMinutes: Int {
        Int(endTime.timeIntervalSince(startTime) / 60)
    }
    
    var formattedDuration: String {
        let mins = durationMinutes
        if mins < 60 {
            return "\(mins)m"
        } else {
            let hours = mins / 60
            let remaining = mins % 60
            return remaining > 0 ? "\(hours)h \(remaining)m" : "\(hours)h"
        }
    }
}
