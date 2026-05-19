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
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        titleSection
                            .padding(.top, 20)
                        
                        typePicker
                        
                        timeSection
                        
                        durationShortcuts
                        
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 22)
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
                        
                        Button { saveEvent() } label: {
                            Text("Schedule Event")
                                .font(.system(size: 17, weight: .bold))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(title.isEmpty ? DSColor.surfaceElevated : DSColor.accent)
                                .foregroundStyle(title.isEmpty ? DSColor.textTertiary : .white)
                                .clipShape(Capsule())
                        }
                        .disabled(title.isEmpty)
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
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Event name", text: $title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Rectangle()
                .fill(DSColor.hairline)
                .frame(height: 1)
        }
    }
    
    private var typePicker: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TYPE")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(DSColor.textTertiary)
                .kerning(0.6)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                ForEach(blockTypes, id: \.0) { type, label, icon, color in
                    Button {
                        DSHaptics.selection()
                        withAnimation { selectedType = type }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: icon)
                                .font(.system(size: 16))
                                .foregroundStyle(selectedType == type ? .white : color)
                            
                            Text(label)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(selectedType == type ? .white : DSColor.textSecondary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .background(selectedType == type ? color : DSColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(selectedType == type ? color : DSColor.hairline, lineWidth: 0.5)
                        )
                    }
                }
            }
        }
    }
    
    private var timeSection: some View {
        VStack(spacing: 1) {
            HStack {
                Label("Starts", systemImage: "clock")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                Spacer()
                DatePicker("", selection: $startTime)
                    .labelsHidden()
                    .tint(DSColor.accent)
            }
            .padding(18)
            .background(DSColor.surface)
            
            Divider().background(DSColor.hairline)
            
            HStack {
                Label("Ends", systemImage: "clock.fill")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
                Spacer()
                DatePicker("", selection: $endTime, in: startTime...)
                    .labelsHidden()
                    .tint(DSColor.accent)
            }
            .padding(18)
            .background(DSColor.surface)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(DSColor.hairline, lineWidth: 0.5))
    }
    
    private var durationShortcuts: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("QUICK DURATION")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(DSColor.textTertiary)
            
            HStack(spacing: 8) {
                ForEach([30, 60, 90, 120], id: \.self) { mins in
                    Button {
                        DSHaptics.selection()
                        withAnimation {
                            endTime = startTime.addingTimeInterval(Double(mins) * 60)
                        }
                    } label: {
                        Text(formatDuration(mins))
                            .font(.system(size: 13, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                            .background(DSColor.surface)
                            .foregroundStyle(DSColor.textSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(DSColor.hairline, lineWidth: 0.5))
                    }
                }
            }
        }
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
