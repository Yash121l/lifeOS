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
    
    private init() {}
    
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
                guard let snapshot else { return }
                self?.isFromCache = snapshot.metadata.isFromCache
                self?.tasks = snapshot.documents.compactMap { doc in
                    try? doc.data(as: TaskItem.self)
                }
            }
        listeners.append(listener)
    }
    
    func saveTask(_ task: TaskItem, userId: String) async throws {
        network.markPendingWrite()
        var t = task
        t.userId = userId
        t.updatedAt = .now
        try tasksCollection(userId: userId).document(t.id).setData(from: t)
    }
    
    func deleteTask(_ taskId: String, userId: String) async throws {
        network.markPendingWrite()
        try await tasksCollection(userId: userId).document(taskId).delete()
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
        try transactionsCollection(userId: userId).document(t.id).setData(from: t)
    }
    
    func deleteTransaction(_ transactionId: String, userId: String) async throws {
        network.markPendingWrite()
        try await transactionsCollection(userId: userId).document(transactionId).delete()
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
}
