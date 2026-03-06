import Foundation
import SwiftData

@Model
final class TransactionItem {
    var title: String
    var amount: Double
    var date: Date
    var category: String
    var isExpense: Bool
    var isRecurring: Bool
    var iconName: String
    
    init(
        title: String,
        amount: Double,
        date: Date = Date(),
        category: String = "Other",
        isExpense: Bool = true,
        isRecurring: Bool = false,
        iconName: String = "creditcard"
    ) {
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.isExpense = isExpense
        self.isRecurring = isRecurring
        self.iconName = iconName
    }
    
    var categoryEmoji: String {
        switch category.lowercased() {
        case "food", "dining": return "🍕"
        case "transport", "travel": return "🚗"
        case "shopping": return "🛍️"
        case "entertainment": return "🎮"
        case "bills", "utilities": return "💡"
        case "health": return "💊"
        case "education": return "📚"
        case "subscription": return "🔄"
        case "income", "salary": return "💰"
        default: return "💳"
        }
    }
}
