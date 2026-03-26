# ISSUE-003

## Title
Settings and Notification screens not captured in QA audit — navigation failed silently

## Category
Testing

## Severity
Low

## Priority
P3

## Screen / Feature
Settings, Notifications, Pomodoro — QA test coverage gaps

## Root Cause
The XCUITest `testFullAppAuditWithData` uses `if` guards for navigation, so when a button isn't found (e.g., "Settings" gear icon in Profile toolbar), the test silently skips that section. Missing screenshots: Settings, Appearance, Notifications, Habit Settings, Data & Export, Privacy Policy, Terms, Pomodoro, Notifications center.

## Recommended Fix
Make the Settings navigation more robust — try alternative accessibility labels or identifiers for the gear icon button. Add XCTFail or warning logging when expected screens can't be reached.
