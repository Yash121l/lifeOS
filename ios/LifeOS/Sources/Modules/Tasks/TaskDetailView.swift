import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var task: TaskItem
    
    var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                // Title
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("Title")
                        .font(DSFont.caption())
                        .foregroundStyle(DSColor.textTertiary)
                    
                    TextField("What needs to be done?", text: $task.title)
                        .font(DSFont.title())
                        .foregroundStyle(DSColor.textPrimary)
                        .tint(DSColor.accent)
                }
                .padding(.horizontal, DSSpacing.md)
                
                Divider().overlay(DSColor.cardBorder)
                
                // Priority & Energy
                HStack(spacing: DSSpacing.sm) {
                    // Priority
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("Priority")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                        
                        HStack(spacing: DSSpacing.xs) {
                            ForEach(0..<3) { level in
                                let labels = ["Low", "Med", "High"]
                                let colors: [Color] = [DSColor.energyLow, DSColor.accent, DSColor.error]
                                
                                Button {
                                    DSHaptics.selection()
                                    task.priority = level
                                } label: {
                                    Text(labels[level])
                                        .font(DSFont.captionSmall())
                                        .foregroundStyle(task.priority == level ? .white : DSColor.textSecondary)
                                        .padding(.horizontal, DSSpacing.sm)
                                        .padding(.vertical, DSSpacing.xs)
                                        .background(
                                            Capsule()
                                                .fill(task.priority == level ? colors[level] : DSColor.surfaceLight)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Energy
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("Energy")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                        
                        HStack(spacing: DSSpacing.xs) {
                            ForEach(1..<4) { level in
                                let icons = ["bolt", "bolt.fill", "bolt.trianglebadge.exclamationmark.fill"]
                                let colors: [Color] = [DSColor.energyLow, DSColor.energyMedium, DSColor.energyHigh]
                                
                                Button {
                                    DSHaptics.selection()
                                    task.energyLevel = level
                                } label: {
                                    Image(systemName: icons[level - 1])
                                        .font(.system(size: 14))
                                        .foregroundStyle(task.energyLevel == level ? colors[level - 1] : DSColor.textTertiary)
                                        .frame(width: 36, height: 36)
                                        .background(
                                            Circle()
                                                .fill(task.energyLevel == level ? colors[level - 1].opacity(0.15) : DSColor.surfaceLight)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, DSSpacing.md)
                
                Divider().overlay(DSColor.cardBorder)
                
                // Time Estimate
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("Time Estimate")
                        .font(DSFont.captionSmall())
                        .foregroundStyle(DSColor.textTertiary)
                    
                    HStack(spacing: DSSpacing.xs) {
                        ForEach([15, 30, 60, 120], id: \.self) { minutes in
                            let label = minutes < 60 ? "\(minutes)m" : "\(minutes / 60)h"
                            
                            Button {
                                DSHaptics.selection()
                                task.timeEstimateMinutes = minutes
                            } label: {
                                Text(label)
                                    .font(DSFont.caption())
                                    .foregroundStyle(task.timeEstimateMinutes == minutes ? .white : DSColor.textSecondary)
                                    .padding(.horizontal, DSSpacing.md)
                                    .padding(.vertical, DSSpacing.xs)
                                    .background(
                                        Capsule()
                                            .fill(task.timeEstimateMinutes == minutes ? DSColor.accent : DSColor.surfaceLight)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, DSSpacing.md)
                
                Divider().overlay(DSColor.cardBorder)
                
                // Due Date
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("Due Date")
                        .font(DSFont.captionSmall())
                        .foregroundStyle(DSColor.textTertiary)
                    
                    DatePicker(
                        "Due",
                        selection: Binding(
                            get: { task.dueDate ?? Date() },
                            set: { task.dueDate = $0 }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .tint(DSColor.accent)
                    .labelsHidden()
                }
                .padding(.horizontal, DSSpacing.md)
                
                Divider().overlay(DSColor.cardBorder)
                
                // Add to Calendar Button
                if task.dueDate != nil {
                    PrimaryButton("Add to iOS Calendar", icon: "calendar.badge.plus", style: .outline) {
                        Task {
                            let success = await CalendarManager.shared.addEventToCalendar(
                                title: task.title,
                                startDate: task.dueDate!,
                                durationMinutes: task.timeEstimateMinutes,
                                notes: task.notes
                            )
                            if success {
                                DSHaptics.success()
                            }
                        }
                    }
                    .disabled(!SettingsManager.shared.isCalendarSyncEnabled)
                    .padding(.horizontal, DSSpacing.md)
                    
                    Divider().overlay(DSColor.cardBorder)
                }
                
                // Notes
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("Notes")
                        .font(DSFont.captionSmall())
                        .foregroundStyle(DSColor.textTertiary)
                    
                    TextField("Add notes...", text: $task.notes, axis: .vertical)
                        .font(DSFont.body())
                        .foregroundStyle(DSColor.textPrimary)
                        .lineLimit(3...8)
                        .tint(DSColor.accent)
                }
                .padding(.horizontal, DSSpacing.md)
                
                // Completed Toggle
                HStack {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(task.isCompleted ? DSColor.success : DSColor.textTertiary)
                        .font(.system(size: 22))
                    
                    Text("Mark as completed")
                        .font(DSFont.body())
                        .foregroundStyle(DSColor.textPrimary)
                    
                    Spacer()
                    
                    Toggle("", isOn: $task.isCompleted)
                        .tint(DSColor.success)
                        .labelsHidden()
                }
                .glassCard(padding: DSSpacing.md)
                .padding(.horizontal, DSSpacing.md)
            }
            .padding(.top, DSSpacing.lg)
        }
        .background(DSColor.background)
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    DSHaptics.success()
                    if task.modelContext == nil {
                        modelContext.insert(task)
                    }
                    dismiss()
                }
                .foregroundStyle(task.title.isEmpty ? DSColor.textTertiary : DSColor.accent)
                .fontWeight(.semibold)
                .disabled(task.title.isEmpty)
            }
        }
    }
}
