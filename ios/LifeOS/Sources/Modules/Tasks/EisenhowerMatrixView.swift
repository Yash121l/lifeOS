import SwiftUI

struct EisenhowerMatrixView: View {
    @State private var store = FirestoreService.shared
    
    private var activeTasks: [TaskItem] {
        store.tasks.filter { !$0.isCompleted }
    }
    
    var body: some View {
        VStack(spacing: DSSpacing.xs) {
            // Labels row
            HStack(spacing: DSSpacing.xs) {
                Spacer().frame(width: 50)
                Text("URGENT")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(DSColor.textTertiary)
                    .tracking(1.2)
                    .frame(maxWidth: .infinity)
                Text("NOT URGENT")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(DSColor.textTertiary)
                    .tracking(1.2)
                    .frame(maxWidth: .infinity)
            }
            
            HStack(spacing: DSSpacing.xs) {
                // Side labels
                VStack(spacing: 0) {
                    Text("IMPORTANT")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(DSColor.textTertiary)
                        .tracking(1.2)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 16)
                        .frame(maxHeight: .infinity)
                    
                    Text("LESS")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(DSColor.textTertiary)
                        .tracking(1.2)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 16)
                        .frame(maxHeight: .infinity)
                }
                .frame(width: 30)
                
                VStack(spacing: DSSpacing.xs) {
                    HStack(spacing: DSSpacing.xs) {
                        matrixQuadrant(
                            title: "Do First",
                            icon: "flame.fill",
                            color: DSColor.error,
                            tasks: urgentImportant
                        )
                        matrixQuadrant(
                            title: "Schedule",
                            icon: "calendar",
                            color: DSColor.accent,
                            tasks: notUrgentImportant
                        )
                    }
                    HStack(spacing: DSSpacing.xs) {
                        matrixQuadrant(
                            title: "Delegate",
                            icon: "person.2",
                            color: DSColor.warning,
                            tasks: urgentNotImportant
                        )
                        matrixQuadrant(
                            title: "Eliminate",
                            icon: "xmark.circle",
                            color: DSColor.textTertiary,
                            tasks: notUrgentNotImportant
                        )
                    }
                }
            }
        }
        .padding(.top, DSSpacing.sm)
    }
    
    @ViewBuilder
    private func matrixQuadrant(title: String, icon: String, color: Color, tasks: [TaskItem]) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack(spacing: DSSpacing.xxs) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(title)
                    .font(DSFont.captionSmall())
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(tasks.count)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule().fill(color.opacity(0.15))
                    )
            }
            .foregroundStyle(color)
            
            if tasks.isEmpty {
                Text("Empty")
                    .font(DSFont.captionSmall())
                    .foregroundStyle(DSColor.textTertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    ForEach(tasks.prefix(4)) { task in
                        HStack(spacing: DSSpacing.xxs) {
                            Circle()
                                .fill(color.opacity(0.5))
                                .frame(width: 4, height: 4)
                            Text(task.title)
                                .font(.system(size: 11))
                                .foregroundStyle(DSColor.textSecondary)
                                .lineLimit(1)
                        }
                    }
                    if tasks.count > 4 {
                        Text("+\(tasks.count - 4) more")
                            .font(.system(size: 10))
                            .foregroundStyle(DSColor.textTertiary)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .padding(DSSpacing.sm)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.md)
                        .stroke(color.opacity(0.15), lineWidth: 0.5)
                )
        )
    }
    
    private var urgentImportant: [TaskItem] { activeTasks.filter { $0.priority == 2 && isUrgent($0) } }
    private var notUrgentImportant: [TaskItem] { activeTasks.filter { $0.priority == 2 && !isUrgent($0) } }
    private var urgentNotImportant: [TaskItem] { activeTasks.filter { $0.priority < 2 && isUrgent($0) } }
    private var notUrgentNotImportant: [TaskItem] { activeTasks.filter { $0.priority < 2 && !isUrgent($0) } }
    
    private func isUrgent(_ task: TaskItem) -> Bool {
        guard let due = task.dueDate else { return false }
        return due.timeIntervalSinceNow < 172800
    }
}
