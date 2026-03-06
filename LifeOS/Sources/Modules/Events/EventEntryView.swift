import SwiftUI
import SwiftData

struct EventEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date().addingTimeInterval(3600)
    @State private var blockCategory: BlockCategory = .deepWork
    @State private var syncToAppleCalendar: Bool = SettingsManager.shared.isCalendarSyncEnabled
    
    enum BlockCategory: String, CaseIterable {
        case deepWork = "Deep Work"
        case meeting = "Meeting"
        case personal = "Personal"
        case routine = "Routine"
        
        var colorHex: String {
            switch self {
            case .deepWork: return "5E5CE6"
            case .meeting: return "FF9F0A"
            case .personal: return "30D158"
            case .routine: return "636366"
            }
        }
        
        var icon: String {
            switch self {
            case .deepWork: return "brain.head.profile"
            case .meeting: return "person.2.fill"
            case .personal: return "figure.mind.and.body"
            case .routine: return "arrow.triangle.2.circlepath"
            }
        }
        
        var identifier: String {
            switch self {
            case .deepWork: return "deepWork"
            case .meeting: return "meeting"
            case .personal: return "personal"
            case .routine: return "routine"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DSSpacing.lg) {
                    
                    // Title Input
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("Event Title")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                        
                        TextField("What's happening?", text: $title)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(DSColor.textPrimary)
                            .tint(DSColor.accent)
                    }
                    .padding(.top, DSSpacing.lg)
                    
                    // Category Picker
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("Category")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DSSpacing.xs) {
                            ForEach(BlockCategory.allCases, id: \.self) { category in
                                let isSelected = blockCategory == category
                                let color = Color(hex: category.colorHex)
                                
                                Button {
                                    DSHaptics.selection()
                                    blockCategory = category
                                } label: {
                                    HStack(spacing: DSSpacing.xs) {
                                        Image(systemName: category.icon)
                                            .font(.system(size: 14))
                                        Text(category.rawValue)
                                            .font(DSFont.caption())
                                            .fontWeight(.medium)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, DSSpacing.sm)
                                    .background(isSelected ? color.opacity(0.2) : DSColor.surfaceLight)
                                    .foregroundStyle(isSelected ? color : DSColor.textSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DSRadius.sm)
                                            .stroke(isSelected ? color : Color.clear, lineWidth: 1.5)
                                    )
                                }
                            }
                        }
                    }
                    
                    // Time Range
                    VStack(spacing: 0) {
                        HStack {
                            Text("Starts")
                                .font(DSFont.body())
                                .foregroundStyle(DSColor.textPrimary)
                            Spacer()
                            DatePicker("", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .tint(DSColor.accent)
                                .labelsHidden()
                        }
                        .padding(DSSpacing.md)
                        
                        Divider().overlay(DSColor.cardBorder)
                        
                        HStack {
                            Text("Ends")
                                .font(DSFont.body())
                                .foregroundStyle(DSColor.textPrimary)
                            Spacer()
                            DatePicker("", selection: $endTime, in: startTime..., displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .tint(DSColor.accent)
                                .labelsHidden()
                        }
                        .padding(DSSpacing.md)
                    }
                    .glassCard(padding: 0)
                    
                    // Sync Configuration
                    if SettingsManager.shared.isCalendarSyncEnabled {
                        VStack(spacing: 0) {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                    .foregroundStyle(DSColor.accent)
                                    .font(.system(size: 18))
                                    .frame(width: 24)
                                
                                Text("Sync to iOS Calendar")
                                    .font(DSFont.body())
                                    .foregroundStyle(DSColor.textPrimary)
                                
                                Spacer()
                                
                                Toggle("", isOn: $syncToAppleCalendar)
                                    .tint(Color(hex: blockCategory.colorHex))
                                    .labelsHidden()
                            }
                            .padding(DSSpacing.md)
                        }
                        .glassCard(padding: 0)
                    }
                    
                    // Save Action
                    Button {
                        saveEvent()
                    } label: {
                        Text("Add Event")
                            .font(DSFont.headline())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DSSpacing.md)
                            .background(title.isEmpty ? DSColor.surfaceLight : Color(hex: blockCategory.colorHex))
                            .foregroundStyle(title.isEmpty ? DSColor.textTertiary : .white)
                            .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
                    }
                    .disabled(title.isEmpty)
                    .padding(.top, DSSpacing.sm)
                    
                }
                .padding(.horizontal, DSSpacing.md)
            }
            .background(DSColor.background)
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(DSColor.textSecondary)
                }
            }
            .onChange(of: startTime) { oldValue, newValue in
                // Automatically adjust end time to keep a 1-hour duration by default
                // if they haven't explicitly edited the end date yet
                if endTime <= startTime {
                    endTime = startTime.addingTimeInterval(3600)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func saveEvent() {
        let block = TimeBlock(
            title: title,
            startTime: startTime,
            endTime: endTime,
            colorHex: blockCategory.colorHex,
            blockType: blockCategory.identifier
        )
        modelContext.insert(block)
        DSHaptics.success()
        
        if syncToAppleCalendar {
            Task {
                let durationMinutes = Int(endTime.timeIntervalSince(startTime) / 60)
                _ = await CalendarManager.shared.addEventToCalendar(
                    title: title,
                    startDate: startTime,
                    durationMinutes: durationMinutes,
                    notes: "Created via LifeOS (Category: \(blockCategory.rawValue))"
                )
            }
        }
        dismiss()
    }
}

#Preview {
    EventEntryView()
}
