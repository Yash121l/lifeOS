import Foundation
import SwiftData

@Model
final class TimeBlock {
    var title: String
    var startTime: Date
    var endTime: Date
    var colorHex: String
    var isCompleted: Bool
    var blockType: String // deepWork, meeting, personal, routine
    
    // Optional link to a task
    var linkedTaskId: String?
    
    init(
        title: String,
        startTime: Date,
        endTime: Date,
        linkedTaskId: String? = nil,
        colorHex: String = "007AFF",
        isCompleted: Bool = false,
        blockType: String = "deepWork"
    ) {
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.linkedTaskId = linkedTaskId
        self.colorHex = colorHex
        self.isCompleted = isCompleted
        self.blockType = blockType
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
