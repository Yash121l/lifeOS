import XCTest
import SwiftData
@testable import LifeOS

final class LifeOSTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUpWithError() throws {
        let schema = Schema([
            TaskItem.self,
            Project.self,
            TimeBlock.self,
            TransactionItem.self,
            NoteItem.self
        ])
        
        // Use an in-memory configuration for testing
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = ModelContext(modelContainer)
    }

    override func tearDownWithError() throws {
        modelContext = nil
        modelContainer = nil
    }

    func testCreateTaskItem() throws {
        let task = TaskItem(title: "Write Tests", priority: 2)
        modelContext.insert(task)
        
        let descriptor = FetchDescriptor<TaskItem>()
        let fetchedTasks = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetchedTasks.count, 1)
        XCTAssertEqual(fetchedTasks.first?.title, "Write Tests")
        XCTAssertEqual(fetchedTasks.first?.priority, 2)
        XCTAssertFalse(fetchedTasks.first!.isCompleted)
    }
    
    func testTaskCompletion() throws {
        let task = TaskItem(title: "Complete Me")
        modelContext.insert(task)
        
        task.isCompleted = true
        
        let descriptor = FetchDescriptor<TaskItem>()
        let fetchedTasks = try modelContext.fetch(descriptor)
        
        XCTAssertTrue(fetchedTasks.first!.isCompleted)
    }

    func testCreateTimeBlock() throws {
        let now = Date()
        let end = now.addingTimeInterval(3600)
        let block = TimeBlock(title: "Deep Work", startTime: now, endTime: end)
        
        modelContext.insert(block)
        
        let descriptor = FetchDescriptor<TimeBlock>()
        let fetchedBlocks = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetchedBlocks.count, 1)
        XCTAssertEqual(fetchedBlocks.first?.title, "Deep Work")
        XCTAssertEqual(fetchedBlocks.first?.startTime, now)
        XCTAssertEqual(fetchedBlocks.first?.endTime, end)
    }
    
    func testCreateTransactionItem() throws {
        let tx = TransactionItem(title: "Coffee", amount: 4.50, category: "Food", isExpense: true)
        modelContext.insert(tx)
        
        let descriptor = FetchDescriptor<TransactionItem>()
        let fetchedTxs = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetchedTxs.count, 1)
        XCTAssertEqual(fetchedTxs.first?.title, "Coffee")
        XCTAssertEqual(fetchedTxs.first?.amount, 4.50)
        XCTAssertTrue(fetchedTxs.first!.isExpense)
    }
}
