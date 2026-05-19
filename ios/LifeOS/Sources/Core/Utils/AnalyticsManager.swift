import Foundation
import FirebaseAnalytics

/// A centralized wrapper for logging analytics events.
public struct AnalyticsManager {
    
    /// Standard event names
    public enum Event: String {
        case appOpen = "app_open"
        case login = "login"
        case signUp = "sign_up"
        case logout = "logout"
        case taskCreated = "task_created"
        case taskCompleted = "task_completed"
        case eventCreated = "event_created"
        case syncStarted = "sync_started"
        case syncCompleted = "sync_completed"
        case calendarConnected = "calendar_connected"
        case calendarDisconnected = "calendar_disconnected"
        case settingChanged = "setting_changed"
        case sessionLogged = "session_logged"
    }
    
    /// Log a custom event with properties
    public static func logEvent(_ event: Event, parameters: [String: Any]? = nil) {
        Analytics.logEvent(event.rawValue, parameters: parameters)
        Logger.d("Logged Event: \(event.rawValue) | Params: \(parameters ?? [:])", category: .app)
    }
    
    /// Log screen view
    public static func logScreen(_ screenName: String, screenClass: String = "View") {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass
        ])
    }
    
    /// Set the user ID after login
    public static func setUserID(_ id: String?) {
        Analytics.setUserID(id)
    }
    
    /// Set a custom user property
    public static func setUserProperty(_ value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
}
