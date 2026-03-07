import SwiftUI

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var authService = AuthService.shared
    @State private var store = FirestoreService.shared
    
    @State private var title: String
    @State private var notes: String
    @State private var priority: Int
    @State private var energyLevel: Int
    @State private var timeEstimate: Int
    @State private var urgency: Int
    @State private var dueDate: Date
    @State private var hasDueDate: Bool
    @State private var showCustomTime = false
    
    private let existingTask: TaskItem?
    private var userId: String { authService.currentUser?.uid ?? "" }
    
    private var isNew: Bool { existingTask == nil }
    
    init(task: TaskItem?) {
        self.existingTask = task
        _title = State(initialValue: task?.title ?? "")
        _notes = State(initialValue: task?.notes ?? "")
        _priority = State(initialValue: task?.priority ?? 1)
        _energyLevel = State(initialValue: task?.energyLevel ?? 2)
        _timeEstimate = State(initialValue: task?.timeEstimateMinutes ?? 30)
        _urgency = State(initialValue: task?.urgency ?? 0)
        _dueDate = State(initialValue: task?.dueDate ?? Date())
        _hasDueDate = State(initialValue: task?.dueDate != nil)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DSSpacing.xl) {
                    // Title
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("TITLE")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                        DSTextField(placeholder: "What needs to be done?", text: $title)
                    }
                    
                    // Priority
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("PRIORITY")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                        
                        HStack(spacing: DSSpacing.xs) {
                            ForEach(0..<3) { level in
                                let (label, color): (String, Color) = {
                                    switch level {
                                    case 0: return ("Low", DSColor.success)
                                    case 2: return ("High", DSColor.error)
                                    default: return ("Medium", DSColor.amber)
                                    }
                                }()
                                
                                Button {
                                    DSHaptics.selection()
                                    withAnimation(DSAnimation.springQuick) { priority = level }
                                } label: {
                                    Text(label)
                                        .font(DSFont.caption())
                                        .foregroundStyle(priority == level ? .white : color)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, DSSpacing.sm)
                                        .background(
                                            RoundedRectangle(cornerRadius: DSRadius.md)
                                                .fill(priority == level ? color : color.opacity(0.1))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: DSRadius.md)
                                                        .stroke(color.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                }
                            }
                        }
                    }
                    
                    // Energy Level
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("ENERGY REQUIRED")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                        
                        HStack(spacing: DSSpacing.xs) {
                            ForEach(1..<4) { level in
                                let (label, icon): (String, String) = {
                                    switch level {
                                    case 1: return ("Light", "leaf")
                                    case 3: return ("Intense", "flame")
                                    default: return ("Moderate", "bolt")
                                    }
                                }()
                                
                                Button {
                                    DSHaptics.selection()
                                    withAnimation(DSAnimation.springQuick) { energyLevel = level }
                                } label: {
                                    VStack(spacing: DSSpacing.xxs) {
                                        Image(systemName: icon)
                                            .font(.system(size: 18, weight: .light))
                                            .foregroundStyle(energyLevel == level ? .white : DSColor.textSecondary)
                                        Text(label)
                                            .font(DSFont.captionSmall())
                                            .foregroundStyle(energyLevel == level ? .white : DSColor.textSecondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, DSSpacing.sm)
                                    .background(
                                        RoundedRectangle(cornerRadius: DSRadius.md)
                                            .fill(energyLevel == level ? DSColor.accent : DSColor.surfaceElevated)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: DSRadius.md)
                                                    .stroke(energyLevel == level ? DSColor.accent.opacity(0.5) : DSColor.cardBorder, lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                    }
                    
                    // Time Estimate
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        HStack {
                            Text("TIME ESTIMATE")
                                .font(DSFont.captionSmall())
                                .foregroundStyle(DSColor.textTertiary)
                            Spacer()
                            Text(formatTime(timeEstimate))
                                .font(DSFont.headline())
                                .foregroundStyle(DSColor.accent)
                        }
                        
                        let presets = [15, 30, 60, 120]
                        let isCustom = !presets.contains(timeEstimate)
                        
                        HStack(spacing: DSSpacing.xs) {
                            ForEach(presets, id: \.self) { mins in
                                Button {
                                    DSHaptics.selection()
                                    withAnimation(DSAnimation.springQuick) {
                                        timeEstimate = mins
                                        showCustomTime = false
                                    }
                                } label: {
                                    Text(formatTime(mins))
                                        .font(DSFont.caption())
                                        .foregroundStyle(timeEstimate == mins && !showCustomTime ? .white : DSColor.textSecondary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, DSSpacing.xs)
                                        .background(
                                            RoundedRectangle(cornerRadius: DSRadius.sm)
                                                .fill(timeEstimate == mins && !showCustomTime ? DSColor.accent : DSColor.surfaceElevated)
                                        )
                                }
                            }
                            
                            // Custom button
                            Button {
                                DSHaptics.selection()
                                withAnimation(DSAnimation.springQuick) {
                                    showCustomTime.toggle()
                                    if showCustomTime && !isCustom {
                                        timeEstimate = 45
                                    }
                                }
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundStyle(showCustomTime ? .white : DSColor.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, DSSpacing.xs)
                                    .background(
                                        RoundedRectangle(cornerRadius: DSRadius.sm)
                                            .fill(showCustomTime ? DSColor.accent : DSColor.surfaceElevated)
                                    )
                            }
                        }
                        
                        // Custom time wheel picker
                        if showCustomTime {
                            HStack(spacing: 0) {
                                // Hours wheel
                                Picker("Hours", selection: Binding(
                                    get: { timeEstimate / 60 },
                                    set: { timeEstimate = $0 * 60 + (timeEstimate % 60) }
                                )) {
                                    ForEach(0..<5) { h in
                                        Text("\(h)h").tag(h)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                
                                // Minutes wheel
                                Picker("Minutes", selection: Binding(
                                    get: { (timeEstimate % 60) / 5 * 5 },
                                    set: { timeEstimate = (timeEstimate / 60) * 60 + $0 }
                                )) {
                                    ForEach(Array(stride(from: 0, through: 55, by: 5)), id: \.self) { m in
                                        Text("\(m)m").tag(m)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(maxWidth: .infinity)
                                .clipped()
                            }
                            .frame(height: 120)
                            .padding(.horizontal, DSSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: DSRadius.md)
                                    .fill(DSColor.surfaceElevated)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DSRadius.md)
                                            .stroke(DSColor.cardBorder, lineWidth: 1)
                                    )
                            )
                        }
                    }
                    
                    // Due Date
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Toggle(isOn: $hasDueDate) {
                            Text("DUE DATE")
                                .font(DSFont.captionSmall())
                                .foregroundStyle(DSColor.textTertiary)
                        }
                        .tint(DSColor.accent)
                        
                        if hasDueDate {
                            DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.graphical)
                                .tint(DSColor.accent)
                                .padding(DSSpacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: DSRadius.md)
                                        .fill(DSColor.surfaceElevated)
                                )
                        }
                    }
                    
                    // Notes
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("NOTES")
                            .font(DSFont.captionSmall())
                            .foregroundStyle(DSColor.textTertiary)
                        
                        TextEditor(text: $notes)
                            .font(DSFont.body())
                            .foregroundStyle(DSColor.textPrimary)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 100)
                            .padding(DSSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: DSRadius.md)
                                    .fill(DSColor.surfaceElevated)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DSRadius.md)
                                            .stroke(DSColor.cardBorder, lineWidth: 1)
                                    )
                            )
                    }
                    
                    // Delete button (for existing tasks)
                    if !isNew {
                        DSButton("Delete Task", icon: "trash", style: .destructive, isFullWidth: true) {
                            DSHaptics.error()
                            Task {
                                try? await store.deleteTask(existingTask!.id, userId: userId)
                                dismiss()
                            }
                        }
                    }
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.lg)
            }
            .background(DSColor.background)
            .navigationTitle(isNew ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(DSColor.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveTask() }
                        .font(DSFont.headline())
                        .foregroundStyle(title.isEmpty ? DSColor.textTertiary : DSColor.accent)
                        .disabled(title.isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func saveTask() {
        DSHaptics.success()
        var task = existingTask ?? TaskItem(title: title)
        task.title = title
        task.priority = priority
        task.energyLevel = energyLevel
        task.timeEstimateMinutes = timeEstimate
        task.urgency = urgency
        task.notes = notes
        task.dueDate = hasDueDate ? dueDate : nil
        task.updatedAt = .now
        
        Task {
            try? await store.saveTask(task, userId: userId)
            dismiss()
        }
    }
    
    private func formatTime(_ minutes: Int) -> String {
        if minutes < 60 { return "\(minutes)m" }
        let h = minutes / 60
        let m = minutes % 60
        return m > 0 ? "\(h)h \(m)m" : "\(h)h"
    }
}
