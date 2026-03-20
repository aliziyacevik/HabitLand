# Issue ID
ISSUE-007

# Title
Onboarding skip persists even after app data reset — uses UserDefaults not SwiftData

# Category
Bug / State

# Severity
Medium

# Priority
P2

# Screen / Feature
ContentView / OnboardingView

# Steps to Reproduce
1. Complete onboarding
2. Delete all SwiftData content (e.g. via Settings > Data & Export)
3. Relaunch app

# Expected Result
Fresh start experience with onboarding

# Actual Result
ContentView.swift:8: `@AppStorage("hasCompletedOnboarding")` uses UserDefaults. If user deletes app data through the app's data export/reset, this flag persists. User sees empty dashboard with no onboarding guidance.

# Code References
- ContentView.swift:8
- HabitLandApp.swift:154 (screenshot mode sets this in UserDefaults)

# Recommended Fix Direction
If implementing a "reset all data" feature, also clear `UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")`.

# Notes for Next Agent
Check DataExportView.swift for any reset functionality and ensure it clears this UserDefaults key.
