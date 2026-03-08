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
                        Picker("Period", selection: $selectedPeriod) {
                            Text("Today").tag(0)
                            Text("Week").tag(1)
                            Text("Month").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .padding(.top, DSSpacing.sm)
                        
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
        VStack(spacing: DSSpacing.xl) {
            // Balance
            VStack(spacing: DSSpacing.xs) {
                Text("Net Balance")
                    .font(DSFont.subheadline())
                    .foregroundStyle(.white.opacity(0.8))
                Text("₹\(String(format: "%.0f", balance))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
            }
            
            HStack(spacing: DSSpacing.md) {
                // Income
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "arrow.down.left.circle.fill")
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Income")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(.white.opacity(0.7))
                        Text("₹\(String(format: "%.0f", totalIncome))")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Expenses
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "arrow.up.right.circle.fill")
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Expenses")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(.white.opacity(0.7))
                        Text("₹\(String(format: "%.0f", totalExpenses))")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(DSSpacing.xl)
        .background(
            ZStack {
                LinearGradient(colors: [Color(hex: "#4A00E0"), Color(hex: "#8E2DE2")], startPoint: .topLeading, endPoint: .bottomTrailing)
                
                // Detailed glassmorphic Mesh Overlays
                Circle()
                    .fill(Color(hex: "#ff00cc").opacity(0.4))
                    .frame(width: 200, height: 200)
                    .blur(radius: 50)
                    .offset(x: 100, y: -50)
                
                Circle()
                    .fill(Color(hex: "#333399").opacity(0.5))
                    .frame(width: 150, height: 150)
                    .blur(radius: 40)
                    .offset(x: -80, y: 80)
            }
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.xxl))
        )
        .shadow(color: Color(hex: "#8E2DE2").opacity(0.35), radius: 15, x: 0, y: 10)
    }
    
    // MARK: - Category Breakdown
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            DSSectionHeader("Spending by Category")
            
            VStack(spacing: DSSpacing.md) {
                ForEach(categoryBreakdown, id: \.0) { category, amount, color in
                    VStack(spacing: DSSpacing.xxs) {
                        HStack {
                            Text(category)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.white)
                            Spacer()
                            Text("₹\(String(format: "%.0f", amount))")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(DSColor.textSecondary)
                        }
                        
                        GeometryReader { geo in
                            let maxAmount = categoryBreakdown.first?.1 ?? 1
                            let width = max(4, geo.size.width * (amount / maxAmount))
                            
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(DSColor.surfaceElevated)
                                    .frame(height: 8)
                                    
                                Capsule()
                                    .fill(LinearGradient(colors: [color.opacity(0.8), color], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: width, height: 8)
                                    .shadow(color: color.opacity(0.5), radius: 4, x: 0, y: 0)
                            }
                        }
                        .frame(height: 8)
                    }
                }
            }
            .padding(DSSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.lg)
                    .fill(DSColor.surfaceElevated.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.lg)
                            .stroke(DSColor.cardBorder.opacity(0.5), lineWidth: 1)
                    )
            )
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
                            .listRowSeparator(.visible, edges: .bottom)
                            .listRowSeparatorTint(DSColor.cardBorder)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .frame(minHeight: CGFloat(filteredTransactions.count) * 72)
            }
        }
    }
    
    private func transactionRow(_ tx: TransactionItem) -> some View {
        HStack(spacing: DSSpacing.md) {
            // Category icon with vibrant radial bounds
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(colors: [DSColor.accent.opacity(0.3), DSColor.accent.opacity(0.05)], center: .center, startRadius: 0, endRadius: 20)
                    )
                    .overlay(Circle().stroke(DSColor.accent.opacity(0.2), lineWidth: 1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: tx.categoryIcon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(DSColor.accent)
            }
            
            VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                Text(tx.title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
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
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(tx.isExpense ? .white : DSColor.success)
        }
        .padding(.vertical, DSSpacing.sm)
    }
}
