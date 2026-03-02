import Foundation
import SwiftData

class NLPTaskParser {
    static func parse(input: String) -> TaskItem {
        let title = input
        var priority = 1
        var dueDate: Date? = nil
        let lowerInput = input.lowercased()
        
        if lowerInput.contains("urgent") || lowerInput.contains("high priority") {
            priority = 2
        } else if lowerInput.contains("low priority") {
            priority = 0
        }
        
        if lowerInput.contains("tomorrow") {
            dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        } else if lowerInput.contains("next week") {
            dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        }
        
        return TaskItem(title: title, priority: priority, dueDate: dueDate, isCompleted: false)
    }
}
