import Foundation
import SwiftData

@Model
final class TransactionItem {
    var title: String
    var amount: Double
    var date: Date
    var category: String
    var isExpense: Bool
    
    init(title: String, amount: Double, date: Date = Date(), category: String = "Other", isExpense: Bool = true) {
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
        self.isExpense = isExpense
    }
}
