# ISSUE-004: Potential division by zero in UserProfile.levelProgress

**Severity:** Low
**Category:** Code Safety
**File:** `HabitLand/Models/Models.swift:272`

## Description

`levelProgress` computes `Double(xp) / Double(xpForNextLevel)` where `xpForNextLevel = level * 100`. If `level` were ever 0, this would crash with division by zero.

## Impact

Default level is 1, so this is extremely unlikely. But no guard prevents level from being set to 0 through data corruption or future code changes.

## Fix

Change to: `Double(xp) / Double(max(xpForNextLevel, 1))`
