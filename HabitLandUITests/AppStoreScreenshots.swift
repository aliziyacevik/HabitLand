import XCTest

final class AppStoreScreenshots: XCTestCase {

    @MainActor
    func testCaptureScreenshots_6_7() throws {
        captureScreenshots(dir: "/Users/azc/works/HabitLand/.appstore/screenshots/6.7/")
    }

    @MainActor
    func testCaptureScreenshots_6_5() throws {
        captureScreenshots(dir: "/Users/azc/works/HabitLand/.appstore/screenshots/6.5/")
    }

    @MainActor
    func testCaptureScreenshots_iPad_13() throws {
        captureIPadScreenshots(dir: "/Users/azc/works/HabitLand/.appstore/screenshots/ipad_13/")
    }

    // MARK: - iPad Capture

    private func captureIPadScreenshots(dir: String) {
        let app = XCUIApplication()
        app.launchArguments = ["-screenshotMode"]
        app.launch()
        continueAfterFailure = true

        sleep(5)
        dismissEverything(app)
        sleep(1)
        dismissEverything(app)

        let dismissBtn = app.buttons["Dismiss"]
        if dismissBtn.waitForExistence(timeout: 1) && dismissBtn.isHittable {
            dismissBtn.tap()
            sleep(1)
        }

        // iPad uses top tab bar (pill buttons, not standard tabBars)
        func tapTab(_ name: String) {
            // First dismiss any alerts
            if app.alerts.count > 0 {
                let allowBtn = app.alerts.buttons["Allow"]
                if allowBtn.exists { allowBtn.tap() }
                else if app.alerts.buttons.count > 0 { app.alerts.buttons.firstMatch.tap() }
                sleep(1)
            }

            // Try standard tabBar first, then top-bar buttons (iPad)
            let tabBarBtn = app.tabBars.buttons[name]
            if tabBarBtn.waitForExistence(timeout: 1) && tabBarBtn.isHittable {
                tabBarBtn.tap()
            } else {
                // iPad: tab is rendered as a button in the navigation area
                // Try tapping by label matching
                let predicate = NSPredicate(format: "label == %@", name)
                let matches = app.buttons.matching(predicate)
                if matches.count > 0 && matches.firstMatch.isHittable {
                    matches.firstMatch.tap()
                }
            }
            sleep(3)
            dismissEverything(app)
        }

        // Dismiss notification permission alert first
        sleep(2)
        if app.alerts.count > 0 {
            let allowBtn = app.alerts.buttons["Allow"]
            if allowBtn.exists { allowBtn.tap() }
            else if app.alerts.buttons.count > 0 { app.alerts.buttons.firstMatch.tap() }
            sleep(1)
        }
        dismissEverything(app)

        // 1. HOME
        tapTab("Home")
        sleep(1)
        save(app, dir + "01_home_dashboard.png")

        // 2. HABIT DETAIL
        let meditation = app.staticTexts["Morning Meditation"]
        if meditation.waitForExistence(timeout: 3) && meditation.isHittable {
            meditation.tap()
            sleep(2)
            dismissEverything(app)
            save(app, dir + "02_habit_detail.png")
            tapBack(app)
        }

        // 3. SLEEP
        tapTab("Sleep")
        save(app, dir + "03_sleep_dashboard.png")

        // 4. HABITS LIST
        tapTab("Habits")
        save(app, dir + "04_habits_list.png")

        // 5. PROFILE
        tapTab("Profile")
        save(app, dir + "05_profile.png")

        // 6. REMINDER
        tapTab("Home")
        let med2 = app.staticTexts["Morning Meditation"]
        if med2.waitForExistence(timeout: 3) && med2.isHittable {
            med2.tap()
            sleep(2)
            app.swipeUp()
            sleep(1)
            let remindersLink = app.staticTexts["Reminders"]
            if remindersLink.waitForExistence(timeout: 3) && remindersLink.isHittable {
                remindersLink.tap()
                sleep(2)
                app.swipeUp()
                sleep(1)
                app.swipeUp()
                sleep(1)
                save(app, dir + "06_reminder.png")
                tapBack(app)
            }
            tapBack(app)
        }

        // 7. POMODORO
        let pomodoroBtn = app.buttons["Pomodoro Focus"]
        if pomodoroBtn.waitForExistence(timeout: 3) && pomodoroBtn.isHittable {
            pomodoroBtn.tap()
            sleep(3)
            let playBtn = app.buttons["Start"]
            if playBtn.waitForExistence(timeout: 2) && playBtn.isHittable {
                playBtn.tap()
                sleep(2)
            }
            save(app, dir + "07_pomodoro.png")
            let closeBtn = app.buttons["Close"]
            if closeBtn.waitForExistence(timeout: 1) && closeBtn.isHittable {
                closeBtn.tap()
                sleep(1)
            }
        }
    }

    private func captureScreenshots(dir: String) {
        let app = XCUIApplication()
        app.launchArguments = ["-screenshotMode"]
        app.launch()
        continueAfterFailure = true

        // Wait for app to fully load and dismiss ALL popups
        sleep(5)
        dismissEverything(app)
        sleep(1)
        dismissEverything(app)

        // Dismiss "Getting Started" card if visible
        let dismissBtn = app.buttons["Dismiss"]
        if dismissBtn.waitForExistence(timeout: 1) && dismissBtn.isHittable {
            dismissBtn.tap()
            sleep(1)
        }

        // ═══════════════════════════════════════════
        // 1. HOME DASHBOARD — hero screenshot (100% complete day)
        // ═══════════════════════════════════════════
        app.tabBars.buttons["Home"].tap()
        sleep(3)
        dismissEverything(app)
        save(app, dir + "01_home_dashboard.png")

        // ═══════════════════════════════════════════
        // 2. HABIT DETAIL — show streak heatmap + stats
        // ═══════════════════════════════════════════
        let meditation = app.staticTexts["Morning Meditation"]
        if meditation.waitForExistence(timeout: 3) && meditation.isHittable {
            meditation.tap()
            sleep(2)
            dismissEverything(app)
            save(app, dir + "02_habit_detail.png")
            tapBack(app)
        }

        // ═══════════════════════════════════════════
        // 3. SLEEP DASHBOARD — show last night + weekly chart
        // ═══════════════════════════════════════════
        app.tabBars.buttons["Sleep"].tap()
        sleep(2)
        dismissEverything(app)
        save(app, dir + "03_sleep_dashboard.png")

        // ═══════════════════════════════════════════
        // 4. HABITS LIST — all habits with streaks
        // ═══════════════════════════════════════════
        app.tabBars.buttons["Habits"].tap()
        sleep(2)
        dismissEverything(app)
        save(app, dir + "04_habits_list.png")

        // ═══════════════════════════════════════════
        // 5. PROFILE — avatar, stats, achievements
        // ═══════════════════════════════════════════
        app.tabBars.buttons["Profile"].tap()
        sleep(2)
        dismissEverything(app)
        save(app, dir + "05_profile.png")

        // ═══════════════════════════════════════════
        // 6. REMINDER — show Custom Message + Preview
        // ═══════════════════════════════════════════
        app.tabBars.buttons["Home"].tap()
        sleep(2)
        let meditationForReminder = app.staticTexts["Morning Meditation"]
        if meditationForReminder.waitForExistence(timeout: 3) && meditationForReminder.isHittable {
            meditationForReminder.tap()
            sleep(2)
            app.swipeUp()
            sleep(1)
            let remindersLink = app.staticTexts["Reminders"]
            if remindersLink.waitForExistence(timeout: 3) && remindersLink.isHittable {
                remindersLink.tap()
                sleep(2)
                // Scroll past time picker to show Custom Message + Preview + Save
                app.swipeUp()
                sleep(1)
                app.swipeUp()
                sleep(1)
                sleep(1)
                save(app, dir + "06_reminder.png")
                tapBack(app)
            }
            tapBack(app)
        }

        // ═══════════════════════════════════════════
        // 7. POMODORO — start timer for active state
        // ═══════════════════════════════════════════
        let pomodoroBtn = app.buttons["Pomodoro Focus"]
        if pomodoroBtn.waitForExistence(timeout: 3) && pomodoroBtn.isHittable {
            pomodoroBtn.tap()
            sleep(3)
            // Tap play button to show active timer state
            let playBtn = app.buttons["Start"]
            if playBtn.waitForExistence(timeout: 2) && playBtn.isHittable {
                playBtn.tap()
                sleep(2) // Let timer tick for a moment
            }
            save(app, dir + "07_pomodoro.png")
            // Close pomodoro
            let closeBtn = app.buttons["Close"]
            if closeBtn.waitForExistence(timeout: 1) && closeBtn.isHittable {
                closeBtn.tap()
                sleep(1)
            }
        }
    }

    // MARK: - Helpers

    private func tapBack(_ app: XCUIApplication) {
        if app.navigationBars.buttons.element(boundBy: 0).exists {
            app.navigationBars.buttons.element(boundBy: 0).tap()
            sleep(1)
        }
    }

    private func dismissEverything(_ app: XCUIApplication) {
        let dismissLabels = [
            "Awesome!", "Got it!", "OK", "Close", "Cancel", "Skip",
            "Not Now", "Maybe Later", "Dismiss", "Done", "Continue",
            "xmark.circle.fill"
        ]
        for _ in 0..<8 {
            for label in dismissLabels {
                let btn = app.buttons[label]
                if btn.exists && btn.isHittable {
                    btn.tap()
                    usleep(300000)
                }
            }
            if app.alerts.count > 0 {
                app.alerts.buttons.firstMatch.tap()
                usleep(300000)
            }
        }
    }

    private func save(_ app: XCUIApplication, _ path: String) {
        let data = app.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: path))
    }
}
