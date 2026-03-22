# ISSUE-004: Force Unwrap `try!` in SharedModelContainer Fallback

**Category:** Crash Risk / Code Quality
**Severity:** High

## Description

The `SharedModelContainer` has a last-resort fallback path that uses `try!` which will crash the app if the ModelContainer cannot be created. While extremely unlikely, this is the only force unwrap in the entire codebase and could cause an unrecoverable crash.

## File Reference

`HabitLand/Services/SharedModelContainer.swift` line 56:
```swift
return try! ModelContainer(for: schema)
```

## Context

The code has 3 fallback levels:
1. CloudKit-enabled container (primary)
2. Local-only container (fallback)
3. In-memory container (second fallback)
4. `try!` (crash if all else fails) -- line 56

## Recommended Fix

While the probability of reaching this code path is near zero (three prior attempts failed), consider using `fatalError()` with a descriptive message instead of `try!` for clearer crash diagnostics, or wrap in a do-catch that shows an error UI. The `assertionFailure` on line 55 is good for debug but does nothing in release.
