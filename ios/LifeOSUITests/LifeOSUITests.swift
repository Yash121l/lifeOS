import XCTest

final class LifeOSUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAppLaunchAndTabNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify Dashboard is the first tab and visible
        XCTAssertTrue(app.navigationBars["Dashboard"].waitForExistence(timeout: 5))
        
        let tabBar = app.tabBars.firstMatch
        
        // Tap "Time" tab
        tabBar.buttons["Time"].tap()
        XCTAssertTrue(app.navigationBars["Calendar"].waitForExistence(timeout: 2))
        
        // Tap "Tasks" tab
        tabBar.buttons["Tasks"].tap()
        XCTAssertTrue(app.navigationBars["Tasks"].waitForExistence(timeout: 2))
        
        // Tap "Finance" tab
        tabBar.buttons["Finance"].tap()
        XCTAssertTrue(app.navigationBars["Finance"].waitForExistence(timeout: 2))
        
        // Tap "Notes" tab
        tabBar.buttons["Notes"].tap()
        XCTAssertTrue(app.navigationBars["Notes"].waitForExistence(timeout: 2))
    }
    
    func testDashboardHasSections() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Ensure we're on the Dashboard
        app.tabBars.firstMatch.buttons["Dashboard"].tap()
        XCTAssertTrue(app.navigationBars["Dashboard"].waitForExistence(timeout: 2))
        
        // Verify key sections are present
        XCTAssertTrue(app.staticTexts["Today's Schedule"].exists)
        XCTAssertTrue(app.staticTexts["Up Next"].exists)
        XCTAssertTrue(app.staticTexts["Finance Snapshot"].exists)
    }
}
