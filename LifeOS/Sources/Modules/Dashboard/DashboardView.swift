import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \TaskItem.dueDate) private var tasks: [TaskItem]
    @Query(sort: \TimeBlock.startTime) private var blocks: [TimeBlock]
    @Query(sort: \TransactionItem.date, order: .reverse) private var transactions: [TransactionItem]
    
    // Filter for today's blocks
    private var todaysBlocks: [TimeBlock] {
        blocks.filter { Calendar.current.isDateInToday($0.startTime) }
    }
    
    // Filter for pending tasks
    private var pendingTasks: [TaskItem] {
        tasks.filter { !$0.isCompleted }.prefix(3).map { $0 }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - Time Schedule
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Today's Schedule")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if todaysBlocks.isEmpty {
                            Text("No events today.")
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(todaysBlocks) { block in
                                        VStack(alignment: .leading) {
                                            Text(block.title)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .lineLimit(1)
                                            Text("\(block.startTime, style: .time) - \(block.endTime, style: .time)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding()
                                        .frame(width: 150, alignment: .leading)
                                        .background(Color(UIColor.secondarySystemBackground))
                                        .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // MARK: - Top Tasks
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Up Next")
                                .font(.headline)
                            Spacer()
                            NavigationLink("View All", destination: TaskListView())
                                .font(.subheadline)
                                .foregroundColor(.accentColor)
                        }
                        .padding(.horizontal)
                        
                        if pendingTasks.isEmpty {
                            Text("All caught up!")
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(pendingTasks) { task in
                                    HStack {
                                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(task.isCompleted ? .green : .secondary)
                                        
                                        Text(task.title)
                                            .strikethrough(task.isCompleted)
                                            .foregroundColor(task.isCompleted ? .secondary : .primary)
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    
                    // MARK: - Finance Snapshot
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Finance Snapshot")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Recent Spent")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                let recentExpenses = transactions.filter { $0.isExpense }.prefix(5).reduce(0) { $0 + $1.amount }
                                Text("$\(recentExpenses, specifier: "%.2f")")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Net Worth")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("$10,400.00") // Mocked for now, per PRD this would be dynamic
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
        }
    }
}

#Preview {
    DashboardView()
}
