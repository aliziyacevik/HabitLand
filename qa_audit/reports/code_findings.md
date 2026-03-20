# Code Findings — HabitLand v1.0

## Critical
1. **Force unwrap** — InsightsOverviewView.swift:418 `computedStrongestHabit!`
2. **Logic error** — SleepInsightsView.swift:145 `hour < 23 || hour >= 0` always true
3. **fatalError** — HabitLandApp.swift:70 crashes app if ModelContainer fails

## High
4. **Race condition** — HomeDashboardView.swift:536-539 queries completion before SwiftData flush
5. **Missing validation** — CreateHabitView/EditHabitView allow custom frequency with 0 days
6. **Missing notification management** — EditHabitView.saveChanges() doesn't reschedule/cancel reminders
7. **Dead code** — LoginView/RegisterView/ForgotPasswordView — no backend, infinite loading on action

## Medium
8. **weekCompletionRate** — Models.swift:99-109 divides by 7.0 regardless of habit targetDays. A weekday-only habit (5 days) can never exceed 71%
9. **currentStreak** — Models.swift:65-80 returns 0 if today isn't completed, even if yesterday was. Users lose visible streak before completing today's habit
10. **Reorder bug** — HabitListView.swift:414-421 operates on filteredHabits indices but mutates sortOrder. If search is active, only visible habits get reordered, corrupting order of hidden ones
11. **"On track today!"** — HomeDashboardView.swift:396 hardcoded text regardless of actual progress (shows even at 0%)
12. **Celebration overlap** — HomeDashboardView.swift:554+563 two DispatchQueue delays can fire overlapping celebrations
13. **PaywallView @StateObject** — PaywallView.swift:6 uses `@StateObject` for ProManager.shared singleton. Should be `@ObservedObject` — @StateObject re-initializes the wrapper on each view creation
14. **No name length limit** — CreateHabitView/EditHabitView TextField has no `.limit()` or character cap

## Low
15. **Night Owl achievement** — AchievementManager.swift:107-109 only checks hours 0-3. Bedtimes at 11pm-midnight (hour 23) don't count as "after midnight"
16. **rescheduleAll** — NotificationManager.swift:59 calls `removeAllPendingNotificationRequests()` which wipes weekly summary and streak reminders too
17. **hasPerfectWeek** — AchievementManager.swift:170 iterates 84 days × all habits × all completions on every check. Could be expensive with large data
18. **Share Profile / See All buttons** — UserProfileView.swift:190,138 — buttons with empty or nil actions
19. **Settings links** — GeneralSettingsView.swift:87-89 Help/Contact/Rate have no action handlers
20. **Social tab** — PremiumGateModifier.swift:102 `comingSoon` flag prevents Pro users from accessing Social even after purchase
