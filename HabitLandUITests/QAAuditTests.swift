import XCTest

final class QAAuditTests: XCTestCase {

    let screenshotDir = "/Users/azc/works/HabitLand/qa_audit/screenshots/by_screen/"

    @MainActor
    func testFullAppAudit() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screenshotMode"]
        app.launch()
        sleep(2)
        continueAfterFailure = true

        // ═══════════════════════════════════════
        // TAB 1: HOME
        // ═══════════════════════════════════════
        tapTab(app, "Home")
        sleep(1)
        save(app, "01_home_dashboard")

        // Scroll down to see all cards
        app.swipeUp()
        sleep(1)
        save(app, "01_home_dashboard_scrolled")

        // ═══════════════════════════════════════
        // TAB 2: HABITS
        // ═══════════════════════════════════════
        tapTab(app, "Habits")
        sleep(1)
        save(app, "02_habits_list")

        // Tap first habit to open detail
        let firstHabit = app.staticTexts["Morning Meditation"]
        if firstHabit.waitForExistence(timeout: 3) {
            firstHabit.tap()
            sleep(1)
            save(app, "02_habit_detail")

            // Back
            let backButton = app.navigationBars.buttons.element(boundBy: 0)
            if backButton.exists { backButton.tap() }
            sleep(1)
        }

        // Tap + to create habit
        let addButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Add' OR label CONTAINS 'plus' OR label CONTAINS 'New'")).firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
            sleep(1)
            save(app, "02_create_habit")

            // Check HealthKit section exists
            let healthLabel = app.staticTexts["Apple Health"]
            XCTAssertTrue(healthLabel.waitForExistence(timeout: 3), "HealthKit section should exist in CreateHabitView")

            // Scroll to see HealthKit section
            app.swipeUp()
            sleep(1)
            save(app, "02_create_habit_healthkit")

            // Dismiss
            let closeButton = app.navigationBars.buttons.element(boundBy: 0)
            if closeButton.exists { closeButton.tap() }
            sleep(1)
        }

        // ═══════════════════════════════════════
        // TAB 3: SLEEP (Pro-gated in non-screenshot mode)
        // ═══════════════════════════════════════
        tapTab(app, "Sleep")
        sleep(1)
        save(app, "03_sleep_dashboard")

        app.swipeUp()
        sleep(1)
        save(app, "03_sleep_dashboard_scrolled")

        // ═══════════════════════════════════════
        // TAB 4: SOCIAL
        // ═══════════════════════════════════════
        tapTab(app, "Social")
        sleep(1)
        save(app, "04_social_hub")

        // Check if SocialHubView loaded (should show Friends/Leaderboard/Challenges/Feed sections)
        // or iCloud Required message
        let iCloudRequired = app.staticTexts["iCloud Required"]
        if iCloudRequired.waitForExistence(timeout: 2) {
            save(app, "04_social_icloud_required")
        } else {
            // Try tapping Leaderboard section
            let leaderboardTab = app.staticTexts["Leaderboard"]
            if leaderboardTab.waitForExistence(timeout: 2) {
                leaderboardTab.tap()
                sleep(1)
                save(app, "04_social_leaderboard")
            }

            // Challenges section
            let challengesTab = app.staticTexts["Challenges"]
            if challengesTab.waitForExistence(timeout: 2) {
                challengesTab.tap()
                sleep(1)
                save(app, "04_social_challenges")
            }

            // Feed section
            let feedTab = app.staticTexts["Feed"]
            if feedTab.waitForExistence(timeout: 2) {
                feedTab.tap()
                sleep(1)
                save(app, "04_social_feed")
            }

            // Back to Friends
            let friendsTab = app.staticTexts["Friends"]
            if friendsTab.waitForExistence(timeout: 2) {
                friendsTab.tap()
                sleep(1)
                save(app, "04_social_friends")
            }
        }

        // ═══════════════════════════════════════
        // TAB 5: PROFILE
        // ═══════════════════════════════════════
        tapTab(app, "Profile")
        sleep(1)
        save(app, "05_profile")

        app.swipeUp()
        sleep(1)
        save(app, "05_profile_scrolled")

        // Tap Settings
        let settingsRow = app.staticTexts["Settings"]
        if settingsRow.waitForExistence(timeout: 3) {
            settingsRow.tap()
            sleep(1)
            save(app, "05_settings")

            // Privacy settings (data export)
            let privacyRow = app.staticTexts["Privacy"]
            if privacyRow.waitForExistence(timeout: 3) {
                privacyRow.tap()
                sleep(1)
                save(app, "05_privacy_settings")

                // Check Your Data section exists
                let exportButton = app.staticTexts["Export All Data"]
                XCTAssertTrue(exportButton.waitForExistence(timeout: 3), "Export All Data button should exist")
                save(app, "05_privacy_data_export")

                // Back
                app.navigationBars.buttons.element(boundBy: 0).tap()
                sleep(1)
            }

            // Appearance settings
            let appearanceRow = app.staticTexts["Appearance"]
            if appearanceRow.waitForExistence(timeout: 3) {
                appearanceRow.tap()
                sleep(1)
                save(app, "05_appearance_settings")

                app.navigationBars.buttons.element(boundBy: 0).tap()
                sleep(1)
            }

            // Back to profile
            app.navigationBars.buttons.element(boundBy: 0).tap()
            sleep(1)
        }

        // ═══════════════════════════════════════
        // PAYWALL
        // ═══════════════════════════════════════
        // In screenshot mode isPro=true, so paywall isn't shown via gate
        // Try to find an upgrade button
        let upgradeButton = app.staticTexts["Upgrade to Pro"]
        if upgradeButton.waitForExistence(timeout: 2) {
            upgradeButton.tap()
            sleep(1)
            save(app, "06_paywall")

            // Check trial banner
            let trialBanner = app.staticTexts["7-day free trial"]
            if trialBanner.exists {
                save(app, "06_paywall_trial")
            }

            // Dismiss
            let closePaywall = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Close' OR label CONTAINS 'xmark'")).firstMatch
            if closePaywall.exists { closePaywall.tap() }
            sleep(1)
        }

        print("QA Audit complete — screenshots saved to \(screenshotDir)")
    }

    // MARK: - Helpers

    private func tapTab(_ app: XCUIApplication, _ name: String) {
        let tab = app.tabBars.buttons[name]
        if tab.waitForExistence(timeout: 3) {
            tab.tap()
        }
    }

    private func save(_ app: XCUIApplication, _ name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        let data = screenshot.pngRepresentation
        let url = URL(fileURLWithPath: screenshotDir + name + ".png")
        try? data.write(to: url)
        print("[SHOT] Saved: \(name).png")
    }
}
