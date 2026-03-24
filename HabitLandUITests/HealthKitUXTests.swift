import XCTest

final class HealthKitUXTests: XCTestCase {

    let dir = "/Users/azc/works/HabitLand/.qa_audit/screenshots/temp/"

    @MainActor
    func testHealthKitBadgeAndToast() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screenshotMode"]
        app.launch()
        sleep(3)
        continueAfterFailure = true

        // Dismiss any popups
        for label in ["Awesome!", "Got it!", "OK"] {
            let btn = app.buttons[label]
            if btn.waitForExistence(timeout: 1) && btn.isHittable { btn.tap(); sleep(1) }
        }

        // 1. Verify "HabitLand" title is visible (not truncated)
        let title = app.staticTexts["HabitLand"]
        XCTAssertTrue(title.waitForExistence(timeout: 3), "HabitLand title should be fully visible")
        shot(app, "test_01_habitland_title")

        // 2. Navigate to Habits tab to create a HealthKit habit
        app.tabBars.buttons["Habits"].tap()
        sleep(1)
        // Dismiss popups again
        for label in ["Awesome!", "Got it!", "OK"] {
            let btn = app.buttons[label]
            if btn.waitForExistence(timeout: 1) && btn.isHittable { btn.tap(); sleep(1) }
        }

        let addBtn = app.buttons["Add new habit"]
        if addBtn.waitForExistence(timeout: 3) && addBtn.isHittable {
            addBtn.tap()
            sleep(1)

            // Don't fill name — just scroll to Apple Health and pick Steps
            // (Steps auto-fills the name field anyway)

            // Dismiss keyboard if open
            if app.keyboards.count > 0 {
                app.swipeDown()
                sleep(1)
            }

            // Scroll to find Apple Health section and tap "Steps"
            var foundSteps = false
            for _ in 0..<8 {
                let stepsOption = app.staticTexts["Steps"]
                if stepsOption.exists && stepsOption.isHittable {
                    stepsOption.tap()
                    sleep(1)
                    shot(app, "test_02_healthkit_metric_selected")
                    foundSteps = true
                    break
                }
                app.swipeUp()
                usleep(500000)
            }
            XCTAssertTrue(foundSteps, "Should find and tap Steps metric")

            // Scroll to Create button
            app.swipeUp()
            sleep(1)
            let createBtn = app.buttons["Create Habit"]
            if createBtn.waitForExistence(timeout: 3) && createBtn.isEnabled {
                createBtn.tap()
                sleep(1)
                shot(app, "test_03_healthkit_habit_created")
            } else {
                app.swipeDown(velocity: .fast)
                sleep(1)
            }
        }

        // 3. Go to Home tab and check for HealthKit badge
        app.tabBars.buttons["Home"].tap()
        sleep(1)
        for label in ["Awesome!", "Got it!", "OK"] {
            let btn = app.buttons[label]
            if btn.waitForExistence(timeout: 1) && btn.isHittable { btn.tap(); sleep(1) }
        }
        shot(app, "test_04_home_with_healthkit_badge")

        // 4. Try tapping the HealthKit habit → should show toast
        let stepsHabit = app.staticTexts["Daily Steps"]
        if stepsHabit.waitForExistence(timeout: 3) {
            // Find the button near it
            let completeBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Daily Steps'")).firstMatch
            if completeBtn.waitForExistence(timeout: 2) && completeBtn.isHittable {
                completeBtn.tap()
                sleep(1)
                shot(app, "test_05_healthkit_toast")

                // Verify toast text
                let toastText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'syncs from Apple Health'")).firstMatch
                XCTAssertTrue(toastText.waitForExistence(timeout: 3), "HealthKit toast should appear")
            }
        }

        // 5. Also create a progressive habit to verify +1 counter
        app.tabBars.buttons["Habits"].tap()
        sleep(1)
        for label in ["Awesome!", "Got it!", "OK"] {
            let btn = app.buttons[label]
            if btn.waitForExistence(timeout: 1) && btn.isHittable { btn.tap(); sleep(1) }
        }

        if addBtn.waitForExistence(timeout: 3) && addBtn.isHittable {
            addBtn.tap()
            sleep(1)

            let nameField = app.textFields["e.g. Morning Meditation"]
            if nameField.waitForExistence(timeout: 3) {
                nameField.tap()
                nameField.typeText("Drink 8 Glasses")
                sleep(1)
            }

            // Scroll to goal count and set it > 1
            app.swipeUp()
            sleep(1)

            // Find goal stepper/field — look for the unit/goal section
            let goalField = app.textFields.matching(NSPredicate(format: "value CONTAINS '1'")).firstMatch
            if goalField.waitForExistence(timeout: 2) {
                goalField.tap()
                goalField.clearAndTypeText("8")
                sleep(1)
                shot(app, "test_06_progressive_goal_set")
            }

            app.swipeUp()
            sleep(1)
            let createBtn = app.buttons["Create Habit"]
            if createBtn.waitForExistence(timeout: 3) && createBtn.isEnabled {
                createBtn.tap()
                sleep(1)
            } else {
                app.swipeDown(velocity: .fast)
                sleep(1)
            }
        }

        // Check home for +1 counter
        app.tabBars.buttons["Home"].tap()
        sleep(1)
        for label in ["Awesome!", "Got it!", "OK"] {
            let btn = app.buttons[label]
            if btn.waitForExistence(timeout: 1) && btn.isHittable { btn.tap(); sleep(1) }
        }
        app.swipeUp()
        sleep(1)
        shot(app, "test_07_home_progressive_counter")
    }

    // MARK: - Sleep Pill Selector Test

    @MainActor
    func testSleepPillSelector() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screenshotMode"]
        app.launch()
        sleep(3)
        continueAfterFailure = true

        // Dismiss popups
        for label in ["Awesome!", "Got it!", "OK"] {
            let btn = app.buttons[label]
            if btn.waitForExistence(timeout: 1) && btn.isHittable { btn.tap(); sleep(1) }
        }

        // Go to Sleep tab
        app.tabBars.buttons["Sleep"].tap()
        sleep(1)

        // Tap Log Sleep
        let logSleep = app.buttons["Log Sleep"]
        if logSleep.waitForExistence(timeout: 3) && logSleep.isHittable {
            logSleep.tap()
            sleep(1)
            shot(app, "test_08_sleep_form_top")

            // Scroll to quality section
            app.swipeUp()
            sleep(1)
            shot(app, "test_09_sleep_quality_pills")

            // Tap "Excellent" pill
            let excellent = app.staticTexts["Excellent"]
            if excellent.waitForExistence(timeout: 2) && excellent.isHittable {
                excellent.tap()
                sleep(1)
                shot(app, "test_10_quality_excellent_selected")
            }

            // Scroll to mood section
            app.swipeUp()
            sleep(1)
            shot(app, "test_11_mood_pills")

            // Tap "Energized" mood
            let energized = app.staticTexts["Energized"]
            if energized.waitForExistence(timeout: 2) && energized.isHittable {
                energized.tap()
                sleep(1)
                shot(app, "test_12_mood_energized_selected")
            }
        }
    }

    private func shot(_ app: XCUIApplication, _ name: String) {
        let data = app.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: dir + name + ".png"))
    }
}

private extension XCUIElement {
    func clearAndTypeText(_ text: String) {
        guard let currentValue = self.value as? String else {
            self.typeText(text)
            return
        }
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
        self.typeText(deleteString)
        self.typeText(text)
    }
}
