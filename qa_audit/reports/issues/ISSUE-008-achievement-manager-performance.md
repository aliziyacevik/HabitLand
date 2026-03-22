# ISSUE-008: AchievementManager.checkAll Scans 84 Weeks of History

**Category:** Performance
**Severity:** Low

## Description

The `hasPerfectWeek` function in `AchievementManager` iterates through 84 weeks (588 days) of history, checking every active habit's completions for each day. This is called on every habit completion from HomeDashboardView and DailyHabitsOverview.

For users with many habits and extensive history, this could cause noticeable UI lag during the completion animation.

## File Reference

`HabitLand/Services/AchievementManager.swift` line 171:
```swift
for startOffset in 0..<84 {  // Scans 84 weeks
```

## Impact

Currently acceptable with small datasets, but could degrade as users accumulate months of data with many habits.

## Recommended Fix

1. Early-exit once a perfect week is found (already done)
2. Consider caching the "Perfect Week" achievement check result
3. Reduce scan window to 12-16 weeks instead of 84
4. Move achievement checking off the main thread
