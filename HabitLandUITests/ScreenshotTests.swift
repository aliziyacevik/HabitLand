import XCTest

final class ScreenshotTests: XCTestCase {

    // MARK: - Output Directories

    private static let baseDir = "/Users/azc/works/HabitLand/AppStoreAssets/"
    private static let screenshotDir_67 = baseDir + "Screenshots/"
    private static let screenshotDir_55 = baseDir + "Screenshots_5.5/"

    /// Detects the current simulator size and returns the appropriate output directory.
    /// - 6.7" class (nativeBounds width >= 1290): Screenshots/
    /// - 5.5" class (smaller): Screenshots_5.5/
    @MainActor
    private var screenshotDir: String {
        let nativeWidth = UIScreen.main.nativeBounds.width
        return nativeWidth >= 1290 ? Self.screenshotDir_67 : Self.screenshotDir_55
    }

    @MainActor
    func testTakeAppScreenshots() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screenshotMode"]
        app.launch()
        sleep(2)
        continueAfterFailure = false

        // Ensure output directory exists
        let dir = screenshotDir
        try FileManager.default.createDirectory(
            atPath: dir,
            withIntermediateDirectories: true
        )

        // 1. Home Dashboard
        tapTab(app, "Home")
        sleep(1)
        saveScreenshot(app, named: "01_home_dashboard", toDir: dir)

        // 2. Habits Tab
        tapTab(app, "Habits")
        sleep(1)
        saveScreenshot(app, named: "02_streaks_habits", toDir: dir)

        // 3. Sleep Tab
        tapTab(app, "Sleep")
        sleep(1)
        saveScreenshot(app, named: "03_sleep_tracking", toDir: dir)

        // 4. Social Tab
        tapTab(app, "Social")
        sleep(1)
        saveScreenshot(app, named: "04_social_leaderboard", toDir: dir)

        // 5. Profile Tab
        tapTab(app, "Profile")
        sleep(1)
        saveScreenshot(app, named: "05_achievements_xp", toDir: dir)
    }

    @MainActor
    func testTakePaywallScreenshot() throws {
        // Launch WITHOUT screenshot mode so paywall is accessible
        let app = XCUIApplication()
        app.launch()
        sleep(2)
        continueAfterFailure = false

        // Ensure output directory exists
        let dir = screenshotDir
        try FileManager.default.createDirectory(
            atPath: dir,
            withIntermediateDirectories: true
        )

        // Go to Profile > Settings
        tapTab(app, "Profile")
        sleep(1)

        let settingsRow = app.staticTexts["Settings"]
        if settingsRow.waitForExistence(timeout: 3) {
            settingsRow.tap()
            sleep(1)
        }

        // Tap "Upgrade to Pro"
        let upgradeButton = app.staticTexts["Upgrade to Pro"]
        if upgradeButton.waitForExistence(timeout: 3) {
            upgradeButton.tap()
            sleep(1)
            saveScreenshot(app, named: "06_premium_pro", toDir: dir)
        } else {
            // Alternatively, try from the Sleep tab's premium gate
            app.terminate()
            app.launch()
            sleep(2)
            tapTab(app, "Sleep")
            sleep(1)
            let upgradeBtn = app.buttons["Upgrade to Pro"]
            if upgradeBtn.waitForExistence(timeout: 3) {
                upgradeBtn.tap()
                sleep(1)
                saveScreenshot(app, named: "06_premium_pro", toDir: dir)
            }
        }
    }

    private func tapTab(_ app: XCUIApplication, _ name: String) {
        let tab = app.tabBars.buttons[name]
        if tab.waitForExistence(timeout: 3) {
            tab.tap()
        }
    }

    private func saveScreenshot(_ app: XCUIApplication, named name: String, toDir dir: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        let data = screenshot.pngRepresentation
        let url = URL(fileURLWithPath: dir + name + ".png")
        try? data.write(to: url)
    }
}
