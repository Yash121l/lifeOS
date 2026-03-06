import SwiftUI
import SwiftData

struct FinanceView: View {
    @Query(sort: \TransactionItem.date, order: .reverse) private var transactions: [TransactionItem]
    @Environment(\.modelContext) private var modelContext
    @State private var showAddTransaction = false
    
    private var todaySpend: Double {
        transactions
            .filter { $0.isExpense && Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var weeklySpend: Double {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return transactions
            .filter { $0.isExpense && $0.date >= weekAgo }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var monthlyBudget: Double { 2000.00 }
    
    private var monthlySpend: Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        let monthStart = calendar.date(from: components) ?? Date()
        return transactions
            .filter { $0.isExpense && $0.date >= monthStart }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var budgetProgress: Double {
        min(monthlySpend / monthlyBudget, 1.0)
    }
    
    private var recentTransactions: [TransactionItem] {
        Array(transactions.prefix(15))
    }
    
    // Group by date
    private var groupedTransactions: [(String, [TransactionItem])] {
        let grouped = Dictionary(grouping: recentTransactions) { tx in
            if Calendar.current.isDateInToday(tx.date) {
                return "Today"
            } else if Calendar.current.isDateInYesterday(tx.date) {
                return "Yesterday"
            } else {
                return tx.date.formatted(.dateTime.month(.abbreviated).day())
            }
        }
        return grouped.sorted { $0.value.first?.date ?? Date() > $1.value.first?.date ?? Date() }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DSSpacing.lg) {
                    
                    // Grid Layout
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DSSpacing.sm) {
                        netWorthCard
                        budgetRingCard
                    }
                    
                    todaySpendCard
                    
                    // Quick Actions
                    quickActionsRow
                    
                    // AI Insight
                    aiInsightCard
                    
                    // Transactions
                    transactionsSection
                    
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.sm)
            }
            .background(DSColor.background)
            .navigationTitle("Finance")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        DSHaptics.selection()
                        showAddTransaction = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                            .foregroundStyle(DSColor.textSecondary)
                    }
                }
            }
            .sheet(isPresented: $showAddTransaction) {
                TransactionEntryView()
            }
        }
    }
    
    // MARK: - Net Worth Card
    
    private var netWorthCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                Text("Net Worth")
                    .font(DSFont.captionSmall())
                    .foregroundStyle(DSColor.textTertiary)
                
                Spacer()
                
                HStack(spacing: 2) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 8, weight: .bold))
                    Text("+2.4%")
                        .font(.system(size: 10))
                }
                .foregroundStyle(DSColor.success)
            }
            
            Text(SettingsManager.shared.currencySymbol + "10,400")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(DSColor.textPrimary)
                .minimumScaleFactor(0.8)
            
            // Mini chart (decorative)
            miniChart
                .frame(height: 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .glassCard(tint: DSColor.success, padding: DSSpacing.md)
    }
    
    private var miniChart: some View {
        GeometryReader { geo in
            let points: [CGFloat] = [0.3, 0.35, 0.25, 0.4, 0.5, 0.45, 0.55, 0.6, 0.58, 0.65, 0.7, 0.75]
            let width = geo.size.width
            let height = geo.size.height
            
            Path { path in
                for (index, point) in points.enumerated() {
                    let x = width * CGFloat(index) / CGFloat(points.count - 1)
                    let y = height * (1 - point)
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(
                LinearGradient(
                    colors: [DSColor.success.opacity(0.3), DSColor.success],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: 2
            )
            
            // Gradient fill under the line
            Path { path in
                for (index, point) in points.enumerated() {
                    let x = width * CGFloat(index) / CGFloat(points.count - 1)
                    let y = height * (1 - point)
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                path.addLine(to: CGPoint(x: width, y: height))
                path.addLine(to: CGPoint(x: 0, y: height))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [DSColor.success.opacity(0.15), DSColor.success.opacity(0.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    // MARK: - Budget Ring
    
    private var budgetRingCard: some View {
        VStack(spacing: DSSpacing.sm) {
            ZStack {
                Circle()
                    .stroke(DSColor.surfaceLight, lineWidth: 6)
                
                Circle()
                    .trim(from: 0, to: budgetProgress)
                    .stroke(
                        budgetProgress > 0.8 ? DSColor.error : DSColor.accent,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(DSAnimation.springMedium, value: budgetProgress)
                
                VStack(spacing: 0) {
                    Text("\(Int(budgetProgress * 100))%")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(DSColor.textPrimary)
                    Text("used")
                        .font(.system(size: 9))
                        .foregroundStyle(DSColor.textTertiary)
                }
            }
            .frame(width: 50, height: 50)
            
            Text("Monthly")
                .font(DSFont.captionSmall())
                .foregroundStyle(DSColor.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassCard(padding: DSSpacing.md)
    }
    
    // MARK: - Today Spend
    
    private var todaySpendCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text("Today")
                    .font(DSFont.captionSmall())
                    .foregroundStyle(DSColor.textTertiary)
                Text(SettingsManager.shared.currencySymbol + String(format: "%.2f", todaySpend))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(todaySpend > 0 ? DSColor.error : DSColor.textSecondary)
            }
            
            Spacer()
            
            Divider()
                .frame(height: 30)
                .overlay(DSColor.cardBorder)
                .padding(.horizontal, DSSpacing.sm)
            
            VStack(alignment: .trailing, spacing: DSSpacing.xs) {
                Text("This Week")
                    .font(DSFont.captionSmall())
                    .foregroundStyle(DSColor.textTertiary)
                Text(SettingsManager.shared.currencySymbol + String(format: "%.2f", weeklySpend))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(DSColor.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .glassCard(tint: DSColor.error, padding: DSSpacing.md)
    }
    
    // MARK: - AI Insight
    
    private var aiInsightCard: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 20))
                .foregroundStyle(DSColor.accent)
            
            VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                Text("AI Insight")
                    .font(DSFont.captionSmall())
                    .foregroundStyle(DSColor.accent)
                
                Text(insightText)
                    .font(DSFont.subheadline())
                    .foregroundStyle(DSColor.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .glassCard(tint: DSColor.accent, padding: DSSpacing.md)
    }
    
    private var insightText: String {
        let sym = SettingsManager.shared.currencySymbol
        if weeklySpend > 500 {
            return "You've spent \(sym)\(Int(weeklySpend)) this week. Consider reducing discretionary spending."
        } else if todaySpend == 0 {
            return "No spending today — great discipline! 🎯"
        } else {
            return "You're on track with your budget this month."
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsRow: some View {
        HStack(spacing: DSSpacing.sm) {
            Button {
                DSHaptics.selection()
                showAddTransaction = true
            } label: {
                VStack(spacing: DSSpacing.xs) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(DSColor.error)
                    Text("Expense")
                        .font(DSFont.caption())
                        .foregroundStyle(DSColor.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .glassCard(padding: DSSpacing.sm)
            }
            
            Button {
                DSHaptics.selection()
                showAddTransaction = true
            } label: {
                VStack(spacing: DSSpacing.xs) {
                    Image(systemName: "arrow.down.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(DSColor.success)
                    Text("Income")
                        .font(DSFont.caption())
                        .foregroundStyle(DSColor.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .glassCard(padding: DSSpacing.sm)
            }
            
            Button {
                DSHaptics.selection()
            } label: {
                VStack(spacing: DSSpacing.xs) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(DSColor.accent)
                    Text("Transfer")
                        .font(DSFont.caption())
                        .foregroundStyle(DSColor.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .glassCard(padding: DSSpacing.sm)
            }
        }
    }
    
    // MARK: - Transactions
    
    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Recent Transactions")
                .font(DSFont.headline())
                .foregroundStyle(DSColor.textPrimary)
            
            if transactions.isEmpty {
                HStack {
                    Image(systemName: "tray")
                        .foregroundStyle(DSColor.textTertiary)
                    Text("No transactions yet")
                        .font(DSFont.subheadline())
                        .foregroundStyle(DSColor.textTertiary)
                    Spacer()
                }
                .glassCard(padding: DSSpacing.md)
            } else {
                ForEach(groupedTransactions, id: \.0) { group in
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text(group.0)
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                            .padding(.top, DSSpacing.xxs)
                        
                        ForEach(group.1) { tx in
                            transactionRow(tx)
                        }
                    }
                }
            }
        }
    }
    
    private func transactionRow(_ tx: TransactionItem) -> some View {
        HStack(spacing: DSSpacing.sm) {
            // Category emoji
            Text(tx.categoryEmoji)
                .font(.system(size: 20))
                .frame(width: 36, height: 36)
                .background(
                    Circle().fill(DSColor.surfaceLight)
                )
            
            VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                Text(tx.title)
                    .font(DSFont.body())
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: DSSpacing.xxs) {
                    Text(tx.category)
                        .font(DSFont.captionSmall())
                        .foregroundStyle(DSColor.textTertiary)
                    
                    if tx.isRecurring {
                        Image(systemName: "repeat")
                            .font(.system(size: 9))
                            .foregroundStyle(DSColor.textTertiary)
                    }
                }
            }
            
            Spacer()
            
            Text((tx.isExpense ? "-" : "+") + SettingsManager.shared.currencySymbol + String(format: "%.2f", tx.amount))
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(tx.isExpense ? DSColor.error : DSColor.success)
        }
        .glassCard(padding: DSSpacing.sm)
    }
    
    private func addMockTransaction() {
        let categories = [
            ("Lunch", 15.50, "Food"),
            ("Uber", 12.00, "Transport"),
            ("Netflix", 15.99, "Subscription"),
            ("Groceries", 45.30, "Food"),
            ("Gym", 30.00, "Health")
        ]
        let random = categories.randomElement()!
        let tx = TransactionItem(
            title: random.0,
            amount: random.1,
            category: random.2,
            isExpense: true,
            isRecurring: random.0 == "Netflix" || random.0 == "Gym"
        )
        modelContext.insert(tx)
    }
}

#Preview {
    FinanceView()
}
