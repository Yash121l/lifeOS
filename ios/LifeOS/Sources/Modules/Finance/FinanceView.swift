import SwiftUI

struct FinanceView: View {
    @State private var authService = AuthService.shared
    @State private var store = FirestoreService.shared
    @State private var showAddTransaction = false
    @State private var selectedPeriod = 0 // 0: Today, 1: Week, 2: Month
    
    private var userId: String { authService.currentUser?.uid ?? "" }
    
    private var filteredTransactions: [TransactionItem] {
        let cal = Calendar.current
        let now = Date()
        return store.transactions.filter { tx in
            switch selectedPeriod {
            case 0: return cal.isDateInToday(tx.date)
            case 1:
                guard let weekAgo = cal.date(byAdding: .day, value: -7, to: now) else { return false }
                return tx.date >= weekAgo
            case 2:
                guard let monthAgo = cal.date(byAdding: .month, value: -1, to: now) else { return false }
                return tx.date >= monthAgo
            default: return true
            }
        }
    }
    
    private var totalExpenses: Double {
        filteredTransactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalIncome: Double {
        filteredTransactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    private var balance: Double { totalIncome - totalExpenses }
    
    private var categoryBreakdown: [(String, Double, Color)] {
        let expenses = filteredTransactions.filter { $0.isExpense }
        var categories: [String: Double] = [:]
        for tx in expenses { categories[tx.category, default: 0] += tx.amount }
        
        let colors: [Color] = [DSColor.accent, DSColor.coral, DSColor.cyan, DSColor.amber, DSColor.mint, DSColor.info]
        return categories.sorted { $0.value > $1.value }
            .prefix(6)
            .enumerated()
            .map { (index, item) in (item.key, item.value, colors[index % colors.count]) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DSSpacing.xl) {
                        // Period selector
                        HStack(spacing: DSSpacing.xs) {
                            DSChip(label: "Today", isSelected: selectedPeriod == 0) { selectedPeriod = 0 }
                            DSChip(label: "Week", isSelected: selectedPeriod == 1) { selectedPeriod = 1 }
                            DSChip(label: "Month", isSelected: selectedPeriod == 2) { selectedPeriod = 2 }
                            Spacer()
                        }
                        
                        // Summary card
                        summaryCard
                        
                        // Category breakdown
                        if !categoryBreakdown.isEmpty {
                            categorySection
                        }
                        
                        // Recent transactions
                        transactionsList
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.top, DSSpacing.xs)
                }
                .background(DSColor.background)
                
                // FAB
                Button {
                    DSHaptics.medium()
                    showAddTransaction = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Circle().fill(DSGradient.accent))
                        .shadow(color: DSColor.accent.opacity(0.4), radius: 12, y: 4)
                }
                .padding(.trailing, DSSpacing.lg)
                .padding(.bottom, DSSpacing.lg)
            }
            .navigationTitle("Finance")
            .sheet(isPresented: $showAddTransaction) {
                TransactionEntryView()
            }
        }
    }
    
    // MARK: - Summary Card
    
    private var summaryCard: some View {
        VStack(spacing: DSSpacing.md) {
            // Balance
            VStack(spacing: DSSpacing.xxs) {
                Text("Net Balance")
                    .font(DSFont.captionSmall())
                    .foregroundStyle(DSColor.textTertiary)
                Text("₹\(String(format: "%.0f", balance))")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(balance >= 0 ? DSColor.success : DSColor.error)
            }
            
            HStack(spacing: DSSpacing.md) {
                // Income
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "arrow.down.left.circle.fill")
                        .foregroundStyle(DSColor.success)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Income")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                        Text("₹\(String(format: "%.0f", totalIncome))")
                            .font(DSFont.headline())
                            .foregroundStyle(DSColor.success)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Rectangle()
                    .fill(DSColor.cardBorder)
                    .frame(width: 1, height: 30)
                
                // Expenses
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "arrow.up.right.circle.fill")
                        .foregroundStyle(DSColor.error)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Expenses")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                        Text("₹\(String(format: "%.0f", totalExpenses))")
                            .font(DSFont.headline())
                            .foregroundStyle(DSColor.error)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(DSSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.xl)
                .fill(DSColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.xl)
                        .stroke(DSColor.cardBorder, lineWidth: 1)
                )
        )
    }
    
    // MARK: - Category Breakdown
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            DSSectionHeader("Spending by Category")
            
            // Simple bar chart
            VStack(spacing: DSSpacing.xs) {
                ForEach(categoryBreakdown, id: \.0) { category, amount, color in
                    HStack(spacing: DSSpacing.sm) {
                        Text(category)
                            .font(DSFont.caption())
                            .foregroundStyle(DSColor.textSecondary)
                            .frame(width: 80, alignment: .leading)
                        
                        GeometryReader { geo in
                            let maxAmount = categoryBreakdown.first?.1 ?? 1
                            let width = max(4, geo.size.width * (amount / maxAmount))
                            RoundedRectangle(cornerRadius: 3)
                                .fill(color)
                                .frame(width: width, height: 20)
                        }
                        .frame(height: 20)
                        
                        Text("₹\(String(format: "%.0f", amount))")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                            .frame(width: 60, alignment: .trailing)
                    }
                }
            }
            .glassCard()
        }
    }
    
    // MARK: - Transactions List
    
    private var transactionsList: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            DSSectionHeader("Transactions", count: filteredTransactions.count)
                .padding(.horizontal, DSSpacing.md)
            
            if filteredTransactions.isEmpty {
                DSEmptyState(
                    icon: "creditcard",
                    title: "No transactions",
                    subtitle: "Tap + to add your first transaction",
                    actionTitle: "Add Transaction"
                ) {
                    showAddTransaction = true
                }
                .glassCard()
                .padding(.horizontal, DSSpacing.md)
            } else {
                List {
                    ForEach(filteredTransactions) { tx in
                        transactionRow(tx)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    DSHaptics.error()
                                    Task { try? await store.deleteTransaction(tx.id, userId: userId) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .frame(minHeight: CGFloat(filteredTransactions.count) * 72)
            }
        }
    }
    
    private func transactionRow(_ tx: TransactionItem) -> some View {
        HStack(spacing: DSSpacing.sm) {
            // Category icon
            Image(systemName: tx.categoryIcon)
                .font(.system(size: 16, weight: .light))
                .foregroundStyle(DSColor.accent)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: DSRadius.sm)
                        .fill(DSColor.surfaceElevated)
                )
            
            VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                Text(tx.title)
                    .font(DSFont.body())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                HStack(spacing: DSSpacing.xs) {
                    Text(tx.category)
                        .font(DSFont.captionSmall())
                        .foregroundStyle(DSColor.textTertiary)
                    
                    if tx.isRecurring {
                        Image(systemName: DSIcon.recurring)
                            .font(.system(size: 9))
                            .foregroundStyle(DSColor.textTertiary)
                    }
                    
                    Text(tx.date, format: .dateTime.month(.abbreviated).day())
                        .font(DSFont.captionSmall())
                        .foregroundStyle(DSColor.textTertiary)
                }
            }
            
            Spacer()
            
            Text("\(tx.isExpense ? "-" : "+")₹\(String(format: "%.0f", tx.amount))")
                .font(DSFont.headline())
                .foregroundStyle(tx.isExpense ? DSColor.error : DSColor.success)
        }
        .glassCard(padding: DSSpacing.sm)
    }
}
