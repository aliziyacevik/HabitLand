# Code Findings — HabitLand v1.0 (Updated 2026-03-22)

## BLOCKER — Force Unwraps That Can Crash

1. **WeeklyQuestManager.swift:68** — `calendar.date(from:)!` — date from components can fail
2. **ShowStreakIntent.swift:30** — `sorted.first!` — crashes if filtered array is empty
3. **AmbientSoundManager.swift:43,47** — `buffer[0].mData!` — double force unwrap on audio buffer
4. **AchievementManager.swift:218,330,334,335,362,376,380** — Multiple `calendar.date(byAdding:)!`
5. **Effects.swift:669,877,1193** — `colors.randomElement()!` — crashes if array empty
6. **NotificationManager.swift:167** — `messages.randomElement()!`
7. **HealthKitManager.swift:135** — `calendar.date(byAdding:)!`
8. **HabitSuccessTrendsView.swift:23** — `ninetyDaysAgo` force unwrap
9. **HabitDetailView.swift:301** — `calendar.date(byAdding:)!` in weekday calc

## HIGH — Silent Error Swallowing & Missing Saves

10. **DataExportView.swift:262-271** — All delete operations use `try?` without logging
11. **AchievementManager.swift:11-15** — Fetch failures silently return empty array
12. **DailyHabitsOverview.swift:321-324** — No `context.save()` after insert
13. **Inconsistent save pattern** — Some views save after mutations, others don't
14. **SocialFeedView.swift:58** — `friend.lastActive!` — safe via || short-circuit but fragile
15. **InsightsOverviewView.swift:418** — `computedStrongestHabit!` force unwrap
16. **SleepInsightsView.swift:145** — `hour < 23 || hour >= 0` — always true (logic error)

## MEDIUM

17. **ProManager.swift:206** — Silent transaction verification failure
18. **HealthKitManager.swift:212** — Silent habit fetch failure during sync
19. **SharedModelContainer.swift:60** — fatalError as absolute last resort
20. **Multiple views** — Weekday arithmetic assumes specific calendar config

## LOW

21. **HomeDashboardView.swift:660-667** — Potential race in completion toggle
22. **AmbientSoundManager.swift:29** — AVAudioFormat force unwrap
23. **HabitSuccessTrendsView.swift:475** — Inefficient array rewrite
24. **~225 hardcoded Image font sizes** — Acceptable for icon sizing

## Previously Reported (from 2026-03-21 audit)
- ISSUE-004: try! in SharedModelContainer (FIXED — now uses do/catch)
- ISSUE-005: HealthKit stand hours default goal
- ISSUE-006: iCloud sync always shows enabled
- ISSUE-009: Habit completion race condition
- ISSUE-010: Silent error swallowing (partially addressed with HLLogger)
- ISSUE-012: Week completion rate >100% (FIXED — capped at 100%)
- ISSUE-013: CSV export no escaping
- ISSUE-014: HealthKit stand hours unit mismatch
