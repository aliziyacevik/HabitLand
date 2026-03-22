# ISSUE-010: Extensive Silent Error Swallowing with `try?`

**Category:** Code Quality / Debugging
**Severity:** Low

## Description

The codebase uses `try?` extensively (60+ occurrences) to silently swallow errors. While this prevents crashes, it makes debugging difficult because errors are completely invisible. Key areas:

1. **Data persistence** (`try? context.save()`) - data loss is silently ignored
2. **Data deletion** (`try? context.delete(model:)`) - failed deletions go unnoticed
3. **File export** (`try? report.write(to:)`) - export failures are silent
4. **StoreKit** (`try? await AppStore.sync()`) - purchase sync failures hidden

## File Reference

Multiple files throughout the codebase. Most critical:
- `HabitLand/HabitLandApp.swift` (7 occurrences)
- `HabitLand/Services/AchievementManager.swift` (save after achievement unlock)
- `HabitLand/Screens/Settings/DataExportView.swift` (9 occurrences)
- `HabitLand/Services/HealthKitManager.swift` (save after auto-completion)

## Recommended Fix

For critical operations (data save, delete), add logging:
```swift
do {
    try context.save()
} catch {
    HLLogger.data.error("Failed to save context: \(error.localizedDescription)")
}
```

Low-priority for non-critical operations, but critical saves should always be logged.
