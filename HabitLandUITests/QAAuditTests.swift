import XCTest

final class QAAuditTests: XCTestCase {

    private let screenshotDir = "/Users/azc/works/HabitLand/.qa_audit/screenshots/by_screen/"

    // MARK: - Test 1: Full App Audit with Seeded Data (Pro User)

    @MainActor
    func testFullAppAuditWithData() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screenshotMode"]
        app.launch()
        continueAfterFailure = true

        // Wait for app to fully load
        sleep(4)
        dismissEverything(app)
        sleep(1)

        // ═══════════════════════════════════════════
        // TAB 1: HOME
        // ═══════════════════════════════════════════
        app.tabBars.buttons["Home"].tap()
        sleep(2)
        dismissEverything(app)
        save(app, "01_home_dashboard")

        // Scroll down
        app.swipeUp()
        sleep(1)
        save(app, "01_home_dashboard_scrolled")

        app.swipeUp()
        sleep(1)
        save(app, "01_home_dashboard_scrolled2")

        // Scroll back up
        app.swipeDown()
        app.swipeDown()
        app.swipeDown()
        sleep(1)

        // Test notifications bell
        let bellButton = app.buttons["Notifications"]
        if bellButton.waitForExistence(timeout: 2) && bellButton.isHittable {
            bellButton.tap()
            sleep(2)
            save(app, "01_notifications")
            dismissSheet(app)
        }

        // Test FAB (create habit from home)
        let fab = app.buttons["Create Habit"]
        if fab.waitForExistence(timeout: 2) && fab.isHittable {
            fab.tap()
            sleep(2)
            save(app, "01_create_habit_from_home")
            app.swipeUp()
            sleep(1)
            save(app, "01_create_habit_from_home_scrolled")
            dismissSheet(app)
        }

        // Test habit card tap -> detail -> edit
        let firstHabit = app.staticTexts["Morning Meditation"]
        if firstHabit.waitForExistence(timeout: 3) && firstHabit.isHittable {
            firstHabit.tap()
            sleep(2)
            save(app, "02_habit_detail")

            app.swipeUp()
            sleep(1)
            save(app, "02_habit_detail_scrolled")

            // Test edit button
            let editButton = app.buttons["Edit"]
            if editButton.waitForExistence(timeout: 1) && editButton.isHittable {
                editButton.tap()
                sleep(2)
                save(app, "02_habit_edit")
                app.swipeUp()
                sleep(1)
                save(app, "02_habit_edit_scrolled")
                dismissSheet(app)
            }

            // Go back
            tapBackButton(app)
        }

        // ═══════════════════════════════════════════
        // TAB 2: HABITS
        // ═══════════════════════════════════════════
        app.tabBars.buttons["Habits"].tap()
        sleep(2)
        save(app, "02_habits_list")

        app.swipeUp()
        sleep(1)
        save(app, "02_habits_list_scrolled")
        app.swipeDown()
        sleep(1)

        // Test filter: Archived
        let archivedFilter = app.buttons["Archived"]
        if archivedFilter.waitForExistence(timeout: 2) && archivedFilter.isHittable {
            archivedFilter.tap()
            sleep(1)
            save(app, "02_habits_archived")
            let activeFilter = app.buttons["Active"]
            if activeFilter.waitForExistence(timeout: 2) && activeFilter.isHittable {
                activeFilter.tap()
                sleep(1)
            }
        }

        // Test sort menu
        let sortButton = app.buttons["Custom"]
        if sortButton.waitForExistence(timeout: 2) && sortButton.isHittable {
            sortButton.tap()
            sleep(1)
            save(app, "02_habits_sort_menu")
            // Dismiss sort menu by tapping elsewhere
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3)).tap()
            sleep(1)
        }

        // Test create habit from Habits tab
        let addHabitFab = app.buttons["Add new habit"]
        if addHabitFab.waitForExistence(timeout: 2) && addHabitFab.isHittable {
            addHabitFab.tap()
            sleep(2)
            save(app, "02_create_habit")
            app.swipeUp()
            sleep(1)
            save(app, "02_create_habit_scrolled")
            dismissSheet(app)
        }

        // Test habit detail from habits list
        let habitInList = app.staticTexts["Morning Meditation"]
        if habitInList.waitForExistence(timeout: 2) && habitInList.isHittable {
            habitInList.tap()
            sleep(2)
            save(app, "02_habit_detail_from_list")
            tapBackButton(app)
        }

        // ═══════════════════════════════════════════
        // TAB 3: SLEEP (Pro mode - full content)
        // ═══════════════════════════════════════════
        let sleepTab = app.tabBars.buttons["Sleep"]
        if sleepTab.waitForExistence(timeout: 2) {
            sleepTab.tap()
            sleep(2)
            save(app, "03_sleep_dashboard")

            app.swipeUp()
            sleep(1)
            save(app, "03_sleep_dashboard_scrolled")

            app.swipeUp()
            sleep(1)
            save(app, "03_sleep_dashboard_scrolled2")

            app.swipeDown()
            app.swipeDown()
            sleep(1)

            // Log Sleep button
            let logSleepBtn = app.buttons["Log Sleep"]
            if logSleepBtn.waitForExistence(timeout: 2) && logSleepBtn.isHittable {
                logSleepBtn.tap()
                sleep(2)
                save(app, "03_log_sleep")
                app.swipeUp()
                sleep(1)
                save(app, "03_log_sleep_scrolled")
                dismissSheet(app)
            }
        }

        // ═══════════════════════════════════════════
        // TAB 4: PROFILE
        // ═══════════════════════════════════════════
        app.tabBars.buttons["Profile"].tap()
        sleep(2)
        save(app, "04_profile")

        app.swipeUp()
        sleep(1)
        save(app, "04_profile_scrolled")
        app.swipeDown()
        sleep(1)

        // Edit Profile (NavigationLink — use buttons)
        let editProfileBtn = app.buttons["Edit Profile"]
        if editProfileBtn.waitForExistence(timeout: 2) && editProfileBtn.isHittable {
            editProfileBtn.tap()
            sleep(2)
            save(app, "04_edit_profile")
            tapBackButton(app)
        }

        // Personal Statistics (Pro user should see full stats — it's a NavigationLink)
        let statsLink = app.staticTexts["Personal Statistics"]
        if statsLink.waitForExistence(timeout: 2) && statsLink.isHittable {
            statsLink.tap()
            sleep(2)
            save(app, "04_personal_stats")
            app.swipeUp()
            sleep(1)
            save(app, "04_personal_stats_scrolled")
            tapBackButton(app)
        }

        // Achievements (quick link)
        // Scroll to make sure it's visible
        app.swipeUp()
        sleep(1)
        let achievementsLink = app.staticTexts["Achievements"].firstMatch
        if achievementsLink.waitForExistence(timeout: 2) && achievementsLink.isHittable {
            achievementsLink.tap()
            sleep(2)
            save(app, "04_achievements")
            app.swipeUp()
            sleep(1)
            save(app, "04_achievements_scrolled")
            tapBackButton(app)
        }

        // ═══════════════════════════════════════════
        // SETTINGS (via toolbar gear icon)
        // ═══════════════════════════════════════════
        // Scroll back to top first
        app.swipeDown()
        app.swipeDown()
        sleep(1)
        let settingsBtn = app.buttons["Settings"]
        if settingsBtn.waitForExistence(timeout: 2) && settingsBtn.isHittable {
            settingsBtn.tap()
            sleep(2)
            save(app, "05_settings")

            app.swipeUp()
            sleep(1)
            save(app, "05_settings_scrolled")
            app.swipeDown()
            sleep(1)

            // Appearance
            testSettingsSubScreen(app, title: "Appearance", name: "05_appearance")

            // Habit Settings
            testSettingsSubScreen(app, title: "Habit Settings", name: "05_habit_settings")

            // Notifications
            testSettingsSubScreen(app, title: "Notifications", name: "05_notifications")

            // Data & Export
            testSettingsSubScreen(app, title: "Data & Export", name: "05_data_export")

            // Legal: Privacy Policy
            app.swipeUp()
            sleep(1)
            let privacyPolicy = app.staticTexts["Privacy Policy"]
            if privacyPolicy.waitForExistence(timeout: 2) && privacyPolicy.isHittable {
                privacyPolicy.tap()
                sleep(2)
                save(app, "05_privacy_policy")
                dismissSheet(app)
            }

            // Terms of Use
            let terms = app.staticTexts["Terms of Use"]
            if terms.waitForExistence(timeout: 2) && terms.isHittable {
                terms.tap()
                sleep(2)
                save(app, "05_terms")
                dismissSheet(app)
            }

            // Scroll back and go back
            app.swipeDown()
            app.swipeDown()
            sleep(1)
            tapBackButton(app)
        }

        // Final state
        app.tabBars.buttons["Home"].tap()
        sleep(1)
        save(app, "99_final_state")
    }

    // MARK: - Test 2: Premium Gates as Free User

    @MainActor
    func testPremiumGatesAsFreeUser() throws {
        let app = XCUIApplication()
        // Launch WITHOUT screenshotMode = free user
        app.launch()
        continueAfterFailure = true

        sleep(4)

        // ─── Complete Onboarding ───
        completeOnboarding(app)
        sleep(2)
        dismissEverything(app)

        // Verify we're on main tab view
        let homeTab = app.tabBars.buttons["Home"]
        if !homeTab.waitForExistence(timeout: 5) {
            // Still in onboarding, try more dismissals
            dismissEverything(app)
            sleep(2)
        }
        save(app, "free_00_home_after_onboarding")

        // ═══════════════════════════════════════════
        // TEST: Sleep Tab Premium Gate
        // ═══════════════════════════════════════════
        let sleepTab = app.tabBars.buttons["Sleep"]
        if sleepTab.waitForExistence(timeout: 3) {
            sleepTab.tap()
            sleep(2)
            save(app, "free_01_sleep_premium_gate")

            // Check for upgrade button
            let upgradeBtn = app.buttons["Upgrade to Pro"]
            if upgradeBtn.waitForExistence(timeout: 2) {
                save(app, "free_01_sleep_upgrade_visible")
            }
        }

        // ═══════════════════════════════════════════
        // TEST: Profile -> Personal Statistics Lock
        // ═══════════════════════════════════════════
        app.tabBars.buttons["Profile"].tap()
        sleep(2)
        save(app, "free_02_profile")

        // Personal Statistics should show PRO badge
        let statsText = app.staticTexts["Personal Statistics"]
        if statsText.waitForExistence(timeout: 3) && statsText.isHittable {
            statsText.tap()
            sleep(2)
            save(app, "free_03_stats_paywall")
            dismissSheet(app)
            sleep(1)
        }

        // ═══════════════════════════════════════════
        // TEST: Settings -> Upgrade to Pro
        // ═══════════════════════════════════════════
        // Settings is the gear icon in the Profile toolbar
        let settingsGear = app.buttons["Settings"]
        if settingsGear.waitForExistence(timeout: 2) && settingsGear.isHittable {
            settingsGear.tap()
            sleep(2)
            save(app, "free_04_settings")

            let upgradeText = app.staticTexts["Upgrade to Pro"]
            if upgradeText.waitForExistence(timeout: 2) {
                save(app, "free_04_settings_upgrade_visible")
                if upgradeText.isHittable {
                    upgradeText.tap()
                    sleep(2)
                    save(app, "free_05_paywall_from_settings")
                    dismissSheet(app)
                }
            }

            tapBackButton(app)
        }

        // ═══════════════════════════════════════════
        // TEST: Habit Limit for Free User (create 3, then try 4th)
        // ═══════════════════════════════════════════
        app.tabBars.buttons["Habits"].tap()
        sleep(2)
        save(app, "free_06_habits_empty")

        // Create 3 habits to reach the free limit
        for i in 1...3 {
            createQuickHabit(app, name: "Test Habit \(i)")
            sleep(1)
        }

        save(app, "free_07_habits_at_limit")

        // Try creating 4th habit — should open paywall
        let addFab = app.buttons["Add new habit"]
        if addFab.waitForExistence(timeout: 2) && addFab.isHittable {
            addFab.tap()
            sleep(2)
            save(app, "free_08_paywall_from_habit_limit")
            // The paywall sheet should be open now
            dismissSheet(app)
        }

        save(app, "free_99_final_state")
    }

    // MARK: - Onboarding Helper

    private func completeOnboarding(_ app: XCUIApplication) {
        // Page 1: Welcome — tap Next
        let nextBtn = app.buttons["Next"]
        if nextBtn.waitForExistence(timeout: 3) && nextBtn.isHittable {
            nextBtn.tap()
            sleep(1)
        }

        // Page 2: Name entry — type name and tap Continue
        let nameField = app.textFields["Your name"]
        if nameField.waitForExistence(timeout: 3) && nameField.isHittable {
            nameField.tap()
            usleep(500_000)
            nameField.typeText("QA Tester")
            usleep(500_000)
        }

        let continueBtn = app.buttons["Continue"]
        if continueBtn.waitForExistence(timeout: 2) && continueBtn.isHittable {
            continueBtn.tap()
            sleep(2)
        }

        // Step 3: Theme selection — tap Continue
        let themeContinue = app.buttons["Continue"]
        if themeContinue.waitForExistence(timeout: 3) && themeContinue.isHittable {
            themeContinue.tap()
            sleep(2)
        }

        // Step 4: Pro offer — tap Maybe Later
        let maybeLater = app.buttons["Maybe Later"]
        if maybeLater.waitForExistence(timeout: 3) && maybeLater.isHittable {
            maybeLater.tap()
            sleep(2)
        }

        // Fallback: try other dismissal buttons
        dismissEverything(app)
    }

    // MARK: - Quick Habit Creator

    private func createQuickHabit(_ app: XCUIApplication, name: String) {
        let addFab = app.buttons["Add new habit"]
        guard addFab.waitForExistence(timeout: 3) && addFab.isHittable else { return }
        addFab.tap()
        sleep(2)

        // Type habit name
        let nameField = app.textFields["e.g. Morning Meditation"]
        if nameField.waitForExistence(timeout: 2) && nameField.isHittable {
            nameField.tap()
            usleep(500_000)
            nameField.typeText(name)
            usleep(500_000)
        }

        // Tap Create Habit button
        let createBtn = app.buttons["Create Habit"]
        if createBtn.waitForExistence(timeout: 2) && createBtn.isHittable {
            createBtn.tap()
            sleep(2)
        } else {
            // Scroll down to find Create Habit button
            app.swipeUp()
            sleep(1)
            let createBtnRetry = app.buttons["Create Habit"]
            if createBtnRetry.waitForExistence(timeout: 2) && createBtnRetry.isHittable {
                createBtnRetry.tap()
                sleep(2)
            }
        }

        // Dismiss any remaining sheet
        dismissSheet(app)
        sleep(1)
    }

    // MARK: - Settings Sub-Screen Helper

    private func testSettingsSubScreen(_ app: XCUIApplication, title: String, name: String) {
        let link = app.staticTexts[title]
        if link.waitForExistence(timeout: 2) && link.isHittable {
            link.tap()
            sleep(2)
            save(app, name)
            app.swipeUp()
            sleep(1)
            save(app, "\(name)_scrolled")
            tapBackButton(app)
        }
    }

    // MARK: - Helpers

    private func save(_ app: XCUIApplication, _ name: String) {
        let screenshot = app.screenshot()
        let data = screenshot.pngRepresentation
        let path = screenshotDir + name + ".png"
        let url = URL(fileURLWithPath: path)
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? data.write(to: url)
    }

    private func tapBackButton(_ app: XCUIApplication) {
        if app.navigationBars.buttons.count > 0 {
            let backBtn = app.navigationBars.buttons.element(boundBy: 0)
            if backBtn.isHittable {
                backBtn.tap()
                sleep(1)
                return
            }
        }
        // Fallback: swipe from left edge
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.5))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        start.press(forDuration: 0.1, thenDragTo: end)
        sleep(1)
    }

    private func dismissSheet(_ app: XCUIApplication) {
        // Method 1: Close / Done / Cancel buttons
        for label in ["Close", "Done", "Cancel", "Dismiss"] {
            let btn = app.buttons[label]
            if btn.waitForExistence(timeout: 0.5) && btn.isHittable {
                btn.tap()
                sleep(1)
                return
            }
        }

        // Method 2: xmark button (accessibility label "Close")
        let xmark = app.buttons["xmark.circle.fill"]
        if xmark.waitForExistence(timeout: 0.5) && xmark.isHittable {
            xmark.tap()
            sleep(1)
            return
        }

        // Method 3: Navigation back button
        if app.navigationBars.buttons.count > 0 {
            let backBtn = app.navigationBars.buttons.element(boundBy: 0)
            if backBtn.isHittable {
                backBtn.tap()
                sleep(1)
                return
            }
        }

        // Method 4: Swipe down
        let topCoord = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
        let bottomCoord = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
        topCoord.press(forDuration: 0.1, thenDragTo: bottomCoord)
        sleep(1)
    }

    private func dismissEverything(_ app: XCUIApplication) {
        // Dismiss alerts
        let alert = app.alerts.firstMatch
        if alert.waitForExistence(timeout: 0.5) {
            let okBtn = alert.buttons["OK"]
            if okBtn.exists { okBtn.tap() }
            else {
                let cancelBtn = alert.buttons["Cancel"]
                if cancelBtn.exists { cancelBtn.tap() }
                else if alert.buttons.count > 0 { alert.buttons.firstMatch.tap() }
            }
            sleep(1)
        }

        // Dismiss overlays and sheets
        let dismissLabels = [
            "Dismiss", "Got it", "Later", "Not Now", "Maybe Later",
            "Skip", "Awesome!", "Continue with Free Plan",
            "Close", "xmark.circle.fill"
        ]
        for label in dismissLabels {
            let btn = app.buttons[label]
            if btn.waitForExistence(timeout: 0.3) && btn.isHittable {
                btn.tap()
                usleep(500_000)
            }
        }
    }
}
