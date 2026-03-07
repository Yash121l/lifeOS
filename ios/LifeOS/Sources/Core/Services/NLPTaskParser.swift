import Foundation

class NLPTaskParser {
    static func parse(input: String) -> TaskItem {
        let title = input
        var priority = 1
        var energyLevel = 2
        var dueDate: Date? = nil
        var urgency = 0
        let lowerInput = input.lowercased()
        
        // Priority detection
        if lowerInput.contains("urgent") || lowerInput.contains("high priority") || lowerInput.contains("important") {
            priority = 2
            urgency = 1
        } else if lowerInput.contains("low priority") || lowerInput.contains("whenever") {
            priority = 0
        }
        
        // Energy detection
        if lowerInput.contains("easy") || lowerInput.contains("quick") || lowerInput.contains("simple") {
            energyLevel = 1
        } else if lowerInput.contains("hard") || lowerInput.contains("complex") || lowerInput.contains("deep") {
            energyLevel = 3
        }
        
        // Date detection
        if lowerInput.contains("tomorrow") {
            dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        } else if lowerInput.contains("next week") {
            dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        } else if lowerInput.contains("today") {
            dueDate = Date()
        }
        
        // Time estimate detection
        var timeEstimate = 30
        if lowerInput.contains("quick") || lowerInput.contains("5 min") {
            timeEstimate = 15
        } else if lowerInput.contains("1 hour") || lowerInput.contains("an hour") {
            timeEstimate = 60
        } else if lowerInput.contains("2 hour") {
            timeEstimate = 120
        }
        
        return TaskItem(
            title: title,
            priority: priority,
            dueDate: dueDate,
            isCompleted: false,
            energyLevel: energyLevel,
            timeEstimateMinutes: timeEstimate,
            urgency: urgency
        )
    }
}
