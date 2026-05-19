import SwiftUI

struct FinanceView: View {
    @State private var authService = AuthService.shared
    @State private var store = FirestoreService.shared
    @State private var showAddTransaction = false
    
    enum Period: String, CaseIterable, CustomStringConvertible {
        case today = "Today"
        case week = "Week"
        case month = "Month"
        case year = "Year"
        
        var description: String { self.rawValue }
    }
    
    @State private var selectedPeriod: Period = .week
    
    private var userId: String { authService.currentUser?.uid ?? "" }
    
    private var filteredTransactions: [TransactionItem] {
        let cal = Calendar.current
        let now = Date()
        return store.transactions.filter { tx in
            switch selectedPeriod {
            case .today: return cal.isDateInToday(tx.date)
            case .week:
                guard let weekAgo = cal.date(byAdding: .day, value: -7, to: now) else { return false }
                return tx.date >= weekAgo
            case .month:
                guard let monthAgo = cal.date(byAdding: .month, value: -1, to: now) else { return false }
                return tx.date >= monthAgo
            case .year:
                guard let yearAgo = cal.date(byAdding: .year, value: -1, to: now) else { return false }
                return tx.date >= yearAgo
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
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerSection
                        
                        // Period selector
                        DSSegmentedControl(options: Period.allCases, selection: $selectedPeriod)
                            .padding(.horizontal, 22)
                            .padding(.bottom, 22)
                        
                        // Hero balance card
                        heroBalanceCard
                            .padding(.horizontal, 18)
                            .padding(.bottom, 22)
                        
                        // Transactions
                        if !filteredTransactions.isEmpty {
                            DSSectionHeader("Transactions", count: filteredTransactions.count)
                            
                            groupedTransactionsList
                        } else {
                            DSEmptyState(
                                icon: "creditcard",
                                title: "No transactions yet",
                                subtitle: "Tap + to log your first one."
                            )
                            .padding(.top, 40)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
                .background(DSColor.background)
                
                // FAB
                Button {
                    DSHaptics.medium()
                    showAddTransaction = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Circle().fill(DSColor.accent))
                        .shadow(color: DSColor.accent.opacity(0.35), radius: 12, y: 8)
                }
                .padding(.trailing, 18)
                .padding(.bottom, 30)
            }
            .toolbar(.hidden)
            .sheet(isPresented: $showAddTransaction) {
                TransactionEntryView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(DSColor.background)
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("May 2026")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DSColor.textSecondary)
                
                Text("Finance")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .kerning(-1.2)
            }
            
            Spacer()
            
            Button { DSHaptics.selection() } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(DSColor.surface))
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 22)
        .padding(.top, 60)
        .padding(.bottom, 22)
    }
    
    // MARK: - Hero Balance Card
    
    private var heroBalanceCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Net balance")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(DSColor.textSecondary)
                
                Spacer()
                
                HStack(spacing: 3) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .bold))
                    Text("12.4%")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(balance >= 0 ? DSColor.success : DSColor.error)
            }
            .padding(.bottom, 8)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("₹")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(DSColor.textSecondary)
                
                Text("\(Int(abs(balance)).description)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .kerning(-1.6)
                
                Text(".00")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(DSColor.textTertiary)
                    .kerning(-0.4)
            }
            .padding(.bottom, 18)
            
            // Sparkline
            DSSparkline(data: [12, 18, 15, 22, 28, 24, 31, 27, 33, 38, 35, 42, 39, 44])
                .frame(height: 48)
                .padding(.bottom, 18)
            
            HStack(spacing: 10) {
                miniMetric(label: "Income", value: totalIncome, color: DSColor.success, icon: "arrow.down.left")
                miniMetric(label: "Expenses", value: totalExpenses, color: DSColor.error, icon: "arrow.up.right")
            }
        }
        .padding(24)
        .background(
            ZStack {
                DSColor.surface
                
                RadialGradient(
                    colors: [DSColor.accent.opacity(0.1)],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 200
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(DSColor.hairline, lineWidth: 0.5)
        )
    }
    
    private func miniMetric(label: String, value: Double, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(color)
                    .frame(width: 22, height: 22)
                    .background(color.opacity(0.15))
                    .clipShape(Circle())
                
                Text(label)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundStyle(DSColor.textSecondary)
            }
            
            Text("₹\(Int(value).description)")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .kerning(-0.4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(DSColor.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(DSColor.hairline, lineWidth: 0.5)
        )
    }
    
    private var groupedTransactionsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            let grouped = Dictionary(grouping: filteredTransactions) { tx in
                Calendar.current.isDateInToday(tx.date) ? "TODAY" : 
                Calendar.current.isDateInYesterday(tx.date) ? "YESTERDAY" :
                tx.date.formatted(.dateTime.day().month().year())
            }
            
            ForEach(grouped.keys.sorted(by: >), id: \.self) { dateKey in
                VStack(alignment: .leading, spacing: 8) {
                    Text(dateKey)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(DSColor.textSecondary)
                        .kerning(0.2)
                        .padding(.horizontal, 26)
                    
                    VStack(spacing: 0) {
                        let dayTxns = grouped[dateKey] ?? []
                        ForEach(dayTxns.indices, id: \.self) { index in
                            let txn = dayTxns[index]
                            transactionRow(txn, isLast: index == dayTxns.count - 1)
                        }
                    }
                    .background(DSColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(DSColor.hairline, lineWidth: 0.5)
                    )
                    .padding(.horizontal, 18)
                }
            }
        }
    }
    
    private func transactionRow(_ txn: TransactionItem, isLast: Bool) -> some View {
        Button {
            DSHaptics.selection()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: txn.categoryIcon)
                    .font(.system(size: 18))
                    .foregroundStyle(DSColor.accent)
                    .frame(width: 38, height: 38)
                    .background(DSColor.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(txn.title)
                        .font(.system(size: 15.5, weight: .medium))
                        .foregroundStyle(.white)
                        .kerning(-0.2)
                        .lineLimit(1)
                    
                    Text("\(txn.category) · \(txn.date.formatted(.dateTime.hour().minute()))")
                        .font(.system(size: 12.5))
                        .foregroundStyle(DSColor.textSecondary)
                }
                
                Spacer()
                
                Text("\(txn.isExpense ? "−" : "+")₹\(Int(txn.amount).description)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(txn.isExpense ? .white : DSColor.success)
                    .kerning(-0.3)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .overlay(alignment: .bottom) {
                if !isLast {
                    Divider()
                        .background(DSColor.hairline)
                        .padding(.leading, 68)
                }
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                DSHaptics.medium()
                Task { try? await store.deleteTransaction(txn.id, userId: userId) }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
