import Foundation
import FirebaseAnalytics

protocol AnalyticsServiceProtocol {
    func logEvent(_ name: String, parameters: [String: Any]?)
    func logScreenView(screenName: String, screenClass: String)
    func setUserProperty(_ value: String?, forName name: String)
    func setUserID(_ id: String?)
}

final class AnalyticsService: AnalyticsServiceProtocol {
    static let shared = AnalyticsService()
    
    private init() {}
    
    func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }
    
    func logScreenView(screenName: String, screenClass: String = "View") {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass
        ])
    }
    
    func setUserProperty(_ value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
    
    func setUserID(_ id: String?) {
        Analytics.setUserID(id)
    }
}
