import ActivityKit
import Foundation
import SwiftUI

// MARK: - Focus Timer Live Activity Attributes

struct FocusTimerAttributes: ActivityAttributes {
    // Static data set when activity starts
    var taskTitle: String
    var goalSeconds: Int

    // Dynamic state updated during session
    public struct ContentState: Codable, Hashable {
        var elapsedSeconds: Int
        var goalSeconds: Int
        var isPaused: Bool

        var progress: Double {
            guard goalSeconds > 0 else { return 0 }
            return min(Double(elapsedSeconds) / Double(goalSeconds), 1.0)
        }

        var remainingSeconds: Int { max(goalSeconds - elapsedSeconds, 0) }

        var remainingFormatted: String {
            let s = remainingSeconds
            let m = s / 60, sec = s % 60
            return String(format: "%02d:%02d", m, sec)
        }

        var elapsedFormatted: String {
            let h = elapsedSeconds / 3600
            let m = (elapsedSeconds % 3600) / 60
            let s = elapsedSeconds % 60
            if h > 0 { return String(format: "%02d:%02d:%02d", h, m, s) }
            return String(format: "%02d:%02d", m, s)
        }
    }
}

// Keep the old TimerAttributes for backwards compatibility if it was referenced elsewhere
typealias TimerAttributes = FocusTimerAttributes
