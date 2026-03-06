import Foundation
import SwiftUI

@Observable
final class SettingsManager {
    static let shared = SettingsManager()
    
    var currencyCode: String {
        didSet { UserDefaults.standard.set(currencyCode, forKey: "currencyCode") }
    }
    
    var timezone: String {
        didSet { UserDefaults.standard.set(timezone, forKey: "timezone") }
    }
    
    var isCalendarSyncEnabled: Bool {
        didSet { UserDefaults.standard.set(isCalendarSyncEnabled, forKey: "isCalendarSyncEnabled") }
    }
    
    init() {
        self.currencyCode = UserDefaults.standard.string(forKey: "currencyCode") ?? "USD"
        self.timezone = UserDefaults.standard.string(forKey: "timezone") ?? TimeZone.current.identifier
        self.isCalendarSyncEnabled = UserDefaults.standard.bool(forKey: "isCalendarSyncEnabled")
    }
    
    var currencySymbol: String {
        let locale = NSLocale(localeIdentifier: currencyCode)
        return locale.displayName(forKey: .currencySymbol, value: currencyCode) ?? "$"
    }
    
    let availableCurrencies = ["USD", "EUR", "GBP", "INR", "JPY", "CAD", "AUD"]
    let availableTimezones = TimeZone.knownTimeZoneIdentifiers.filter { $0.contains("/") }.sorted()
}
