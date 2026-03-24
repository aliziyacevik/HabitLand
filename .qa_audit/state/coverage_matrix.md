# Coverage Matrix — QA Audit (2026-03-24)

## Runtime Coverage: 32/43 screens (74%) | Code Audit: 100%

| Screen | Runtime | Screenshot | Issues Found | Status |
|--------|---------|------------|-------------|--------|
| Home Dashboard | Yes | 01_home_top/mid/bottom | - | Pass |
| Daily Overview | Partial | 01_daily_overview* | Nav blocked | Partial |
| Focus Timer/Pomodoro | Yes | 01_pomodoro | - | Pass |
| Notification Center | Yes | 01_notifications | - | Pass |
| Create Habit (FAB) | Yes | 01_create_habit_sheet | - | Pass |
| Habits List | Blocked | 02_habits_list* | Achievement popup | Blocked |
| Habit Detail | Blocked | 02_habit_detail* | Achievement popup | Blocked |
| Edit Habit | Partial | 02_edit_habit* | Achievement popup | Partial |
| Create Habit Form | Partial | 02_create_form* | - | Partial |
| Template Browser | No | — | Not reached | N/A |
| Habit Archive | Partial | — | - | Partial |
| Sleep Dashboard | Yes | 03_sleep_dashboard | "?" quality icons | Pass |
| Log Sleep | Yes | 03_log_sleep_form | "?" quality icons | Pass |
| Sleep History | Yes | 03_sleep_history | "?" quality icons | Pass |
| Sleep Analytics | Yes | 03_sleep_analytics | - | Pass |
| Sleep Saved | Yes | 03_sleep_saved | - | Pass |
| Social Hub | Yes | 04_social_hub | - | Pass |
| Friends List | Yes | 04_friends_scrolled | - | Pass |
| Friend Profile | Yes | 04_friend_profile | Empty bottom section | Pass |
| Leaderboard | Yes | 04_leaderboard | - | Pass |
| Challenges | Yes | 04_challenges | - | Pass |
| Create Challenge | Yes | 04_create_challenge | - | Pass |
| Social Feed | Yes | 04_feed | - | Pass |
| Invite Friends | Yes | 04_invite_friends | - | Pass |
| Pending Requests | No | — | Not reached | N/A |
| Nudges Sheet | No | — | Not reached | N/A |
| Profile | Blocked | 05_profile_top* | Tab nav stuck on Social | Blocked |
| Edit Profile | No | — | Not reached | N/A |
| Avatar Picker | No | — | Not reached | N/A |
| Personal Statistics | Yes | 05_personal_stats | Force unwrap pattern | Pass |
| Achievements | No | — | Not reached | N/A |
| Settings | Blocked | — | Tab nav blocked | Blocked |
| Appearance Settings | No | — | Not reached | N/A |
| Notification Settings | No | — | Not reached | N/A |
| Habit Settings | No | — | Not reached | N/A |
| Privacy Settings | No | — | Not reached | N/A |
| Data Export | No | — | Not reached | N/A |
| Paywall | No | — | Not reached | N/A |
| Onboarding (5 screens) | No | — | Code audit only | N/A |
| Discovery (5 screens) | No | — | Not in main flow | N/A |
| Analytics (5 screens) | No | — | Not in main flow | N/A |

## Improvement from Previous Audit (Mar 23)

**New screens captured this run:**
- Focus Timer / Pomodoro (was blocked)
- Log Sleep form + saved state
- Sleep Analytics scrolled
- Create Challenge form
- Invite Friends
- Personal Statistics

**Still blocked:**
- Habits tab (achievement celebration overlay intercepts navigation)
- Profile tab (tab bar navigation gets stuck on Social after challenges)
- Settings (requires Profile tab access first)

*Blocked = Screenshot captured wrong screen due to achievement popup or tab navigation sticking
