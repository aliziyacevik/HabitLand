# ISSUE-009: Potential Race Condition in Habit Completion with Undo

**Category:** Logic / Race Condition
**Severity:** Low

## Description

When a habit is completed in `HomeDashboardView`, the code immediately looks for the "latest completion" to store for undo. However, because SwiftData may not have flushed the insert yet, `undoCompletion` could be nil.

## File Reference

`HabitLand/Screens/Home/HomeDashboardView.swift` lines 567-570:
```swift
let latestCompletion = habit.safeCompletions.sorted(by: { $0.date > $1.date }).first(where: {
    Calendar.current.isDateInToday($0.date) && $0.isCompleted
})
undoCompletion = latestCompletion
```

## Impact

If `undoCompletion` is nil when the user taps Undo, the undo action will silently fail (the `if let` guard prevents crashes). The user sees the "Completed!" toast but undo does nothing.

## Recommended Fix

Store a reference to the completion object immediately after creating it, rather than querying for it:
```swift
let completion = HabitCompletion(date: Date())
completion.habit = habit
modelContext.insert(completion)
undoCompletion = completion  // Direct reference
```
