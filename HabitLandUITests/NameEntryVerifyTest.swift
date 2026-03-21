import XCTest

final class NameEntryVerifyTest: XCTestCase {
    let dir = "/Users/azc/works/HabitLand/qa_audit/screenshots/by_screen/"

    @MainActor
    func testFullOnboardingFlow() throws {
        let app = XCUIApplication()
        app.launch()
        sleep(2)
        continueAfterFailure = true

        // === PAGE 1: Welcome ===
        save(app, "ob_01_welcome")
        XCTAssertTrue(app.staticTexts["Welcome to HabitLand"].exists, "Welcome title should show")
        let nextBtn = app.buttons["Next"]
        XCTAssertTrue(nextBtn.exists, "Next button should exist")

        // === PAGE 2 ===
        nextBtn.tap()
        sleep(1)
        save(app, "ob_02_page2")

        // === PAGE 3 ===
        let nextBtn2 = app.buttons["Next"]
        if nextBtn2.waitForExistence(timeout: 3) { nextBtn2.tap() }
        sleep(1)
        save(app, "ob_03_page3")

        // === PAGE 4 (Level Up) ===
        let nextBtn3 = app.buttons["Next"]
        if nextBtn3.waitForExistence(timeout: 3) { nextBtn3.tap() }
        sleep(1)
        save(app, "ob_04_level_up")

        // === PAGE 5 (Name Entry — inline) ===
        let nextBtn4 = app.buttons["Next"]
        if nextBtn4.waitForExistence(timeout: 3) { nextBtn4.tap() }
        sleep(1)
        save(app, "ob_05_name_entry")

        // Verify name entry elements on the page
        let nameField = app.textFields["Your name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5), "Name text field should appear")
        XCTAssertTrue(app.staticTexts["What's your name?"].exists, "Name entry title should show")

        // === TEST: Type name ===
        nameField.tap()
        sleep(1)
        nameField.typeText("Ahmet")
        sleep(1)
        save(app, "ob_06_name_typed")

        // === TAP "Choose My Habits" → STARTER HABITS ===
        // Dismiss keyboard first
        app.tap()
        sleep(1)
        let chooseBtn = app.buttons["Choose My Habits"]
        XCTAssertTrue(chooseBtn.waitForExistence(timeout: 3), "Choose My Habits should appear")
        chooseBtn.tap()
        sleep(2)
        save(app, "ob_07_starter_habits")

        // Verify starter habits screen
        let pickTitle = app.staticTexts["Pick Your Habits"]
        XCTAssertTrue(pickTitle.waitForExistence(timeout: 5), "Starter habits screen should appear")

        // === SELECT A HABIT ===
        let drinkWater = app.staticTexts["Drink Water"]
        if drinkWater.waitForExistence(timeout: 3) {
            drinkWater.tap()
            sleep(1)
        }
        save(app, "ob_09_habit_selected")

        // === TAP "Add X Habits" or "Skip for Now" ===
        save(app, "ob_10_after_select")
        // After selecting a habit, button changes to "Add N Habits"
        let addBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Add'")).firstMatch
        let skipBtn = app.buttons["Skip for Now"]
        if addBtn.waitForExistence(timeout: 3) {
            addBtn.tap()
        } else if skipBtn.waitForExistence(timeout: 3) {
            skipBtn.tap()
        }
        sleep(3)
        save(app, "ob_10_after_habits")

        // === VERIFY: Main screen reached (no referral step) ===
        let homeTab = app.tabBars.buttons["Home"]
        XCTAssertTrue(homeTab.waitForExistence(timeout: 10), "Should reach main screen with tab bar")
        save(app, "ob_11_main_screen")

        // === VERIFY: Name is "Ahmet" not "User" ===
        let greeting = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Ahmet'"))
        XCTAssertTrue(greeting.count > 0, "Greeting should contain 'Ahmet' not 'User'")
        save(app, "ob_13_home_with_name")
    }

    private func save(_ app: XCUIApplication, _ name: String) {
        let data = app.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: dir + name + ".png"))
    }
}
