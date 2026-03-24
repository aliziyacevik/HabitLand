import XCTest

final class AppStoreScreenshots: XCTestCase {

    @MainActor
    func testCaptureAppStoreScreenshots() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screenshotMode"]
        app.launch()
        sleep(4)
        continueAfterFailure = true

        // Dismiss all popups aggressively
        for _ in 0..<5 {
            for label in ["Awesome!", "Got it!", "OK", "Close", "Cancel", "Skip", "Not Now", "Maybe Later", "Dismiss", "Done"] {
                let btn = app.buttons[label]
                if btn.exists && btn.isHittable { btn.tap(); usleep(400000) }
            }
        }

        let dir: String
        let screenScale = UIScreen.main.scale
        let screenHeight = UIScreen.main.bounds.height * screenScale
        if screenHeight >= 2778 {
            dir = "/Users/azc/works/HabitLand/.appstore/screenshots/6.7/"
        } else {
            dir = "/Users/azc/works/HabitLand/.appstore/screenshots/6.5/"
        }

        // 1. Home Dashboard
        app.tabBars.buttons["Home"].tap()
        sleep(2)
        nuke(app)
        save(app, dir + "01_home_dashboard.png")

        // 2. Habit Detail
        let drinkWater = app.staticTexts["Drink Water"]
        if drinkWater.waitForExistence(timeout: 3) && drinkWater.isHittable {
            drinkWater.tap()
            sleep(2)
            nuke(app)
            save(app, dir + "02_habit_detail.png")
            app.navigationBars.buttons.element(boundBy: 0).tap()
            sleep(1)
        }

        // 3. Sleep Dashboard
        app.tabBars.buttons["Sleep"].tap()
        sleep(2)
        nuke(app)
        save(app, dir + "03_sleep_dashboard.png")

        // 4. Social Leaderboard
        app.tabBars.buttons["Social"].tap()
        sleep(2)
        nuke(app)
        let lb = app.buttons["Leaderboard"]
        if lb.waitForExistence(timeout: 2) && lb.isHittable {
            lb.tap()
            sleep(2)
            nuke(app)
        }
        save(app, dir + "04_social_leaderboard.png")

        // 5. Profile
        app.tabBars.buttons["Profile"].tap()
        sleep(2)
        nuke(app)
        save(app, dir + "05_profile.png")

        // 6. Create Habit (template browser)
        app.tabBars.buttons["Habits"].tap()
        sleep(2)
        nuke(app)
        let addBtn = app.buttons["Add new habit"]
        if addBtn.waitForExistence(timeout: 2) && addBtn.isHittable {
            addBtn.tap()
            sleep(1)
            nuke(app)
            // Tap Browse Templates
            let browse = app.staticTexts["Browse Templates"]
            if browse.waitForExistence(timeout: 2) && browse.isHittable {
                browse.tap()
                sleep(1)
                save(app, dir + "06_template_browser.png")
            } else {
                save(app, dir + "06_create_habit.png")
            }
        }
    }

    private func nuke(_ app: XCUIApplication) {
        for _ in 0..<5 {
            for label in ["Awesome!", "Got it!", "OK", "Close", "Cancel", "Skip", "Not Now", "Maybe Later", "Dismiss", "Done"] {
                let btn = app.buttons[label]
                if btn.exists && btn.isHittable { btn.tap(); usleep(400000) }
            }
            if app.alerts.count > 0 { app.alerts.buttons.firstMatch.tap(); usleep(400000) }
        }
    }

    private func save(_ app: XCUIApplication, _ path: String) {
        let data = app.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: path))
    }
}
