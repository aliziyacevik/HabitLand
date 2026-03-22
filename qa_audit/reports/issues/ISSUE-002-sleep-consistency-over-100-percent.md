# ISSUE-002: Sleep Consistency Can Exceed 100%

**Category:** Data / UI
**Severity:** Medium

## Description

The Sleep Dashboard shows "Consistency" as a percentage calculated by `(weekLogs.count / 7.0) * 100`. When a user logs sleep more than once per day (e.g., a nap), or if demo data has more than 7 logs in the last 7 days, this value can exceed 100%.

## Steps to Reproduce

1. Navigate to Sleep tab in screenshot mode
2. Observe the "Consistency" stat shows "128%" (visible in screenshot `qa_03_sleep_dashboard.png`)

## Expected Result

Consistency should be capped at 100%.

## Actual Result

Shows "128%" which is not meaningful to the user.

## File Reference

`HabitLand/Screens/Sleep/SleepDashboardView.swift` line 31:
```swift
var consistencyPercent: Int {
    Int((Double(weekLogs.count) / 7.0) * 100)
}
```

## Recommended Fix

Cap the value: `min(Int((Double(weekLogs.count) / 7.0) * 100), 100)` or count unique days rather than total logs.
