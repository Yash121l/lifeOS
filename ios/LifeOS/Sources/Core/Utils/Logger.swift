import Foundation
import os
import FirebaseCrashlytics

public enum LogCategory: String {
    case app = "App"
    case network = "Network"
    case database = "Database"
    case auth = "Auth"
    case ui = "UI"
    case notifications = "Notifications"
    case sync = "Sync"
}

/// A centralized, production-ready logging utility wrapping `os.Logger`.
public struct Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.lifeos.app"
    
    // Internal loggers per category
    private static let loggers: [LogCategory: os.Logger] = [
        .app: os.Logger(subsystem: subsystem, category: LogCategory.app.rawValue),
        .network: os.Logger(subsystem: subsystem, category: LogCategory.network.rawValue),
        .database: os.Logger(subsystem: subsystem, category: LogCategory.database.rawValue),
        .auth: os.Logger(subsystem: subsystem, category: LogCategory.auth.rawValue),
        .ui: os.Logger(subsystem: subsystem, category: LogCategory.ui.rawValue),
        .notifications: os.Logger(subsystem: subsystem, category: LogCategory.notifications.rawValue),
        .sync: os.Logger(subsystem: subsystem, category: LogCategory.sync.rawValue)
    ]
    
    /// Log a trace / conceptual debug message.
    public static func d(_ message: String, category: LogCategory = .app, file: String = #file, function: String = #function, line: Int = #line) {
        loggers[category]?.debug("🟢 \(format(message, file: file, function: function, line: line))")
    }
    
    /// Log informational messages (state changes, normal operations).
    public static func i(_ message: String, category: LogCategory = .app, file: String = #file, function: String = #function, line: Int = #line) {
        loggers[category]?.info("🔵 \(format(message, file: file, function: function, line: line))")
    }
    
    /// Log warnings (unexpected behavior but recoverable).
    public static func w(_ message: String, category: LogCategory = .app, file: String = #file, function: String = #function, line: Int = #line) {
        let formatted = format(message, file: file, function: function, line: line)
        loggers[category]?.warning("🟡 \(formatted)")
        
        // Optionally send warnings to Crashlytics as localized logs
        Crashlytics.crashlytics().log("WARNING [\((category.rawValue))]: \(formatted)")
    }
    
    /// Log errors (operation failed). Sends severe non-fatals to Crashlytics.
    public static func e(_ message: String, error: Error? = nil, category: LogCategory = .app, file: String = #file, function: String = #function, line: Int = #line) {
        var formatted = format(message, file: file, function: function, line: line)
        if let err = error {
            formatted += " | Error: \(err.localizedDescription)"
        }
        
        loggers[category]?.error("🔴 \(formatted)")
        
        // Record non-fatal exception to Crashlytics
        let crashlytics = Crashlytics.crashlytics()
        crashlytics.log("ERROR [\((category.rawValue))]: \(formatted)")
        
        if let nsError = error as NSError? {
            crashlytics.record(error: nsError)
        } else {
            // Create a custom error if we don't have an NSError to pass
            let customError = NSError(
                domain: subsystem,
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: message,
                    "File": (file as NSString).lastPathComponent,
                    "Function": function,
                    "Line": line
                ]
            )
            crashlytics.record(error: customError)
        }
    }
    
    private static func format(_ message: String, file: String, function: String, line: Int) -> String {
        let filename = (file as NSString).lastPathComponent
        return "[\(filename):\(line) \(function)] \(message)"
    }
}
