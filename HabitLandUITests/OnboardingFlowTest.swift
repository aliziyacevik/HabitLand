import XCTest

final class OnboardingFlowTest: XCTestCase {

    let screenshotDir = "/Users/azc/works/HabitLand/.qa_audit/screenshots/by_screen/"

    @MainActor
    func testNewOnboardingFlow() throws {
        let app = XCUIApplication()
        // Fresh start — no screenshotMode so onboarding shows
        app.launchArguments = ["-AppleLanguages", "(en)"]
        app.launch()
        sleep(2)
        continueAfterFailure = true

        // Page 1: Empathy
        let page1 = app.staticTexts["Always giving up\non habits?"]
        if page1.waitForExistence(timeout: 5) {
            save(app, "onb_01_empathy")

            // Next through pages
            let nextButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Next'")).firstMatch
            if nextButton.waitForExistence(timeout: 3) {
                nextButton.tap()
                sleep(1)
                save(app, "onb_02_streaks")

                nextButton.tap()
                sleep(1)
                save(app, "onb_03_sleep")

                nextButton.tap()
                sleep(1)
                save(app, "onb_04_social")

                nextButton.tap()
                sleep(1)
                save(app, "onb_05_levelup")

                nextButton.tap()
                sleep(1)
                save(app, "onb_06_name_entry")
            }

            // Enter name
            let nameField = app.textFields.firstMatch
            if nameField.waitForExistence(timeout: 3) {
                nameField.tap()
                nameField.typeText("TestUser")
                sleep(1)
            }

            // Tap "Choose My Habits" → goes to GuidedFirstHabitView
            let chooseBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Choose'")).firstMatch
            if chooseBtn.waitForExistence(timeout: 3) {
                chooseBtn.tap()
                sleep(1)
                save(app, "onb_07_guided_first_habit")

                // Select a template
                let drinkWater = app.staticTexts["Drink Water"]
                if drinkWater.waitForExistence(timeout: 3) && drinkWater.isHittable {
                    drinkWater.tap()
                    sleep(1)
                    save(app, "onb_08_habit_selected")
                }

                // Tap "Create Habit"
                let createBtn = app.buttons["Create Habit"]
                if createBtn.waitForExistence(timeout: 3) && createBtn.isEnabled {
                    createBtn.tap()
                    sleep(1)
                    save(app, "onb_09_complete_prompt")

                    // Tap the completion circle
                    let tapBtn = app.staticTexts["Tap!"]
                    if tapBtn.waitForExistence(timeout: 3) {
                        tapBtn.tap()
                        sleep(2)
                        save(app, "onb_10_first_completion")
                    }

                    // Wait for celebrate phase
                    sleep(2)
                    save(app, "onb_11_celebrate")

                    // Tap "Add More Habits"
                    let addMoreBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Add More'")).firstMatch
                    if addMoreBtn.waitForExistence(timeout: 3) {
                        addMoreBtn.tap()
                        sleep(1)
                        save(app, "onb_12_starter_habits")

                        // Skip adding more
                        let skipBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Good for Now' OR label CONTAINS 'Skip'")).firstMatch
                        if skipBtn.waitForExistence(timeout: 3) {
                            skipBtn.tap()
                            sleep(1)
                            save(app, "onb_13_reminder_setup")
                        }
                    }
                }
            }
        } else {
            // Onboarding already completed
            save(app, "onb_already_completed")
        }

        print("[QA] Onboarding Flow Test Complete")
    }

    private func save(_ app: XCUIApplication, _ name: String) {
        let screenshot = app.screenshot()
        let data = screenshot.pngRepresentation
        let url = URL(fileURLWithPath: screenshotDir + name + ".png")
        try? data.write(to: url)
        print("[QA-SHOT] \(name).png")
    }
}
