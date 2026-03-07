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
            ScrollView {
                VStack(spacing: DSSpacing.xl) {
                    // Amount display
                    VStack(spacing: DSSpacing.xs) {
                        Text(isExpense ? "EXPENSE" : "INCOME")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(isExpense ? DSColor.error : DSColor.success)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("₹")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(DSColor.textTertiary)
                            
                            TextField("0", text: $amount)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 200)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DSSpacing.xxl)
                    
                    // Type toggle
                    HStack(spacing: 0) {
                        Button {
                            DSHaptics.selection()
                            withAnimation(DSAnimation.springQuick) { isExpense = true }
                        } label: {
                            Text("Expense")
                                .font(DSFont.headline())
                                .foregroundStyle(isExpense ? .white : DSColor.textTertiary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, DSSpacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: DSRadius.md)
                                        .fill(isExpense ? DSColor.error : .clear)
                                )
                        }
                        
                        Button {
                            DSHaptics.selection()
                            withAnimation(DSAnimation.springQuick) { isExpense = false }
                        } label: {
                            Text("Income")
                                .font(DSFont.headline())
                                .foregroundStyle(!isExpense ? .white : DSColor.textTertiary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, DSSpacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: DSRadius.md)
                                        .fill(!isExpense ? DSColor.success : .clear)
                                )
                        }
                    }
                    .padding(3)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadius.md + 3)
                            .fill(DSColor.surfaceElevated)
                    )
                    
                    // Title
                    DSTextField(placeholder: "Description", text: $title, icon: "text.alignleft")
                    
                    // Category grid
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("CATEGORY")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DSSpacing.xs), count: 5), spacing: DSSpacing.xs) {
                            ForEach(categories, id: \.0) { name, icon, color in
                                Button {
                                    DSHaptics.selection()
                                    withAnimation(DSAnimation.springQuick) { selectedCategory = name }
                                } label: {
                                    VStack(spacing: DSSpacing.xxs) {
                                        Image(systemName: icon)
                                            .font(.system(size: 18, weight: .light))
                                            .foregroundStyle(selectedCategory == name ? .white : color)
                                        Text(name)
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundStyle(selectedCategory == name ? .white : DSColor.textTertiary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, DSSpacing.sm)
                                    .background(
                                        RoundedRectangle(cornerRadius: DSRadius.md)
                                            .fill(selectedCategory == name ? DSColor.accent.opacity(0.2) : DSColor.surfaceElevated)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: DSRadius.md)
                                                    .stroke(selectedCategory == name ? DSColor.accent.opacity(0.4) : DSColor.cardBorder, lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                    }
                    
                    // Date & Recurring
                    VStack(spacing: DSSpacing.sm) {
                        HStack {
                            Text("Date")
                                .font(DSFont.body())
                                .foregroundStyle(DSColor.textPrimary)
                            Spacer()
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .labelsHidden()
                                .tint(DSColor.accent)
                        }
                        .glassCard(padding: DSSpacing.sm)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                                Text("Recurring")
                                    .font(DSFont.body())
                                    .foregroundStyle(DSColor.textPrimary)
                                Text("Repeat monthly")
                                    .font(DSFont.captionSmall())
                                    .foregroundStyle(DSColor.textTertiary)
                            }
                            Spacer()
                            Toggle("", isOn: $isRecurring)
                                .labelsHidden()
                                .tint(DSColor.accent)
                        }
                        .glassCard(padding: DSSpacing.sm)
                    }
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.lg)
            }
            .background(DSColor.background)
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(DSColor.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveTransaction() }
                        .font(DSFont.headline())
                        .foregroundStyle(canSave ? DSColor.accent : DSColor.textTertiary)
                        .disabled(!canSave)
                }
            }
        }
        .preferredColorScheme(.dark)
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
