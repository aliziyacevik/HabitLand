# Issue ID
ISSUE-010

# Title
Notification permission dialog appears immediately on first launch before user understands the app

# Category
UX / Product

# Severity
Medium

# Priority
P2

# Screen / Feature
Onboarding — first page

# Environment
iPhone 17 Pro Simulator, iOS 26.3.1

# Preconditions
Fresh install, first launch

# Steps to Reproduce
1. Install app fresh
2. Launch app
3. Notification permission dialog appears immediately over onboarding

# Expected Result
Notification permission should be requested AFTER onboarding completes, or at a contextually appropriate moment (e.g., when setting up reminders)

# Actual Result
System dialog appears immediately on first page of onboarding, before user has context about what notifications are for

# Frequency
Always (first launch only)

# Evidence
Screenshot: screen_app_launch_post_fix.png

# Suspected Root Cause
`requestNotificationsIfNeeded()` is called in `HabitLandApp.onAppear` which fires before onboarding completes.

# Code References
- `HabitLand/HabitLandApp.swift:69` — `requestNotificationsIfNeeded()` called unconditionally in onAppear

# Impact
Users who deny notifications on first launch rarely re-enable them. Apple HIG recommends contextual permission requests. This reduces notification opt-in rate significantly.

# Recommended Fix Direction
Gate `requestNotificationsIfNeeded()` behind `hasCompletedOnboarding` check, or move it to the notification setup onboarding page.

# Notes for Next Agent
Simple fix: wrap the call in `if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")`. The onboarding already has a NotificationSetupView page that would be the ideal place to request.
