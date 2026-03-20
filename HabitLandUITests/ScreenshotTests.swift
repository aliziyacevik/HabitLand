import XCTest

final class ScreenshotTests: XCTestCase {

    let screenshotDir = "/Users/azc/works/HabitLand/AppStoreAssets/Screenshots/"

    @MainActor
    func testTakeAppScreenshots() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screenshotMode"]
        app.launch()
        sleep(2)
        continueAfterFailure = false

        // 1. Home Dashboard
        tapTab(app, "Home")
        sleep(1)
        saveScreenshot(app, named: "01_home_dashboard")

        // 2. Habits Tab
        tapTab(app, "Habits")
        sleep(1)
        saveScreenshot(app, named: "02_streaks_habits")

        // 3. Sleep Tab
        tapTab(app, "Sleep")
        sleep(1)
        saveScreenshot(app, named: "03_sleep_tracking")

        // 4. Social Tab
        tapTab(app, "Social")
        sleep(1)
        saveScreenshot(app, named: "04_social_leaderboard")

        // 5. Profile Tab
        tapTab(app, "Profile")
        sleep(1)
        saveScreenshot(app, named: "05_achievements_xp")
    }

    @MainActor
    func testTakePaywallScreenshot() throws {
        // Launch WITHOUT screenshot mode so paywall is accessible
        let app = XCUIApplication()
        app.launch()
        sleep(2)
        continueAfterFailure = false

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
            saveScreenshot(app, named: "06_premium_pro")
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
                saveScreenshot(app, named: "06_premium_pro")
            }
        }
    }

    private func tapTab(_ app: XCUIApplication, _ name: String) {
        let tab = app.tabBars.buttons[name]
        if tab.waitForExistence(timeout: 3) {
            tab.tap()
        }
    }

    private func saveScreenshot(_ app: XCUIApplication, named name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        let data = screenshot.pngRepresentation
        let url = URL(fileURLWithPath: screenshotDir + name + ".png")
        try? data.write(to: url)
    }
}
