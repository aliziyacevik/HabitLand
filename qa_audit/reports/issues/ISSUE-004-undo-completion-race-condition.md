# Issue ID
ISSUE-004

# Title
Undo toast after habit completion may fail silently — race condition on completion lookup

# Category
Bug / State

# Severity
High

# Priority
P1

# Screen / Feature
HomeDashboardView — habit completion + undo

# Preconditions
User has habits on home dashboard

# Steps to Reproduce
1. Tap checkmark to complete a habit
2. Undo toast appears
3. Tap "Undo"

# Expected Result
Completion is deleted, XP removed

# Actual Result
HomeDashboardView.swift:536-539: After inserting a completion, the code immediately queries for it:
```swift
let latestCompletion = habit.completions.first(where: {
    Calendar.current.isDateInToday($0.date) && $0.isCompleted
})
undoCompletion = latestCompletion
```
SwiftData may not have flushed the insert yet. If `latestCompletion` is nil, `undoCompletion` is nil, and the undo button silently does nothing (line 227: `if let completion = undoCompletion`).

# Frequency
Sometimes (timing-dependent)

# Code References
- HomeDashboardView.swift:526-539 (completion insert + lookup)
- HomeDashboardView.swift:227 (undo handler)
- HomeDashboardView.swift:611-614 (same bug in completeHabit function)

# Recommended Fix Direction
Store reference to the HabitCompletion object directly after creating it, rather than re-querying. Change to: `let completion = HabitCompletion(date: Date()); ... modelContext.insert(completion); undoCompletion = completion`

# Notes for Next Agent
Two code paths have this bug: the inline button handler (~line 526) and `completeHabit()` (~line 600). Fix both.
