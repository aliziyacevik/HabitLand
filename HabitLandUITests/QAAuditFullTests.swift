import XCTest

final class QAAuditFullTests: XCTestCase {

    let screenshotDir = "/Users/azc/works/HabitLand/qa_audit/screenshots/by_screen/"

    // MARK: - Full App Audit

    @MainActor
    func testFullAppAudit() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screenshotMode"]
        app.launch()
        sleep(3)
        continueAfterFailure = true

        // ═══════════════════════════════════════════════
        // TAB 1: HOME DASHBOARD
        // ═══════════════════════════════════════════════
        tapTab(app, "Home")
        sleep(1)
        save(app, "qa_01_home_dashboard")

        // Verify key home elements exist
        XCTAssertTrue(app.staticTexts["HabitLand"].exists, "HabitLand title should be in nav bar")

        // Scroll to reveal all cards
        app.swipeUp()
        sleep(1)
        save(app, "qa_01_home_scrolled_mid")

        app.swipeUp()
        sleep(1)
        save(app, "qa_01_home_scrolled_bottom")

        // Scroll back up
        app.swipeDown()
        app.swipeDown()
        sleep(1)

        // Tap Notifications button
        let notifButton = app.buttons["Notifications"]
        if notifButton.waitForExistence(timeout: 3) {
            notifButton.tap()
            sleep(1)
            save(app, "qa_01_notification_center")

            // Dismiss notification center
            dismissSheet(app)
            sleep(1)
        }

        // Tap FAB (Add new habit) from Home
        let addHabitButton = app.buttons["Add new habit"]
        if addHabitButton.waitForExistence(timeout: 3) {
            addHabitButton.tap()
            sleep(1)
            save(app, "qa_01_home_create_habit_sheet")

            // Dismiss
            dismissSheet(app)
            sleep(1)
        }

        // Tap "See All" for daily habits if visible
        let seeAllButton = app.buttons["See All"]
        if seeAllButton.waitForExistence(timeout: 2) {
            seeAllButton.tap()
            sleep(1)
            save(app, "qa_01_daily_habits_overview")
            dismissSheet(app)
            sleep(1)
        }

        // ═══════════════════════════════════════════════
        // TAB 2: HABITS
        // ═══════════════════════════════════════════════
        tapTab(app, "Habits")
        sleep(1)
        save(app, "qa_02_habits_list")

        // Check summary header exists
        let todaysProgress = app.staticTexts["Today's Progress"]
        XCTAssertTrue(todaysProgress.waitForExistence(timeout: 3), "Today's Progress label should exist on Habits tab")

        // Scroll habits list
        app.swipeUp()
        sleep(1)
        save(app, "qa_02_habits_list_scrolled")
        app.swipeDown()
        sleep(1)

        // Tap first habit to see detail
        let morningMeditation = app.staticTexts["Morning Meditation"]
        if morningMeditation.waitForExistence(timeout: 3) {
            morningMeditation.tap()
            sleep(1)
            save(app, "qa_02_habit_detail")

            // Scroll detail view
            app.swipeUp()
            sleep(1)
            save(app, "qa_02_habit_detail_scrolled")

            // Go back
            tapNavBack(app)
            sleep(1)
        }

        // Tap + button on Habits tab
        let habitsAddButton = app.buttons["Add new habit"]
        if habitsAddButton.waitForExistence(timeout: 3) {
            habitsAddButton.tap()
            sleep(1)
            save(app, "qa_02_create_habit_form")

            // Test form: enter habit name
            let nameField = app.textFields["e.g. Morning Meditation"]
            if nameField.waitForExistence(timeout: 3) {
                nameField.tap()
                nameField.typeText("Test Habit QA")
                sleep(1)
                save(app, "qa_02_create_habit_name_entered")
            }

            // Scroll to see more options
            app.swipeUp()
            sleep(1)
            save(app, "qa_02_create_habit_form_scrolled")

            // Check Apple Health section
            let healthLabel = app.staticTexts["Apple Health"]
            if healthLabel.waitForExistence(timeout: 2) {
                save(app, "qa_02_create_habit_healthkit")
            }

            // Scroll to create button
            app.swipeUp()
            sleep(1)
            save(app, "qa_02_create_habit_form_bottom")

            // Tap Create Habit button
            let createButton = app.buttons["Create Habit"]
            if createButton.waitForExistence(timeout: 3) && createButton.isEnabled {
                createButton.tap()
                sleep(1)
                save(app, "qa_02_habit_created_success")
            } else {
                // Dismiss if can't create
                dismissSheet(app)
                sleep(1)
            }
        }

        // Test edge case: long habit name
        tapTab(app, "Habits")
        sleep(1)
        if habitsAddButton.waitForExistence(timeout: 3) {
            habitsAddButton.tap()
            sleep(1)

            let nameField = app.textFields["e.g. Morning Meditation"]
            if nameField.waitForExistence(timeout: 3) {
                nameField.tap()
                // Type exactly 50 chars (max)
                nameField.typeText("ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklmn")
                sleep(1)
                save(app, "qa_02_create_habit_long_name")
            }

            dismissSheet(app)
            sleep(1)
        }

        // Test Archived tab
        let archivedTab = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Archived'")).firstMatch
        if archivedTab.waitForExistence(timeout: 3) {
            archivedTab.tap()
            sleep(1)
            save(app, "qa_02_archived_habits_empty")
        }

        // Back to Active
        let activeTab = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Active'")).firstMatch
        if activeTab.waitForExistence(timeout: 2) {
            activeTab.tap()
            sleep(1)
        }

        // ═══════════════════════════════════════════════
        // TAB 3: SLEEP
        // ═══════════════════════════════════════════════
        tapTab(app, "Sleep")
        sleep(1)
        save(app, "qa_03_sleep_dashboard")

        // Check last night card
        let lastNight = app.staticTexts["Last Night"]
        XCTAssertTrue(lastNight.waitForExistence(timeout: 3), "Last Night label should exist on Sleep tab")

        // Scroll sleep dashboard
        app.swipeUp()
        sleep(1)
        save(app, "qa_03_sleep_dashboard_scrolled")

        // Tap Log Sleep button
        let logSleepButton = app.buttons["Log Sleep"]
        if logSleepButton.waitForExistence(timeout: 3) {
            logSleepButton.tap()
            sleep(1)
            save(app, "qa_03_log_sleep_form")

            // Check form elements
            let bedtimeLabel = app.staticTexts["Bedtime"]
            XCTAssertTrue(bedtimeLabel.waitForExistence(timeout: 3), "Bedtime label should exist in Log Sleep form")

            let sleepQualityLabel = app.staticTexts["Sleep Quality"]
            XCTAssertTrue(sleepQualityLabel.waitForExistence(timeout: 3), "Sleep Quality should exist")

            // Scroll to see more of the form
            app.swipeUp()
            sleep(1)
            save(app, "qa_03_log_sleep_form_scrolled")

            // Check mood section
            let moodLabel = app.staticTexts["Morning Mood"]
            XCTAssertTrue(moodLabel.waitForExistence(timeout: 3), "Morning Mood should exist in sleep form")

            // Save the sleep log
            let saveButton = app.buttons["Save"]
            if saveButton.waitForExistence(timeout: 3) {
                saveButton.tap()
                sleep(1)
                save(app, "qa_03_sleep_saved")
            } else {
                dismissSheet(app)
                sleep(1)
            }
        }

        // Tap Sleep Insights
        let sleepInsights = app.staticTexts["Sleep Insights"]
        if sleepInsights.waitForExistence(timeout: 3) {
            sleepInsights.tap()
            sleep(1)
            save(app, "qa_03_sleep_insights")
            tapNavBack(app)
            sleep(1)
        }

        // ═══════════════════════════════════════════════
        // TAB 4: SOCIAL
        // ═══════════════════════════════════════════════
        tapTab(app, "Social")
        sleep(2)
        save(app, "qa_04_social_hub")

        // Friends section (default)
        let friendsBtn = app.buttons["Friends"]
        if friendsBtn.waitForExistence(timeout: 3) {
            friendsBtn.tap()
            sleep(1)
            save(app, "qa_04_social_friends")

            // Tap Sarah's profile
            let sarahText = app.staticTexts["Sarah"]
            if sarahText.waitForExistence(timeout: 3) {
                sarahText.tap()
                sleep(1)
                save(app, "qa_04_friend_profile")

                // Scroll friend profile
                app.swipeUp()
                sleep(1)
                save(app, "qa_04_friend_profile_scrolled")

                tapNavBack(app)
                sleep(1)
            }
        }

        // Leaderboard
        let leaderboardBtn = app.buttons["Leaderboard"]
        if leaderboardBtn.waitForExistence(timeout: 3) {
            leaderboardBtn.tap()
            sleep(2)
            save(app, "qa_04_social_leaderboard")
        }

        // Challenges
        let challengesBtn = app.buttons["Challenges"]
        if challengesBtn.waitForExistence(timeout: 3) {
            challengesBtn.tap()
            sleep(2)
            save(app, "qa_04_social_challenges")
        }

        // Feed
        let feedBtn = app.buttons["Feed"]
        if feedBtn.waitForExistence(timeout: 3) {
            feedBtn.tap()
            sleep(2)
            save(app, "qa_04_social_feed")
        }

        // ═══════════════════════════════════════════════
        // TAB 5: PROFILE
        // ═══════════════════════════════════════════════
        tapTab(app, "Profile")
        sleep(1)
        save(app, "qa_05_profile")

        // Check profile elements
        let editProfileLink = app.staticTexts["Edit Profile"]
        XCTAssertTrue(editProfileLink.waitForExistence(timeout: 3), "Edit Profile link should be visible")

        // Scroll profile
        app.swipeUp()
        sleep(1)
        save(app, "qa_05_profile_scrolled")

        // Personal Statistics
        let personalStats = app.staticTexts["Personal Statistics"]
        if personalStats.waitForExistence(timeout: 3) {
            personalStats.tap()
            sleep(1)
            save(app, "qa_05_personal_statistics")
            tapNavBack(app)
            sleep(1)
        }

        // Achievements - use the button variant to avoid multiple matches
        let achievementsButton = app.buttons["Achievements"]
        if achievementsButton.waitForExistence(timeout: 3) {
            achievementsButton.tap()
            sleep(1)
            save(app, "qa_05_achievements")

            app.swipeUp()
            sleep(1)
            save(app, "qa_05_achievements_scrolled")

            tapNavBack(app)
            sleep(1)
        }

        // Settings
        let settingsLink = app.staticTexts["Settings"]
        if settingsLink.waitForExistence(timeout: 3) {
            settingsLink.tap()
            sleep(1)
            save(app, "qa_05_settings")

            // Scroll settings
            app.swipeUp()
            sleep(1)
            save(app, "qa_05_settings_scrolled")

            app.swipeUp()
            sleep(1)
            save(app, "qa_05_settings_bottom")

            // Navigate to Appearance
            app.swipeDown()
            app.swipeDown()
            sleep(1)
            let appearanceRow = app.staticTexts["Appearance"]
            if appearanceRow.waitForExistence(timeout: 3) {
                appearanceRow.tap()
                sleep(1)
                save(app, "qa_05_appearance_settings")
                tapNavBack(app)
                sleep(1)
            }

            // Navigate to Notifications
            let notifRow = app.staticTexts["Notifications"]
            if notifRow.waitForExistence(timeout: 3) {
                notifRow.tap()
                sleep(1)
                save(app, "qa_05_notification_settings")
                tapNavBack(app)
                sleep(1)
            }

            // Navigate to Privacy
            let privacyRow = app.staticTexts["Privacy"]
            if privacyRow.waitForExistence(timeout: 3) {
                privacyRow.tap()
                sleep(1)
                save(app, "qa_05_privacy_settings")

                // Check Export All Data button
                let exportButton = app.staticTexts["Export All Data"]
                if exportButton.waitForExistence(timeout: 3) {
                    save(app, "qa_05_privacy_data_export")
                }

                tapNavBack(app)
                sleep(1)
            }

            // Navigate to Data & Export
            let dataExportRow = app.staticTexts["Data & Export"]
            if dataExportRow.waitForExistence(timeout: 3) {
                dataExportRow.tap()
                sleep(1)
                save(app, "qa_05_data_export")
                tapNavBack(app)
                sleep(1)
            }

            // Navigate to Habit Settings
            let habitSettingsRow = app.staticTexts["Habit Settings"]
            if habitSettingsRow.waitForExistence(timeout: 3) {
                habitSettingsRow.tap()
                sleep(1)
                save(app, "qa_05_habit_settings")
                tapNavBack(app)
                sleep(1)
            }

            // Check version info
            app.swipeUp()
            app.swipeUp()
            sleep(1)
            let versionText = app.staticTexts["Version 1.0.0 (Build 1)"]
            if versionText.waitForExistence(timeout: 2) {
                save(app, "qa_05_settings_version")
            }

            // Back to Profile
            tapNavBack(app)
            sleep(1)
        }

        // Edit Profile
        tapTab(app, "Profile")
        sleep(1)
        if editProfileLink.waitForExistence(timeout: 3) {
            editProfileLink.tap()
            sleep(1)
            save(app, "qa_05_edit_profile")
            tapNavBack(app)
            sleep(1)
        }

        // ═══════════════════════════════════════════════
        // HABIT COMPLETION FLOW
        // ═══════════════════════════════════════════════
        tapTab(app, "Home")
        sleep(1)

        // Try to complete "Healthy Eating" (not completed today in screenshot mode)
        let healthyEating = app.staticTexts["Healthy Eating"]
        if healthyEating.waitForExistence(timeout: 3) {
            // Find the complete button near it
            let completeButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Complete Healthy Eating'")).firstMatch
            if completeButton.waitForExistence(timeout: 3) {
                completeButton.tap()
                sleep(2)
                save(app, "qa_06_habit_completed")
            }
        }

        // ═══════════════════════════════════════════════
        // SHEET TRANSITIONS
        // ═══════════════════════════════════════════════
        // Open and dismiss multiple sheets to check transitions
        if addHabitButton.waitForExistence(timeout: 3) {
            addHabitButton.tap()
            sleep(1)
            save(app, "qa_07_sheet_open")
            dismissSheet(app)
            sleep(1)
            save(app, "qa_07_sheet_dismissed")
        }

        print("QA Full Audit Complete — screenshots at \(screenshotDir)")
    }

    // MARK: - Onboarding Test (separate test to not interfere with main audit)

    @MainActor
    func testOnboardingFlow() throws {
        let app = XCUIApplication()
        // Do NOT use screenshotMode, so onboarding shows
        // But clear UserDefaults first
        app.launchArguments = ["-AppleLanguages", "(en)"]
        app.launch()
        sleep(2)
        continueAfterFailure = true

        // Check if onboarding is shown
        let welcomeText = app.staticTexts["Welcome to HabitLand"]
        if welcomeText.waitForExistence(timeout: 5) {
            save(app, "qa_08_onboarding_page1")

            // Next
            let nextButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Next'")).firstMatch
            if nextButton.waitForExistence(timeout: 3) {
                nextButton.tap()
                sleep(1)
                save(app, "qa_08_onboarding_page2")

                nextButton.tap()
                sleep(1)
                save(app, "qa_08_onboarding_page3")

                nextButton.tap()
                sleep(1)
                save(app, "qa_08_onboarding_page4")
            }

            // "Choose My Habits"
            let chooseButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Choose'")).firstMatch
            if chooseButton.waitForExistence(timeout: 3) {
                chooseButton.tap()
                sleep(1)
                save(app, "qa_08_onboarding_starter_habits")
            }
        } else {
            // Onboarding already completed, just verify home loads
            let homeTab = app.tabBars.buttons["Home"]
            XCTAssertTrue(homeTab.waitForExistence(timeout: 5), "Home tab should exist after onboarding")
            save(app, "qa_08_home_after_onboarding")
        }
    }

    // MARK: - iCloud Required Test

    @MainActor
    func testSocialWithoutICloud() throws {
        let app = XCUIApplication()
        // Launch without screenshot mode to see iCloud required state
        app.launch()
        sleep(2)
        continueAfterFailure = true

        // Navigate to Social tab
        tapTab(app, "Social")
        sleep(1)
        save(app, "qa_09_social_no_icloud")

        // Check for either content or iCloud required message
        let icloudRequired = app.staticTexts["iCloud Required"]
        let socialContent = app.buttons["Friends"]

        if icloudRequired.waitForExistence(timeout: 3) {
            save(app, "qa_09_icloud_required")
        } else if socialContent.waitForExistence(timeout: 3) {
            save(app, "qa_09_social_available")
        }
    }

    // MARK: - Premium Gate Test

    @MainActor
    func testPremiumGateAndPaywall() throws {
        let app = XCUIApplication()
        // Launch WITHOUT screenshot mode to see premium gates
        app.launch()
        sleep(2)
        continueAfterFailure = true

        // Check Sleep tab premium gate
        tapTab(app, "Sleep")
        sleep(1)

        let unlockSleep = app.staticTexts["Unlock Sleep Tracking"]
        if unlockSleep.waitForExistence(timeout: 3) {
            save(app, "qa_10_sleep_premium_gate")

            // Tap Upgrade to Pro
            let upgradeBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Upgrade to Pro'")).firstMatch
            if upgradeBtn.waitForExistence(timeout: 3) {
                upgradeBtn.tap()
                sleep(1)
                save(app, "qa_10_paywall")

                // Dismiss paywall
                dismissSheet(app)
                sleep(1)
            }
        }

        // Check Social tab premium gate
        tapTab(app, "Social")
        sleep(1)

        let unlockSocial = app.staticTexts["Unlock Social Features"]
        if unlockSocial.waitForExistence(timeout: 3) {
            save(app, "qa_10_social_premium_gate")
        }

        // Check habit limit - go to Profile > Settings > Upgrade to Pro
        tapTab(app, "Profile")
        sleep(1)

        let settingsRow = app.staticTexts["Settings"]
        if settingsRow.waitForExistence(timeout: 3) {
            settingsRow.tap()
            sleep(1)

            let upgradeText = app.staticTexts["Upgrade to Pro"]
            if upgradeText.waitForExistence(timeout: 3) {
                upgradeText.tap()
                sleep(1)
                save(app, "qa_10_paywall_from_settings")
                dismissSheet(app)
                sleep(1)
            }
        }
    }

    // MARK: - Helpers

    private func tapTab(_ app: XCUIApplication, _ name: String) {
        let tab = app.tabBars.buttons[name]
        if tab.waitForExistence(timeout: 3) {
            tab.tap()
        }
    }

    private func tapNavBack(_ app: XCUIApplication) {
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        if backButton.exists && backButton.isHittable {
            backButton.tap()
        }
    }

    private func dismissSheet(_ app: XCUIApplication) {
        // Try close/cancel button first
        let closeButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Cancel' OR label CONTAINS 'Close'")).firstMatch
        if closeButton.waitForExistence(timeout: 1) && closeButton.isHittable {
            closeButton.tap()
            return
        }
        // Try X button (xmark)
        let xButton = app.navigationBars.buttons.element(boundBy: 0)
        if xButton.exists && xButton.isHittable {
            xButton.tap()
            return
        }
        // Fallback: swipe down
        app.swipeDown(velocity: .fast)
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
        print("[QA-SHOT] Saved: \(name).png")
    }
}
