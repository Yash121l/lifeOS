import SwiftUI
import SwiftData

struct TransactionEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: String = ""
    @State private var title: String = ""
    @State private var selectedCategory: String = "Food"
    @State private var isExpense: Bool = true
    @State private var date: Date = Date()
    @State private var isRecurring: Bool = false
    
    let categories = [
        "Food", "Transport", "Shopping", "Entertainment",
        "Bills", "Health", "Education", "Subscription",
        "Income", "Other"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DSSpacing.lg) {
                    
                    // Amount Input
                    VStack(spacing: DSSpacing.xs) {
                        Text(isExpense ? "Expense Amount" : "Income Amount")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(SettingsManager.shared.currencySymbol)
                                .font(.system(size: 32, weight: .semibold, design: .rounded))
                                .foregroundStyle(DSColor.textSecondary)
                            
                            TextField("0.00", text: $amount)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(isExpense ? DSColor.error : DSColor.success)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Type Toggle
                        HStack(spacing: 0) {
                            Button {
                                isExpense = true
                            } label: {
                                Text("Expense")
                                    .font(DSFont.caption())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, DSSpacing.xs)
                                    .background(isExpense ? DSColor.error : Color.clear)
                                    .foregroundStyle(isExpense ? .white : DSColor.textSecondary)
                                    .clipShape(Capsule())
                            }
                            
                            Button {
                                isExpense = false
                                selectedCategory = "Income"
                            } label: {
                                Text("Income")
                                    .font(DSFont.caption())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, DSSpacing.xs)
                                    .background(!isExpense ? DSColor.success : Color.clear)
                                    .foregroundStyle(!isExpense ? .white : DSColor.textSecondary)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(2)
                        .background(Capsule().fill(DSColor.surfaceLight))
                        .frame(width: 200)
                        .padding(.top, DSSpacing.sm)
                    }
                    .padding(.top, DSSpacing.xl)
                    .padding(.bottom, DSSpacing.md)
                    
                    // Details Form
                    VStack(spacing: 0) {
                        // Title
                        HStack {
                            Text("Title")
                                .font(DSFont.body())
                                .foregroundStyle(DSColor.textPrimary)
                            Spacer()
                            TextField("What was this for?", text: $title)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(DSColor.textSecondary)
                                .tint(DSColor.accent)
                        }
                        .padding(DSSpacing.md)
                        
                        Divider().overlay(DSColor.cardBorder)
                        
                        // Category (Picker)
                        HStack {
                            Text("Category")
                                .font(DSFont.body())
                                .foregroundStyle(DSColor.textPrimary)
                            Spacer()
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(categories, id: \.self) { cat in
                                    Text(cat).tag(cat)
                                }
                            }
                            .tint(DSColor.accent)
                            .labelsHidden()
                        }
                        .padding(DSSpacing.md)
                        
                        Divider().overlay(DSColor.cardBorder)
                        
                        // Date
                        HStack {
                            Text("Date")
                                .font(DSFont.body())
                                .foregroundStyle(DSColor.textPrimary)
                            Spacer()
                            DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .tint(DSColor.accent)
                                .labelsHidden()
                        }
                        .padding(DSSpacing.md)
                        
                        Divider().overlay(DSColor.cardBorder)
                        
                        // Recurring
                        HStack {
                            Text("Recurring")
                                .font(DSFont.body())
                                .foregroundStyle(DSColor.textPrimary)
                            Spacer()
                            Toggle("", isOn: $isRecurring)
                                .tint(DSColor.accent)
                                .labelsHidden()
                        }
                        .padding(DSSpacing.md)
                    }
                    .glassCard(padding: 0)
                    
                    // Save Button
                    PrimaryButton("Add Transaction", style: .solid) {
                        saveTransaction()
                    }
                    .disabled(amount.isEmpty || title.isEmpty)
                    .opacity(amount.isEmpty || title.isEmpty ? 0.5 : 1.0)
                    .padding(.top, DSSpacing.sm)
                }
                .padding(.horizontal, DSSpacing.md)
            }
            .background(DSColor.background)
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(DSColor.textSecondary)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else { return }
        let transaction = TransactionItem(
            title: title,
            amount: amountValue,
            date: date,
            category: selectedCategory,
            isExpense: isExpense,
            isRecurring: isRecurring,
            iconName: "creditcard"
        )
        modelContext.insert(transaction)
        DSHaptics.success()
        dismiss()
    }
}

#Preview {
    TransactionEntryView()
}
