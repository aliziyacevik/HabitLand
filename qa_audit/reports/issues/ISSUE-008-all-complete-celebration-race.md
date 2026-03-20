# Issue ID
ISSUE-008

# Title
"All habits done" celebration uses stale count — may trigger prematurely or not at all

# Category
Bug / State

# Severity
Medium

# Priority
P2

# Screen / Feature
HomeDashboardView — all-complete celebration

# Steps to Reproduce
1. Have 3 habits, 2 completed
2. Complete the 3rd habit quickly

# Expected Result
Celebration shows exactly when all habits are done

# Actual Result
HomeDashboardView.swift:552: `let newCompletedCount = completedCount + 1` — `completedCount` is a computed property from `habits.filter(\.todayCompleted).count`. At this point the @Query may not have updated yet after the insert, so `completedCount` could still be the OLD value. The +1 assumption may be wrong if the query already updated.

Additionally, lines 554-558 and 563-568 both set `showCelebration` with different messages via overlapping DispatchQueue delays (0.5s and 0.3s). If a streak milestone AND all-complete happen simultaneously, celebrations collide.

# Code References
- HomeDashboardView.swift:552-559 (all-complete check)
- HomeDashboardView.swift:562-568 (streak milestone check)

# Recommended Fix Direction
Use the actual new state rather than `completedCount + 1`. Queue celebrations sequentially rather than overlapping.
