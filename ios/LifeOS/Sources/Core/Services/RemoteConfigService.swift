import Foundation
import FirebaseRemoteConfig

protocol RemoteConfigServiceProtocol {
    func fetchAndActivate() async throws
    func bool(forKey key: String) -> Bool
    func string(forKey key: String) -> String
    func double(forKey key: String) -> Double
}

final class RemoteConfigService: RemoteConfigServiceProtocol {
    static let shared = RemoteConfigService()
    private let remoteConfig: RemoteConfig
    
    private init() {
        self.remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0 // Fetch immediately in debug
        #else
        settings.minimumFetchInterval = 3600 // Fetch every hour in prod
        #endif
        self.remoteConfig.configSettings = settings
        
        // Default values
        self.remoteConfig.setDefaults([
            "new_feature_enabled": false as NSObject,
            "theme_mode": "dark" as NSObject
        ])
    }
    
    func fetchAndActivate() async throws {
        do {
            let status = try await remoteConfig.fetchAndActivate()
            print("RemoteConfig fetched and activated. Status: \(status)")
        } catch {
            print("Failed to fetch RemoteConfig: \(error.localizedDescription)")
            throw error
        }
    }
    
    func bool(forKey key: String) -> Bool {
        return remoteConfig.configValue(forKey: key).boolValue
    }
    
    func string(forKey key: String) -> String {
        return remoteConfig.configValue(forKey: key).stringValue ?? ""
    }
    
    func double(forKey key: String) -> Double {
        return remoteConfig.configValue(forKey: key).numberValue.doubleValue
    }
}
