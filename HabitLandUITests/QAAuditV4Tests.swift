import XCTest

final class QAAuditV4Tests: XCTestCase {

    let dir = "/Users/azc/works/HabitLand/.qa_audit/runs/v4/screenshots/"

    // MARK: - Test 1: Fresh Onboarding

    @MainActor
    func testOnboarding() throws {
        let app = XCUIApplication()
        app.launch()
        sleep(3)
        continueAfterFailure = true

        shot(app, "onb_01_first_screen")

        // Page through onboarding
        let nextBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Next'")).firstMatch
        if nextBtn.waitForExistence(timeout: 3) && nextBtn.isHittable {
            nextBtn.tap(); sleep(2)
            shot(app, "onb_02_name_entry")

            // Enter name
            let nameField = app.textFields.firstMatch
            if nameField.waitForExistence(timeout: 3) {
                nameField.tap()
                nameField.typeText("QA User")
                sleep(1)
            }

            // Continue
            let continueBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Continue'")).firstMatch
            if continueBtn.waitForExistence(timeout: 3) && continueBtn.isHittable {
                continueBtn.tap(); sleep(2)
                shot(app, "onb_03_theme")
            }
        }

        // Theme — tap continue
        let themeContinue = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Continue'")).firstMatch
        if themeContinue.waitForExistence(timeout: 3) && themeContinue.isHittable {
            themeContinue.tap(); sleep(2)
            shot(app, "onb_04_trial")
        }

        // Trial — start
        let trialBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Start' OR label CONTAINS[c] 'Trial'")).firstMatch
        if trialBtn.waitForExistence(timeout: 3) && trialBtn.isHittable {
            trialBtn.tap(); sleep(2)
            shot(app, "onb_05_home_empty")
        }

        // Verify home loaded
        let habitLandTitle = app.staticTexts["HabitLand"]
        if habitLandTitle.waitForExistence(timeout: 5) {
            shot(app, "onb_06_home_confirmed")
        }
    }

    // MARK: - Test 2: Full App with Seeded Data

    @MainActor
    func testFullApp() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screenshotMode"]
        app.launch()
        sleep(3)
        continueAfterFailure = true
        dismissAll(app)

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

        // Tap a habit → detail
        goTab(app, "Home"); scrollTop(app)
        let habit = app.staticTexts["Drink Water"]
        if habit.waitForExistence(timeout: 3) && habit.isHittable {
            habit.tap(); sleep(2); dismissAll(app)
            shot(app, "home_06_habit_detail")
            app.swipeUp(); sleep(1); shot(app, "home_07_habit_detail_mid")
            app.swipeUp(); sleep(1); shot(app, "home_08_habit_detail_bottom")
            back(app)
        }

        // ══════════════════════════════════
        // HABITS TAB
        // ══════════════════════════════════
        goTab(app, "Habits")
        shot(app, "habits_01_list")
        app.swipeUp(); sleep(1); shot(app, "habits_02_scrolled")
        scrollTop(app)

        // Habit detail from Habits tab
        let medit = app.staticTexts["Morning Meditation"]
        if medit.waitForExistence(timeout: 3) && medit.isHittable {
            medit.tap(); sleep(1); dismissAll(app)
            shot(app, "habits_03_detail")
            back(app)
        }

        // Create habit form — full scroll
        goTab(app, "Habits")
        if tapSafe(app.buttons["Add new habit"], app) {
            shot(app, "habits_04_create_top")
            app.swipeUp(); sleep(1); shot(app, "habits_05_create_mid")
            app.swipeUp(); sleep(1); shot(app, "habits_06_create_bottom")
            app.swipeUp(); sleep(1); shot(app, "habits_07_create_health")
            app.swipeUp(); sleep(1); shot(app, "habits_08_create_reminder")
            dismiss(app)
        }

        // Archived
        goTab(app, "Habits")
        let archived = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Archived'")).firstMatch
        if archived.waitForExistence(timeout: 2) && archived.isHittable {
            archived.tap(); sleep(1); shot(app, "habits_09_archived")
        }

        // ══════════════════════════════════
        // SLEEP TAB
        // ══════════════════════════════════
        goTab(app, "Sleep")
        shot(app, "sleep_01_dashboard")
        app.swipeUp(); sleep(1); shot(app, "sleep_02_scrolled")
        scrollTop(app)

        // Log Sleep
        let logSleep = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Log Sleep'")).firstMatch
        if logSleep.waitForExistence(timeout: 2) && logSleep.isHittable {
            logSleep.tap(); sleep(1)
            shot(app, "sleep_03_form_top")
            app.swipeUp(); sleep(1); shot(app, "sleep_04_form_quality")
            app.swipeUp(); sleep(1); shot(app, "sleep_05_form_mood")
            dismiss(app)
        }

        // History
        goTab(app, "Sleep"); scrollTop(app)
        if tapSafe(app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'history'")).firstMatch, app) {
            shot(app, "sleep_06_history"); app.swipeUp(); sleep(1); shot(app, "sleep_07_history_scrolled"); back(app)
        }

        // Analytics
        goTab(app, "Sleep"); scrollTop(app)
        if tapSafe(app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'analytics'")).firstMatch, app) {
            shot(app, "sleep_08_analytics"); app.swipeUp(); sleep(1); shot(app, "sleep_09_analytics_scrolled"); back(app)
        }

        // ══════════════════════════════════
        // SOCIAL TAB
        // ══════════════════════════════════
        goTab(app, "Social")
        shot(app, "social_01_friends")
        app.swipeUp(); sleep(1); shot(app, "social_02_friends_scrolled")
        scrollTop(app)

        // Friend profile
        let sarah = app.staticTexts["Sarah"]
        if sarah.waitForExistence(timeout: 2) && sarah.isHittable {
            sarah.tap(); sleep(1); shot(app, "social_03_friend_profile"); back(app)
        }

        // Leaderboard
        if tapSafe(app.buttons["Leaderboard"], app) { shot(app, "social_04_leaderboard") }

        // Challenges
        if tapSafe(app.buttons["Challenges"], app) { shot(app, "social_05_challenges") }

        // Feed
        if tapSafe(app.buttons["Feed"], app) { shot(app, "social_06_feed"); app.swipeUp(); sleep(1); shot(app, "social_07_feed_scrolled") }

        // ══════════════════════════════════
        // PROFILE TAB
        // ══════════════════════════════════
        goTab(app, "Profile")
        shot(app, "profile_01_top")
        app.swipeUp(); sleep(1); shot(app, "profile_02_scrolled")
        scrollTop(app)

        // Edit Profile
        let editProfile = app.staticTexts["Edit Profile"]
        if editProfile.waitForExistence(timeout: 2) && editProfile.isHittable {
            editProfile.tap(); sleep(1); shot(app, "profile_03_edit"); back(app)
        }

        // Personal Stats
        goTab(app, "Profile"); app.swipeUp(); sleep(1)
        let stats = app.staticTexts["Personal Statistics"]
        if stats.waitForExistence(timeout: 2) && stats.isHittable {
            stats.tap(); sleep(1); shot(app, "profile_04_stats"); app.swipeUp(); sleep(1); shot(app, "profile_05_stats_scrolled"); back(app)
        }

        // Achievements
        let achievements = app.staticTexts["Achievements"]
        if achievements.waitForExistence(timeout: 2) && achievements.isHittable {
            achievements.tap(); sleep(1); shot(app, "profile_06_achievements"); back(app)
        }

        // ══════════════════════════════════
        // SETTINGS
        // ══════════════════════════════════
        goTab(app, "Profile"); scrollTop(app)
        let settings = app.buttons["Settings"]
        if settings.waitForExistence(timeout: 2) && settings.isHittable {
            settings.tap(); sleep(1); shot(app, "settings_01_top")
            app.swipeUp(); sleep(1); shot(app, "settings_02_scrolled")
            scrollTop(app)

            for (label, name) in [
                ("Appearance", "settings_03_appearance"),
                ("Notifications", "settings_04_notifications"),
                ("Habit Settings", "settings_05_habit"),
                ("Privacy", "settings_06_privacy")
            ] {
                let row = app.staticTexts[label]
                if row.waitForExistence(timeout: 2) && row.isHittable {
                    row.tap(); sleep(1); shot(app, name); back(app)
                }
            }

            // Data Export (may need scroll)
            app.swipeUp(); sleep(1)
            let dataExport = app.staticTexts["Data & Export"]
            if dataExport.waitForExistence(timeout: 2) && dataExport.isHittable {
                dataExport.tap(); sleep(1); shot(app, "settings_07_data_export"); back(app)
            }

            back(app) // back to profile
        }

        print("[QA-V4] Complete — \(shotCount) screenshots")
    }

    // MARK: - Helpers

    private var shotCount = 0

    private func goTab(_ app: XCUIApplication, _ name: String) {
        app.tabBars.buttons[name].tap(); sleep(2); dismissAll(app)
    }

    private func tapSafe(_ element: XCUIElement, _ app: XCUIApplication) -> Bool {
        if element.waitForExistence(timeout: 2) && element.isHittable {
            element.tap(); sleep(1); dismissAll(app); return true
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

    private func dismissAll(_ app: XCUIApplication) {
        for _ in 0..<3 {
            for label in ["Awesome!", "Got it!", "OK", "Close", "Cancel", "Skip", "Not Now", "Maybe Later", "Continue", "Dismiss", "Done"] {
                let btn = app.buttons[label]
                if btn.waitForExistence(timeout: 0.3) && btn.isHittable { btn.tap(); usleep(300000) }
            }
        }
    }

    private func dismiss(_ app: XCUIApplication) {
        sleep(1); dismissAll(app)
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
