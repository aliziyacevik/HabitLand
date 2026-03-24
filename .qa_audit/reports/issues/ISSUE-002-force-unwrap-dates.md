# Issue ID
ISSUE-002

# Title
Force unwrap on Calendar.date(byAdding:) can crash

# Category
Crash

# Severity
Critical

# Priority
P0

# Screen / Feature
HabitScheduleView, HabitStatisticsView, HabitHistoryView (preview/demo data)

# Steps to Reproduce
1. Open habit detail with statistics
2. Calendar.date(byAdding:) returns nil on edge case
3. App crashes

# Expected Result
Safe date arithmetic with fallback

# Actual Result
Force unwrap crashes:
- HabitScheduleView.swift:260 — `Calendar.current.date(byAdding: .day, value: -i * 2, to: Date())!`
- HabitStatisticsView.swift:414 — `Calendar.current.date(byAdding: .day, value: -i, to: Date())!`
- HabitHistoryView.swift:192 — `Calendar.current.date(byAdding: .day, value: -i, to: Date())!`

# Evidence
Code inspection — grep for `Calendar.current.date(byAdding` followed by `!`

# Suspected Root Cause
Force unwrap on Calendar date arithmetic which can return nil

# Recommended Fix
Use `?? Date()` as fallback: `Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date()`

# Notes for Next Agent
These are primarily in preview/demo data generation but the pattern is dangerous
