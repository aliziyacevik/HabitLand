# Issue ID
ISSUE-014

# Title
HealthKit stand hours metric has unit mismatch — compares minutes against hours goal

# Category
Bug / Data

# Severity
High

# Priority
P1

# Screen / Feature
HealthKit auto-completion — Stand Hours metric

# Preconditions
User creates a habit linked to "Stand Hours" HealthKit metric

# Steps to Reproduce
1. Create habit linked to Stand Hours (default goal: 12)
2. Wait for HealthKit sync
3. Query returns appleStandTime in minutes
4. Comparison: minutes_value >= 12 (goal)
5. After 12 minutes of standing, habit auto-completes (should be 12 hours)

# Expected Result
Habit completes after 12 hours of standing (720 minutes)

# Actual Result
Habit completes after only 12 minutes of standing

# Frequency
Always (for Stand Hours metric)

# Suspected Root Cause
`hkUnit` returns `.minute()` for standHours, but `defaultGoal` is 12 (meaning 12 hours). The `syncHealthHabits` method compares `todayValue(for:)` against `habit.goalCount`, but the value is in minutes while the goal assumes hours.

# Code References
- `HabitLand/Services/HealthKitManager.swift:65` — `standHours` returns `.appleStandTime`
- `HabitLand/Services/HealthKitManager.swift:78` — unit is `.minute()`
- `HabitLand/Services/HealthKitManager.swift:56` — defaultGoal is 12

# Impact
Stand Hours habits auto-complete far too early, giving false completion data.

# Recommended Fix Direction
Either: (a) change defaultGoal to 720 (minutes), or (b) change hkUnit to `.hour()` and ensure the query converts correctly, or (c) add a conversion factor in the sync logic.

# Notes for Next Agent
Simplest fix: change `defaultGoal` for standHours to 720 and keep the unit as minutes. Or change the unit to `.hour()` since appleStandTime can be queried in hours.
