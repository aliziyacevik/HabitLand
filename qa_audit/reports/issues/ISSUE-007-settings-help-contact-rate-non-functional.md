# ISSUE-007: Settings "Help Center", "Contact Support", "Rate HabitLand" Are Non-Functional

**Category:** UI / Missing Implementation
**Severity:** Medium

## Description

The Support section in Settings has three rows (Help Center, Contact Support, Rate HabitLand) that have no action handlers. They render as static rows with no tap behavior.

## Steps to Reproduce

1. Navigate to Profile > Settings
2. Scroll to "Support" section
3. Tap "Help Center", "Contact Support", or "Rate HabitLand"
4. Nothing happens

## Expected Result

- Help Center: Opens help documentation or FAQ
- Contact Support: Opens email composer or support page
- Rate HabitLand: Opens App Store review prompt

## Actual Result

No action on tap. The rows are plain views, not buttons or navigation links.

## File Reference

`HabitLand/Screens/Settings/GeneralSettingsView.swift` lines 221-224:
```swift
settingsRow(icon: "questionmark.circle", color: .hlTextSecondary, title: "Help Center")
settingsRow(icon: "envelope", color: .hlTextSecondary, title: "Contact Support")
settingsRow(icon: "star", color: .hlGold, title: "Rate HabitLand")
```

## Recommended Fix

- Rate HabitLand: Use `ReviewManager.requestIfAppropriate()` or `SKStoreReviewController`
- Contact Support: Use `MFMailComposeViewController` or `mailto:` link
- Help Center: Navigate to an FAQ view or open a URL
