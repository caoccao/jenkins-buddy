import XCTest

@MainActor
final class JenkinsBuddyUITests: XCTestCase {
    private func launchedApp() -> XCUIApplication {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
        return app
    }

    func testJobsTabIsPermanent() {
        let app = launchedApp()
        XCTAssertTrue(app.otherElements["tabs-bar"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["settings-button"].exists)
        XCTAssertTrue(app.buttons["refresh-button"].exists)
    }

    func testSettingsWindowCanBeOpenedRepeatedly() {
        let app = launchedApp()
        app.buttons["settings-button"].click()
        XCTAssertTrue(app.windows["Settings"].waitForExistence(timeout: 5))
        app.typeKey("w", modifierFlags: .command)
        app.typeKey(",", modifierFlags: .command)
        XCTAssertTrue(app.windows["Settings"].waitForExistence(timeout: 5))
    }
}
