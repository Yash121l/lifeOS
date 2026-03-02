import Foundation
import SwiftData

@Model
final class TimeBlock {
    var title: String
    var startTime: Date
    var endTime: Date
    
    // Optional link to a task
    var linkedTaskId: String?
    
    init(title: String, startTime: Date, endTime: Date, linkedTaskId: String? = nil) {
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.linkedTaskId = linkedTaskId
    }
}
