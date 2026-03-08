import Foundation
import FirebaseFirestore

@Observable
final class FirestoreService {
    static let shared = FirestoreService()
    
    private let db = Firestore.firestore()
    private let network = NetworkMonitor.shared
    
    // MARK: - Live Data
    var tasks: [TaskItem] = []
    var transactions: [TransactionItem] = []
    var notes: [NoteItem] = []
    var timeBlocks: [TimeBlock] = []
    var projects: [Project] = []
    
    /// Whether data came from local cache (offline) or server
    var isFromCache = false
    
    private var listeners: [ListenerRegistration] = []
    
    private init() {
        Logger.i("Initializing FirestoreService", category: .database)
    }
    
    // MARK: - Listener Management
    
    func startListening(for userId: String) {
        stopListening()
        listenToTasks(userId: userId)
        listenToTransactions(userId: userId)
        listenToNotes(userId: userId)
        listenToTimeBlocks(userId: userId)
        listenToProjects(userId: userId)
    }
    
    func stopListening() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
        tasks = []
        transactions = []
        notes = []
        timeBlocks = []
        projects = []
    }
    
    // MARK: - Tasks
    
    private func tasksCollection(userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("tasks")
    }
    
    private func listenToTasks(userId: String) {
        let listener = tasksCollection(userId: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    Logger.e("Failed to listen to tasks", error: error, category: .database)
                    return
                }
                guard let snapshot else { return }
                self?.isFromCache = snapshot.metadata.isFromCache
                self?.tasks = snapshot.documents.compactMap { doc in
                    do {
                        return try doc.data(as: TaskItem.self)
                    } catch {
                        Logger.e("Failed to decode TaskItem", error: error, category: .database)
                        return nil
                    }
                }
                self?.refreshWidgetData()
            }
        listeners.append(listener)
    }
    
    func saveTask(_ task: TaskItem, userId: String) async throws {
        network.markPendingWrite()
        var t = task
        let isNew = t.id.isEmpty
        if isNew { t.id = UUID().uuidString }
        let wasAlreadyCompleted = tasks.first(where: { $0.id == t.id })?.isCompleted ?? false
        
        t.userId = userId
        t.updatedAt = .now
        
        do {
            try tasksCollection(userId: userId).document(t.id).setData(from: t)
            Logger.i("Saved Task \(t.id)", category: .database)
            
            // Analytics
            if isNew {
                AnalyticsManager.logEvent(.taskCreated)
            } else if t.isCompleted && !wasAlreadyCompleted {
                AnalyticsManager.logEvent(.taskCompleted)
            }
            
            // Schedule or cancel notification
            if !t.isCompleted {
                NotificationManager.shared.scheduleTaskReminder(task: t)
            } else {
                NotificationManager.shared.cancelTaskReminder(taskId: t.id)
            }
        } catch {
            Logger.e("Failed to save task \(t.id)", error: error, category: .database)
            throw error
        }
    }
    
    func deleteTask(_ taskId: String, userId: String) async throws {
        network.markPendingWrite()
        do {
            try await tasksCollection(userId: userId).document(taskId).delete()
            Logger.i("Deleted Task \(taskId)", category: .database)
            NotificationManager.shared.cancelTaskReminder(taskId: taskId)
        } catch {
            Logger.e("Failed to delete task \(taskId)", error: error, category: .database)
            throw error
        }
    }
    
    // MARK: - Transactions
    
    private func transactionsCollection(userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("transactions")
    }
    
    private func listenToTransactions(userId: String) {
        let listener = transactionsCollection(userId: userId)
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot else { return }
                self?.isFromCache = snapshot.metadata.isFromCache
                self?.transactions = snapshot.documents.compactMap { doc in
                    try? doc.data(as: TransactionItem.self)
                }
            }
        listeners.append(listener)
    }
    
    func saveTransaction(_ transaction: TransactionItem, userId: String) async throws {
        network.markPendingWrite()
        var t = transaction
        t.userId = userId
        t.updatedAt = .now
        do {
            try transactionsCollection(userId: userId).document(t.id).setData(from: t)
            Logger.i("Saved Transaction \(t.id)", category: .database)
        } catch {
            Logger.e("Failed to save transaction \(t.id)", error: error, category: .database)
            throw error
        }
    }
    
    func deleteTransaction(_ transactionId: String, userId: String) async throws {
        network.markPendingWrite()
        do {
            try await transactionsCollection(userId: userId).document(transactionId).delete()
            Logger.i("Deleted Transaction \(transactionId)", category: .database)
        } catch {
            Logger.e("Failed to delete transaction \(transactionId)", error: error, category: .database)
            throw error
        }
    }
    
    // MARK: - Notes
    
    private func notesCollection(userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("notes")
    }
    
    private func listenToNotes(userId: String) {
        let listener = notesCollection(userId: userId)
            .order(by: "updatedAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot else { return }
                self?.isFromCache = snapshot.metadata.isFromCache
                self?.notes = snapshot.documents.compactMap { doc in
                    try? doc.data(as: NoteItem.self)
                }
            }
        listeners.append(listener)
    }
    
    func saveNote(_ note: NoteItem, userId: String) async throws {
        network.markPendingWrite()
        var n = note
        n.userId = userId
        n.updatedAt = .now
        try notesCollection(userId: userId).document(n.id).setData(from: n)
    }
    
    func deleteNote(_ noteId: String, userId: String) async throws {
        network.markPendingWrite()
        try await notesCollection(userId: userId).document(noteId).delete()
    }
    
    // MARK: - Time Blocks
    
    private func timeBlocksCollection(userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("timeBlocks")
    }
    
    private func listenToTimeBlocks(userId: String) {
        let listener = timeBlocksCollection(userId: userId)
            .order(by: "startTime", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot else { return }
                self?.isFromCache = snapshot.metadata.isFromCache
                self?.timeBlocks = snapshot.documents.compactMap { doc in
                    try? doc.data(as: TimeBlock.self)
                }
                self?.refreshWidgetData()
            }
        listeners.append(listener)
    }
    
    func saveTimeBlock(_ block: TimeBlock, userId: String) async throws {
        network.markPendingWrite()
        var b = block
        b.userId = userId
        b.updatedAt = .now
        try timeBlocksCollection(userId: userId).document(b.id).setData(from: b)
    }
    
    func deleteTimeBlock(_ blockId: String, userId: String) async throws {
        network.markPendingWrite()
        try await timeBlocksCollection(userId: userId).document(blockId).delete()
    }
    
    // MARK: - Projects
    
    private func projectsCollection(userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("projects")
    }
    
    private func listenToProjects(userId: String) {
        let listener = projectsCollection(userId: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot else { return }
                self?.isFromCache = snapshot.metadata.isFromCache
                self?.projects = snapshot.documents.compactMap { doc in
                    try? doc.data(as: Project.self)
                }
            }
        listeners.append(listener)
    }
    
    func saveProject(_ project: Project, userId: String) async throws {
        network.markPendingWrite()
        var p = project
        p.userId = userId
        p.updatedAt = .now
        try projectsCollection(userId: userId).document(p.id).setData(from: p)
    }
    
    func deleteProject(_ projectId: String, userId: String) async throws {
        network.markPendingWrite()
        try await projectsCollection(userId: userId).document(projectId).delete()
    }
    
    // MARK: - Widget Data Refresh
    
    func refreshWidgetData() {
        let now = Date()
        let calendar = Calendar.current
        
        // Task stats
        let pendingTasks = tasks.filter { !$0.isCompleted }
        let completedToday = tasks.filter { $0.isCompleted && calendar.isDateInToday($0.updatedAt) }
        
        // Today's events
        let googleEvents = GoogleCalendarService.shared.events
        let todayGoogleEvents = googleEvents.filter { event in
            guard let start = event.startDate else { return false }
            return calendar.isDateInToday(start)
        }
        let todayTimeBlocks = timeBlocks.filter { calendar.isDateInToday($0.startTime) }
        let totalTodayEvents = todayGoogleEvents.count + todayTimeBlocks.count
        
        SharedData.writeStats(pending: pendingTasks.count, completed: completedToday.count, total: tasks.count, eventCount: totalTodayEvents)
        
        // Next event
        let upcomingGoogleEvents = googleEvents
            .filter { event in
                guard let start = event.startDate else { return false }
                return start > now
            }
            .sorted { ($0.startDate ?? .distantFuture) < ($1.startDate ?? .distantFuture) }
        
        let upcomingTimeBlocks = timeBlocks
            .filter { $0.startTime > now }
            .sorted { $0.startTime < $1.startTime }
        
        let nextGoogleEvent = upcomingGoogleEvents.first
        let nextTimeBlock = upcomingTimeBlocks.first
        
        if let gEvent = nextGoogleEvent {
            let gTime = gEvent.startDate ?? .distantFuture
            let tTime = nextTimeBlock?.startTime ?? .distantFuture
            
            if gTime <= tTime {
                SharedData.writeNextEvent(title: gEvent.title, startTime: gEvent.startDate, endTime: gEvent.endDate, isAllDay: gEvent.isAllDay, meetingLink: gEvent.hangoutLink, location: gEvent.location, description: gEvent.description, id: gEvent.id)
            } else if let tb = nextTimeBlock {
                SharedData.writeNextEvent(title: tb.title, startTime: tb.startTime, endTime: tb.endTime, isAllDay: false, meetingLink: nil, location: nil, description: nil, id: tb.id)
            }
        } else if let tb = nextTimeBlock {
            SharedData.writeNextEvent(title: tb.title, startTime: tb.startTime, endTime: tb.endTime, isAllDay: false, meetingLink: nil, location: nil, description: nil, id: tb.id)
        } else {
            SharedData.writeNextEvent(title: nil, startTime: nil, endTime: nil, isAllDay: false, meetingLink: nil, location: nil, description: nil, id: nil)
        }
        
        // Encode tasks
        let topTasks = Array(pendingTasks
            .sorted { ($0.priority, $0.energyLevel) > ($1.priority, $1.energyLevel) }
            .prefix(5))
            .map { SharedData.WidgetTask(id: $0.id, title: $0.title, priority: $0.priority, dueDate: $0.dueDate, isCompleted: $0.isCompleted, energyLevel: $0.energyLevel, timeEstimateMinutes: $0.timeEstimateMinutes) }
        SharedData.writeTasks(topTasks)
        
        // Encode events
        let topEvents = Array(upcomingGoogleEvents.prefix(5))
            .map { SharedData.WidgetEvent(id: $0.id, title: $0.title, startTime: $0.startDate, endTime: $0.endDate, isAllDay: $0.isAllDay, meetingLink: $0.hangoutLink, location: $0.location, description: $0.description) }
        SharedData.writeEvents(topEvents)
    }
}
