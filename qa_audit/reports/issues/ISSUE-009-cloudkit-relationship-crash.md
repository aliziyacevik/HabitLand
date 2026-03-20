# Issue ID
ISSUE-009

# Title
App crashes on launch — CloudKit requires optional relationships

# Category
Crash / Blocker

# Severity
Blocker

# Priority
P0

# Screen / Feature
App launch — SharedModelContainer initialization

# Environment
iPhone 17 Pro Simulator, iOS 26.3.1

# Preconditions
- CloudKit entitlements added with iCloud sync enabled
- Habit model has non-optional `completions` relationship

# Steps to Reproduce
1. Install app with CloudKit private database sync enabled
2. Launch app
3. App crashes immediately with fatal error in SharedModelContainer

# Expected Result
App launches normally

# Actual Result
Fatal error: "CloudKit integration requires that all relationships be optional, the following are not: Habit: completions"

# Frequency
Always

# Evidence
Console log captured via `xcrun simctl spawn ... log show`

# Suspected Root Cause
SwiftData CloudKit sync requires ALL relationships to be optional (not just attributes). The `Habit.completions: [HabitCompletion]` relationship had a default `= []` but was not declared as optional type.

# Code References
- `HabitLand/Models/Models.swift` — `@Relationship(deleteRule: .cascade) var completions: [HabitCompletion]`
- `HabitLand/Services/SharedModelContainer.swift` — `cloudKitDatabase: .private("iCloud.azc.HabitLand")`

# Impact
App is completely unusable — crashes on every launch. 100% of users affected.

# Recommended Fix Direction
1. Change relationship to `[HabitCompletion]?` (optional)
2. Add `safeCompletions` computed property for safe unwrapping
3. Update all ~40 references to use `safeCompletions` instead of `completions`
4. Add `remote-notification` background mode to Info.plist (required by CloudKit)

# Status
**FIXED** — Relationship made optional, safeCompletions helper added, all references updated, background mode added.

# Notes for Next Agent
This was a critical regression introduced when enabling iCloud sync. The fix required touching 15+ files. Future model changes must keep all relationships optional for CloudKit compatibility.
