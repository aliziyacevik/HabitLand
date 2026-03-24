import XCTest

final class QAAuditFullTests: XCTestCase {

    /// Reads the output directory from `.qa_audit/current_run_dir`.
    /// Falls back to `.qa_audit/screenshots/by_screen/` if file not found.
    private lazy var dir: String = {
        let projectRoot = "/Users/azc/works/HabitLand"
        let configPath = projectRoot + "/.qa_audit/current_run_dir"
        if let runDir = try? String(contentsOfFile: configPath, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines) {
            let screenshotDir = runDir + "/screenshots/"
            try? FileManager.default.createDirectory(atPath: screenshotDir, withIntermediateDirectories: true)
            return screenshotDir
        }
        // Fallback to legacy path
        return projectRoot + "/.qa_audit/screenshots/by_screen/"
    }()

    @MainActor
    func testFullAppAudit() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screenshotMode"]
        app.launch()
        sleep(3)
        continueAfterFailure = true

        // Aggressively dismiss any popups/celebrations on launch
        dismissAll(app)
        sleep(1)
        dismissAll(app)

        // ═══════════════════════════════════════════════
        // TAB 1: HOME
        // ═══════════════════════════════════════════════
        goTab(app, "Home")
        shot(app, "01_home_top")

        app.swipeUp(); sleep(1)
        shot(app, "01_home_mid")

        app.swipeUp(); sleep(1)
        shot(app, "01_home_bottom")

        scrollTop(app)

        // Notifications
        if tapIfExists(app.buttons["Notifications"], app) {
            shot(app, "01_notifications")
            dismiss(app)
        }

        // FAB → Create Habit
        if tapIfExists(app.buttons["Add new habit"], app) {
            shot(app, "01_create_habit_sheet")
            dismiss(app)
        }

        // Pomodoro / Focus Timer
        goTab(app, "Home")
        scrollTop(app)
        app.swipeUp(); sleep(1)
        let focusTimer = app.staticTexts["Focus Timer"]
        if focusTimer.waitForExistence(timeout: 2) && focusTimer.isHittable {
            let playBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Start focus' OR label CONTAINS[c] 'pomodoro' OR label CONTAINS[c] 'timer'")).firstMatch
            if playBtn.waitForExistence(timeout: 1) && playBtn.isHittable {
                playBtn.tap(); sleep(1)
                shot(app, "01_pomodoro")
                dismiss(app)
            }
        }

        // Daily Overview - tap progress card
        goTab(app, "Home")
        scrollTop(app)
        let dailyProgress = app.staticTexts["Daily Progress"]
        if dailyProgress.waitForExistence(timeout: 2) && dailyProgress.isHittable {
            dailyProgress.tap(); sleep(1)
            dismissAll(app)
            shot(app, "01_daily_overview")
            dismiss(app)
        }

        // ═══════════════════════════════════════════════
        // TAB 2: HABITS
        // ═══════════════════════════════════════════════
        goTab(app, "Habits")
        shot(app, "02_habits_list")

        app.swipeUp(); sleep(1)
        shot(app, "02_habits_scrolled")
        scrollTop(app)

        // Tap first habit → detail
        let firstHabit = app.staticTexts["Morning Meditation"]
        if firstHabit.waitForExistence(timeout: 3) && firstHabit.isHittable {
            firstHabit.tap(); sleep(1)
            dismissAll(app)
            shot(app, "02_habit_detail_top")

            app.swipeUp(); sleep(1)
            shot(app, "02_habit_detail_mid")

            app.swipeUp(); sleep(1)
            shot(app, "02_habit_detail_bottom")

            scrollTop(app)

            // Edit habit (menu button)
            let menuBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Edit' OR label CONTAINS[c] 'More' OR label CONTAINS[c] 'Options' OR label CONTAINS[c] 'ellipsis'")).firstMatch
            if menuBtn.waitForExistence(timeout: 2) && menuBtn.isHittable {
                menuBtn.tap(); sleep(1)
                let editOption = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Edit'")).firstMatch
                if editOption.waitForExistence(timeout: 1) && editOption.isHittable {
                    editOption.tap(); sleep(1)
                }
                shot(app, "02_edit_habit")
                app.swipeUp(); sleep(1)
                shot(app, "02_edit_habit_scrolled")
                dismiss(app)
            }

            back(app)
        }

        // Create habit form
        goTab(app, "Habits")
        if tapIfExists(app.buttons["Add new habit"], app) {
            shot(app, "02_create_form_empty")

            let browseBtn = app.staticTexts["Browse Templates"]
            if browseBtn.waitForExistence(timeout: 2) && browseBtn.isHittable {
                browseBtn.tap(); sleep(1)
                shot(app, "02_template_browser")
                app.swipeUp(); sleep(1)
                shot(app, "02_template_browser_scrolled")
                dismiss(app)
            }

            let nameField = app.textFields.firstMatch
            if nameField.waitForExistence(timeout: 2) {
                nameField.tap()
                nameField.typeText("QA Test Habit")
                sleep(1)
                shot(app, "02_create_form_filled")
            }

            app.swipeUp(); sleep(1)
            shot(app, "02_create_form_mid")

            app.swipeUp(); sleep(1)
            shot(app, "02_create_form_bottom")

            let createBtn = app.buttons["Create Habit"]
            if createBtn.waitForExistence(timeout: 2) && createBtn.isEnabled {
                createBtn.tap(); sleep(2)
                dismissAll(app)
                shot(app, "02_habit_created")
            } else {
                dismiss(app)
            }
        }

        // Archived tab
        goTab(app, "Habits")
        let archivedBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Archived'")).firstMatch
        if archivedBtn.waitForExistence(timeout: 2) && archivedBtn.isHittable {
            archivedBtn.tap(); sleep(1)
            shot(app, "02_archived_habits")
        }

        // ═══════════════════════════════════════════════
        // TAB 3: SLEEP
        // ═══════════════════════════════════════════════
        goTab(app, "Sleep")
        shot(app, "03_sleep_dashboard")

        app.swipeUp(); sleep(1)
        shot(app, "03_sleep_scrolled")

        app.swipeUp(); sleep(1)
        shot(app, "03_sleep_bottom")

        scrollTop(app)

        // Log Sleep
        let logSleep = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Log Sleep'")).firstMatch
        if logSleep.waitForExistence(timeout: 2) && logSleep.isHittable {
            logSleep.tap(); sleep(1)
            shot(app, "03_log_sleep_form")
            app.swipeUp(); sleep(1)
            shot(app, "03_log_sleep_scrolled")

            let saveBtn = app.buttons["Save"]
            if saveBtn.waitForExistence(timeout: 2) && saveBtn.isHittable {
                saveBtn.tap(); sleep(2)
                dismissAll(app)
                shot(app, "03_sleep_saved")
            } else {
                dismiss(app)
            }
        }

        // Sleep History
        goTab(app, "Sleep")
        scrollTop(app)
        let histBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'history'")).firstMatch
        if histBtn.waitForExistence(timeout: 2) && histBtn.isHittable {
            histBtn.tap(); sleep(1)
            shot(app, "03_sleep_history")
            app.swipeUp(); sleep(1)
            shot(app, "03_sleep_history_scrolled")
            back(app)
        }

        // Sleep Analytics
        goTab(app, "Sleep")
        scrollTop(app)
        let analyticsBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'analytics'")).firstMatch
        if analyticsBtn.waitForExistence(timeout: 2) && analyticsBtn.isHittable {
            analyticsBtn.tap(); sleep(1)
            shot(app, "03_sleep_analytics")
            app.swipeUp(); sleep(1)
            shot(app, "03_sleep_analytics_scrolled")
            back(app)
        }

        // ═══════════════════════════════════════════════
        // TAB 4: SOCIAL
        // ═══════════════════════════════════════════════
        goTab(app, "Social")
        shot(app, "04_social_hub")

        app.swipeUp(); sleep(1)
        shot(app, "04_friends_scrolled")
        scrollTop(app)

        // Friend profile
        let sarah = app.staticTexts["Sarah"]
        if sarah.waitForExistence(timeout: 2) && sarah.isHittable {
            sarah.tap(); sleep(1)
            shot(app, "04_friend_profile")
            app.swipeUp(); sleep(1)
            shot(app, "04_friend_profile_scrolled")
            back(app)
        }

        // Invite friends
        goTab(app, "Social")
        let friendsSection = app.buttons["Friends"]
        if friendsSection.waitForExistence(timeout: 1) { friendsSection.tap(); sleep(1) }
        let addFriends = app.staticTexts["Add Friends"]
        if addFriends.waitForExistence(timeout: 2) && addFriends.isHittable {
            addFriends.tap(); sleep(1)
            shot(app, "04_invite_friends")
            dismiss(app)
        }

        // Leaderboard
        let lb = app.buttons["Leaderboard"]
        if lb.waitForExistence(timeout: 2) && lb.isHittable {
            lb.tap(); sleep(2)
            shot(app, "04_leaderboard")
            app.swipeUp(); sleep(1)
            shot(app, "04_leaderboard_scrolled")
        }

        // Challenges
        let ch = app.buttons["Challenges"]
        if ch.waitForExistence(timeout: 2) && ch.isHittable {
            ch.tap(); sleep(2)
            shot(app, "04_challenges")

            let createCh = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Create Challenge'")).firstMatch
            if createCh.waitForExistence(timeout: 2) && createCh.isHittable {
                createCh.tap(); sleep(1)
                shot(app, "04_create_challenge")
                dismiss(app)
            }
        }

        // Feed
        let feedTab = app.buttons["Feed"]
        if feedTab.waitForExistence(timeout: 2) && feedTab.isHittable {
            feedTab.tap(); sleep(2)
            shot(app, "04_feed")
            app.swipeUp(); sleep(1)
            shot(app, "04_feed_scrolled")
        }

        // ═══════════════════════════════════════════════
        // TAB 5: PROFILE
        // ═══════════════════════════════════════════════
        goTab(app, "Profile")
        shot(app, "05_profile_top")

        app.swipeUp(); sleep(1)
        shot(app, "05_profile_scrolled")

        app.swipeUp(); sleep(1)
        shot(app, "05_profile_bottom")

        scrollTop(app)

        // Edit Profile
        let editProfile = app.staticTexts["Edit Profile"]
        if editProfile.waitForExistence(timeout: 2) && editProfile.isHittable {
            editProfile.tap(); sleep(1)
            shot(app, "05_edit_profile")
            app.swipeUp(); sleep(1)
            shot(app, "05_edit_profile_scrolled")

            let avatarArea = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'avatar' OR label CONTAINS[c] 'Change' OR label CONTAINS[c] 'Photo' OR label CONTAINS[c] 'Edit Avatar'")).firstMatch
            if avatarArea.waitForExistence(timeout: 2) && avatarArea.isHittable {
                avatarArea.tap(); sleep(1)
                shot(app, "05_avatar_picker")
                dismiss(app)
            }

            back(app)
        }

        // Personal Statistics
        goTab(app, "Profile")
        app.swipeUp(); sleep(1)
        let statsLink = app.staticTexts["Personal Statistics"]
        if statsLink.waitForExistence(timeout: 2) && statsLink.isHittable {
            statsLink.tap(); sleep(1)
            shot(app, "05_personal_stats")
            app.swipeUp(); sleep(1)
            shot(app, "05_personal_stats_scrolled")
            back(app)
        }

        // Achievements
        goTab(app, "Profile")
        app.swipeUp(); sleep(1)
        let achieveLink = app.staticTexts["Achievements"]
        if achieveLink.waitForExistence(timeout: 2) && achieveLink.isHittable {
            achieveLink.tap(); sleep(1)
            shot(app, "05_achievements")
            app.swipeUp(); sleep(1)
            shot(app, "05_achievements_scrolled")
            back(app)
        }

        // ═══════════════════════════════════════════════
        // SETTINGS
        // ═══════════════════════════════════════════════
        goTab(app, "Profile")
        scrollTop(app)
        let settingsBtn = app.buttons["Settings"]
        if settingsBtn.waitForExistence(timeout: 2) && settingsBtn.isHittable {
            settingsBtn.tap(); sleep(1)
            shot(app, "06_settings_top")
            app.swipeUp(); sleep(1)
            shot(app, "06_settings_mid")
            app.swipeUp(); sleep(1)
            shot(app, "06_settings_bottom")

            scrollTop(app)

            for (label, name) in [
                ("Edit Profile", "06_edit_profile_from_settings"),
                ("Appearance", "06_appearance"),
                ("Habit Settings", "06_habit_settings"),
                ("Notifications", "06_notification_settings"),
                ("Privacy", "06_privacy"),
                ("Data & Export", "06_data_export")
            ] {
                scrollTop(app)
                let row = app.staticTexts[label]
                if row.waitForExistence(timeout: 2) && row.isHittable {
                    row.tap(); sleep(1)
                    shot(app, name)
                    app.swipeUp(); sleep(1)
                    shot(app, name + "_scrolled")
                    back(app)
                } else {
                    app.swipeUp(); sleep(1)
                    if row.waitForExistence(timeout: 1) && row.isHittable {
                        row.tap(); sleep(1)
                        shot(app, name)
                        back(app)
                    }
                }
            }

            // Paywall from Settings
            scrollTop(app)
            let upgradeBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Upgrade'")).firstMatch
            if upgradeBtn.waitForExistence(timeout: 2) && upgradeBtn.isHittable {
                upgradeBtn.tap(); sleep(1)
                shot(app, "06_paywall")
                app.swipeUp(); sleep(1)
                shot(app, "06_paywall_scrolled")
                dismiss(app)
            }

            back(app)
        }

        // Write metadata
        let meta = """
        {
            "date": "\(ISO8601DateFormatter().string(from: Date()))",
            "screenshotCount": \(screenshotCount),
            "testPassed": true
        }
        """
        try? meta.write(toFile: dir + "../metadata.json", atomically: true, encoding: .utf8)

        print("[QA] Full audit complete — \(dir) (\(screenshotCount) screenshots)")
    }

    // MARK: - State

    private var screenshotCount = 0

    // MARK: - Helpers

    private func goTab(_ app: XCUIApplication, _ name: String) {
        let tab = app.tabBars.buttons[name]
        if tab.waitForExistence(timeout: 3) { tab.tap() }
        sleep(2)
        dismissAll(app)
    }

    private func tapIfExists(_ element: XCUIElement, _ app: XCUIApplication) -> Bool {
        if element.waitForExistence(timeout: 2) && element.isHittable {
            element.tap()
            sleep(1)
            dismissAll(app)
            return true
        }
        return false
    }

    private func back(_ app: XCUIApplication) {
        sleep(1)
        let btn = app.navigationBars.buttons.element(boundBy: 0)
        if btn.exists && btn.isHittable { btn.tap(); sleep(1) }
    }

    private func scrollTop(_ app: XCUIApplication) {
        app.swipeDown(); app.swipeDown(); app.swipeDown()
        sleep(1)
    }

    private func dismissAll(_ app: XCUIApplication) {
        for _ in 0..<3 {
            for label in ["Awesome!", "Got it!", "OK", "Close", "Cancel", "Skip", "Not Now", "Maybe Later", "Continue", "Dismiss", "Done"] {
                let btn = app.buttons[label]
                if btn.waitForExistence(timeout: 0.3) && btn.isHittable {
                    btn.tap(); usleep(300000)
                }
            }
            if app.alerts.count > 0 {
                let alertBtn = app.alerts.buttons.firstMatch
                if alertBtn.exists { alertBtn.tap(); usleep(300000) }
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
        app.swipeDown(velocity: .fast)
        sleep(1)
    }

    private func shot(_ app: XCUIApplication, _ name: String) {
        let data = app.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: dir + name + ".png"))
        screenshotCount += 1
    }
}
