# ISSUE-005: HealthKit Stand Hours Default Goal is 720 (Incorrect)

**Category:** Data / Logic
**Severity:** Medium

## Description

The `standHours` HealthKit metric has a default goal of `720` with a unit of "hours", which would mean 720 hours (30 days) of standing per day. The intent is likely 12 stand hours per day, matching Apple's default Activity ring goal.

Additionally, the `hkUnit` for standHours is `.minute()` with a comment "convert later" but no conversion is ever performed.

## File Reference

`HabitLand/Services/HealthKitManager.swift`:
- Line 53: `case .standHours: return 720` (should be 12)
- Line 79: `case .standHours: return .minute() // convert later` (minutes vs hours inconsistency)

## Recommended Fix

1. Change `defaultGoal` to `12` (12 stand hours per day)
2. Either use `.hour()` as the unit or convert minutes to hours when displaying
