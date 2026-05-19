import Foundation

enum Platform {
    case ios
    case android
}

enum TabBarStyle {
    case floating
    case fixed
}

struct NavigationProvider {
    static func getTabBarStyle(for platform: Platform) -> TabBarStyle {
        switch platform {
        case .ios:
            return .floating
        case .android:
            return .fixed
        }
    }
    
    static var currentPlatformTabBarStyle: TabBarStyle {
        #if os(iOS)
        return .floating
        #else
        // For other platforms or simulated android behavior
        return .fixed
        #endif
    }
}
