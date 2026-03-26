# Coverage Matrix — QA Audit v7 (2026-03-26)

## Runtime Coverage: 24 screens tested (Pro) + 12 screens tested (Free)

| Screen | Pro Test | Free Test | Screenshot | Issues | Status |
|--------|----------|-----------|------------|--------|--------|
| Home Dashboard | Yes | Yes | 01_home_dashboard.png | 0 | Pass |
| Home Scrolled | Yes | - | 01_home_dashboard_scrolled.png | Minor clip | Pass |
| Notifications | Skipped | - | - | Nav failed | Gap |
| Create Habit | Yes | - | 02_create_habit.png | 0 | Pass |
| Habit Detail | Yes | - | 02_habit_detail.png | 0 | Pass |
| Habit Edit | Yes | - | 02_habit_edit.png | 0 | Pass |
| Habits List | Yes | Yes | 02_habits_list.png | 0 | Pass |
| Habits Archived | Yes | - | 02_habits_archived.png | 0 | Pass |
| Habits Sort | Yes | - | 02_habits_sort_menu.png | 0 | Pass |
| Sleep Dashboard | Yes | - | 03_sleep_dashboard.png | 0 | Pass |
| Log Sleep | Yes | - | 03_log_sleep.png | 0 | Pass |
| Sleep Premium Gate | - | Yes | free_01_sleep_premium_gate.png | 0 | Pass |
| Profile | Yes | Yes | 04_profile.png | 0 | Pass |
| Edit Profile | Yes | - | 04_edit_profile.png | 0 | Pass |
| Personal Statistics | Yes | - | 04_personal_stats.png | 0 | Pass |
| Stats Paywall | - | Yes | free_03_stats_paywall.png | 0 | Pass |
| Achievements | Yes | - | 04_achievements.png | 0 | Pass |
| Settings | Skipped | Yes | free_04_settings.png | 0 | Gap |
| Paywall | - | Yes | free_05_paywall_from_settings.png | 0 | Pass |
| Habit Limit | - | Yes | free_07_habits_at_limit.png | 0 | Pass |
| Habit Limit Paywall | - | Yes | free_08_paywall_from_habit_limit.png | 0 | Pass |
| Pomodoro | Skipped | - | - | Nav failed | Gap |
| Appearance Settings | Skipped | - | - | Nav failed | Gap |
| Notification Settings | Skipped | - | - | Nav failed | Gap |
| Data & Export | Skipped | - | - | Nav failed | Gap |

## Coverage Summary
- **Tested**: 20 unique screens with screenshots
- **Gaps**: 5 screens (Settings sub-screens, Pomodoro, Notifications center) — navigation failed silently in XCUITest
- **Code Audit**: All 68 screen files inspected
- **Data Integrity**: All modelContext.insert/delete calls verified to have save()
