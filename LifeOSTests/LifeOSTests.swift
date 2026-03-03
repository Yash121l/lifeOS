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
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = ModelContext(modelContainer)
    }

    override func tearDownWithError() throws {
        modelContext = nil
        modelContainer = nil
    }

    // MARK: - TaskItem Tests
    
    func testCreateTaskItem() throws {
        let task = TaskItem(title: "Write Tests", priority: 2, energyLevel: 3, timeEstimateMinutes: 60)
        modelContext.insert(task)
        
        let descriptor = FetchDescriptor<TaskItem>()
        let fetchedTasks = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetchedTasks.count, 1)
        XCTAssertEqual(fetchedTasks.first?.title, "Write Tests")
        XCTAssertEqual(fetchedTasks.first?.priority, 2)
        XCTAssertEqual(fetchedTasks.first?.energyLevel, 3)
        XCTAssertEqual(fetchedTasks.first?.timeEstimateMinutes, 60)
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
    
    func testTaskDefaultValues() throws {
        let task = TaskItem(title: "Default Task")
        modelContext.insert(task)
        
        let descriptor = FetchDescriptor<TaskItem>()
        let fetchedTasks = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetchedTasks.first?.priority, 1)
        XCTAssertEqual(fetchedTasks.first?.energyLevel, 2)
        XCTAssertEqual(fetchedTasks.first?.timeEstimateMinutes, 30)
        XCTAssertEqual(fetchedTasks.first?.urgency, 0)
        XCTAssertEqual(fetchedTasks.first?.notes, "")
    }
    
    func testTaskFormattedTimeEstimate() throws {
        let shortTask = TaskItem(title: "Quick", timeEstimateMinutes: 15)
        XCTAssertEqual(shortTask.formattedTimeEstimate, "15m")
        
        let hourTask = TaskItem(title: "Long", timeEstimateMinutes: 60)
        XCTAssertEqual(hourTask.formattedTimeEstimate, "1h")
        
        let mixedTask = TaskItem(title: "Mixed", timeEstimateMinutes: 90)
        XCTAssertEqual(mixedTask.formattedTimeEstimate, "1h 30m")
    }

    // MARK: - TimeBlock Tests
    
    func testCreateTimeBlock() throws {
        let now = Date()
        let end = now.addingTimeInterval(3600)
        let block = TimeBlock(title: "Deep Work", startTime: now, endTime: end, colorHex: "5E5CE6", blockType: "deepWork")
        
        modelContext.insert(block)
        
        let descriptor = FetchDescriptor<TimeBlock>()
        let fetchedBlocks = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetchedBlocks.count, 1)
        XCTAssertEqual(fetchedBlocks.first?.title, "Deep Work")
        XCTAssertEqual(fetchedBlocks.first?.colorHex, "5E5CE6")
        XCTAssertEqual(fetchedBlocks.first?.blockType, "deepWork")
        XCTAssertEqual(fetchedBlocks.first?.durationMinutes, 60)
    }
    
    // MARK: - TransactionItem Tests
    
    func testCreateTransactionItem() throws {
        let tx = TransactionItem(title: "Coffee", amount: 4.50, category: "Food", isExpense: true)
        modelContext.insert(tx)
        
        let descriptor = FetchDescriptor<TransactionItem>()
        let fetchedTxs = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetchedTxs.count, 1)
        XCTAssertEqual(fetchedTxs.first?.title, "Coffee")
        XCTAssertEqual(fetchedTxs.first?.amount, 4.50)
        XCTAssertTrue(fetchedTxs.first!.isExpense)
        XCTAssertEqual(fetchedTxs.first?.categoryEmoji, "🍕")
    }
    
    func testTransactionCategoryEmoji() throws {
        let food = TransactionItem(title: "Pizza", amount: 10, category: "Food")
        XCTAssertEqual(food.categoryEmoji, "🍕")
        
        let transport = TransactionItem(title: "Uber", amount: 15, category: "Transport")
        XCTAssertEqual(transport.categoryEmoji, "🚗")
        
        let other = TransactionItem(title: "Misc", amount: 5, category: "Random")
        XCTAssertEqual(other.categoryEmoji, "💳")
    }
    
    // MARK: - NoteItem Tests
    
    func testCreateNoteItem() throws {
        let note = NoteItem(title: "Test Note", content: "Some content", tagsRaw: "swift,ios", isPinned: true)
        modelContext.insert(note)
        
        let descriptor = FetchDescriptor<NoteItem>()
        let fetched = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.title, "Test Note")
        XCTAssertTrue(fetched.first!.isPinned)
        XCTAssertEqual(fetched.first?.tags, ["swift", "ios"])
    }
    
    func testNoteTagsParsing() throws {
        let note = NoteItem(title: "Tags Test", content: "")
        note.tags = ["swift", "ios", "architecture"]
        XCTAssertEqual(note.tagsRaw, "swift,ios,architecture")
        XCTAssertEqual(note.tags.count, 3)
    }
    
    // MARK: - NLP Parser Tests
    
    func testNLPParserHighPriority() throws {
        let task = NLPTaskParser.parse(input: "Call Mom urgent")
        XCTAssertEqual(task.priority, 2)
        XCTAssertEqual(task.urgency, 1)
    }
    
    func testNLPParserTomorrow() throws {
        let task = NLPTaskParser.parse(input: "Submit report tomorrow")
        XCTAssertNotNil(task.dueDate)
    }
    
    func testNLPParserEasyTask() throws {
        let task = NLPTaskParser.parse(input: "Quick easy check on emails")
        XCTAssertEqual(task.energyLevel, 1)
        XCTAssertEqual(task.timeEstimateMinutes, 15)
    }
}
