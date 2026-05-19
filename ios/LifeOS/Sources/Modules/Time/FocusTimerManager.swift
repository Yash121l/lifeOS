import Foundation
import ActivityKit
import Combine
import SwiftUI

// MARK: - Persistent Focus Timer Manager

/// Singleton that owns the active focus session.
/// Persists across app termination via UserDefaults.
/// Drives the inline Dashboard card and the Dynamic Island Live Activity.
@Observable
final class FocusTimerManager {
    static let shared = FocusTimerManager()

    // MARK: - State
    var taskTitle: String = ""
    var taskId: String = ""
    var goalSeconds: Int = 0
    var elapsedSeconds: Int = 0
    var isRunning: Bool = false
    var isPaused: Bool = false
    var hasActiveSession: Bool = false

    // Derived
    var progress: Double {
        guard goalSeconds > 0 else { return 0 }
        return min(Double(elapsedSeconds) / Double(goalSeconds), 1.0)
    }

    var remainingSeconds: Int {
        max(goalSeconds - elapsedSeconds, 0)
    }

    var elapsedFormatted: String { formatTime(elapsedSeconds) }
    var remainingFormatted: String { formatTime(remainingSeconds) }
    var goalFormatted: String { formatTime(goalSeconds) }

    // MARK: - Private
    private var timer: Timer?
    private var startWallTime: Date?   // wall-clock start (for accuracy after app resume)

    // UserDefaults keys
    private enum Keys {
        static let taskTitle = "focus_taskTitle"
        static let taskId = "focus_taskId"
        static let goalSeconds = "focus_goalSeconds"
        static let elapsedSeconds = "focus_elapsedSeconds"
        static let isRunning = "focus_isRunning"
        static let startWallTime = "focus_startWallTime"
    }

    // Live Activity
    private var liveActivity: Activity<FocusTimerAttributes>?

    private init() {
        restore()
    }

    // MARK: - Public API

    func start(taskId: String, title: String, goalMinutes: Int) {
        self.taskId = taskId
        self.taskTitle = title
        self.goalSeconds = goalMinutes * 60
        self.elapsedSeconds = 0
        self.isRunning = true
        self.isPaused = false
        self.hasActiveSession = true
        self.startWallTime = Date()
        persist()
        startTimer()
        startLiveActivity()
    }

    func pause() {
        guard isRunning else { return }
        isRunning = false
        isPaused = true
        stopTimer()
        persist()
        updateLiveActivity()
    }

    func resume() {
        guard isPaused else { return }
        isRunning = true
        isPaused = false
        startWallTime = Date().addingTimeInterval(-Double(elapsedSeconds))
        persist()
        startTimer()
        updateLiveActivity()
    }

    func end(saveToFirebase: Bool = true) {
        stopTimer()
        if saveToFirebase && elapsedSeconds > 10 {
            saveFocusSession()
        }
        endLiveActivity()
        // Reset
        taskTitle = ""
        taskId = ""
        goalSeconds = 0
        elapsedSeconds = 0
        isRunning = false
        isPaused = false
        hasActiveSession = false
        startWallTime = nil
        clearPersisted()
    }

    // MARK: - Timer

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        elapsedSeconds += 1
        // Sync with wall clock every 30s to correct drift
        if elapsedSeconds % 30 == 0 {
            if let wall = startWallTime {
                elapsedSeconds = Int(Date().timeIntervalSince(wall))
            }
        }
        // Update Live Activity every 10s to save battery
        if elapsedSeconds % 10 == 0 {
            updateLiveActivity()
        }
        if remainingSeconds == 0 {
            end(saveToFirebase: true)
        }
    }

    // MARK: - Persistence

    func restore() {
        let ud = UserDefaults.standard
        guard ud.bool(forKey: Keys.isRunning) || ud.integer(forKey: Keys.elapsedSeconds) > 0,
              !ud.string(forKey: Keys.taskId).isNilOrEmpty else { return }

        taskId = ud.string(forKey: Keys.taskId) ?? ""
        taskTitle = ud.string(forKey: Keys.taskTitle) ?? ""
        goalSeconds = ud.integer(forKey: Keys.goalSeconds)
        hasActiveSession = true
        isPaused = true // Start paused; user resumes manually or we resume below

        // Compute elapsed accounting for time spent in background
        if let wallStart = ud.object(forKey: Keys.startWallTime) as? Date,
           ud.bool(forKey: Keys.isRunning) {
            let elapsed = Int(Date().timeIntervalSince(wallStart))
            elapsedSeconds = min(elapsed, goalSeconds)
            // If timer was running when app died, auto-resume
            isRunning = true
            isPaused = false
            self.startWallTime = wallStart
            startTimer()
            updateLiveActivity()
        } else {
            elapsedSeconds = ud.integer(forKey: Keys.elapsedSeconds)
        }
    }

    private func persist() {
        let ud = UserDefaults.standard
        ud.set(taskId, forKey: Keys.taskId)
        ud.set(taskTitle, forKey: Keys.taskTitle)
        ud.set(goalSeconds, forKey: Keys.goalSeconds)
        ud.set(elapsedSeconds, forKey: Keys.elapsedSeconds)
        ud.set(isRunning, forKey: Keys.isRunning)
        ud.set(startWallTime, forKey: Keys.startWallTime)
    }

    private func clearPersisted() {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: Keys.taskId)
        ud.removeObject(forKey: Keys.taskTitle)
        ud.removeObject(forKey: Keys.goalSeconds)
        ud.removeObject(forKey: Keys.elapsedSeconds)
        ud.removeObject(forKey: Keys.isRunning)
        ud.removeObject(forKey: Keys.startWallTime)
    }

    // MARK: - Firebase

    private func saveFocusSession() {
        guard !taskId.isEmpty else { return }
        let session = FocusSession(
            userId: AuthService.shared.currentUser?.uid ?? "",
            taskId: taskId,
            taskTitle: taskTitle,
            durationSeconds: elapsedSeconds,
            goalSeconds: goalSeconds,
            isCompleted: elapsedSeconds >= goalSeconds
        )
        Task {
            try? await FirestoreService.shared.saveFocusSession(session, userId: session.userId)
        }
    }

    // MARK: - Live Activity (Dynamic Island)

    private func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attrs = FocusTimerAttributes(taskTitle: taskTitle, goalSeconds: goalSeconds)
        let state = FocusTimerAttributes.ContentState(
            elapsedSeconds: elapsedSeconds,
            goalSeconds: goalSeconds,
            isPaused: false
        )
        do {
            liveActivity = try Activity.request(
                attributes: attrs,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            // Live Activities may not be available in simulator
            print("Live Activity error: \(error)")
        }
    }

    private func updateLiveActivity() {
        guard let activity = liveActivity else { return }
        let state = FocusTimerAttributes.ContentState(
            elapsedSeconds: elapsedSeconds,
            goalSeconds: goalSeconds,
            isPaused: isPaused
        )
        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    private func endLiveActivity() {
        guard let activity = liveActivity else { return }
        let state = FocusTimerAttributes.ContentState(
            elapsedSeconds: elapsedSeconds,
            goalSeconds: goalSeconds,
            isPaused: false
        )
        Task {
            await activity.end(.init(state: state, staleDate: nil), dismissalPolicy: .immediate)
        }
        liveActivity = nil
    }

    // MARK: - Helpers

    private func formatTime(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            return String(format: "%02d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - String helper

private extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool { self?.isEmpty ?? true }
}
