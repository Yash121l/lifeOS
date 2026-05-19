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
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .kerning(0.4)
                
                Spacer()
                
                Text("\(tasks.count)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(color)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(color.opacity(0.15))
                    .clipShape(Capsule())
            }
            .foregroundStyle(color)
            
            if tasks.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "circle.dotted")
                        .font(.system(size: 18))
                        .foregroundStyle(DSColor.textTertiary.opacity(0.3))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(tasks.prefix(3)) { task in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(color.opacity(0.6))
                                .frame(width: 4, height: 4)
                            Text(task.title)
                                .font(.system(size: 12.5))
                                .foregroundStyle(.white.opacity(0.85))
                                .lineLimit(1)
                        }
                    }
                    if tasks.count > 3 {
                        Text("+\(tasks.count - 3) more")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(DSColor.textTertiary)
                            .padding(.leading, 10)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DSColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(DSColor.hairline, lineWidth: 0.5)
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
