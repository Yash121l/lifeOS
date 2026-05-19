import XCTest
@testable import LifeOS

final class TabBarTests: XCTestCase {
    
    func testTabBarStyleForiOS() {
        // iOS should always be floating
        let style = NavigationProvider.getTabBarStyle(for: .ios)
        XCTAssertEqual(style, .floating, "iOS tab bar must be floating")
    }
    
    func testTabBarStyleForAndroid() {
        // Android should follow standard fixed bottom navigation
        let style = NavigationProvider.getTabBarStyle(for: .android)
        XCTAssertEqual(style, .fixed, "Android tab bar must be fixed")
    }
    
    func testiOSImplementationIsFloating() {
        // Verify that on iOS platform, the style remains floating
        // regardless of any other settings (simulated by the provider)
        #if os(iOS)
        let style = NavigationProvider.currentPlatformTabBarStyle
        XCTAssertEqual(style, .floating, "Current iOS implementation must use floating tab bar")
        #endif
    }
}
