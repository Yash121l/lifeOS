import SwiftUI
import Combine

@MainActor
final class FocusViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var elapsedSeconds = 0
    @Published var endedAt: Date? = nil
    
    let task: TaskItem?
    let goalSeconds: Int
    let startedAt = Date()
    
    private var timer: AnyCancellable?
    private let database = FirestoreService.shared
    private let auth = AuthService.shared
    
    init(task: TaskItem?) {
        self.task = task
        // Default to 25 mins if no task estimate
        self.goalSeconds = (task?.timeEstimateMinutes ?? 25) * 60
    }
    
    var progress: Double {
        min(Double(elapsedSeconds) / Double(goalSeconds), 1.0)
    }
    
    var remainingSeconds: Int {
        max(goalSeconds - elapsedSeconds, 0)
    }
    
    var formattedRemainingTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedElapsedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }
    
    var isFinished: Bool {
        endedAt != nil
    }
    
    func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    func startTimer() {
        guard !isFinished else { return }
        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }
    
    func finish(completed: Bool) {
        pauseTimer()
        endedAt = Date()
        
        let session = FocusSession(
            userId: auth.currentUser?.uid ?? "",
            taskId: task?.id,
            taskTitle: task?.title ?? "Deep Work",
            startedAt: startedAt,
            durationSeconds: elapsedSeconds,
            goalSeconds: goalSeconds,
            isCompleted: completed
        )
        
        Task {
            try? await database.saveFocusSession(session, userId: auth.currentUser?.uid ?? "")
        }
    }
    
    private func tick() {
        elapsedSeconds += 1
        if elapsedSeconds >= goalSeconds {
            finish(completed: true)
            DSHaptics.success()
        }
    }
}
