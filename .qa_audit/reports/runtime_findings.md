# Runtime Findings — QA Audit

## Visual Inspection Summary (46 Screenshots)

### Issues Found

#### ISSUE-001: Pomodoro fullScreenCover blocks tab navigation
- **Severity:** High
- **Screenshots:** qa_02_habits_list.png, qa_02_habit_detail.png, qa_02_create_habit_form.png
- **Description:** When Pomodoro timer (fullScreenCover) is opened from Home tab, switching to Habits tab via test automation shows Pomodoro still covering the screen. The fullScreenCover persists across tab switches until explicitly dismissed.
- **Root Cause:** fullScreenCover is presented at ContentView level, blocking tab bar interaction until dismissed.

#### ISSUE-002: Edit Profile screen not captured
- **Severity:** Low
- **Description:** qa_05_edit_profile.png was not saved — likely the "Edit Profile" link navigation failed or timing issue.

#### ISSUE-003: "HabitLand" title assertion failed
- **Severity:** Low
- **Description:** Test expected `app.staticTexts["HabitLand"]` but the nav bar title may render differently. The title is visible in screenshots as green "HabitLand" text.

### Screens Successfully Verified (No Issues)

| Screen | Screenshot | Status |
|--------|-----------|--------|
| Home Dashboard | qa_01_home_dashboard.png | PASS - Layout clean, all cards visible |
| Home Scrolled | qa_01_home_scrolled_mid/bottom.png | PASS - No clipping, proper scroll |
| Notification Center | qa_01_notification_center.png | PASS - Empty state correct |
| Daily Habits Overview | qa_01_daily_habits_overview.png | PASS |
| Create Habit Sheet | qa_01_home_create_habit_sheet.png | PASS |
| Archived Habits | qa_02_archived_habits_empty.png | PASS - Empty state clear |
| Long Name Input | qa_02_create_habit_long_name.png | PASS - 50/50 counter visible |
| Sleep Dashboard | qa_03_sleep_dashboard.png | PASS - Clean layout, charts visible |
| Sleep Dashboard Scrolled | qa_03_sleep_dashboard_scrolled.png | PASS |
| Log Sleep Form | qa_03_log_sleep_form.png | PASS - All fields visible |
| Sleep Insights | qa_03_sleep_insights.png | PASS - Personalized insights show |
| Social Hub - Friends | qa_04_social_friends.png | PASS - Friend list clean |
| Social Hub - Leaderboard | qa_04_social_leaderboard.png | PASS - Podium + rankings |
| Social Hub - Challenges | qa_04_social_challenges.png | PASS - Empty state good |
| Social Hub - Feed | qa_04_social_feed.png | PASS - Activity cards clean |
| Friend Profile | qa_04_friend_profile.png | PASS - Stats, nudge/challenge buttons |
| Profile | qa_05_profile.png | PASS - Avatar, stats, achievements |
| Settings | qa_05_settings.png | PASS - All sections visible |
| Appearance | qa_05_appearance_settings.png | PASS - Theme picker, preview |
| Notification Settings | qa_05_notification_settings.png | PASS - All toggles present |
| Privacy Settings | qa_05_privacy_settings.png | PASS - Visibility, sharing, analytics |
| Data Export | qa_05_data_export.png | PASS - Format, date range, export options |
| Achievements | qa_05_achievements.png | PASS - Grid layout, progress bars |
| Personal Statistics | qa_05_personal_statistics.png | PASS - Stats grid, monthly chart |
| Habit Completed | qa_06_habit_completed.png | PASS - Celebration overlay, undo toast |

### Dynamic Sizing Verification

All screens reviewed show proper layout without text truncation or overflow on iPhone 16 Pro simulator. The @ScaledMetric changes need real-device testing with larger text size settings to fully verify.
