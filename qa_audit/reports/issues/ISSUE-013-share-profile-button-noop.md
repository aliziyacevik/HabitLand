# ISSUE-013: "Share Profile" Button Does Nothing

**Category:** UI / Missing Implementation
**Severity:** Medium

## Description

The "Share Profile" quick link on the Profile screen has an empty action handler (`Button { } label: {}`). Tapping it does nothing.

## Steps to Reproduce

1. Navigate to Profile tab
2. Scroll down to quick links
3. Tap "Share Profile"
4. Nothing happens

## File Reference

`HabitLand/Screens/Profile/UserProfileView.swift` line 183:
```swift
quickLink(icon: "square.and.arrow.up", title: "Share Profile", destination: nil)
```

Line 194:
```swift
Button { } label: { ... }
```

## Recommended Fix

Implement share functionality using `ShareLink` or `UIActivityViewController` to share a user's profile card or referral code.
