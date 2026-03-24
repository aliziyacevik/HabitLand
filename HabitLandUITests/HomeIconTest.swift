import XCTest

final class HomeIconTest: XCTestCase {
    let dir = "/Users/azc/works/HabitLand/.qa_audit/screenshots/temp/"

    @MainActor
    func testHomeIcons() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screenshotMode"]
        app.launch()
        sleep(3)
        continueAfterFailure = true

        // Dismiss popups
        for _ in 0..<3 {
            for label in ["Awesome!", "Got it!", "OK"] {
                let btn = app.buttons[label]
                if btn.waitForExistence(timeout: 0.5) && btn.isHittable { btn.tap(); usleep(300000) }
            }
        }

        // Home tab
        app.tabBars.buttons["Home"].tap()
        sleep(2)
        for _ in 0..<3 {
            for label in ["Awesome!", "Got it!", "OK"] {
                let btn = app.buttons[label]
                if btn.waitForExistence(timeout: 0.5) && btn.isHittable { btn.tap(); usleep(300000) }
            }
        }

        let data = app.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: dir + "home_icons_check.png"))

        // Scroll to see all habits
        app.swipeUp()
        sleep(1)
        let data2 = app.screenshot().pngRepresentation
        try? data2.write(to: URL(fileURLWithPath: dir + "home_icons_scrolled.png"))
    }
}
