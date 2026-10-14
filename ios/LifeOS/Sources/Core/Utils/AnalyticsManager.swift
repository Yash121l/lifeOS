import Foundation
import FirebaseAnalytics
import PostHog

/// A centralized wrapper for logging analytics events. Every event goes to
/// Firebase Analytics and, in release builds, to PostHog.
public struct AnalyticsManager {

    /// Public PostHog project key (phc_ client key, safe to ship in the binary).
    private static let postHogKey = "phc_oLm8fb7L4CXDqGdJcc7a6boCtR8rVjf6dNx7G995eGdy"
    private static var postHogStarted = false

    /// Starts PostHog. Release builds only, so simulator and debug runs stay out.
    public static func start() {
        #if !DEBUG
        guard !postHogStarted else { return }
        let config = PostHogConfig(projectToken: postHogKey, host: "https://us.i.posthog.com")
        config.captureApplicationLifecycleEvents = true
        config.captureScreenViews = true
        config.errorTrackingConfig.autoCapture = true
        config.sessionReplay = true
        config.sessionReplayConfig.maskAllTextInputs = true
        config.sessionReplayConfig.maskAllImages = false
        PostHogSDK.shared.setup(config)
        PostHogSDK.shared.register(["app": "lifeos"])
        postHogStarted = true
        #endif
    }
    
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
        case transactionAdded = "transaction_added"
        case noteCreated = "note_created"

        /// PostHog uses object_verb names; Firebase keeps its reserved ones.
        var postHogName: String {
            switch self {
            case .login: return "user_logged_in"
            case .signUp: return "signup_completed"
            case .logout: return "user_logged_out"
            case .sessionLogged: return "focus_session_logged"
            default: return rawValue
            }
        }
    }
    
    /// Log a custom event with properties
    public static func logEvent(_ event: Event, parameters: [String: Any]? = nil) {
        Analytics.logEvent(event.rawValue, parameters: parameters)
        if postHogStarted {
            PostHogSDK.shared.capture(event.postHogName, properties: parameters)
            if event == .logout {
                PostHogSDK.shared.reset()
                PostHogSDK.shared.register(["app": "lifeos"])
            }
        }
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

    /// PostHog identify with the Firebase uid plus email and name.
    public static func identify(id: String, email: String?, name: String?) {
        guard postHogStarted else { return }
        var props: [String: Any] = [:]
        if let email { props["email"] = email }
        if let name { props["name"] = name }
        PostHogSDK.shared.identify(id, userProperties: props)
    }
    
    /// Set a custom user property
    public static func setUserProperty(_ value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
}
