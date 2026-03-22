# ISSUE-014: Habit Name 50-Character Limit Has No User Feedback

**Category:** UX
**Severity:** Low

## Description

When creating a habit, the name field silently truncates input at 50 characters via `onChange`. There is no visual indicator (counter, error message, or animation) to inform the user that their input has been truncated.

## Steps to Reproduce

1. Navigate to Habits > + (create habit)
2. Type a name longer than 50 characters
3. Input is silently truncated with no feedback

## File Reference

`HabitLand/Screens/Habits/CreateHabitView.swift` lines 93-96:
```swift
.onChange(of: name) { _, newValue in
    if newValue.count > 50 {
        name = String(newValue.prefix(50))
    }
}
```

## Recommended Fix

Add a character counter below the text field (e.g., "42/50") that changes color when approaching the limit.
