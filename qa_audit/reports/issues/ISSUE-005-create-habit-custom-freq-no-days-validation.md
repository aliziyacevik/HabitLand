# Issue ID
ISSUE-005

# Title
Custom frequency habit can be created with zero days selected

# Category
Validation / Bug

# Severity
High

# Priority
P1

# Screen / Feature
CreateHabitView, EditHabitView — frequency section

# Steps to Reproduce
1. Tap "+" to create new habit
2. Enter name
3. Select "Custom" frequency
4. Do NOT select any days
5. Tap "Create Habit"

# Expected Result
Button disabled or validation error when custom frequency has no days

# Actual Result
Habit is created with `targetDays: []` (empty array). This habit will never appear as "due today", streak calculations return 0, weekCompletionRate divides by 7 but habit is never expected — producing misleading 0% rates. The habit exists but can never be completed on schedule.

# Code References
- CreateHabitView.swift:305 (disabled only checks `name.isEmpty`)
- CreateHabitView.swift:315-321 (targetDays returns empty array for custom with no days)
- EditHabitView.swift:314 (same validation gap)

# Recommended Fix Direction
Add validation: `name.isEmpty || (frequency == .custom && customDays.isEmpty)` to the disabled condition.

# Notes for Next Agent
Same bug exists in EditHabitView. Fix both files.
