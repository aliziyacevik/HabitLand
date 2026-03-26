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

        // 1. HOME DASHBOARD — hero screenshot
        app.tabBars.buttons["Home"].tap()
        sleep(2)
        dismissEverything(app)
        save(app, dir + "01_home_dashboard.png")

        // 2. HABIT DETAIL — tap first habit
        let meditation = app.staticTexts["Morning Meditation"]
        if meditation.waitForExistence(timeout: 3) && meditation.isHittable {
            meditation.tap()
            sleep(2)
            dismissEverything(app)
            save(app, dir + "02_habit_detail.png")
            if app.navigationBars.buttons.element(boundBy: 0).exists {
                app.navigationBars.buttons.element(boundBy: 0).tap()
                sleep(1)
            }
        }

        // 3. SLEEP DASHBOARD
        app.tabBars.buttons["Sleep"].tap()
        sleep(2)
        dismissEverything(app)
        save(app, dir + "03_sleep_dashboard.png")

        // 4. HABITS LIST
        app.tabBars.buttons["Habits"].tap()
        sleep(2)
        dismissEverything(app)
        save(app, dir + "04_habits_list.png")

        // 5. PROFILE
        app.tabBars.buttons["Profile"].tap()
        sleep(2)
        dismissEverything(app)
        save(app, dir + "05_profile.png")

        // 6. HABIT REMINDER — navigate from habit detail
        app.tabBars.buttons["Home"].tap()
        sleep(2)
        let meditationForReminder = app.staticTexts["Morning Meditation"]
        if meditationForReminder.waitForExistence(timeout: 3) && meditationForReminder.isHittable {
            meditationForReminder.tap()
            sleep(2)
            // Scroll down to find Reminders action row
            app.swipeUp()
            sleep(1)
            let remindersLink = app.staticTexts["Reminders"]
            if remindersLink.waitForExistence(timeout: 3) && remindersLink.isHittable {
                remindersLink.tap()
                sleep(2)
                // Scroll down to show Custom Message and Preview sections
                app.swipeUp()
                sleep(1)
                save(app, dir + "06_reminder.png")
                // Go back to home
                if app.navigationBars.buttons.element(boundBy: 0).exists {
                    app.navigationBars.buttons.element(boundBy: 0).tap()
                    sleep(1)
                }
            }
            // Back from detail
            if app.navigationBars.buttons.element(boundBy: 0).exists {
                app.navigationBars.buttons.element(boundBy: 0).tap()
                sleep(1)
            }
        }

        // 7. POMODORO TIMER
        let pomodoroBtn = app.buttons["Pomodoro Focus"]
        if pomodoroBtn.waitForExistence(timeout: 3) && pomodoroBtn.isHittable {
            pomodoroBtn.tap()
            sleep(3)
            save(app, dir + "07_pomodoro.png")
            let closeBtn = app.buttons["Close"]
            if closeBtn.waitForExistence(timeout: 1) && closeBtn.isHittable {
                closeBtn.tap()
                sleep(1)
            }
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
