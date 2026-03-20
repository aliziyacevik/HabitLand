# Issue ID
ISSUE-011

# Title
EditHabitView missing HealthKit metric section — users can't modify Health link after creation

# Category
Bug / Feature Gap

# Severity
Medium

# Priority
P2

# Screen / Feature
Edit Habit screen

# Preconditions
User has created a habit with or without HealthKit metric

# Steps to Reproduce
1. Create a habit with a HealthKit metric (e.g., Steps)
2. Go to habit detail → Edit
3. No way to change or remove the HealthKit metric

# Expected Result
EditHabitView should show the same HealthKit section as CreateHabitView, allowing users to change or remove the Health data link

# Actual Result
HealthKit section is completely absent from EditHabitView

# Frequency
Always

# Suspected Root Cause
HealthKit section was only added to CreateHabitView, not EditHabitView

# Code References
- `HabitLand/Screens/Habits/CreateHabitView.swift` — has healthKitSection
- `HabitLand/Screens/Habits/EditHabitView.swift` — missing healthKitSection

# Impact
Users who want to change which Health metric a habit tracks, or disconnect it from Health entirely, cannot do so without deleting and recreating the habit.

# Recommended Fix Direction
Copy the healthKitSection from CreateHabitView to EditHabitView, initializing selectedHealthMetric from the habit's existing healthKitMetric.

# Notes for Next Agent
The EditHabitView init already reads all habit properties into @State vars. Add a `@State private var selectedHealthMetric: HealthKitMetric?` initialized from `HealthKitMetric(rawValue: habit.healthKitMetric ?? "")` and add the same healthKitSection view.
