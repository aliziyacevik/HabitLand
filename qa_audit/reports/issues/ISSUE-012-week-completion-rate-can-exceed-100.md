# ISSUE-012: weekCompletionRate Can Exceed 100%

**Category:** Data / Logic
**Severity:** Low

## Description

The `weekCompletionRate` computed property on the `Habit` model divides total week completions by `max(targetDays.count, 1)`. If a habit has multiple completions per day (e.g., goalCount > 1) or if target days don't match the actual 7-day window, the rate can exceed 1.0 (100%).

This value is displayed in HabitDetailView and used in InsightsOverviewView calculations.

## File Reference

`HabitLand/Models/Models.swift` lines 119-130:
```swift
var weekCompletionRate: Double {
    ...
    return Double(weekCompletions.count) / Double(expectedDays)
}
```

## Recommended Fix

Cap return value: `min(Double(weekCompletions.count) / Double(expectedDays), 1.0)`
