# Master Issue List — HabitLand QA Audit (Updated)

**Updated:** March 20, 2026 — Post-feature audit (CloudKit, HealthKit, iCloud sync, data export, free trial)

## All Issues

| ID | Title | Severity | Priority | Status |
|---|---|---|---|---|
| ISSUE-001 | Force unwrap crash in InsightsOverviewView | Critical | P0 | Open |
| ISSUE-002 | Sleep insights bedtime logic always true | Low | P3 | Open |
| ISSUE-003 | Auth views have no backend (dead code) | Low | P3 | Open |
| ISSUE-004 | Undo completion race condition | Medium | P2 | Open |
| ISSUE-005 | Create habit custom freq no days validation | Medium | P2 | Open |
| ISSUE-006 | Edit habit no notification reschedule | Medium | P2 | Open |
| ISSUE-007 | Onboarding skipped on relaunch | Low | P3 | Open |
| ISSUE-008 | All complete celebration race | Low | P3 | Open |
| **ISSUE-009** | **CloudKit crash — non-optional relationship** | **Blocker** | **P0** | **FIXED** |
| ISSUE-010 | Notification permission too early in onboarding | Medium | P2 | Open |
| ISSUE-011 | EditHabitView missing HealthKit section | Medium | P2 | Open |
| ISSUE-012 | CloudKit wrong container check | High | P1 | Open |
| ISSUE-013 | CSV export no special character escaping | Medium | P2 | Open |
| ISSUE-014 | HealthKit Stand Hours unit mismatch (minutes vs hours) | High | P1 | Open |

## Code Audit Findings

| Finding | Severity | File |
|---|---|---|
| Force unwraps in Habit.currentStreak | High | Models.swift:82,89 |
| Silent failure on friend accept returns true | Critical | CloudKitManager.swift:199 |
| fatalError on ModelContainer init failure | Critical | SharedModelContainer.swift:36 |
| Night Owl achievement logic error | Low | AchievementManager.swift:106 |
| Missing error logging in 15+ try? patterns | High | Multiple services |

## Totals: 22 issues found, 1 fixed (ISSUE-009 blocker)
