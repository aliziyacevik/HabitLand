# Issue ID
ISSUE-006

# Title
Editing habit does not reschedule or cancel notifications

# Category
Bug

# Severity
High

# Priority
P1

# Screen / Feature
EditHabitView — save changes

# Steps to Reproduce
1. Create habit with reminder at 8am
2. Edit habit, change reminder to 9am (or disable reminder)
3. Save

# Expected Result
Old notification cancelled, new one scheduled (or all cancelled if disabled)

# Actual Result
EditHabitView.swift:348-361 `saveChanges()` updates the model properties but never calls `NotificationManager.shared.scheduleHabitReminder()` or `cancelHabitReminder()`. The old notification continues firing at the old time.

# Code References
- EditHabitView.swift:348-361 (saveChanges — no notification code)
- CreateHabitView.swift:339-346 (correctly schedules on create)
- NotificationManager.swift:54-56 (cancel/schedule methods exist)

# Recommended Fix Direction
In `saveChanges()`, add: if reminderEnabled, cancel old and schedule new. If !reminderEnabled, cancel.

# Notes for Next Agent
Compare with CreateHabitView.swift:339-346 which does this correctly. Copy that pattern into EditHabitView.saveChanges().
