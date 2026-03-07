import SwiftUI

struct EventEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var authService = AuthService.shared
    @State private var store = FirestoreService.shared
    
    @State private var title = ""
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    @State private var selectedType = "deepWork"
    
    private var userId: String { authService.currentUser?.uid ?? "" }
    
    private let blockTypes: [(String, String, String, Color)] = [
        ("deepWork", "Deep Work", "brain.head.profile", Color(hex: "6C5CE7")),
        ("meeting", "Meeting", "person.2.fill", Color(hex: "FDCB6E")),
        ("personal", "Personal", "heart.fill", Color(hex: "00B894")),
        ("routine", "Routine", "arrow.triangle.2.circlepath", Color(hex: "636E72"))
    ]
    
    private var selectedColor: String {
        blockTypes.first { $0.0 == selectedType }?.3.toHex() ?? "6C5CE7"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DSSpacing.xl) {
                    // Title
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("EVENT NAME")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                        DSTextField(placeholder: "What are you working on?", text: $title)
                    }
                    
                    // Block type
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("TYPE")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                        
                        HStack(spacing: DSSpacing.xs) {
                            ForEach(blockTypes, id: \.0) { type, label, icon, color in
                                Button {
                                    DSHaptics.selection()
                                    withAnimation(DSAnimation.springQuick) { selectedType = type }
                                } label: {
                                    VStack(spacing: DSSpacing.xxs) {
                                        Image(systemName: icon)
                                            .font(.system(size: 18))
                                            .foregroundStyle(selectedType == type ? .white : color)
                                        Text(label)
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundStyle(selectedType == type ? .white : DSColor.textSecondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, DSSpacing.sm)
                                    .background(
                                        RoundedRectangle(cornerRadius: DSRadius.md)
                                            .fill(selectedType == type ? color : color.opacity(0.08))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: DSRadius.md)
                                                    .stroke(selectedType == type ? color : color.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                    }
                    
                    // Time pickers
                    VStack(spacing: DSSpacing.sm) {
                        HStack {
                            Text("Start")
                                .font(DSFont.body())
                                .foregroundStyle(.white)
                            Spacer()
                            DatePicker("", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                                .tint(DSColor.accent)
                        }
                        .glassCard(padding: DSSpacing.sm)
                        
                        HStack {
                            Text("End")
                                .font(DSFont.body())
                                .foregroundStyle(.white)
                            Spacer()
                            DatePicker("", selection: $endTime, in: startTime..., displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                                .tint(DSColor.accent)
                        }
                        .glassCard(padding: DSSpacing.sm)
                    }
                    
                    // Duration preview
                    let minutes = Int(endTime.timeIntervalSince(startTime) / 60)
                    if minutes > 0 {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundStyle(DSColor.textTertiary)
                            Text("Duration: \(formatDuration(minutes))")
                                .font(DSFont.caption())
                                .foregroundStyle(DSColor.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glassCard(padding: DSSpacing.sm)
                    }
                    
                    // Quick durations
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("QUICK SET")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                        
                        HStack(spacing: DSSpacing.xs) {
                            ForEach([30, 60, 90, 120], id: \.self) { mins in
                                Button {
                                    DSHaptics.selection()
                                    withAnimation(DSAnimation.springQuick) {
                                        endTime = startTime.addingTimeInterval(Double(mins) * 60)
                                    }
                                } label: {
                                    Text(formatDuration(mins))
                                        .font(DSFont.caption())
                                        .foregroundStyle(DSColor.textSecondary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, DSSpacing.xs)
                                        .background(
                                            RoundedRectangle(cornerRadius: DSRadius.sm)
                                                .fill(DSColor.surfaceElevated)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: DSRadius.sm)
                                                        .stroke(DSColor.cardBorder, lineWidth: 1)
                                                )
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.lg)
            }
            .background(DSColor.background)
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(DSColor.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveEvent() }
                        .font(DSFont.headline())
                        .foregroundStyle(title.isEmpty ? DSColor.textTertiary : DSColor.accent)
                        .disabled(title.isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func saveEvent() {
        DSHaptics.success()
        let block = TimeBlock(
            userId: userId,
            title: title,
            startTime: startTime,
            endTime: endTime,
            colorHex: selectedColor,
            blockType: selectedType
        )
        
        Task {
            try? await store.saveTimeBlock(block, userId: userId)
            dismiss()
        }
    }
    
    private func formatDuration(_ minutes: Int) -> String {
        if minutes < 60 { return "\(minutes)m" }
        let h = minutes / 60
        let m = minutes % 60
        return m > 0 ? "\(h)h \(m)m" : "\(h)h"
    }
}

// Helper extension for Color to hex
extension Color {
    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
