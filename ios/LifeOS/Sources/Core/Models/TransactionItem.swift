import Foundation

struct TransactionItem: Codable, Identifiable, Hashable {
    var id: String
    var userId: String
    var title: String
    var amount: Double
    var date: Date
    var category: String
    var isExpense: Bool
    var isRecurring: Bool
    var iconName: String
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        userId: String = "",
        title: String,
        amount: Double,
        date: Date = Date(),
        category: String = "Other",
        isExpense: Bool = true,
        isRecurring: Bool = false,
        iconName: String = "creditcard",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.isExpense = isExpense
        self.isRecurring = isRecurring
        self.iconName = iconName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var categoryIcon: String {
        switch category.lowercased() {
        case "food", "dining": return "fork.knife"
        case "transport", "travel": return "car"
        case "shopping": return "bag"
        case "entertainment": return "play.circle"
        case "bills", "utilities": return "bolt"
        case "health": return "heart"
        case "education": return "book"
        case "subscription": return "arrow.2.squarepath"
        case "income", "salary": return "banknote"
        default: return "creditcard"
        }
    }
}
