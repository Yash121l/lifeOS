import SwiftUI

struct TransactionEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var authService = AuthService.shared
    @State private var store = FirestoreService.shared
    
    @State private var title = ""
    @State private var amount = ""
    @State private var isExpense = true
    @State private var selectedCategory = "Other"
    @State private var date = Date()
    @State private var isRecurring = false
    
    private var userId: String { authService.currentUser?.uid ?? "" }
    
    private let categories: [(String, String, Color)] = [
        ("Food", "fork.knife", Color(hex: "FF6B6B")),
        ("Transport", "car", Color(hex: "4ECDC4")),
        ("Shopping", "bag", Color(hex: "A29BFE")),
        ("Entertainment", "play.circle", Color(hex: "FDCB6E")),
        ("Bills", "bolt", Color(hex: "FFA502")),
        ("Health", "heart", Color(hex: "FF6348")),
        ("Education", "book", Color(hex: "7BED9F")),
        ("Subscription", "arrow.2.squarepath", Color(hex: "74B9FF")),
        ("Salary", "banknote", Color(hex: "00B894")),
        ("Other", "creditcard", Color(hex: "636E72"))
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        amountHeader
                            .padding(.top, 20)
                            .padding(.bottom, 32)
                        
                        typeToggle
                            .padding(.horizontal, 22)
                            .padding(.bottom, 28)
                        
                        VStack(spacing: 22) {
                            descriptionSection
                            categoryGrid
                            detailsSection
                        }
                        .padding(.horizontal, 22)
                        
                        Spacer(minLength: 120)
                    }
                }
                .background(DSColor.background)
                
                // Bottom Action Button
                VStack(spacing: 0) {
                    Divider().background(DSColor.hairline)
                    HStack {
                        Button { dismiss() } label: {
                            Text("Cancel")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(DSColor.textSecondary)
                        }
                        
                        Spacer()
                        
                        Button { saveTransaction() } label: {
                            Text("Log Transaction")
                                .font(.system(size: 17, weight: .bold))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(canSave ? DSColor.accent : DSColor.surfaceElevated)
                                .foregroundStyle(canSave ? .white : DSColor.textTertiary)
                                .clipShape(Capsule())
                        }
                        .disabled(!canSave)
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 16)
                    .background(.ultraThinMaterial)
                }
            }
            .ignoresSafeArea(.keyboard)
            .toolbar(.hidden)
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Sections
    
    private var amountHeader: some View {
        VStack(spacing: 8) {
            Text("AMOUNT")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(DSColor.textTertiary)
                .kerning(0.6)
            
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("₹")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(isExpense ? DSColor.error : DSColor.success)
                
                TextField("0", text: $amount)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .fixedSize()
            }
        }
    }
    
    private var typeToggle: some View {
        HStack(spacing: 0) {
            Button {
                DSHaptics.selection()
                withAnimation { isExpense = true }
            } label: {
                Text("Expense")
                    .font(.system(size: 15, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(isExpense ? DSColor.error : Color.clear)
                    .foregroundStyle(isExpense ? .white : DSColor.textSecondary)
            }
            
            Button {
                DSHaptics.selection()
                withAnimation { isExpense = false }
            } label: {
                Text("Income")
                    .font(.system(size: 15, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(!isExpense ? DSColor.success : Color.clear)
                    .foregroundStyle(!isExpense ? .white : DSColor.textSecondary)
            }
        }
        .background(DSColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(DSColor.hairline, lineWidth: 0.5))
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DESCRIPTION")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(DSColor.textTertiary)
            
            TextField("What was this for?", text: $title)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.white)
            
            Rectangle()
                .fill(DSColor.hairline)
                .frame(height: 1)
        }
    }
    
    private var categoryGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CATEGORY")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(DSColor.textTertiary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                ForEach(categories, id: \.0) { name, icon, color in
                    Button {
                        DSHaptics.selection()
                        selectedCategory = name
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: icon)
                                .font(.system(size: 18))
                                .foregroundStyle(selectedCategory == name ? .white : color)
                            Text(name)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(selectedCategory == name ? .white : DSColor.textSecondary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedCategory == name ? color : DSColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selectedCategory == name ? color : DSColor.hairline, lineWidth: 0.5)
                        )
                    }
                }
            }
        }
    }
    
    private var detailsSection: some View {
        VStack(spacing: 1) {
            HStack {
                Label("Date", systemImage: "calendar")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                Spacer()
                DatePicker("", selection: $date, displayedComponents: .date)
                    .labelsHidden()
                    .tint(DSColor.accent)
            }
            .padding(18)
            .background(DSColor.surface)
            
            Divider().background(DSColor.hairline)
            
            Toggle(isOn: $isRecurring) {
                Label("Recurring", systemImage: "repeat")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(18)
            .background(DSColor.surface)
            .tint(DSColor.accent)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(DSColor.hairline, lineWidth: 0.5))
    }
    
    private var canSave: Bool {
        !title.isEmpty && (Double(amount) ?? 0) > 0
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount) else { return }
        DSHaptics.success()
        
        let tx = TransactionItem(
            userId: userId,
            title: title,
            amount: amountValue,
            date: date,
            category: selectedCategory,
            isExpense: isExpense,
            isRecurring: isRecurring
        )
        
        Task {
            try? await store.saveTransaction(tx, userId: userId)
            dismiss()
        }
    }
}
