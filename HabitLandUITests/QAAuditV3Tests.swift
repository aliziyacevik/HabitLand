import XCTest

final class QAAuditV3Tests: XCTestCase {

    let dir = "/Users/azc/works/HabitLand/.qa_audit/runs/v3/screenshots/"

    // MARK: - Test 1: Fresh Install Onboarding (NO screenshotMode)

    @MainActor
    func testOnboardingFreshInstall() throws {
        let app = XCUIApplication()
        app.launch() // NO screenshotMode — fresh install shows onboarding
        sleep(3)
        continueAfterFailure = true

        // Page 1
        shot(app, "onb_01_page1")

        // Navigate through all pages
        let nextBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Next'")).firstMatch
        for i in 2...5 {
            if nextBtn.waitForExistence(timeout: 3) && nextBtn.isHittable {
                nextBtn.tap()
                sleep(2)
                shot(app, "onb_0\(i)_page\(i)")
            }
        }

        // Last page — name entry + "Let's Go"
        sleep(1)
        shot(app, "onb_06_name_entry")

        let nameField = app.textFields.firstMatch
        if nameField.waitForExistence(timeout: 3) {
            nameField.tap()
            nameField.typeText("QA Tester")
            sleep(1)
        }

        let letsGoBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Go' OR label CONTAINS[c] 'Choose' OR label CONTAINS[c] 'Start'")).firstMatch
        if letsGoBtn.waitForExistence(timeout: 3) && letsGoBtn.isHittable {
            letsGoBtn.tap()
            sleep(2)
            shot(app, "onb_07_after_name")
        }

        // Reminder step
        shot(app, "onb_08_reminder")
        let skipBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Skip' OR label CONTAINS[c] 'later'")).firstMatch
        if skipBtn.waitForExistence(timeout: 3) && skipBtn.isHittable {
            skipBtn.tap()
            sleep(2)
            shot(app, "onb_09_after_reminder")
        } else {
            let enableBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Enable' OR label CONTAINS[c] 'Remind'")).firstMatch
            if enableBtn.waitForExistence(timeout: 2) && enableBtn.isHittable {
                enableBtn.tap()
                sleep(2)
                shot(app, "onb_09_after_reminder")
            }
        }

        // Theme step
        shot(app, "onb_10_theme")
        let continueBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Continue' OR label CONTAINS[c] 'Next' OR label CONTAINS[c] 'Choose'")).firstMatch
        if continueBtn.waitForExistence(timeout: 3) && continueBtn.isHittable {
            continueBtn.tap()
            sleep(2)
            shot(app, "onb_11_after_theme")
        }

        // Trial step
        shot(app, "onb_12_trial")
        let trialBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Start' OR label CONTAINS[c] 'Trial' OR label CONTAINS[c] 'Free'")).firstMatch
        if trialBtn.waitForExistence(timeout: 3) && trialBtn.isHittable {
            trialBtn.tap()
            sleep(2)
            shot(app, "onb_13_after_trial")
        }

        // Complete step
        shot(app, "onb_14_complete")
        let goBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Go' OR label CONTAINS[c] 'Start' OR label CONTAINS[c] 'Done'")).firstMatch
        if goBtn.waitForExistence(timeout: 3) && goBtn.isHittable {
            goBtn.tap()
            sleep(2)
        }

        // Should be on home now
        shot(app, "onb_15_home_empty")

        // Check coaching overlay
        let coaching = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'first habit'")).firstMatch
        if coaching.waitForExistence(timeout: 3) {
            shot(app, "onb_16_coaching_overlay")
        }
    }

    // MARK: - Test 2: Full App with Seeded Data

    @MainActor
    func testFullAppSeeded() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screenshotMode"]
        app.launch()
        sleep(3)
        continueAfterFailure = true

        dismissAll(app)

        // ═══════════════════════════════════════
        // HOME TAB
        // ═══════════════════════════════════════
        goTab(app, "Home")
        shot(app, "home_01_top")

        app.swipeUp(); sleep(1)
        shot(app, "home_02_mid")

        app.swipeUp(); sleep(1)
        shot(app, "home_03_bottom")

        scrollTop(app)

        // Notifications
        if tapSafe(app.buttons["Notifications"], app) {
            shot(app, "home_04_notifications")
            dismiss(app)
        }

        // Create Habit Sheet
        if tapSafe(app.buttons["Add new habit"], app) {
            shot(app, "home_05_create_habit")
            dismiss(app)
        }

        // ═══════════════════════════════════════
        // HABITS TAB
        // ═══════════════════════════════════════
        goTab(app, "Habits")
        shot(app, "habits_01_list")

        app.swipeUp(); sleep(1)
        shot(app, "habits_02_scrolled")
        scrollTop(app)

        // First habit detail
        let firstHabit = app.staticTexts["Morning Meditation"]
        if firstHabit.waitForExistence(timeout: 3) && firstHabit.isHittable {
            firstHabit.tap(); sleep(1)
            dismissAll(app)
            shot(app, "habits_03_detail_top")

            app.swipeUp(); sleep(1)
            shot(app, "habits_04_detail_mid")

            app.swipeUp(); sleep(1)
            shot(app, "habits_05_detail_bottom")

            back(app)
        }

        // Create habit with full form
        goTab(app, "Habits")
        if tapSafe(app.buttons["Add new habit"], app) {
            shot(app, "habits_06_create_empty")

            // Scroll through entire form
            app.swipeUp(); sleep(1)
            shot(app, "habits_07_create_mid")

            app.swipeUp(); sleep(1)
            shot(app, "habits_08_create_bottom")

            app.swipeUp(); sleep(1)
            shot(app, "habits_09_create_health")

            dismiss(app)
        }

        // Archived
        goTab(app, "Habits")
        let archived = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Archived'")).firstMatch
        if archived.waitForExistence(timeout: 2) && archived.isHittable {
            archived.tap(); sleep(1)
            shot(app, "habits_10_archived")
        }

        // ═══════════════════════════════════════
        // SLEEP TAB
        // ═══════════════════════════════════════
        goTab(app, "Sleep")
        shot(app, "sleep_01_dashboard")

        app.swipeUp(); sleep(1)
        shot(app, "sleep_02_scrolled")

        scrollTop(app)

        // Log Sleep
        let logSleep = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Log Sleep'")).firstMatch
        if logSleep.waitForExistence(timeout: 2) && logSleep.isHittable {
            logSleep.tap(); sleep(1)
            shot(app, "sleep_03_log_form_top")

            app.swipeUp(); sleep(1)
            shot(app, "sleep_04_log_form_quality")

            app.swipeUp(); sleep(1)
            shot(app, "sleep_05_log_form_mood")

            dismiss(app)
        }

        // Sleep History
        goTab(app, "Sleep"); scrollTop(app)
        let histBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'history'")).firstMatch
        if histBtn.waitForExistence(timeout: 2) && histBtn.isHittable {
            histBtn.tap(); sleep(1)
            shot(app, "sleep_06_history")
            back(app)
        }

        // Sleep Analytics
        goTab(app, "Sleep"); scrollTop(app)
        let analyticsBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'analytics'")).firstMatch
        if analyticsBtn.waitForExistence(timeout: 2) && analyticsBtn.isHittable {
            analyticsBtn.tap(); sleep(1)
            shot(app, "sleep_07_analytics")
            app.swipeUp(); sleep(1)
            shot(app, "sleep_08_analytics_scrolled")
            back(app)
        }

        // ═══════════════════════════════════════
        // SOCIAL TAB
        // ═══════════════════════════════════════
        goTab(app, "Social")
        shot(app, "social_01_hub")

        // Friend profile
        let sarah = app.staticTexts["Sarah"]
        if sarah.waitForExistence(timeout: 2) && sarah.isHittable {
            sarah.tap(); sleep(1)
            shot(app, "social_02_friend_profile")
            back(app)
        }

        // Leaderboard
        let lb = app.buttons["Leaderboard"]
        if lb.waitForExistence(timeout: 2) && lb.isHittable {
            lb.tap(); sleep(2)
            shot(app, "social_03_leaderboard")
        }

        // Challenges
        let ch = app.buttons["Challenges"]
        if ch.waitForExistence(timeout: 2) && ch.isHittable {
            ch.tap(); sleep(2)
            shot(app, "social_04_challenges")
        }

        // Feed
        let feed = app.buttons["Feed"]
        if feed.waitForExistence(timeout: 2) && feed.isHittable {
            feed.tap(); sleep(2)
            shot(app, "social_05_feed")
        }

        // ═══════════════════════════════════════
        // PROFILE TAB
        // ═══════════════════════════════════════
        goTab(app, "Profile")
        shot(app, "profile_01_top")

        app.swipeUp(); sleep(1)
        shot(app, "profile_02_scrolled")

        scrollTop(app)

        // Edit Profile
        let editProfile = app.staticTexts["Edit Profile"]
        if editProfile.waitForExistence(timeout: 2) && editProfile.isHittable {
            editProfile.tap(); sleep(1)
            shot(app, "profile_03_edit")
            app.swipeUp(); sleep(1)
            shot(app, "profile_04_edit_scrolled")
            back(app)
        }

        // Personal Statistics
        goTab(app, "Profile"); app.swipeUp(); sleep(1)
        let stats = app.staticTexts["Personal Statistics"]
        if stats.waitForExistence(timeout: 2) && stats.isHittable {
            stats.tap(); sleep(1)
            shot(app, "profile_05_stats")
            app.swipeUp(); sleep(1)
            shot(app, "profile_06_stats_scrolled")
            back(app)
        }

        // Achievements
        let achievements = app.staticTexts["Achievements"]
        if achievements.waitForExistence(timeout: 2) && achievements.isHittable {
            achievements.tap(); sleep(1)
            shot(app, "profile_07_achievements")
            back(app)
        }

        // Settings
        goTab(app, "Profile"); scrollTop(app)
        let settings = app.buttons["Settings"]
        if settings.waitForExistence(timeout: 2) && settings.isHittable {
            settings.tap(); sleep(1)
            shot(app, "settings_01_top")

            app.swipeUp(); sleep(1)
            shot(app, "settings_02_scrolled")

            scrollTop(app)

            // Appearance
            let appearance = app.staticTexts["Appearance"]
            if appearance.waitForExistence(timeout: 2) && appearance.isHittable {
                appearance.tap(); sleep(1)
                shot(app, "settings_03_appearance")
                back(app)
            }

            // Notifications
            let notif = app.staticTexts["Notifications"]
            if notif.waitForExistence(timeout: 2) && notif.isHittable {
                notif.tap(); sleep(1)
                shot(app, "settings_04_notifications")
                back(app)
            }

            // Habit Settings
            let habitSettings = app.staticTexts["Habit Settings"]
            if habitSettings.waitForExistence(timeout: 2) && habitSettings.isHittable {
                habitSettings.tap(); sleep(1)
                shot(app, "settings_05_habit")
                back(app)
            }

            // Privacy
            let privacy = app.staticTexts["Privacy"]
            if privacy.waitForExistence(timeout: 2) && privacy.isHittable {
                privacy.tap(); sleep(1)
                shot(app, "settings_06_privacy")
                back(app)
            }

            // Data & Export
            app.swipeUp(); sleep(1)
            let dataExport = app.staticTexts["Data & Export"]
            if dataExport.waitForExistence(timeout: 2) && dataExport.isHittable {
                dataExport.tap(); sleep(1)
                shot(app, "settings_07_data_export")
                back(app)
            }

            back(app) // back to profile
        }

        print("[QA-V3] Complete — \(shotCount) screenshots")
    }

    // MARK: - State

    private var shotCount = 0

    // MARK: - Helpers

    private func goTab(_ app: XCUIApplication, _ name: String) {
        app.tabBars.buttons[name].tap()
        sleep(2)
        dismissAll(app)
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
        sleep(1)
        dismissAll(app)
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
