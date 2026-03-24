import XCTest

final class QAAuditV5Tests: XCTestCase {

    let dir = "/Users/azc/works/HabitLand/.qa_audit/runs/v5/screenshots/"

    // MARK: - Test 1: Fresh Onboarding

    @MainActor
    func testOnboarding() throws {
        let app = XCUIApplication()
        app.launch()
        sleep(3)
        continueAfterFailure = true

        shot(app, "onb_01_welcome")

        // Page 1 → Next
        tap(app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Next'")), app)
        shot(app, "onb_02_name")

        // Enter name
        let nameField = app.textFields.firstMatch
        if nameField.waitForExistence(timeout: 3) { nameField.tap(); nameField.typeText("QA User"); sleep(1) }

        // Continue
        tap(app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Continue'")), app)
        shot(app, "onb_03_theme")

        // Theme → Continue
        tap(app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Continue'")), app)
        shot(app, "onb_04_trial")

        // Trial → Start
        tap(app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Start' OR label CONTAINS[c] 'Trial'")), app)
        shot(app, "onb_05_home")
    }

    // MARK: - Test 2: Full App Seeded

    @MainActor
    func testFullApp() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screenshotMode"]
        app.launch()
        sleep(4)
        continueAfterFailure = true
        nuke(app) // aggressive popup clear

        // ══════════════════════════════════
        // HOME
        // ══════════════════════════════════
        goTab(app, "Home")
        shot(app, "home_01_top")
        app.swipeUp(); sleep(1); shot(app, "home_02_mid")
        app.swipeUp(); sleep(1); shot(app, "home_03_bottom")
        scrollTop(app)

        // Notifications
        if tapSafe(app.buttons["Notifications"], app) { shot(app, "home_04_notifications"); dismiss(app) }

        // FAB
        if tapSafe(app.buttons["Add new habit"], app) { shot(app, "home_05_create_sheet"); dismiss(app) }

        // Habit detail via tap
        goTab(app, "Home"); scrollTop(app)
        let drinkWater = app.staticTexts["Drink Water"]
        if drinkWater.waitForExistence(timeout: 3) && drinkWater.isHittable {
            drinkWater.tap(); sleep(2); nuke(app)
            shot(app, "home_06_habit_detail")
            app.swipeUp(); sleep(1); shot(app, "home_07_habit_detail_scrolled")
            back(app)
        }

        // ══════════════════════════════════
        // HABITS
        // ══════════════════════════════════
        goTab(app, "Habits")
        shot(app, "habits_01_list")
        app.swipeUp(); sleep(1); shot(app, "habits_02_scrolled")
        scrollTop(app)

        // Detail
        let medit = app.staticTexts["Morning Meditation"]
        if medit.waitForExistence(timeout: 3) && medit.isHittable {
            medit.tap(); sleep(2); nuke(app)
            shot(app, "habits_03_detail")
            back(app)
        }

        // Create form full scroll
        goTab(app, "Habits")
        if tapSafe(app.buttons["Add new habit"], app) {
            shot(app, "habits_04_create_top")
            for i in 1...4 { app.swipeUp(); sleep(1); shot(app, "habits_05_create_scroll\(i)") }
            dismiss(app)
        }

        // Archived
        goTab(app, "Habits")
        let archived = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Archived'")).firstMatch
        if archived.waitForExistence(timeout: 2) && archived.isHittable { archived.tap(); sleep(1); shot(app, "habits_06_archived") }

        // ══════════════════════════════════
        // SLEEP
        // ══════════════════════════════════
        goTab(app, "Sleep")
        shot(app, "sleep_01_dashboard")
        app.swipeUp(); sleep(1); shot(app, "sleep_02_scrolled")
        scrollTop(app)

        // Log Sleep
        if tapSafe(app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Log Sleep'")).firstMatch, app) {
            shot(app, "sleep_03_form_top")
            app.swipeUp(); sleep(1); shot(app, "sleep_04_form_quality")
            app.swipeUp(); sleep(1); shot(app, "sleep_05_form_mood")
            dismiss(app)
        }

        // History
        goTab(app, "Sleep"); scrollTop(app)
        if tapSafe(app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'history'")).firstMatch, app) {
            shot(app, "sleep_06_history"); back(app)
        }

        // Analytics
        goTab(app, "Sleep"); scrollTop(app)
        if tapSafe(app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'analytics'")).firstMatch, app) {
            shot(app, "sleep_07_analytics"); back(app)
        }

        // ══════════════════════════════════
        // SOCIAL
        // ══════════════════════════════════
        goTab(app, "Social")
        shot(app, "social_01_friends")

        // Friend profile
        let sarah = app.staticTexts["Sarah"]
        if sarah.waitForExistence(timeout: 2) && sarah.isHittable { sarah.tap(); sleep(1); shot(app, "social_02_friend_profile"); back(app) }

        if tapSafe(app.buttons["Leaderboard"], app) { shot(app, "social_03_leaderboard") }
        if tapSafe(app.buttons["Challenges"], app) { shot(app, "social_04_challenges") }
        if tapSafe(app.buttons["Feed"], app) { shot(app, "social_05_feed") }

        // ══════════════════════════════════
        // PROFILE
        // ══════════════════════════════════
        goTab(app, "Profile")
        shot(app, "profile_01_top")
        app.swipeUp(); sleep(1); shot(app, "profile_02_scrolled")
        scrollTop(app)

        // Edit Profile
        let editProfile = app.staticTexts["Edit Profile"]
        if editProfile.waitForExistence(timeout: 3) && editProfile.isHittable {
            editProfile.tap(); sleep(1); nuke(app)
            shot(app, "profile_03_edit")
            app.swipeUp(); sleep(1); shot(app, "profile_04_edit_scrolled")
            back(app)
        }

        // Personal Stats
        goTab(app, "Profile"); app.swipeUp(); sleep(1)
        let stats = app.staticTexts["Personal Statistics"]
        if stats.waitForExistence(timeout: 2) && stats.isHittable {
            stats.tap(); sleep(1); shot(app, "profile_05_stats"); back(app)
        }

        // Achievements
        let achieve = app.staticTexts["Achievements"]
        if achieve.waitForExistence(timeout: 2) && achieve.isHittable {
            achieve.tap(); sleep(1); nuke(app)
            shot(app, "profile_06_achievements"); back(app)
        }

        // ══════════════════════════════════
        // SETTINGS — use multiple strategies to find gear icon
        // ══════════════════════════════════
        goTab(app, "Profile"); scrollTop(app); sleep(1)

        // Strategy 1: accessibilityLabel
        var settingsFound = false
        let settingsBtn = app.buttons["Settings"]
        if settingsBtn.waitForExistence(timeout: 2) && settingsBtn.isHittable {
            settingsBtn.tap(); sleep(1); settingsFound = true
        }

        // Strategy 2: NavigationBar trailing button
        if !settingsFound {
            let navBtn = app.navigationBars.buttons.element(boundBy: 1)
            if navBtn.exists && navBtn.isHittable { navBtn.tap(); sleep(1); settingsFound = true }
        }

        // Strategy 3: tap "Settings" text in quick links
        if !settingsFound {
            goTab(app, "Profile"); app.swipeUp(); sleep(1)
            let settingsText = app.staticTexts["Settings"]
            if settingsText.waitForExistence(timeout: 2) && settingsText.isHittable {
                settingsText.tap(); sleep(1); settingsFound = true
            }
        }

        if settingsFound {
            nuke(app)
            shot(app, "settings_01_top")
            app.swipeUp(); sleep(1); shot(app, "settings_02_scrolled")
            scrollTop(app)

            // Sub-screens
            for (label, name) in [
                ("Appearance", "settings_03_appearance"),
                ("Notifications", "settings_04_notifications"),
                ("Habit Settings", "settings_05_habit"),
                ("Privacy", "settings_06_privacy")
            ] {
                scrollTop(app)
                let row = app.staticTexts[label]
                if row.waitForExistence(timeout: 2) && row.isHittable {
                    row.tap(); sleep(1); shot(app, name); back(app)
                }
            }

            // Data Export (needs scroll)
            app.swipeUp(); sleep(1)
            let dataExport = app.staticTexts["Data & Export"]
            if dataExport.waitForExistence(timeout: 2) && dataExport.isHittable {
                dataExport.tap(); sleep(1); shot(app, "settings_07_data_export"); back(app)
            }

            back(app) // back to profile
        }

        print("[QA-V5] Complete — \(shotCount) screenshots")
    }

    // MARK: - Helpers

    private var shotCount = 0

    private func goTab(_ app: XCUIApplication, _ name: String) {
        app.tabBars.buttons[name].tap(); sleep(2); nuke(app)
    }

    private func tap(_ query: XCUIElementQuery, _ app: XCUIApplication) {
        let el = query.firstMatch
        if el.waitForExistence(timeout: 3) && el.isHittable { el.tap(); sleep(2); nuke(app) }
    }

    private func tapSafe(_ element: XCUIElement, _ app: XCUIApplication) -> Bool {
        if element.waitForExistence(timeout: 2) && element.isHittable {
            element.tap(); sleep(1); nuke(app); return true
        }
        return false
    }

    private func back(_ app: XCUIApplication) {
        sleep(1)
        let btn = app.navigationBars.buttons.element(boundBy: 0)
        if btn.exists && btn.isHittable { btn.tap(); sleep(1) }
    }

    private func scrollTop(_ app: XCUIApplication) {
        app.swipeDown(); app.swipeDown(); app.swipeDown(); sleep(1)
    }

    private func nuke(_ app: XCUIApplication) {
        for _ in 0..<5 {
            var found = false
            for label in ["Awesome!", "Got it!", "OK", "Close", "Cancel", "Skip", "Not Now", "Maybe Later", "Dismiss", "Done"] {
                let btn = app.buttons[label]
                if btn.exists && btn.isHittable { btn.tap(); usleep(400000); found = true }
            }
            if app.alerts.count > 0 { app.alerts.buttons.firstMatch.tap(); usleep(400000); found = true }
            if !found { break }
        }
    }

    private func dismiss(_ app: XCUIApplication) {
        sleep(1); nuke(app)
        let close = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Cancel' OR label CONTAINS 'Close' OR label CONTAINS 'Done'")).firstMatch
        if close.waitForExistence(timeout: 1) && close.isHittable { close.tap(); sleep(1); return }
        let nav = app.navigationBars.buttons.element(boundBy: 0)
        if nav.exists && nav.isHittable { nav.tap(); sleep(1); return }
        app.swipeDown(velocity: .fast); sleep(1)
    }

    private func shot(_ app: XCUIApplication, _ name: String) {
        let data = app.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: dir + name + ".png"))
        shotCount += 1
    }
}
