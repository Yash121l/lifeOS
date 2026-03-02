import SwiftUI
import SwiftData

struct FinanceView: View {
    @Query(sort: \TransactionItem.date, order: .reverse) private var transactions: [TransactionItem]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Overview")) {
                    HStack {
                        Text("Net Worth")
                        Spacer()
                        Text("$10,400.00")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }
                
                Section(header: Text("Recent Transactions")) {
                    if transactions.isEmpty {
                        Text("No recent transactions.")
                            .foregroundStyle(.gray)
                    }
                    ForEach(transactions) { tx in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(tx.title).font(.body)
                                Text(tx.category).font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(tx.isExpense ? "-\(tx.amount, specifier: "%.2f")" : "+\(tx.amount, specifier: "%.2f")")
                                .foregroundColor(tx.isExpense ? .red : .green)
                        }
                    }
                }
            }
            .navigationTitle("Finance")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addMockTx) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    private func addMockTx() {
        let expense = TransactionItem(title: "Lunch", amount: 15.50, category: "Food", isExpense: true)
        modelContext.insert(expense)
    }
}

#Preview {
    FinanceView()
}
