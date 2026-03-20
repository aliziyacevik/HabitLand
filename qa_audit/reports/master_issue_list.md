# Master Issue List — HabitLand v1.0 QA Audit

| ID | Title | Severity | Priority | Screen | Category |
|----|-------|----------|----------|--------|----------|
| ISSUE-001 | Force unwrap crash in InsightsOverviewView | Critical | P0 | InsightsOverviewView | Crash |
| ISSUE-002 | Sleep bedtime filter logic always true | Critical | P0 | SleepInsightsView | Data/Logic |
| ISSUE-003 | Auth views have no backend — infinite loading | High | P1 | Login/Register/Forgot | State |
| ISSUE-004 | Undo toast race condition — silent failure | High | P1 | HomeDashboardView | State |
| ISSUE-005 | Custom frequency allows zero days selected | High | P1 | CreateHabitView/EditHabitView | Validation |
| ISSUE-006 | Edit habit doesn't reschedule notifications | High | P1 | EditHabitView | Bug |
| ISSUE-007 | Onboarding flag persists after data reset | Medium | P2 | ContentView | State |
| ISSUE-008 | All-complete celebration race condition | Medium | P2 | HomeDashboardView | State |
| ISSUE-009 | No habit name max length validation | Medium | P2 | CreateHabitView/EditHabitView | Validation |
| ISSUE-010 | Streak calculation skips if not completed today | Medium | P2 | Models.swift:currentStreak | Logic |
| ISSUE-011 | weekCompletionRate always divides by 7 ignoring targetDays | Medium | P2 | Models.swift:99-109 | Logic |
| ISSUE-012 | HabitList reorder can corrupt sortOrder with filtering | Medium | P2 | HabitListView:414-421 | Bug |
| ISSUE-013 | LogSleepView bedTime default uses yesterday — confusing UX | Low | P3 | LogSleepView:8-14 | UX |
| ISSUE-014 | PaywallView uses @StateObject for singleton — should be @ObservedObject | Low | P3 | PaywallView:6 | Bug |
| ISSUE-015 | "On track today!" always shows regardless of actual progress | Medium | P2 | HomeDashboardView:396 | Product |
| ISSUE-016 | Settings support links (Help, Contact, Rate) are non-functional | Medium | P2 | GeneralSettingsView:87-89 | Product |
| ISSUE-017 | Social tab always gated even in Pro — comingSoon overrides Pro | Low | P3 | ContentView:91/PremiumGateModifier:102 | Product |
| ISSUE-018 | Achievement "Night Owl" bedtime filter misses 11pm-midnight | Low | P3 | AchievementManager:107-109 | Logic |
| ISSUE-019 | hasPerfectWeek scans 84 days — O(n*m) performance concern | Low | P3 | AchievementManager:170 | Performance |
| ISSUE-020 | No confirmation for habit archive toggle | Low | P3 | HabitDetailView:41-43 | UX |
| ISSUE-021 | Share Profile button does nothing | Low | P3 | UserProfileView:190,201 | Product |
| ISSUE-022 | Achievements "See All" button has empty action | Low | P3 | UserProfileView:138-140 | Product |
| ISSUE-023 | ModelContainer fatalError on creation failure | Medium | P2 | HabitLandApp:70 | Crash |
| ISSUE-024 | rescheduleAll in NotificationManager wipes ALL notifications | Low | P3 | NotificationManager:59 | Bug |
